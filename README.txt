README for DelMapMaker

Authors: Kotaro Ishii (kotaro@riken.jp)
	 and Yusuke Kazama (ykaze@riken.jp)
Date:	22/7/2015

(1) INTRODUCTION
DelMapMaker is a Perl program for generating a CSV file representing a simulated deletion map that consists of a PCR result showing the presence or absence (a deletion) of simulated markers in simulated mutants according to user designations.

DelMapMaker generates an output file in the following manner: (a) DelMapMaker assumes a matrix that has n columns and m rows where n and m indicate the number of markers and mutants, according to user input. (b) All elements are filled with Åg1,Åh indicating that the marker is Ågpresent.Åh In each mutant, two adjacent elements in a random location are changed to Åg0Åh; that is, a deletion with a length of two markers is made, except when the ÅgbiasedÅh option is selected in the settings (see usage). (c) Each deletion is extended randomly from one marker to 28% of the total markers (based on the mean number in the experimental data). (d) Step (c) is repeated until the total number of ÅgdeletedÅh (represented by Åg0Åh) elements equals the number input by the user. DelMapMaker outputs the virtual result as a CSV file, which can then be used as an input file for DelMapper.

DelMapper has been tested using Cygwin (version 1.7.31-3).

(2) REQUIRED SYSTEMS
-perl (an interpreter for the Perl language, see https://www.perl.org/)

(3) PACKAGE FILES
The following files are included in the DelMapMaker package.

delmapmaker.pl	# Perl script to make an input file for DelMapper
README.txt	# this file

(4) USAGE
An input file is not necessary. Instead, the numbers of virtual markers, mutants, and ÅgdeletedÅh elements in the matrix are input by the user. 

Syntax:
   perl delmapmaker.pl [-b] nmarker nmutant ndelelement outname
where nmarker denotes the number of markers, nmutant denotes the number of mutants, and ndelelement represents the total number of ÅgdeletedÅh elements in the matrix representing the virtual PCR result. outname is used in the names of the output directory and files.

Option:
   -b	switches on the Biased option
Usually a deletion is made in a random location (at the two adjacent markers). When the Biased option is on, this location is at the mean of the given markers, with a standard deviation of half of the number of markers.

Output file:
   outname.csv	# input file for the Perl script clusterinput.pl, which is a component of DelMapper.
The output file can be processed by clusterinput.pl without any modification.

(5) LICENSE
Copyright (c) 2015 Kotaro Ishii and Yusuke Kazama

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
