# Changelog for 211bsd_rpeth oskit

## 2019-05-30: fpsim-bug + dz11 update

### Apply fpsim+tcsh patch
- for details see [w11a blog 2017-06-06](https://wfjm.github.io/blogs/211bsd/2017-06-06-kernel-panic-here-doc-tcsh.html)
- patch `/usr/src/sys/pdp/mch_fpsim.s`
- rebuild `RETRONFPETH` kernel
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
  ```

## 2017-05-26: initial system setup
Derived from the [211bsd_rp](../211bsd_rp/CHANGELOG.md). A new kernel with
```
  NETHER      1             # was   0, enable ethernet
  NDE         1             # was   0, enable DEUNA
  NSL         1             # was   1, remove slip
```

In /etc/netstart the networking is enabled with
```
hostname=w11a
netmask=255.255.255.0
broadcast=192.168.2.255
default=192.168.2.1
...
ifconfig de0 inet netmask $netmask $hostname broadcast $broadcast
route add default $default 1
```
