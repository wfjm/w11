# Installation of urjtag

`urjtag` is a available as Debian/Ubuntu package since long time.
but with quite varying quality:
  - Debian Squeeze and Ubuntu 11.10 (oneiric) or were **broken** due to a
    string size limitation problem
  - Ubuntu 12.04 **works**
  - Ubuntu 14.04 **works**
  - Ubuntu 16.04 is **corrupt**, crashes with a SEGFAULT in the `detect` command

If you have installed the package `urjtag` and the command

    jtag

prints

    UrJTAG 0.10 #2007

with a version number of `#2007` or higher and

    cd $RETROBASE/rtl/sys_gen/tst_rlink_cuff/nexys3/ic
    make sys_tst_rlink_cuff_ic_n3.jconfig

works fine with a connected `nexys3` board all is fine.

Otherwise install from sources. I prefer in install in `$HOME/usr_local`
to keep distribution packages and self-compiled things separate. Do do

    cd <your source directory>
    time git clone https://git.code.sf.net/p/urjtag/git urjtag

    cd urjtag/urjtag
    ./autogen.sh --prefix=$HOME/usr_local 2>&1 | tee autogen.log
    time make 2>&1 | tee make.log
    time make install 2>&1 | tee install.log

Tested with urjtag version (from `git log`)

    commit d938d4679692d94709f30fa9d20205e22436f39b
    Author: Geert Stappers <stappers@debian.org>
    Date:   Mon Mar 20 12:04:22 2017 +0100

