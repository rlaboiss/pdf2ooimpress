#!/usr/bin/perl -w

### This script converts a PDF file containing slides for a presentation
### into the OpenOffice Impress format (.sxi)
### Based on a script written by K.-H. Herrmann June 2005
### (http://linuxgazette.net/116/misc/herrmann/img2ooImpress.pl.txt)

### Copyright (C) 2008  Rafael Laboissiere
###
### This program is free software: you can redistribute it and/or
### modify it under the terms of the GNU General Public License as
### published by the Free Software Foundation, either version 3 of the
### License, or (at your option) any later version.
###
### This program is distributed in the hope that it will be useful,
### but WITHOUT ANY WARRANTY; without even the implied warranty of
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
### GNU General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see
### <http://www.gnu.org/licenses/>.

use OpenOffice::OODoc;

### Progam name
(my $prog = $0) =~ s{^.*/}{};

### Check number of arguments
die "Usage: $prog inputfile.pdf outputfile.swi\n"
  if (@ARGV != 2);

### Input paramenters
my $infile = $ARGV [0];
my $outfile = $ARGV [1];

### Get number of pages of the input PDF file
open (PDFINFO, "pdfinfo $infile |")
  or die "$prog:E: Cannot run pdfinfo on input file $infile\n";
my $npages;
while (<PDFINFO>) {
    if (/^Pages:\s+(\d+)/) {
        $npages = $1;
    }
}

### Temporary file for each page in the PDF input file
my $pdfpage = qx (tempfile --suffix=.pdf);
chomp $pdfpage;

### Create ooImpress document
my $document = ooDocument (
    file => $outfile,
    create => 'presentation');
$document -> createImageStyle ("slide");

### Store PNG file names for later removal
my @files = ();

print (sprintf ("Page: %4d (out of $npages)", 0));

foreach $i (1 .. $npages) {

    ## Get individual page in a separate PDF file
    system ("pdftk $infile cat $i output $pdfpage") == 0
      or die "$prog:E: pdftk cannot extract page $i of $infile\n";

    ## Temporary file for PNG image
    my $pngpage = qx (tempfile --suffix=.png);
    chomp $pngpage;
    push (@files, $pngpage);

    ## Convert page to PNG image
    system ("convert -density 300x300 -resize 1024x768 $pdfpage $pngpage") == 0
      or die "$prog:E: convert PDF->PNG file for page $i\n";

    ## Create new page in presentation
    my $page = $document -> appendElement (
        "//office:presentation", 0, "draw:page");

    ## Add image to page
    $document -> createImageElement (
        "slide" . $i,
        description     => "image " . $i,
        page            => $page,
        position        => "0,0",
        import          => $pngpage,
        size            => "28cm, 21cm",
        style           => "slide");

    ## Progress meter
    print (sprintf ("\rPage: %4d (out of $npages)", $i));
}

print "\n";

### Close ooImpress document
$document -> save ();

### Remove temporary files
map {unlink $_} @files;
unlink $pdfpage;

