# DL11 echo tester

The `dl11echo` code simply echos any input entered on the console DL11 device.
Default is direct echo, only modification is to add a `LF` after `CR`.
Other modes can be selected by two ESC plus a character:
```
  ESC + ESC + u -> uppercase
  ESC + ESC + l -> lowercase
  ESC + ESC + o -> octal echo (16 per line)
  ESC + ESC + a -> direct echo
```
If the board has LEDs they will show an RSX-style light pattern.

### Start on w11
See general notes on
- [FPGA Board setup](../../../doc/w11a_board_connection.md)
- [Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md)

Start `dl11echo` on an FPGA board or a GHDL simulation with
```bash
    console_starter -d DL0 &
    ti_w11 <opt> @dl11echo_run.tcl
```
with the options `<opt>` as described in
[Rlink and Backend Server setup](../../../doc/w11a_backend_setup.md).

### Start on SimH
```bash
    console_starter -s -d DL0 &
    pdp11 dl11echo.scmd
```
