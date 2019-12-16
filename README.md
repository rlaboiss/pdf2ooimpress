# pdf2ooimpress – PDF to OpenDocument Presentation converter

## Description

This script converts a PDF file containing slides for a presentation
into the OpenDocument Presentation format (.odp).

## Usage

```
pdf2ooimpress [--size=NNNxMMM] inputfile.pdf outputfile.odp
```

(default size is 1024x768 pixels)

## Dependencies

The `pdf2ooimpress` script uses the modules `Getopt::Long`, `File::Temp`,
`OpenOffice::OODoc`, `Image::Magick`, and `PDF::API2`.  The first two are
standard in Perl and the later three can be installed like this, in
Debian-based distributions:

```
apt install libimage-magick-perl
apt install libopenoffice-oodoc-perl
apt install libpdf-api2-perl
```

## Installation

```
make install
```

The `pdf2ooimpress` script is installed by default into `/usr/local/bin`.
Another destination directory can be specified like this:

```
make BINDIR=/path/to/installation/directory install
```

## Credits

Based on a script written by K.-H. Herrmann June 2005
(http://linuxgazette.net/116/misc/herrmann/img2ooImpress.pl.txt)

Thanks to Ben Okopnik for the suggestions to improve this script.

## Author

Copyright (C) 2018, 2019  Rafael Laboissiere (<rafael@laboissiere.net>)

Released under the GNU General Public License, version 3 or later.  No
warranties.

