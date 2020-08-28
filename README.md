# GPVPlot
Geochemical data graphing software

## Installation (Linux)

GPVplot can be used in any standard Linux distribution. The programs it depends on should be available either through a package manager or through manual installation.


### Run GPVplot

Start by downloading GPVplot.zip to any directory.
Navigate to that directory, and run these commands:

	unzip GPVplot.zip
	cd GPVplot
	perl gpvplot.pl

If all of the dependencies are already installed on your system, the program should begin prompting you to plot data. Try some of the example .csv files in the GPVplot folder.

If it instead tells you that you are missing "gnuplot" or "ImageMagick" you will need to continue.



### Install gnuplot and ImageMagick

If your Linux distribution has a package manager, use it to install the gnuplot and convert packages. For example, in Ubuntu you would do:

	sudo apt-get install gnuplot
	sudo apt-get install imagemagick

You can also download the binary source tarballs from these sites:

	http://www.gnuplot.info/
	http://www.imagemagick.org/

Manual installation of a tarball generally works like this:

	tar -xzf WHATEVER.tar.gz
	cd WHATEVER
	./configure
	make
	sudo make install

Once these are done, you should be able to return to the GPVplot step and run the program successfully.

## Installation (Mac)

GPVplot can be used in Mac OS X 10.5 or higher. The programs it depends on are available for free on this platform, though they are less easy to acquire than they are on Linux. Instructions are provided below.


### Run GPVplot

Start by downloading GPVplot.zip to your Desktop.
Open a Terminal and run these commands:

	cd Desktop
	unzip GPVplot.zip
	cd GPVplot
	perl gpvplot.pl

If all of the dependencies are already installed on your system, the program should begin prompting you to plot data. Try some of the example .csv files in the GPVplot folder.

If it instead tells you that you are missing "gnuplot" or "ImageMagick" you will need to continue.


### Install Dependencies

This is best done by a system administrator if you have one. The process will prompt you several times for your password, and this will only succeed if your account has administrative (sudo) privileges.

By far the easiest way to install gnuplot and convert is through a program called MacPorts. If you already have this program, you can skip straight to the last step. To check whether you have it, run this command in the Terminal:

	which port

If it displays something like "/opt/local/bin/port" on the next line, you have MacPorts. If it doesn't display anything, you need to install MacPorts.


### Install MacPorts

MacPorts itself has one dependency: Xcode, the Apple development toolkit. You can download Xcode for free, but you will have to register as an Apple developer. This was the website for doing so when last we checked:

	http://developer.apple.com/programs/register/

On this site, click the "Get Started" button, and follow the instructions there to register. Once that's done, sign in here:

	http://connect.apple.com/

In the Downloads section, search for Xcode. Many versions will be listed - expand the descriptions and find one that is compatible with your version of OS X. Download the .dmg file, and if it doesn't run automatically, click it to install Xcode.

Next go to the MacPorts site:

	http://www.macports.org/

Follow the link for installing MacPorts, and on that page find a link to a .dmg file that is compatible with your version of OS X. Download the .dmg file, and if it doesn't run automatically, click it to install MacPorts.

If you have a terminal window open, close it and open a new one to make sure these changes register. Now you should be able to do the last step.


### Install gnuplot and ImageMagick

In a terminal, run these commands:

	sudo port install gnuplot
	sudo port install ImageMagick

Note that these may take a long time to finish, but once they're done, you should be able to return to the GPVplot step and run the program successfully.

## Example Input:

    > How many data sets would you like to graph? 
    2
    > Enter filename for set 1: 
    1991-P1-glass-phases
    > Enter filename for set 2: 
    1991-P2-glass-phases
    > Na20 MgO P2O5 SiO2 Al2O3 K2O CaO TiO2 FeO MnO Na2O+K2O
    > Enter an x-axis variable from the list above exactly as it appears
    Al2O3
    > Would you like to scale the x-axis? (y/n):
    y
    > The approximate range is 12.842 to 19.194
    > Enter low:
    12
    > Enter high:
    20
    > How many variables would you like to graph (1-8):
    3
    > One at a time, enter a y-axis variable from the list above.
    > Enter variable 1:
    Na2O
    > Enter variable 2:
    MgO
    > Enter variable 3:
    P2O5
    
