# w11 I/O emulation setup

All UNIBUS peripherals which exchange data (currently DL11, DZ11, LP11, PC11,
DEUNA, RK11, RL11, RPRH, and TM11) are currently emulated via a backend
process. For details see
[w11 architecture](https://wfjm.github.io/home/w11/impl/architecture.html)
description.
The communication between the FPGA board and backend server can be via

- Serial port
  - via an integrated USB-UART bridge
    - on Arty A7, Basys3, Cmod A7 and Nexys A7, and Nexys4 with an `FT2232HQ`, 
      allows up to 12M Baud
    - on Nexys3 with an `FT232R`, allows up to 2M Baud
    - for all FTDI USB-UART it is essential to set them to `low latency` mode.
      That was the default for Linux kernels 2.6.32 to 4.4.52. Since about March
      2017, one gets kernels with 16 ms default latency again, thanks to
      kernel patch 9589541.
      **On newer systems, it is essential to install a udev rule** which
      automatically sets low latency, see the
      [documentation in tools/sys](../tools/sys/README.md).
  - via RS232 port, as on Nexys2 and S3board
    - using a serial port (/dev/ttySx) is limited to 115 kBaud on most PCs.
    - using a USB-RS232 adapter was tested up to 460k Baud. 

- Direct USB connection using a Cypress FX2 USB controller
  - is supported on the Nexys3 and Nexys2 FPGA boards
  - much faster than serial port connections (see below)
  - also allows configuring the FPGA over the same USB connection

- Notes: 
  - A 12M Baud connection, like on a Nexys A7, gives disk access rates and 
    throughputs much better than the real hardware of the 70's and is well 
    suitable for practical usage.
  - In an OS with good disk caching like 2.11BSD the impact of disk speed
    is actually smaller than the bare numbers suggest.
  - A 460k Baud connection gives in practice a disk throughput of ~20 kB/s. 
    This allows to test the system but is a bit slow for real usage.
  - USB-RS232 cables with an FTDI `FT232R` chip work fine, tests with Prolific 
    Technology `PL2303` based cable never gave reliable connections for higher 
    Baud rates.

Recommended setup for best performance (boards ordered by vintage):

| Board      | Channel/Interface      | nom. speed   | peak transfer rate |
| :--------- | :--------------------- | :----------- | -----------------: |
| [Arty S7](https://wfjm.github.io/home/w11/inst/boards.html#digi_artys7)   | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| [Arty A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_arty)     | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| [Basys3](https://wfjm.github.io/home/w11/inst/boards.html#digi_basys3)    | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| [Cmod A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_cmoda7)   | USB-UART bridge        | 12M Baud     |  1090 kB/sec |
| [Nexys A7](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexysa7) | USB-UART bridge        | 12M Baud     |  1090 kb/sec |
| [Nexys4](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys4)    | USB-UART bridge        | 12M Baud     |  1090 kb/sec |
| [Nexys3](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys3)    | Cypress FX2 USB        | USB2.0 speed | 30000 kB/sec |
| [Nexys2](https://wfjm.github.io/home/w11/inst/boards.html#digi_nexys2)    | Cypress FX2 USB        | USB2.0 speed | 30000 kB/sec |
| [S3board](https://wfjm.github.io/home/w11/inst/boards.html#digi_s3board)  |  RS232+USB-RS232 cable | 460k Baud    |    41 kB/sec |
