# Changelog for 211bsd_rp oskit

## 2019-05-30: fpsim-bug + dz11 update

### Apply fpsim+tcsh patch
- for details see [w11a blog 2017-06-06](https://wfjm.github.io/blogs/211bsd/2017-06-06-kernel-panic-here-doc-tcsh.html)
- patch `/usr/src/sys/pdp/mch_fpsim.s`
- rebuild `RETRONFPNW` kernel
- patch `sh.dol.c` and `sh.glob.c` in `/usr/src/bin/tcsh`
- rebuild `tcsh`

### System changes
- enable login on first four dz11 lines

  `/etc/ttys` contains now
  ```
    tty00   "/usr/libexec/getty std.9600"   vt100           on secure
    tty01   "/usr/libexec/getty std.9600"   vt100           on secure
    tty02   "/usr/libexec/getty std.9600"   vt100           on secure
    tty03   "/usr/libexec/getty std.9600"   vt100           on secure
  ```
- update network context
  - use 192.168.178.* instead of 192.168.2.*
  - slip `sl0` started at boot time on dz11 line `/dev/tty07`

  `/etc/hosts` contains now
  ```
    127.0.0.1         localhost
    192.168.178.150   w11a
    192.168.178.20    athome
  ```
  `/etc/netstart` contains now
  ```
    hostname=w11a
    netmask=255.255.255.0
    broadcast=192.168.178.255
    default=192.168.178.1
    ...
    ifconfig sl0 inet 192.168.178.150 192.168.178.20 ...
    slattach /dev/tty07 9600
  ```

## 2017-05-25: Major update
The oskit was so far an almost 'out-of-the-box' 211bsb tape distribution kit,
updated to version #447 and set up with a kernel including `FPSIM`.
The current revision for a first time brings a system tuned for w11a.

### Issues with old oskit (all fixed now)
- swap partition too small for a crash dump of a 4 MB system
- `/tmp` and `/home` were on `/` root file system
- many files were in group 7 and should be in group `bin`
### System changes
- system disk repartitioned
  ```
    par  use      size    size   offset  size(kB)  comment
     a   /         50c   20900        0    10450   no tmp needed for fsck!
     b   swap      20c    8360    20900     4180   >3840 kB phys mem
     c   /tmp      25c   10450    29260     5200
     d   /home     50c   20900    39710    10450
     e   /usr     669c  279642    60610   139821   will be ~68% full
  ```
- kernel rebuild
  - slip support enabled (NSL now 1)
- system setup sanitized
  - `/etc/ttys`: all DZ11 lines set 'off' for now
  - `/etc/printcap`: default printer now `lp0`, others removed
- network setup sanitized
  - `/etc/netstart`: now suitable for usage in a 192.168.2.* subnet
    ```
    hostname=w11a
    netmask=255.255.255.0
    broadcast=192.168.2.255
    default=192.168.2.1
    ```
  - `/etc/resolv.conf` now empty
  - `/etc/hosts` now minimal
    ```
    127.0.0.1       localhost
    192.168.2.150   w11a
    192.168.2.25    athome
    ```
  - only loopback device `lo0` enabled at boot time
  - slip `sl0` is available and working, but must be started after boot
- added user `test` with password `test4W11a`

## 2009-xx-xx: Initial system setup
Setup 211bsd system from tape distribution kit obtained from
[TUHS](https://www.tuhs.org/).
- get tape distribution kit from [UnixArchive/Distributions/UCB/2.11BSD](https://www.tuhs.org/Archive/Distributions/UCB/2.11BSD/)
- get patches from [UnixArchive/Distributions/UCB/2.11BSD/Patches](https://www.tuhs.org/Archive/Distributions/UCB/2.11BSD/Patches/)
- set up initial system using `SimH`
  - load tape distribution kit (is version 431)
  - install all patches: 432,...,444
  - `FPSIM` didn't work. Fixed with [patch #445](https://wfjm.github.io/blogs/211bsd/2007-01-03-patch-445.html).
  - boot from a `RK05` wasn't possible. Fixed with [patch #446+447](https://wfjm.github.io/blogs/211bsd/2009-01-04-patch-446+447.html).
- build a kernel with `FPSIM` enabled (see `/sys/conf/RETRONFPNW`)
- set up oskits for RP06, RL02 and RK05
