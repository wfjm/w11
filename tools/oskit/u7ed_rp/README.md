## Notes on oskit: Unix 7th Edition system on a RP04 volume

### Proviso

The current disk image is the plain 'Keith_Bostic' distribution
**without any adoptions of further configurations**.
Especially no program was rebuild to use the floating point simulator.

**All programs using floating point arithmetic will core dump !!**

Most in fact work fine because floating point is rarely used, but a simple
```
    awk "BEGIN { print 1/100 }" /dev/null
```

will generate a `core` because awk for example does use floating point
arithmetic.

**So far only minimal testing on the Cmod A7 system (672 kB memory) done.**

### General remarks
See notes in [w11a_os_guide.md](../../../doc/w11a_os_guide.md) on
  1. I/O emulation setup
  2. FPGA Board setup
  3. Rlink and Backend Server setup
  4. SimH simulator setup
  5. Legal terms

### Installation
A disk set is available from
http://www.retro11.de/data/oc_w11/oskits/u7ed_rpset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```bash

       cd $RETROBASE/tools/oskit/u7ed_rp
       u7ed_rp_setup
```

### Usage

- Start backend server and boot system (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       boot script:  u7ed_rp_boot.tcl
       example:      ti_w11 <opt> @u7ed_rp_boot.tcl
                     where <opt> is the proper option set for the board.
  ```
  or use for verification the SimH simulator  (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
  pdp11 u7ed_rp_boot.scmd
  ```

- Hit `<ENTER>` in the xterm window to connect to backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```
       {boot}
       Boot
       : {hp(0,0)unix}
       mem = 611520
       # {^D}
       RESTRICTED RIGHTS: USE, DUPLICATION, OR DISCLOSURE
       IS SUBJECT TO RESTRICTIONS STATED IN YOUR CONTRACT WITH
       WESTERN ELECTRIC COMPANY, INC.
       WED DEC 31 19:02:00 EST 1969
       login: {root}
       Password: {root}
  ```

  **Note**: one has to type `boot` to start the 1st level boot loader. There
  is no initial prompt ! Just type `boot` followed by an enter to get going.

  Now you are at the shell prompt and can exercise the system, e.g.
  ```
       # {ls -al}
       total 542
       drwxr-xr-x  8 root      288 Dec 31 19:01 .
       drwxr-xr-x  8 root      288 Dec 31 19:01 ..
       drwxrwxr-x  2 bin      2480 May  5 05:59 bin
       -rwxrwxr-x  1 bin      6900 May 16 01:33 boot
       drwxr-xr-x  2 root      304 Dec 31 19:01 dev
       drwxr-xr-x  2 root      336 Dec 31 19:03 etc
       -rwxrwxr-x  1 sys     53302 Jun  8 16:56 hphtunix
       -rwxrwxr-x  1 sys     52850 Jun  8 16:56 hptmunix
       drwxrwxr-x  2 bin       336 Jan 22 19:58 lib
       -rwxrwxr-x  1 sys     51790 Jun  8 16:56 rphtunix
       -rwxrwxr-x  1 sys     51274 Jun  8 16:56 rptmunix
       drwxrwxrwx  2 bin       304 Jun  8 16:52 tmp
       -rwxrwxr-x  1 root    52850 Dec 31 19:01 unix
       drwxr-xr-x 15 bin       304 May 17 01:02 usr

       # {ps aux}
           PID TTY TIME CMD
           16 co  0:00 -sh 
           17 co  0:00 ps aux 
           15 ?   0:00 /etc/cron
       # {df}
       /dev/rp0 5311
       /dev/rp3 130595
   ```

  There is no `halt` or `shutdown` command, the proper way to shutdown
  is to do a few `sync`
  ```
       {sync}
       {sync}
       {sync}
  ```

  and just terminate the server session with a 
  ``` 
       .qq
  ```

  command. 
