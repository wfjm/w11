## Notes on oskit: 2.11BSD system on a RP06 volume

### General remarks
See notes in [w11a_os_guide.md](../../../doc/w11a_os_guide.md) on
  1. I/O emulation setup
  2. FPGA Board setup
  3. Rlink and Backend Server setup
  4. SimH simulator setup
  5. Legal terms

### System properties and intended usage
- patch level is #447 plus [fpsim+tcsh patch](https://wfjm.github.io/blogs/211bsd/2017-06-06-kernel-panic-here-doc-tcsh.html)
- for history see [CHANGELOG.md](CHANGELOG.md)
- This system is created for multi-user usage without Ethernet. The
  `RETRONFPNW` kernel is configured with
  ```
    INET    YES        # networking available
    NETHER  0          # no Ethernet
    NSL     1          # Serial Line IP enabled
  ```
- see [211bsd_rpeth](../211bsd_rpeth/README.md) for a system with `DEUNA` support
- see [211bsd_rpmin](../211bsd_rpmin/README.md) for a minimal memory system.

### Installation
A disk set is available from
http://www.retro11.de/data/oc_w11/oskits/211bsd_rpset.tgz

Download, unpack and copy the disk images (*.dsk), e.g.
```bash
       cd $RETROBASE/tools/oskit/211bsd_rp/
       211bsd_rp_setup
```

### Usage

- Start backend server and boot system (see section Rlink in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-rlink))
  ```
       boot script:  211bsd_rp_boot.tcl
       example:      ti_w11 <opt> @211bsd_rp_boot.tcl
                     where <opt> is the proper option set for the board.
  ```
  or use for verification the SimH simulator  (see section SimH in
  [w11a_os_guide](../../../doc/w11a_os_guide.md#user-content-simh))
  ```
  pdp11 211bsd_rp_boot.scmd
  ```

- Hit `<ENTER>` in the `xterm` window to connect to backend server.
  The boot dialog in the console `xterm` window will look like
  (required input is in `{..}`, with `{<CR>}` denoting a carriage return:
  ```
       70Boot from xp(0,0,0) at 0176700
       : {<CR>}
       : xp(0,0,0)unix
       Boot: bootdev=05000 bootcsr=0176700

       2.11 BSD UNIX #13: Wed May 29 22:05:40 PDT 2019
           root@w11a:/usr/src/sys/RETRONFPNW

       attaching sl
       attaching lo0

       phys mem  = 3932160
       avail mem = 3461952
       user mem  = 307200

       May 29 22:25:35 init: configure system
       
       dz 0 csr 160100 vector 310 attached
       lp 0 csr 177514 vector 200 attached
       rk 0 csr 177400 vector 220 attached
       rl 0 csr 174400 vector 160 attached
       tm 0 csr 172520 vector 224 attached
       xp 0 csr 176700 vector 254 attached
       cn 1 csr 176500 vector 300 attached
       erase, kill ^U, intr ^C
  ```

  In first `'#'` prompt the system is in single-user mode. Just enter a `^D` 
  to continue the system startup to multi-user mode:
  ```
       #^D
       Fast boot ... skipping disk checks
       Checking quotas: done.
       Assuming NETWORKING system ...
       add host w11a: gateway localhost
       starting system logger
       checking for core dump... 
       preserving editor files
       clearing /tmp
       standard daemons: update cron accounting.
       starting network daemons: inetd printer.
       starting local daemons:Wed May 29 22:25:49 PDT 2019
       May 29 22:25:49 w11a init: kernel security level changed from 0 to 1
       
       
       2.11 BSD UNIX (w11a) (console)
       
       login:
  ```

  The login prompt is sometimes mangled with system messages, if its not
  visible just hit `<ENTER>` to get a fresh one.
  ```
       login: {root}
       erase, kill ^U, intr ^C
  ```

  Now the system is in multi-user mode, daemons running. You can explore
  the system, e.g. with a `pstat -T` or a `mount` command.

  The second DL11 and the first four DZ11 lines can me activated too.
  Also simple networking via SLIP and a DZ11 line, for details see
  [using SLIP with 211bsd](../doc/211bsd_slip.md).
  
  At the end is important to shutdown properly with a `halt`:
  ```
       # {pstat -T}
        49/186 files
        65/208 inodes
        16/150 processes
        11/ 46 texts active,  37 used
         3/135 swapmap entries,  530 kB used, 3649 kB free, 3642 kB max
        33/150 coremap entries, 2599 kB free, 2520 kB max
         1/ 10  ub_map entries,    8    free,    8    max
       # {mount}
       /dev/xp0a on /
       /dev/xp0c on /tmp
       /dev/xp0d on /home
       /dev/xp0e on /usr
       # {halt}
       syncing disks... done
       halting
  ```

  While the system was running the server process display the
  ```
       cpu0> 
  ```

  prompt. When the w11 has halted after 211bsd shutdown a message like
  ```
       CPU down attention
       Processor registers and status:
         PS: 030350 cm,pm=k,u s,p,t=0,7,0 NZVC=1000  rust: 01 HALTed
         R0: 177560  R1: 010330  R2: 056172  R3: 000010
         R4: 005000  R5: 147510  SP: 147466  PC: 000014
   ```

   will be visible. Now the server process can be stopped with `^D`.
