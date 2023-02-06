# DZ11 echo tester

The `dz11echo` code echos any input entered or prints generated output on
all DZ11 lines.
Default is direct echo, only modification is to add a `LF` after `CR`.
Other modes can be selected by two ESC plus a character:
```
  ESC + ESC + u -> uppercase
  ESC + ESC + l -> lowercase
  ESC + ESC + o -> octal echo (16 per line)
  ESC + ESC + a -> direct echo
```
The DZ11 device and line state and automatic generation of output can be
controlled and inspected via single character commands entered on the console
```
   ?   help text
   c   char: only rie
   s   silo: only sae
   a   auto: rie or sae
   i   info: print line status
  0-7  define current line
   h   hangup:  set dtr=0
   r   ready:   set dtr=1
   b   break:   set brk=0 and send one char
   u   unbreak: set brk=1
   g   generate test output on line
   q   quit generating test output
```
`0` selects line 0, and a subsequent `g` will start generated output on that
line 0.

If the board has LEDs the light pattern depends on DZ11 device state
```
  no lines connected:  2.11BSD style
  >0 lines connected:  RSX11-M style
  ring active:         msb: 11111111-00000000  lsb: ring mask
  co change: :         msb: 10101010-01010101  lsb: co   mask
```

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Start `dl11echo` on an FPGA board for 2 DZ windows with
```bash
    console_starter -d DL0 &
    console_starter -d DZ0 &
    console_starter -d DZ1 &
    ti_w11 <opt> @dz11echo_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).

### Start on SimH
```bash
    console_starter -s -d DL0 &
    console_starter -s -d DZ0 &
    console_starter -s -d DZ1 &
    pdp11 dz11echo.scmd
```
