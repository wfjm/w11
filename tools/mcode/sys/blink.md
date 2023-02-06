# _Blinking Lights_ Demonstrator

The `blink` code generates the _blinking lights_ pattern of RSX-11M and
2.11BSD and some other patterns. The type of pattern and the update speed
can be controlled with single letter commands entered on the console.
```
    styles
       r   RSX-11M style
       b   2.11BSD style
       f   flipper
       c   counter
       R   random pattern
    other controls
       0   use default speed
      1-9  set update speed (1 fastest, 9 slowest)
       a   auto, cycle styles
       s   surprise, random styles
```

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Start `blink` on an FPGA board, best one with a 16 LED display, with
```bash
    console_starter -d DL0 &
    ti_w11 <opt> @blink_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).
