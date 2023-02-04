# Rlink and Backend Server setup

After a board has been [connected and configured](w11a_board_connection.md)
and `vt100` emulator windows have been started with `console_starter`,
the backend server can be started and an [oskits](../tools/oskit/README.md)
or a _bare metal_ code like an [mcode](../tools/mcode/README.md) be executed.

The first step is to ensure that the switches on the FPGA board have the correct
setting for w11 operation. The usage of the available switches, bottons and
LEDs is documented in the top entity of the respective design. The default
setting for w11 operation is given in the next section.

Finally, the backend server is started the `ti_w11` quick start wrapper script
```
  ti_w11 <opt> <script>
```
with options `<opt>` that define to connection setup to the board and
the a Tcl script `<script>` that defines the system configuration.
Alternatively, `ti_w11` can start a GHDL based simulation model for
a w11 design.

The default switch settings and options for FPGA board connections and
GHDL simulation runs are

| w11 design | Link | SWI | FPGA<br>Options | GHDL<br>Options | Comment |
| ---------- | ---- | --: | --------------- | :-------------: | ------- |
| [sys_w11a_arty](../rtl/sys_gen/w11a/arty/README.md)   | FT2232HQ  | 0110              | -tuD,12M,break,xon     | -ar  | |
| [sys_w11a_as7](../rtl/sys_gen/w11a/artys7/README.md)  | FT2232HQ  | 0110              | -tuD,12M,break,xon     |      | |
| [sys_w11a_b3](../rtl/sys_gen/w11a/basys3/README.md)   | FT2232HQ  | 00000000 00101000 | -tuD,12M,break,xon     | -b3  | 176 kB memory only |
| [sys_w11a_c7](../rtl/sys_gen/w11a/cmoda7/README.md)   | FT2232HQ  | n/a               | -tuD,12M,break,xon     | -c7  | 672 kB memory only |
| [sys_w11a_n4d](../rtl/sys_gen/w11a/nexys4d/README.md) | FT2232HQ  | 00000000 00101000 | -tuD,12M,break,cts     | -n4d | |
| [sys_w11a_n4](../rtl/sys_gen/w11a/nexys4/README.md)   | FT2232HQ  | 00000000 00101000 | -tuD,12M,break,cts     | -n4  | |
| [sys_w11a_n3](../rtl/sys_gen/w11a/nexys3/README.md)   | FX2       | 00101100          | -u                     | -n3  | |
| [sys_w11a_n2](../rtl/sys_gen/w11a/nexys2/README.md)   | FX2       | 00101100          | -u                     | -n2  | |
| [sys_w11a_s3](../rtl/sys_gen/w11a/s3board/README.md)  | USB-RS232 | 00101010          | -tu&lt;dn&gt;,460k,break,xon | -s3 | |
   
Notes:
- a detailed documentation `ti_w11` is available via `man ti_w11`.
- the letter after `-tu` is either the serial device number,
  denoted as `<dn>`, or the letter `D` for auto-detection of
  Digilent boards with an FT2232HQ based interface.
  - for Arty A7, Basys3, Cmod A7, Nexys4, and Nexys A7 board simply use `D`
  - otherwise check with `ls /dev/ttyUSB*` to see what is available
  - `<dn>` is typically '1' if a single `FT2232HQ` based board is connected,
    like an Arty, Basys3, Cmod A7, or Nexys4. Initially, two ttyUSB devices
    show up, the lower is for FPGA configuration and will disappear when
    the Vivado hardware server is used once. The upper provides the data
    connection.
  - `<dn>` is typically '0' if only a single USB-RS232 cable is connected

- the LEDs are used, if available, by default to show the PDP-11 display register.
  On boards with less then 16 LEDs the pattern is folded. Other usages are on some
  boards available with SWI(3)

        0 -> system status
        1 -> DR emulation --> OS specific light patterns

- the hex display, if available, can be controlled with SWI(5:4)
  - boards with a 4 digit display

        00 -> serial link rate divider
        01 -> PC
        10 -> DISPREG
        11 -> DR emulation

  - boards with 8 digit display

        SWI(5) select for DSP(7:4) display
            0 -> serial link rate divider
            1 -> PC
        SWI(4) select for DSP(3:0) display
            0 -> DISPREG
            1 -> DR emulation
