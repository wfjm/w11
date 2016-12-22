# Installation of urjtag

The w11 project uses the open source JTAG Access software from the
SourceForge project
[urjtag](https://sourceforge.net/projects/urjtag/) 
for configuring FPGA over the Cypress FX2 USB Interface available on 
Digilent Nexys2, Nexys3 and Atlys boards.

The most recent version works fine. This version is delivered with 
Ubuntu 12.04 LTS and later Ubuntu versions. In this case simply install the 
package `urjtag`. Try the command

    jtag

it should print

    UrJTAG 0.10 #2007

and show a version number of `#2007` or higher.

Old versions unfortunately have a string size limitation problem with can
lead to problems when used with Digilent S3BOARDS (or other cases with
multiple devices in the jtag chain). Therefore for

    Debian Squeeze and older
    Ubuntu 11.10 (oneiric) and older

or if the 'jtag' command prints something like

    UrJTAG 0.10 #1502
    UrJTAG 0.9 #1476

it is advisible to install the urjtag software from sources.

Simlest is to install an up-to-date version directly from the SourceForge
svn repository, start at
https://sourceforge.net/p/urjtag/svn/HEAD/tree/trunk/ , do a 
`svn co` for revision `2007` or later, build and install.

Alternatively start with the `V0.10 (rev #1502)` tarball available from
https://sourceforge.net/projects/urjtag/files/
and download

    urjtag-0.10.tar.gz            (dated 2009-04-17)

Change in file `src/cmd/parse.c` the line

    #define MAXINPUTLINE 100    /* Maximum input line length */

and replace `100` with `512`, build and install.
