-- $Id: sys_tst_sram_s3.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2016 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    sys_tst_sram_s3 - syn
-- Description:    test of s3board sram and its controller
--
-- Dependencies:   vlib/genlib/clkdivce
--                 bplib/bpgen/bp_rs232_2line_iob
--                 bplib/bpgen/sn_humanio
--                 vlib/rlink/rlink_sp1c
--                 tst_sram
--                 bplib/s3board/s3_sram_memctl
--
-- Test bench:     tb/tb_tst_sram_s3
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; ghdl 0.18-0.33
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2014-12-20   614 14.7  131013 xc3s1000-4   816 1801   96 1135 t 18.3 ns
-- 2014-08-13   581 14.7  131013 xc3s1000-4   664 1433   64  899 t 16.3 ns
-- 2011-12-21   352 12.1    M53d xc3s1000-4   664 1433   64  898 p 17.1 ns
-- 2010-12-31   352 12.1    M53d xc3s200-4    644 1366   36  856 p 14.6 ns
-- 2010-11-06   336 12.1    M53d xc3s200-4    605 1334   36  824 p 14.6 ns
-- 2010-05-21   291 11.4    L68  xc3s200-4    600 1301   18  795 p 16.6 ns
-- 2010-05-16   291 11.4    L68  xc3s200-4    594 1273   18  764 p 15.3 ns
-- 2010-04-04   274 11.4    L68  xc3s200-4    607 1303   18  807 p 14.2 ns
-- 2009-11-14   249 11.2    L46  xc3s1000-4   603 1340   18  795 p 18.8 ns
-- 2009-11-08   248 11.2    L46  xc3s1000-4   594 1329   18  771 p 15.4 ns
-- 2009-11-08   248  8.2.3  I34  xc3s1000-4   616 1320   18  805 p 16.3 ns
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2016-07-10   785   2.3.4  SWI(1) now XON
-- 2016-07-09   784   2.3.3  tst_sram with AWIDTH and 22bit support
-- 2016-03-19   748   2.3.2  define rlink SYSID
-- 2015-04-11   666   2.3.1  rearrange XON handling
-- 2014-08-28   588   2.3    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   2.2    rb_mreq addr now 16 bit
-- 2011-12-21   442   2.1.4  use rlink_sp1c
-- 2011-11-21   432   2.1.3  now numeric_std clean
-- 2011-07-08   390   2.1.2  use now sn_humanio
-- 2011-07-02   387   2.1.1  use bp_rs232_2line_iob now
-- 2010-12-31   352   2.1    port to rbv3
-- 2010-11-06   336   2.0.5  rename input pin CLK -> I_CLK50
-- 2010-10-23   335   2.0.4  rename RRI_LAM->RB_LAM;
-- 2010-06-03   300   2.0.3  use default FAWIDTH for rri_core_serport
-- 2010-05-32   294   2.0.2  rename sys_tst_sram -> sys_tst_sram_s3
-- 2010-05-21   292   2.0.1  move memory controller to top level entity
-- 2010-05-16   291   2.0    move tester code to tst_sram; use s3_rs232_iob_int
-- 2010-05-02   287   1.1.6  ren CE_XSEC->CE_INT,RP_STAT->RB_STAT,AP_LAM->RB_LAM
--                           drop RP_IINT from interfaces; drop RTSFLUSH generic
-- 2010-05-01   286   1.1.5  set RTSFLUSH=>false till tested; rri_a_ -> rbaddr_
-- 2010-04-24   281   1.1.4  mv from vlib/s3board/sys/sys_s3board_memtest.vhd
-- 2010-04-18   279   1.1.3  drop RTSFBUF generic for rri_serport
-- 2010-04-10   275   1.1.2  use s3_humanio, rri_core_serport;
-- 2010-04-04   274   1.1.1  add CE_USEC, CP_FLUSH, CTS_N, RTS_N signals
-- 2009-11-14   249   1.1    ported to rri V2 rb_mreq/rb_sres interface; cleaner
--                           rbus logic, should work with 2nd rbus device
-- 2008-02-17   117   1.0.5  use req,we rather req_r,req_w interface
-- 2008-01-20   113   1.0.4  rename memdrv->memctl_s3sram
-- 2008-01-20   112   1.0.3  rename clkgen->clkdivce
-- 2007-12-24   105   1.0.2  now fully implemented
-- 2007-12-22   104   1.0.1  finish mblk, add smem and sblk.
-- 2007-12-20   103   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.genlib.all;
use work.serportlib.all;
use work.rblib.all;
use work.rlinklib.all;
use work.bpgenlib.all;
use work.s3boardlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_tst_sram_s3 is               -- top level
                                        -- implements s3board_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz board clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slv2;              -- sram: chip enables  (act.low)
    O_MEM_BE_N : out slv4;              -- sram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- sram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- sram: output enable (act.low)
    O_MEM_ADDR  : out slv18;            -- sram: address lines
    IO_MEM_DATA : inout slv32           -- sram: data lines
  );
end sys_tst_sram_s3;

architecture syn of sys_tst_sram_s3 is
  
  signal CLK :   slbit := '0';

  signal CE_USEC :  slbit := '0';
  signal CE_MSEC :  slbit := '0';

  signal GBL_RESET : slbit := '0';
  
  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal CTS_N : slbit := '0';
  signal RTS_N : slbit := '0';

  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RB_MREQ : rb_mreq_type := rb_mreq_init;
  signal RB_SRES : rb_sres_type := rb_sres_init;
  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv4 := (others=>'0');
  
  signal SER_MONI : serport_moni_type := serport_moni_init;

  signal RB_SRES_TST : rb_sres_type := rb_sres_init;
  signal RB_LAM_TST  : slbit := '0';

  signal MEM_RESET : slbit := '0';
  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACK_W : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv18 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  constant sysid_proj  : slv16 := x"0104";   -- tst_sram
  constant sysid_board : slv8  := x"01";     -- s3board
  constant sysid_vers  : slv8  := x"00";

begin

  CLK <= I_CLK50;                       -- use 50MHz as system clock

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => 50,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : bp_rs232_2line_iob
    port map (
      CLK   => CLK,
      RXD   => RXD,
      TXD   => TXD,
      I_RXD => I_RXD,
      O_TXD => O_TXD
    );

  HIO : sn_humanio
    port map (
      CLK     => CLK,
      RESET   => '0',
      CE_MSEC => CE_MSEC,
      SWI     => SWI,
      BTN     => BTN,
      LED     => LED,
      DSP_DAT => DSP_DAT,
      DSP_DP  => DSP_DP,
      I_SWI   => I_SWI,
      I_BTN   => I_BTN,
      O_LED   => O_LED,
      O_ANO_N => O_ANO_N,
      O_SEG_N => O_SEG_N
    );

  RLINK : rlink_sp1c
    generic map (
      BTOWIDTH     => 6,                --  64 cycles access timeout
      RTAWIDTH     => 12,
      SYSID        => (others=>'0'),
      IFAWIDTH     => 5,                --  32 word input fifo
      OFAWIDTH     => 5,                --  32 word output fifo
      ENAPIN_RLMON => sbcntl_sbf_rlmon,
      ENAPIN_RBMON => sbcntl_sbf_rbmon,
      CDWIDTH      => 13,
      CDINIT       => sys_conf_ser2rri_cdinit,
      RBMON_AWIDTH => 0,
      RBMON_RBADDR => x"ffe8")
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => GBL_RESET,
      ENAXON   => SWI(1),
      ESCFILL  => '0',
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT,
      RL_MONI  => open,
      SER_MONI => SER_MONI
    );

  TST : entity work.tst_sram
    generic map (
      RB_ADDR => slv(to_unsigned(2#0000000000000000#,16)),
      AWIDTH  => 18)
    port map (
      CLK       => CLK,
      RESET     => GBL_RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_TST,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM_TST,
      SWI       => SWI,
      BTN       => BTN,
      LED       => LED,
      DSP_DAT   => DSP_DAT,
      MEM_RESET => MEM_RESET,
      MEM_REQ   => MEM_REQ,
      MEM_WE    => MEM_WE,
      MEM_BUSY  => MEM_BUSY,
      MEM_ACK_R => MEM_ACK_R,
      MEM_ACK_W => MEM_ACK_W,
      MEM_ACT_R => MEM_ACT_R,
      MEM_ACT_W => MEM_ACT_W,
      MEM_ADDR  => MEM_ADDR,
      MEM_BE    => MEM_BE,
      MEM_DI    => MEM_DI,
      MEM_DO    => MEM_DO
    );

  SRAMCTL : s3_sram_memctl
    port map (
      CLK     => CLK,
      RESET   => MEM_RESET,
      REQ     => MEM_REQ,
      WE      => MEM_WE,
      BUSY    => MEM_BUSY,
      ACK_R   => MEM_ACK_R,
      ACK_W   => MEM_ACK_W,
      ACT_R   => MEM_ACT_R,
      ACT_W   => MEM_ACT_W,
      ADDR    => MEM_ADDR,
      BE      => MEM_BE,
      DI      => MEM_DI,
      DO      => MEM_DO,
      O_MEM_CE_N  => O_MEM_CE_N,
      O_MEM_BE_N  => O_MEM_BE_N,
      O_MEM_WE_N  => O_MEM_WE_N,
      O_MEM_OE_N  => O_MEM_OE_N,
      O_MEM_ADDR  => O_MEM_ADDR,
      IO_MEM_DATA => IO_MEM_DATA
    );

  RB_SRES   <= RB_SRES_TST;             -- can be sres_or later...
  RB_LAM(0) <= RB_LAM_TST;
  
  DSP_DP(3) <= not SER_MONI.txok;
  DSP_DP(2) <= SER_MONI.txact;
  DSP_DP(1) <= not SER_MONI.rxok;
  DSP_DP(0) <= SER_MONI.rxact;
  
end syn;

