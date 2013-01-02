# $Id: README.txt 395 2011-07-17 22:02:55Z mueller $
#

The FX2 software is based on the Sourceforge project ixo-jtag

  http://sourceforge.net/projects/ixo-jtag/

The usb_jtag sub project was checked out on 2011-07-17 (Rev 204)
from Sourceforge and take as the basis for the further developement.
The original README.txt is preserved under README_iso_jtag.txt.
Only the hw_nexys.c branch is kept on the import.

Change log:

2011-07-17 (Rev 395)
  - Makefile: reorganized to support multiple target/fifo configs
  - renames: 
      dscr.a51->dscr_jtag.a51
      hw_nexys.c->hw_nexys2.c
      usbjtag.c->main.c
  - dscr_jtag.a51
    - Use USB 2.0; New string values
    - use 512 byte for all high speed endpoints
  - dscr_jtag_2fifo.a51
    - dscr with EP4 as HOST->FPGA and EP6 as FPGA->HOST hardware fifo
