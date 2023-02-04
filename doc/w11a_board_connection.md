# FPGA Board connection setup

The recommended connection setups for configuration and operation the supported
boards are

- [Arty A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_arty) or
  [Arty S7](https://wfjm.github.io/home/w11/inst/boards.html#digi_artys7)
  - connect USB cable to micro-USB connector labeled 'J10'
  - to configure via Vivado hardware server `make <sys>.vconfig`

- [Basys3](https://wfjm.github.io/home/w11/inst/boards.html#digi_basys3)
  - connect USB cable to micro-USB connector labeled 'PROG'
  - to configure via ivado hardware server `make <sys>.vconfig`

- [Cmod A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_cmoda7)
  - connect USB cable to micro-USB connector
  - to configure via Vivado hardware server `make <sys>.vconfig`

- [Nexys4](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4)
  and [Nexys A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexysa7)
  (or
  [Nexys4 DDR](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4d))
  - connect USB cable to micro-USB connector labeled 'PROG'
  - to configure via Vivado hardware server `make <sys>.vconfig`

- [Nexys3](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys3)
  - use Cypress FX for configure and and rlink communication
  - connect USB cable to micro-USB connector labeled 'USB PROG'
  - to configure via FX2 and jtag tool `make <sys>.jconfig`

- [Nexys2](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys2)
  - connect USB cable to mini-USB connector (between RS232 and PS/2 port)
  - to configure via FX2 and jtag tool `make <sys>.jconfig`

- [S3board](https://wfjm.github.io/home/w11/inst/boards.html#digi_s3board)
  - connect the USB-RS232 cable to the RS232 port
  - connect a JTAG programmer (e.g. Xilinx USB Cable II) to JTAG pins
  - to configure via ISE Impact `make <sys>.iconfig`
