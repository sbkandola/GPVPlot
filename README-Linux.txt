GPVplot can be used in any standard Linux distribution. The programs it depends on should be available either through a package manager or through manual installation.


Run GPVplot
-----------

Start by downloading GPVplot.zip to any directory.
Navigate to that directory, and run these commands:

	unzip GPVplot.zip
	cd GPVplot
	perl gpvplot.pl

If all of the dependencies are already installed on your system, the program should begin prompting you to plot data. Try some of the example .csv files in the GPVplot folder.

If it instead tells you that you are missing "gnuplot" or "ImageMagick" you will need to continue.



Install gnuplot and ImageMagick
-------------------------------

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
