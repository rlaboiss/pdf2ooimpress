# pdf2ooimpress – PDF to OpenDocument Presentation converter

## Description

This script converts a PDF file containing slides for a presentation
into the OpenDocument Presentation format (.odp).

## Usage

```
pdf2ooimpress [--size=NNNxMMM] inputfile.pdf outputfile.odp
```

(default size is 1024x768 pixels)

### Installation

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

