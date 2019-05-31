# Changelog for 211bsd_rl oskit

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
- use 211bsd_rp system as base
- configure a kernel RETRONFPRL, as non-networking, main differences
  ```
    IDENT         RETRONFPNW     -->  RETRONFPRL
    BOOTDEV       rm             -->  rl
    DUMPDEV       makedev(10,1)  -->  makedev(7,1)
    DUMPROUTINE   xpdump         -->  rldump
    INET          YES            -->  NO
    NPTY          16             -->  8
  ```
- create a set of 2 disks with a minimal non-networking system
  ```
    /dev/rl0a       /       ufs
    /dev/rl0b       none    swap
    /dev/rl1h       /usr    ufs
  ```
- provisos
  - /tmp stays on '/'
  - /home is not mounted
  - minimal system, suitable for a 'root' user
