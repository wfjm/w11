# Changelog for 211bsd_rk oskit

## 2019-05-30: fpsim-bug + dz11 update

### Apply fpsim+tcsh patch
- for details see [w11a blog 2017-06-06](https://wfjm.github.io/blogs/211bsd/2017-06-06-kernel-panic-here-doc-tcsh.html)
- patch `/usr/src/sys/pdp/mch_fpsim.s`
- rebuild `RETRONFPRK` kernel
- patch `sh.dol.c` and `sh.glob.c` in `/usr/src/bin/tcsh`
- rebuild `tcsh`

### System changes
- enable login on first two dz11 lines

  `/etc/ttys` contains now
  ```
    tty00   "/usr/libexec/getty std.9600"   vt100           on secure
    tty01   "/usr/libexec/getty std.9600"   vt100           on secure
  ```

## 2017-05-25: major update
- kernel config unchanged
- kernel rebuild (to reflect node name ect)
- disk set re-build from [211bsd_rp](../211bsd_rp) master
  - main change is the group 7 fixup done for 211bsd_rp

## 2009-xx-xx: initial system setup
- use [211bsd_rp](../211bsd_rp/README.md) system as base
- configure a kernel `RETRONFPRK`, as non-networking, main differences
  ```
    IDENT         RETRONFPNW     -->  RETRONFPRK
    BOOTDEV       rm             -->  rk
    DUMPDEV       makedev(10,1)  -->  makedev(6,1)
    DUMPROUTINE   xpdump         -->  rkdump
    INET          YES            -->  NO
    NPTY          16             -->  8
  ```
- create a set of 4 disks with a absolute minimal non-networking system
  ```
    /dev/rk0h       /       ufs
    /dev/rk1h       none    swap
    /dev/rk2h       /tmp    ufs
    /dev/rk3h       /bin    ufs
    /dev/rk4h       /usr    ufs
  ```
  `/bin' contains the absolute mininal set of basic Unix tools
  ```
    [           csh         grep        mt          sed         true
    adb         date        hostid      mv          sh          tty
    ar          dd          hostname    nice        size        uname
    as          df          install     nm          sleep       vi
    awk         diff        iostat      od          sort        view
    basename    disklabel   jove        pagesize    strip       vmstat
    cat         du          kermit      passwd      stty        wall
    cc          e           kill        patch       su          wc
    chflags     echo        ld          ping        sync        which
    chfn        ed          less        pr          sysctl      who
    chgrp       egrep       ln          printenv    tar         write
    chmod       ex          login       ps          tcsh        xargs
    chpass      expr        lost+found  pwd         tee
    chsh        false       ls          rcp         test
    cmp         file        mail        rm          time
    copyh       find        make        rmail       touch
    cp          fstat       mkdir       rmdir       tp
  ```

- provisos
  - `/tmp` stays on `/`
  - `/home` is not mounted
  - absolute minimal system, suitable for a 'root' user
