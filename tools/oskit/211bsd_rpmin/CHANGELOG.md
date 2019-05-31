# Changelog for 211bsd_rpmin oskit

## 2019-05-30: fpsim-bug + dz11 update

### Apply fpsim+tcsh patch
- for details see [w11a blog 2017-06-06](https://wfjm.github.io/blogs/211bsd/2017-06-06-kernel-panic-here-doc-tcsh.html)
- patch `/usr/src/sys/pdp/mch_fpsim.s`
- rebuild `RETRONFPNW` kernel
- patch `sh.dol.c` and `sh.glob.c` in `/usr/src/bin/tcsh`
- rebuild `tcsh`

### System changes
- enable login on console and first dz11 line

  `/etc/ttys` contains now
  ```
    console "/usr/libexec/getty std.9600"   vt100           on secure
    ttyl1   "/usr/libexec/getty std.9600"   vt100           off secure
    tty00   "/usr/libexec/getty std.9600"   vt100           on secure
    tty01   "/usr/libexec/getty std.9600"   vt100           off secure
    ...
  ```

## 2017-05-26: initial system setup
Derived from the [211bsd_rp](../211bsd_rp/CHANGELOG.md). Just a new kernel with
```
  NBUF       40             # was 160
  MAXUSERS   10             # was  20
  NPTY        8             # was  16
  INET       NO             # was YES, remove networking
  NSL         0             # was   1, remove network drivers
```
