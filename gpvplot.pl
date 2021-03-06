#!/usr/bin/perl -w

# GPVPlot.pl
# Shelley Kandola
# A program that creates multiple PNG's
# from a .csv of geochemical data
# and embeds them into a PDF

use strict;
use warnings;
if (-d "PDF"){
    use PDF::API2;
}
use File::Basename;

# Checks for gnuplot utility
unless(`which gnuplot`){
    print "Missing required program: gnuplot.  Please install and try again.";
    exit;
}

# Checks for image-rotating utility
unless(`which convert`){
    print "Missing required terminal package: convert (ImageMagick)";
    exit;
}

$| = 1;

# DATA FOR PRINTING KEY TO CONSOLE
##########################################
# Character codes for each shape
my $solid_square = chr(0x25A0);
my $hollow_square = chr(0x25A1);
my $solid_circle = chr(0x25CF);
my $hollow_circle = chr(0x25CB);
my $hollow_trig = chr(0x25B3);
my $solid_trig = chr(0x25B2);
my $down_trig = chr(0x25BD);

# Array of keys
my @tics = ("red +", "green x",
	    "blue *","purple $hollow_square",
	    "teal $solid_square","yellow $hollow_circle",
	    "black $solid_circle","orange $hollow_trig",
	    "gray $solid_trig","red $down_trig");
##########################################

# A hash to store all the data for gnuplot
# img => (height, width, x, y, font size, deg);
my %graphdata = (
    1 => {
        0   => [792, 612, 0, 0, 32, 90],
    },
    2 => {
        0   => [612, 396, 0, 0, 30, 0],
        1   => [612, 396, 0, 396, 30, 0],
    },
    3 => {
        0   => [396, 356, 0, 396, 20, 90],
        1   => [396, 356, 0, 0, 20, 90],
        2   => [396, 256, 356, 396, 20, 90],
    },
    4 => {
        0   => [396, 356, 0, 396, 20, 90],
        1   => [396, 356, 0, 0, 20, 90],
        2   => [396, 256, 356, 396, 20, 90],
        3   => [396, 256, 356, 0, 20, 90],
    },
    5 => {
        0   => [306, 330, 0, 0, 6, 0],
        1   => [306, 330, 306, 0, 6, 0],
        2   => [306, 230, 0, 330, 6, 0],
        3   => [306, 230, 306, 330, 6, 0],
        4   => [306, 230, 0, 560, 6, 0],
    },
    6 => {
        0   => [306, 330, 0, 0, 6, 0],
        1   => [306, 330, 306, 0, 6, 0],
        2   => [306, 230, 0, 330, 6, 0],
        3   => [306, 230, 306, 330, 6, 0],
        4   => [306, 230, 0, 560, 6, 0],
        5   => [306, 230, 306, 560, 6, 0],
    },
    7 => {
        00   => [306, 272, 0, 0, 2, 0],
        1   => [306, 272, 306, 0, 2, 0],
        2   => [306, 173, 0, 272, 2, 0],
        3   => [306, 173, 306, 272, 2, 0],
        4   => [306, 173, 0, 445, 2, 0],
        5   => [306, 173, 306, 445, 2, 0],
        6   => [306, 173, 0, 618, 2, 0],
    },
    8 => {
        0   => [306, 272, 0, 0, 2, 0],
        1   => [306, 272, 306, 0, 2, 0],
        2   => [306, 173, 0, 272, 2, 0],
        3   => [306, 173, 306, 272, 2, 0],
        4   => [306, 173, 0, 445, 2, 0],
        5   => [306, 173, 306, 445, 2, 0],
        6   => [306, 173, 0, 618, 2, 0],
        7   => [306, 173, 306, 618, 2, 0],
    },
);

# Show possible files to choose from
# print "Files found locally:";
my $file_choices = `ls -l`;

# Check if temp already exists
# If not, create it
unless (-d ".temp"){
    my $mkdir = `mkdir .temp`;
}

# Ask how many data sets to graph
print "How many data sets would you like to graph? ";
chop(my $set_count = <STDIN>);
until ($set_count =~ /[0-9]/ and $set_count > 0 and $set_count < 10){
    print "Error: Enter a number 1-9: ";
    chop($set_count = <STDIN>);
}

my @setnames = ();	# An array to store the names of each data set
# For loop to collect data sets
for(my $i=1; $i<=$set_count; $i++){
	print "Enter filename for set $i: ";
	chop(our $path = <STDIN>);
	$_ = $path;
	
	# If the file is in another directory, move it to pwd
	my $path_pattern = /^((\\\w+)\$?)(\\(\w[\w ]*))+\.(\w{3})$/;
	my $file = basename($path);
	if ($path =~ $path_pattern){
	    unless(-e $file){
	    	my $copy = `cp $path $file`;
	    }
	}

	# Don't crash if CSV not found
	until (-e "$file.csv" or -e "$file.txt" or -e "$file"){
		print "$file not found.  Enter filename for set $i: ";
		chop($file = <STDIN>);
	} if(-e "$file"){
	    $file =~ s/\.txt|\.csv//;
	}
	# Copy the file to a temp folder for editing
	my $copy = `cp $file.* .temp`;
	# Don't convert the file again if it exists
	unless (-e "$file.txt"){
		&csvwsv(".temp/$file.csv");
	}
	# Check for carriage returns
	my $carriage = `perl -p -i -e 's/\r/\n/g' .temp/$file.txt`;
	my $quotes = `perl -p -i -e 's/"//g' .temp/$file.txt`;
	# Swap out lone spaces for dashes
	&spaceswap($file);
	# Replace uneven spacing with tabs
	my $spacetab = `perl -p -i -e 's/ {1,10}/\t/g' .temp/$file.txt`;
	# Add it to the list of datasets
	push(@setnames, $file);
}



# Display all Variables in the file
my $set1 = $setnames[0];
my @csvarray = ();
open(VARS, ".temp/$set1.txt");
my @lines = <VARS>;

# Put the CSV into a 2D Array
foreach my $line(@lines){
    my @temp = split(/\s/, $line);
    push(@csvarray, @temp);   
}
	
# For processing by gnuplot
my @header = split(/\t/, $lines[0]);
my @header1 = ();
# Remove all the blank array values
foreach my $head(@header){
    if($head){
	push(@header1, $head);
    }
}

# For processing by hash
my @header2 = split(/\s/, $lines[0]);
our %headerhash = &atoh(\@header2);
	
# Printing all possible variables
foreach my $var(@header2){
    unless($var ~~ "Descrip." or $var ~~ "Total"){
	print "$var ";
    }
}
close(VARS);


# Ask for an x-axis
print "\nEnter an x-axis variable from the list above exactly as it appears: ";
chop(my $xaxis = <STDIN>);

# Make sure x-axis is spelled correctly and exists
until(exists($headerhash{$xaxis})){
	print "$xaxis not found.";
	print "\nEnter an x-axis variable from the list above exactly as it appears: ";
	chop($xaxis = <STDIN>);
}
my $xindex = &stringindex($xaxis, \@header1);
$xindex++;

# Getting the max and min values of the x-axis
my $xcsv = $xindex - 1;
my @xvalues = &csvarray(\@setnames, $xcsv);

my $xmax = &max(@xvalues);
my $xmin = &min(@xvalues);


# Shrinking the x-axis
print "Would you like to scale the x-axis? (y/n): ";
my $xlo = $xmin;
my $xhi = $xmax;
chop(my $scale = <STDIN>);
if($scale eq "y"){
	print "The approximate range is $xmin to $xmax\n";
	print "Enter low: ";
	chop($xlo = <STDIN>);
	until ($xlo =~ /[0-9]/){
	    print "Low value must be a number: ";
	    chop($xlo = <STDIN>);
	}
	print "Enter high: ";
	chop($xhi = <STDIN>);
	until ($xhi =~ /[0-9]/){
	    print "High value must be a number: ";
	    chop($xhi = <STDIN>);
	}
}

# Ask for the y-axes
print "How many variables would you like to graph (1-8): ";
chop(my $num_graphs = <STDIN>);
until($num_graphs ~~ /[0-9]/ and 1 <= $num_graphs and $num_graphs <= 8){
    print "Invalid entry. Enter a number 1-8: ";
    chop($num_graphs = <STDIN>);
}

# A Hash that maps all variables
# to their column numbers in the file
my %yvars = ();

# An Array of all the image names
my @images = ();

# Gathering the data from the user
print "One at a time, enter a y-axis variable from the list above.\n";
for (my $i = 1; $i <= $num_graphs; $i++) {
    print "Enter variable $i: ";
    chomp(our $yaxis = <STDIN>);
    
    until(exists($headerhash{$yaxis})){
	print "$yaxis not found. Enter variable $i: ";
	chomp($yaxis = <STDIN>);
    }
    
    # get the column number from the whitespace values
    our $yindex = &stringindex($yaxis, \@header1);
    # save all axes and indeces into a hash
    $yvars{$yaxis} = $yindex+1;
    push(@images, $yaxis);
}

# Organizing the data for graphing
my $num_imgs = scalar(@images);

print "\nGraphing...\n";

# Start Timer
my $start = time();

# iterate through all axis-index pairs to make the images
while (my ($axis, $index) = each (%yvars)){    
    my $imgindex = &stringindex($axis, \@images);
    my $width = $graphdata{$num_imgs}{$imgindex}[0];
    my $height = $graphdata{$num_imgs}{$imgindex}[1];
    my $font = $graphdata{$num_imgs}{$imgindex}[4];
    my $deg = $graphdata{$num_imgs}{$imgindex}[5];
    
    my $plot;
    if($xlo){$plot = "plot [$xlo:$xhi][]";
    }else{$plot = "plot ";}
    
    $plot .= "\".temp/$set1.txt\" u $xindex:$index ti \"$set1\"";
    if(@setnames>1){
	for(my $i=1; $i<scalar(@setnames); $i++){
	    my $temp = $setnames[$i];
	    $plot .= ", \".temp/$temp.txt\" u $xindex:$index ti \"$temp\"";
	}
    }
    # Erasing the x-axes
    
    # Setting subscripts
    my $subyaxis = $axis;
    $subyaxis =~ s/([0-9])/_$1/g;
    my $subxaxis = $xaxis;
    $subxaxis =~ s/([0-9])/_$1/g;
    
    # Initial axis settings
    my $xlabel = "set xlabel \"$subxaxis\"";
    my $ytics = "set ytics offset 0,-.5";
    my $ylabel = "set ylabel \"$subyaxis\"";
    
    # Initial margin settings
    my $lmargin = "set lmargin 10";
    my $rmargin = "set rmargin 10";
    my $tmargin = "set tmargin ";
    my $bmargin = "set bmargin ";
    
    # Rotate xtic labels
    my $xtics = "set xtics rotate";
    
##### CONDITIONS FOR REMOVING MARGINS, ETC ####	    
    # Condition: 3 or 4 images
    if($num_imgs == 3 or $num_imgs == 4){
	# Top images
	if($imgindex == 2 or $imgindex == 3){
	    $xtics = "unset xtics";
	    $xlabel = "unset xlabel";
	    $bmargin .= "0";
	}
	# Right images
	if($imgindex == 1 or $imgindex == 3){
	    $ytics = "set y2tics offset 0,-.5";
	    $ylabel = "set y2label \"$subyaxis\"";
	    $lmargin = "set lmargin 0";
	}
	# Left images
	if($imgindex == 0 or $imgindex == 2){
	    $rmargin = "set rmargin .1";
	}
	# Bottom images
	if($imgindex == 0 or $imgindex == 1){
	    $tmargin .= "0";
	}
    }
    # Condition: 2 images
    elsif($num_imgs == 2){
	if($imgindex == 1){
	    $xtics = "unset xtics";
	    $xlabel = "unset xlabel";
	    $bmargin .= "0";
	}
	else{
	    $tmargin .= "0";
	}
    }
    # Condition: everything else
    elsif($num_imgs > 4){
	# Condition: top images
	if($imgindex >= 2){
	    $xtics = "unset xtics";
	    $xlabel = "unset xlabel";
	    $bmargin .= "0";
	}
	if($num_imgs%2==0){
	    if($imgindex < ($num_imgs-2)){
	        $tmargin .="0";
	    }
	}
	if($num_imgs%2==1){
	    if($imgindex < ($num_imgs-1)){
	        $tmargin .="0";
	    }
	}
	# Condition: right images
	if($imgindex%2==1){
	    $ytics = "set y2tics offset 0,-.5";
	    $ylabel = "set y2label \"$subyaxis\"";
	    $lmargin = "set lmargin 0";
	}
	# Condition: left images
	if($imgindex%2==0){
	    $rmargin = "set rmargin .1";
	}
    }	

    # Create the image
    open(GNUPLOT, "|gnuplot");
    print GNUPLOT <<EOPLOT;
unset key
unset tics
$xtics
$ytics
set format x "%.2f"
set format y "%.2f"
set format y2 "%.2f"
$lmargin
$rmargin
$tmargin
$bmargin
unset ylabel
$ylabel
$xlabel
set terminal png enhanced size $width,$height
set output ".temp/$xaxis-$axis.png"
$plot                          
EOPLOT
    close(GNUPLOT);

    # Resize the image
    # my $resize = `convert .temp/$xaxis-$axis.png -resize $graphdata{$num_imgs}{$imgindex}[0]x$height -quality 100 .temp/$xaxis-$axis.png`;
	
    # Turn the image if necessary
    if($deg==90){
        &rotate($deg, "$xaxis-$axis.png");
    }
} 

# Start making PDF
my $pdf  = PDF::API2->new(-file => "$xaxis.pdf");
my $page = $pdf->page();
my $gfx = $page->gfx();

while (my ($axis, $index) = each (%yvars)){
    my $imgindex = &stringindex($axis, \@images);
    my $x = $graphdata{$num_imgs}{$imgindex}[2];
    my $y = $graphdata{$num_imgs}{$imgindex}[3];

    # Embedding all Images in PDF
    my $image = $pdf->image_png(".temp/$xaxis-$axis.png");
    $gfx->image($image, $x, $y);
}

# closing PDF
$pdf->save;
$pdf->end( );


my $end = time();
my $time_taken = $end - $start;
printf "Time elapsed: %d second%s\n", $time_taken, $time_taken == 1 ? "":"s";

# Delete temp images
if(-d ".temp"){
    my $rmdir = `rm -rf .temp`;
}

# Print key to console
print "KEY:\n";
for (my $i=0; $i < @setnames; $i++){
    print "DataSet $setnames[$i] is $tics[$i]\n";
}

# Open PDF for viewing
if(-e "$xaxis.pdf"){
    print "Plots are saved in $xaxis.pdf.\n";

    if(`which evince`){
	my $view_pdf = `evince $xaxis.pdf`;
    } elsif(`which open`){
	my $view_pdf = `open $xaxis.pdf`;
    }

}else{
    print "PDF creation failed.\n";
}


#####CSVARRAY subroutines#####
sub csvarray{
    my $n = $_[1];
    my(@sets) = @{$_[0]};
    my @numbers = ();
    
    foreach my $set(@sets){
    
        # Read each line into an array entry
        open(TXT, "<", ".temp/$set.txt");
        my @lines = <TXT>;
        close(TXT);
        
        # Split each line into an array
        foreach my $line(@lines){
            my @temp = split(/\t/, $line);
            my @temp1 = ();
            
            # Remove empty array antries (spaces)
            foreach my $slot(@temp){
                if($slot){
                    push(@temp1, $slot);
                }
            }
            
            # If it's a number, keep it
            if($temp1[$n] =~ /\d\.\d/){
                push(@numbers, $temp1[$n]);
            }
        }
    }
    return @numbers;
}


# Rewrites a file, replacing all lone spaces with dashes
sub spaceswap{
    open(TXT, "+< .temp/$_[0].txt") or die "Opening: $!";
    my @lines = <TXT>;
    foreach my $line(@lines){
        $line =~ s/([a-zA-Z0-9_]) ([a-zA-Z0-9_])/$1-$2/g;
    }
    seek(TXT,0,0) or die "Seeking: $!";
    print TXT @lines or die "Printing: $!";
    truncate(TXT, tell(TXT)) or die "Truncating: $!";
    close(TXT) or die "Closing: $!";  
}


# min
sub min{
    my $min = $_[1];
    foreach my $x(@_){
        $min = $x if $x < $min;
    }
    return $min;
}


# max
sub max{
    my $max = $_[1];
    foreach my $x(@_){
        $max = $x if $x > $max;
    }
    return $max;
}

#####GRAPHER-HELPER subroutines#####
# turns commas into tabs
sub csvwsv{
    my $csv = $_[0];
        
    # Open the source file
    open(CSV, $csv)
        or die("Error: file not found");
    
    # Give the output file the same name
    # as the input file
    my $fileout = $csv;
    $fileout =~ s/.csv/.txt/;
        
    # Create a destination file
    my $touch = `touch $fileout`;
    open(WSV, ">$fileout")
        or die("Cannot open $fileout for writing");
    
    #Switch out first line for a comment
    my $header = $_;
    #print WSV "$header";
        
    # While there are lines in the csv file
    while ($_ = <CSV>) {
        # read each line
        my $word = $_;
        # and globally replace commas with tabs
        $word =~ s/,/\t/g;
	# replace carriage return with newline
	$word =~ s/\r/\n/g;
        # then write that line to a new file
        print WSV $word;
    }
    
    # Close the files
    close(CSV);
    close(WSV);
    
    return $header;
}


# This method takes a string and an @array of strings
# and returns the index of the first appearance of that string
sub stringindex{
    $_[0] =~ s/\s//;
    my $strindex = 0;
    $strindex++ until $_[1][$strindex] =~ $_[0] or $strindex>$_[1];
    return $strindex;
}

sub rotate{
    my $cmd = `convert -rotate $_[0] .temp/$_[1] .temp/$_[1]`;
}

# maps an array to a hash
sub atoh{
    my(@array) = @{$_[0]};
    my %hash = ();
    
    foreach my $item(@array){
        $item =~ s/\s//;
	$hash{$item} = 1;
    }
    return %hash;
}

sub printarray{
    my @array = $_;
    foreach my $var (@array){
	print "$var\n";
    }
}
# Takes a csv and creates a 2D array out of it
sub csvaoa{
    my @csvarray = ();
    my $csv = $_;
    open(FILE, "<", "$csv.txt");
    while(<FILE>){
	my $temp = <>;
	push(@csvarray, split(/\s/, $temp));
    }
    return @csvarray;
}




