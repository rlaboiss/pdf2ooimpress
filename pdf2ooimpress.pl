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

my $errmsg =
  "isn't installed on your system; it's available from http://cpan.org/.\n";

eval 'use OpenOffice::OODoc';
die "OpenOffice::OODoc $errmsg"
  if $@;

eval 'use Getopt::Long';
die "Getopt::Long $errmsg"
  if $@;

eval 'use File::Temp qw [tempfile]';
die "File::Temp $errmsg"
  if $@;

eval 'use Image::Magick';
die "Image::Magick $errmsg"
  if $@;

eval 'use PDF::API2';
die "PDF::API2 $errmsg"
  if $@;

### Program name
(my $prog = $0) =~ s{^.*/}{};

### Process options
my $size = "1024x768";
GetOptions ("size=s" => \$size);
die "$prog:E: --size option must be in NNNxMMM format\n"
  if not ($size =~ /^\d+x\d+$/);

### Check number of arguments
die "Usage: $prog [--size=NNNxMMM] inputfile.pdf outputfile.sxi\n(default size is $size pixels)\n"
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
local $| = 1;

printf ("Page: %4d (out of $npages)", 0);

### Get name of first created page
my $page = $document -> getAttribute ($document -> getElement ('//draw:page', 0),
                                     'name');

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

    ## Create new page in presentation
    if ($i != $npages) {
        $page = $document -> appendElement (
            "//office:presentation", 0, "draw:page");
    }

}

print "\n";

### Close ooImpress document
$document -> save ();

### Remove temporary files
map {unlink $_} @files;
unlink $pdfpage;
