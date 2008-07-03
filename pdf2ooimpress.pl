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
### MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
### General Public License for more details.
###
### You should have received a copy of the GNU General Public License
### along with this program.  If not, see
### <http://www.gnu.org/licenses/>.

### Thanks to Ben Okopnik for the suggestions to improve this script.

### $Id$

use strict;
use OpenOffice::OODoc;
use Getopt::Long;
use File::Temp qw [tempfile];
use Image::Magick;
use PDF::API2;

### Program name
(my $prog = $0) =~ s{^.*/}{};

### Process options
my $size = "1024x768";
GetOptions ("size=s" => \$size);
die "$prog:E: --size option must be in NNNxMMM format\n"
  if not ($size =~ /^\d+x\d+$/);

### Check number of arguments
die "Usage: $prog [--size=NNNxMMM] inputfile.pdf outputfile.swi\n"
  if (@ARGV != 2);

### Input paramenters
my $infile = $ARGV [0];
my $outfile = $ARGV [1];

### Get number of pages of the input PDF file
my $pdf = PDF::API2 -> open ($infile);
my $npages = $pdf -> pages ();

### Temporary file for each page in the PDF input file
my ($fh, $pdfpage) = tempfile (SUFFIX => ".pdf");

### Create ooImpress document
my $document = ooDocument (
    file => $outfile,
    create => 'presentation');
$document -> createImageStyle ("slide");

### Store PNG file names for later removal
my @files = ();

### Autoflush STDOUT
$| = 1;

print (sprintf ("Page: %4d (out of $npages)", 0));

foreach my $i (1 .. $npages) {

    ## Get individual page in a separate PDF file
    my $p = PDF::API2 -> new ();
    $p -> importpage ($pdf, $i);
    $p -> saveas ($pdfpage);

    ## Temporary file for PNG image
    my ($f, $pngpage) = tempfile (SUFFIX => ".png");
    push (@files, $pngpage);

    ## Convert page to PNG image
    my $image = Image::Magick -> new ();
    $image -> Set (density => "300x300");
    $image -> Resize (geometry => $size);
    $image -> Read ($pdfpage);
    $image -> Write ($pngpage);

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
    printf ("\rPage: %4d (out of $npages)", $i);
}

print "\n";

### Close ooImpress document
$document -> save ();

### Remove temporary files
map {unlink $_} @files;
unlink $pdfpage;
