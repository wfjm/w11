-- $Id: sys_w11a_n2.vhd 341 2010-11-27 23:05:43Z mueller $
--
-- Copyright 2010- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
-- This program is free software; you may redistribute and/or modify it under
-- the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 2, or at your option any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for complete details.
--
------------------------------------------------------------------------------
-- Module Name:    sys_w11a_n2 - syn
-- Description:    w11a test design for nexys2
--
-- Dependencies:   vlib/xlib/dcm_sp_sfs
--                 vlib/genlib/clkdivce
--                 bplib/s3board/s3_rs232_iob_int_ext
--                 bplib/s3board/s3_humanio_rri
--                 vlib/rri/rri_core_serport
--                 vlib/rri/rb_sres_or_3
--                 w11a/pdp11_core_rri
--                 w11a/pdp11_core
--                 w11a/pdp11_bram
--                 vlib/nexys2/n2_cram_dummy
--                 w11a/pdp11_cache
--                 w11a/pdp11_mem70
--                 bplib/nexys2/n2_cram_memctl
--                 ibus/ib_sres_or_2
--                 ibus/ibdr_minisys
--                 ibus/ibdr_maxisys
--                 w11a/pdp11_tmu_sb           [sim only]
--
-- Test bench:     tb/tb_s3board_w11a_n2
--
-- Target Devices: generic
-- Tool versions:  xst 8.2, 9.1, 9.2, 10.1, 11.4, 12.1; ghdl 0.26-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-11-06   336 12.1    M53d xc3s1200e-4 1357 4304* 242 2618 ok: LP+PC+DL+II
-- 2010-10-24   335 12.1    M53d xc3s1200e-4 1357 4546  242 2618 ok: LP+PC+DL+II
-- 2010-10-17   333 12.1    M53d xc3s1200e-4 1350 4541  242 2617 ok: LP+PC+DL+II
-- 2010-10-16   332 12.1    M53d xc3s1200e-4 1338 4545  242 2629 ok: LP+PC+DL+II
-- 2010-06-27   310 12.1    M53d xc3s1200e-4 1337 4307  242 2630 ok: LP+PC+DL+II
-- 2010-06-26   309 11.4    L68  xc3s1200e-4 1318 4293  242 2612 ok: LP+PC+DL+II
-- 2010-06-18   306 12.1    M53d xc3s1200e-4 1319 4300  242 2624 ok: LP+PC+DL+II
-- "            306 11.4    L68  xc3s1200e-4 1319 4286  242 2618 ok: LP+PC+DL+II
-- "            306 10.1.02 K39  xc3s1200e-4 1309 4311  242 2665 ok: LP+PC+DL+II
-- "            306  9.2.02 J40  xc3s1200e-4 1316 4259  242 2656 ok: LP+PC+DL+II
-- "            306  9.1    J30  xc3s1200e-4 1311 4260  242 2643 ok: LP+PC+DL+II
-- "            306  8.2.03 I34  xc3s1200e-4 1371 4394  242 2765 ok: LP+PC+DL+II
-- 2010-06-13   305 11.4    L68  xc3s1200e-4 1318 4360  242 2629 ok: LP+PC+DL+II
-- 2010-06-12   304 11.4    L68  xc3s1200e-4 1323 4201  242 2574 ok: LP+PC+DL+II
-- 2010-06-03   300 11.4    L68  xc3s1200e-4 1318 4181  242 2572 ok: LP+PC+DL+II
-- 2010-06-03   299 11.4    L68  xc3s1200e-4 1250 4071  224 2489 ok: LP+PC+DL+II
-- 2010-05-26   296 11.4    L68  xc3s1200e-4 1284 4079  224 2492 ok: LP+PC+DL+II
--   Note: till 2010-10-24 lutm included 'route-thru', after only logic
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-11-27   341   1.1.8  add DCM; new sys_conf consts for mem and clkdiv
-- 2010-11-13   338   1.1.7  add O_CLKSYS (for DCM derived system clock)
-- 2010-11-06   336   1.1.6  rename input pin CLK -> I_CLK50
-- 2010-10-23   335   1.1.5  rename RRI_LAM->RB_LAM;
-- 2010-06-26   309   1.1.4  use constants for rbus addresses (rbaddr_...)
--                           BUGFIX: resolve rbus address clash hio<->ibr
-- 2010-06-18   306   1.1.3  change proc_led sensitivity list to avoid xst warn;
--                           rename RB_ADDR->RB_ADDR_CORE, add RB_ADDR_IBUS;
--                           remove pdp11_ibdr_rri
-- 2010-06-13   305   1.1.2  add CP_ADDR, wire up pdp11_core_rri->pdp11_core
-- 2010-06-12   304   1.1.1  re-do LED driver logic (show cpu modes or cpurust)
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2010-06-03   300   1.0.2  use default FAWIDTH for rri_core_serport
--                           use s3_humanio_rri
-- 2010-05-30   297   1.0.1  put MEM_ACT_(R|W) on LED 6,7
-- 2010-05-28   295   1.0    Initial version (derived from sys_w11a_s3)
------------------------------------------------------------------------------
--
-- w11a test design for nexys2
--    w11a + rri + serport
--
-- Usage of Nexys 2 Switches, Buttons, LEDs:
--
--    SWI(0):   0 -> main board RS232 port
--              1 -> Pmod B/top RS232 port
--    
--    LED(0:4): if cpugo=1 show cpu mode activity
--                  (0) user mode
--                  (1) supervisor mode
--                  (2) kernel mode, wait
--                  (3) kernel mode, pri=0
--                  (4) kernel mode, pri>0
--              if cpugo=0 shows cpurust
--                (3:0) cpurust code
--                  (4) '1'
--         (5)  cmdbusy (all rri access, mostly rdma)
--         (6)  MEM_ACT_R
--         (7)  MEM_ACT_W
--
--    DP(0):    RXSD   (inverted to signal activity)
--    DP(1):    RTS_N  (shows rx back preasure)
--    DP(2):    TXSD   (inverted to signal activity)
--    DP(3):    CTS_N  (shows tx back preasure)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.xlib.all;
use work.genlib.all;
use work.rrilib.all;
use work.s3boardlib.all;
use work.nexys2lib.all;
use work.iblib.all;
use work.ibdlib.all;
use work.pdp11.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity sys_w11a_n2 is                   -- top level
                                        -- implements nexys2_fusp_aif
  port (
    I_CLK50 : in slbit;                 -- 50 MHz clock
    O_CLKSYS : out slbit;               -- DCM derived system clock
    I_RXD : in slbit;                   -- receive data (board view)
    O_TXD : out slbit;                  -- transmit data (board view)
    I_SWI : in slv8;                    -- s3 switches
    I_BTN : in slv4;                    -- s3 buttons
    O_LED : out slv8;                   -- s3 leds
    O_ANO_N : out slv4;                 -- 7 segment disp: anodes   (act.low)
    O_SEG_N : out slv8;                 -- 7 segment disp: segments (act.low)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N  : out slbit;           -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_FLA_CE_N : out slbit;             -- flash ce..          (act.low)
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16;          -- cram: data lines
    O_FUSP_RTS_N : out slbit;           -- fusp: rs232 rts_n
    I_FUSP_CTS_N : in slbit;            -- fusp: rs232 cts_n
    I_FUSP_RXD : in slbit;              -- fusp: rs232 rx
    O_FUSP_TXD : out slbit              -- fusp: rs232 tx
  );
end sys_w11a_n2;

architecture syn of sys_w11a_n2 is

  signal CLK :   slbit := '0';

  signal RXD :   slbit := '1';
  signal TXD :   slbit := '0';
  signal RTS_N : slbit := '0';
  signal CTS_N : slbit := '0';
    
  signal SWI     : slv8  := (others=>'0');
  signal BTN     : slv4  := (others=>'0');
  signal LED     : slv8  := (others=>'0');  
  signal DSP_DAT : slv16 := (others=>'0');
  signal DSP_DP  : slv4  := (others=>'0');

  signal RB_LAM  : slv16 := (others=>'0');
  signal RB_STAT : slv3  := (others=>'0');

  signal RB_MREQ     : rb_mreq_type := rb_mreq_init;
  signal RB_SRES     : rb_sres_type := rb_sres_init;
  signal RB_SRES_CPU : rb_sres_type := rb_sres_init;
  signal RB_SRES_IBD : rb_sres_type := rb_sres_init;
  signal RB_SRES_HIO : rb_sres_type := rb_sres_init;

  signal RESET   : slbit := '0';
  signal CE_USEC : slbit := '0';
  signal CE_MSEC : slbit := '0';

  signal CPU_RESET : slbit := '0';
  signal CP_CNTL : cp_cntl_type := cp_cntl_init;
  signal CP_ADDR : cp_addr_type := cp_addr_init;
  signal CP_DIN  : slv16 := (others=>'0');
  signal CP_STAT : cp_stat_type := cp_stat_init;
  signal CP_DOUT : slv16 := (others=>'0');

  signal EI_PRI  : slv3   := (others=>'0');
  signal EI_VECT : slv9_2 := (others=>'0');
  signal EI_ACKM : slbit  := '0';
  
  signal EM_MREQ : em_mreq_type := em_mreq_init;
  signal EM_SRES : em_sres_type := em_sres_init;
  
  signal HM_ENA      : slbit := '0';
  signal MEM70_FMISS : slbit := '0';
  signal CACHE_FMISS : slbit := '0';
  signal CACHE_CHIT  : slbit := '0';

  signal MEM_REQ   : slbit := '0';
  signal MEM_WE    : slbit := '0';
  signal MEM_BUSY  : slbit := '0';
  signal MEM_ACK_R : slbit := '0';
  signal MEM_ACT_R : slbit := '0';
  signal MEM_ACT_W : slbit := '0';
  signal MEM_ADDR  : slv20 := (others=>'0');
  signal MEM_BE    : slv4  := (others=>'0');
  signal MEM_DI    : slv32 := (others=>'0');
  signal MEM_DO    : slv32 := (others=>'0');

  signal MEM_ADDR_EXT : slv22 := (others=>'0');

  signal BRESET  : slbit := '0';
  signal IB_MREQ : ib_mreq_type := ib_mreq_init;
  signal IB_SRES : ib_sres_type := ib_sres_init;

  signal IB_SRES_MEM70 : ib_sres_type := ib_sres_init;
  signal IB_SRES_IBDR  : ib_sres_type := ib_sres_init;

  signal DM_STAT_DP : dm_stat_dp_type := dm_stat_dp_init;
  signal DM_STAT_VM : dm_stat_vm_type := dm_stat_vm_init;
  signal DM_STAT_CO : dm_stat_co_type := dm_stat_co_init;
  signal DM_STAT_SY : dm_stat_sy_type := dm_stat_sy_init;

  signal DISPREG : slv16 := (others=>'0');

  constant rbaddr_core0 : slv8 := "00000000";
  constant rbaddr_ibus  : slv8 := "10000000";
  constant rbaddr_hio   : slv8 := "11000000";

begin

  assert (sys_conf_clksys mod 1000000) = 0
    report "assert sys_conf_clksys on MHz grid"
    severity failure;
  
  DCM : dcm_sp_sfs
    generic map (
      CLKFX_DIVIDE   => sys_conf_clkfx_divide,
      CLKFX_MULTIPLY => sys_conf_clkfx_multiply,
      CLKIN_PERIOD   => 20.0)
    port map (
      CLKIN   => I_CLK50,
      CLKFX   => CLK,
      LOCKED  => open
    );

  O_CLKSYS <= CLK;

  CLKDIV : clkdivce
    generic map (
      CDUWIDTH => 6,
      USECDIV  => sys_conf_clksys_mhz,
      MSECDIV  => 1000)
    port map (
      CLK     => CLK,
      CE_USEC => CE_USEC,
      CE_MSEC => CE_MSEC
    );

  IOB_RS232 : s3_rs232_iob_int_ext
    port map (
      CLK      => CLK,
      SEL      => SWI(0),
      RXD      => RXD,
      TXD      => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      I_RXD0   => I_RXD,
      O_TXD0   => O_TXD,
      I_RXD1   => I_FUSP_RXD,
      O_TXD1   => O_FUSP_TXD,
      I_CTS1_N => I_FUSP_CTS_N,
      O_RTS1_N => O_FUSP_RTS_N
    );

  HIO : s3_humanio_rri
    generic map (
      DEBOUNCE => sys_conf_hio_debounce,
      RB_ADDR  => rbaddr_hio)
    port map (
      CLK     => CLK,
      RESET   => RESET,
      CE_MSEC => CE_MSEC,
      RB_MREQ => RB_MREQ,
      RB_SRES => RB_SRES_HIO,
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

  RRI : rri_core_serport
    generic map (
      ATOWIDTH =>  6,                   -- 64 cycles access timeout
      ITOWIDTH =>  6,                   -- 64 periods max idle timeout
      CDWIDTH  => 13,
      CDINIT   => sys_conf_ser2rri_cdinit)
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      CE_MSEC  => CE_MSEC,
      CE_INT   => CE_MSEC,
      RESET    => RESET,
      RXSD     => RXD,
      TXSD     => TXD,
      CTS_N    => CTS_N,
      RTS_N    => RTS_N,
      RB_MREQ  => RB_MREQ,
      RB_SRES  => RB_SRES,
      RB_LAM   => RB_LAM,
      RB_STAT  => RB_STAT
    );

  RB_SRES_OR : rb_sres_or_3
    port map (
      RB_SRES_1  => RB_SRES_CPU,
      RB_SRES_2  => RB_SRES_IBD,
      RB_SRES_3  => RB_SRES_HIO,
      RB_SRES_OR => RB_SRES
    );
  
  RB2CP : pdp11_core_rri
    generic map (
      RB_ADDR_CORE => rbaddr_core0,
      RB_ADDR_IBUS => rbaddr_ibus)
    port map (
      CLK       => CLK,
      RESET     => RESET,
      RB_MREQ   => RB_MREQ,
      RB_SRES   => RB_SRES_CPU,
      RB_STAT   => RB_STAT,
      RB_LAM    => RB_LAM(0),
      CPU_RESET => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT      
    );

  CORE : pdp11_core
    port map (
      CLK       => CLK,
      RESET     => CPU_RESET,
      CP_CNTL   => CP_CNTL,
      CP_ADDR   => CP_ADDR,
      CP_DIN    => CP_DIN,
      CP_STAT   => CP_STAT,
      CP_DOUT   => CP_DOUT,
      EI_PRI    => EI_PRI,
      EI_VECT   => EI_VECT,
      EI_ACKM   => EI_ACKM,
      EM_MREQ   => EM_MREQ,
      EM_SRES   => EM_SRES,
      BRESET    => BRESET,
      IB_MREQ_M => IB_MREQ,
      IB_SRES_M => IB_SRES,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO
    );  

  MEM_BRAM: if sys_conf_bram > 0 generate
    signal HM_VAL_BRAM : slbit := '0';
  begin
    
    MEM : pdp11_bram
      generic map (
        AWIDTH => sys_conf_bram_awidth)
      port map (
        CLK     => CLK,
        GRESET  => CPU_RESET,
        EM_MREQ => EM_MREQ,
        EM_SRES => EM_SRES
      );

    HM_VAL_BRAM <= not EM_MREQ.we;        -- assume hit if read, miss if write
      
    MEM70: pdp11_mem70
      port map (
        CLK         => CLK,
        CRESET      => BRESET,
        HM_ENA      => EM_MREQ.req,
        HM_VAL      => HM_VAL_BRAM,
        CACHE_FMISS => MEM70_FMISS,
        IB_MREQ     => IB_MREQ,
        IB_SRES     => IB_SRES_MEM70
      );

    SRAM_PROT : n2_cram_dummy            -- connect CRAM to protection dummy
      port map (
        O_MEM_CE_N  => O_MEM_CE_N,
        O_MEM_BE_N  => O_MEM_BE_N,
        O_MEM_WE_N  => O_MEM_WE_N,
        O_MEM_OE_N  => O_MEM_OE_N,
        O_MEM_ADV_N => O_MEM_ADV_N,
        O_MEM_CLK   => O_MEM_CLK,
        O_MEM_CRE   => O_MEM_CRE,
        I_MEM_WAIT  => I_MEM_WAIT,
        O_FLA_CE_N  => O_FLA_CE_N,
        O_MEM_ADDR  => O_MEM_ADDR,
        IO_MEM_DATA => IO_MEM_DATA
      );

  end generate MEM_BRAM;

  MEM_SRAM: if sys_conf_bram = 0 generate
    
    CACHE: pdp11_cache
      port map (
        CLK       => CLK,
        GRESET    => CPU_RESET,
        EM_MREQ   => EM_MREQ,
        EM_SRES   => EM_SRES,
        FMISS     => CACHE_FMISS,
        CHIT      => CACHE_CHIT,
        MEM_REQ   => MEM_REQ,
        MEM_WE    => MEM_WE,
        MEM_BUSY  => MEM_BUSY,
        MEM_ACK_R => MEM_ACK_R,
        MEM_ADDR  => MEM_ADDR,
        MEM_BE    => MEM_BE,
        MEM_DI    => MEM_DI,
        MEM_DO    => MEM_DO
      );

    MEM70: pdp11_mem70
      port map (
        CLK         => CLK,
        CRESET      => BRESET,
        HM_ENA      => HM_ENA,
        HM_VAL      => CACHE_CHIT,
        CACHE_FMISS => MEM70_FMISS,
        IB_MREQ     => IB_MREQ,
        IB_SRES     => IB_SRES_MEM70
      );

    HM_ENA      <= EM_SRES.ack_r or EM_SRES.ack_w;
    CACHE_FMISS <= MEM70_FMISS or sys_conf_cache_fmiss;

    MEM_ADDR_EXT <= "00" & MEM_ADDR;    -- just use lower 4 MB (of 16 MB)

    SRAM_CTL: n2_cram_memctl_as
      generic map (
        READ0DELAY => sys_conf_memctl_read0delay,
        READ1DELAY => sys_conf_memctl_read1delay,
        WRITEDELAY => sys_conf_memctl_writedelay)
      port map (
        CLK         => CLK,
        RESET       => CPU_RESET,
        REQ         => MEM_REQ,
        WE          => MEM_WE,
        BUSY        => MEM_BUSY,
        ACK_R       => MEM_ACK_R,
        ACK_W       => open,
        ACT_R       => MEM_ACT_R,
        ACT_W       => MEM_ACT_W,
        ADDR        => MEM_ADDR_EXT,
        BE          => MEM_BE,
        DI          => MEM_DI,
        DO          => MEM_DO,
        O_MEM_CE_N  => O_MEM_CE_N,
        O_MEM_BE_N  => O_MEM_BE_N,
        O_MEM_WE_N  => O_MEM_WE_N,
        O_MEM_OE_N  => O_MEM_OE_N,
        O_MEM_ADV_N => O_MEM_ADV_N,
        O_MEM_CLK   => O_MEM_CLK,
        O_MEM_CRE   => O_MEM_CRE,
        I_MEM_WAIT  => I_MEM_WAIT,
        O_FLA_CE_N  => O_FLA_CE_N,
        O_MEM_ADDR  => O_MEM_ADDR,
        IO_MEM_DATA => IO_MEM_DATA
      );
    
  end generate MEM_SRAM;
  
  IB_SRES_OR : ib_sres_or_2
    port map (
      IB_SRES_1  => IB_SRES_MEM70,
      IB_SRES_2  => IB_SRES_IBDR,
      IB_SRES_OR => IB_SRES
    );

  IBD_MINI : if false generate
  begin
    IBDR_SYS : ibdr_minisys
      port map (
        CLK      => CLK,
        CE_USEC  => CE_USEC,
        CE_MSEC  => CE_MSEC,
        RESET    => CPU_RESET,
        BRESET   => BRESET,
        RB_LAM   => RB_LAM(15 downto 1),
        IB_MREQ  => IB_MREQ,
        IB_SRES  => IB_SRES_IBDR,
        EI_ACKM  => EI_ACKM,
        EI_PRI   => EI_PRI,
        EI_VECT  => EI_VECT,
        DISPREG  => DISPREG
      );
  end generate IBD_MINI;
  
  IBD_MAXI : if true generate
  begin
    IBDR_SYS : ibdr_maxisys
      port map (
        CLK      => CLK,
        CE_USEC  => CE_USEC,
        CE_MSEC  => CE_MSEC,
        RESET    => CPU_RESET,
        BRESET   => BRESET,
        RB_LAM   => RB_LAM(15 downto 1),
        IB_MREQ  => IB_MREQ,
        IB_SRES  => IB_SRES_IBDR,
        EI_ACKM  => EI_ACKM,
        EI_PRI   => EI_PRI,
        EI_VECT  => EI_VECT,
        DISPREG  => DISPREG
      );
  end generate IBD_MAXI;
    
  DSP_DAT(15 downto 0) <= DISPREG;
  DSP_DP(0) <= not RXD;
  DSP_DP(1) <= RTS_N;
  DSP_DP(2) <= not TXD;
  DSP_DP(3) <= CTS_N;

  proc_led: process (MEM_ACT_W, MEM_ACT_R, CP_STAT, DM_STAT_DP.psw)
    variable iled : slv8 := (others=>'0');
  begin
    iled := (others=>'0');
    iled(7) := MEM_ACT_W;
    iled(6) := MEM_ACT_R;
    iled(5) := CP_STAT.cmdbusy;
    if CP_STAT.cpugo = '1' then
      case DM_STAT_DP.psw.cmode is
        when c_psw_kmode =>
          if CP_STAT.cpuwait = '1' then
            iled(2) := '1';
          elsif unsigned(DM_STAT_DP.psw.pri) = 0 then
            iled(3) := '1';
          else
            iled(4) := '1';
          end if;
        when c_psw_smode =>
          iled(1) := '1';
        when c_psw_umode =>
          iled(0) := '1';
        when others => null;
      end case;
    else
      iled(4) := '1';
      iled(3 downto 0) := CP_STAT.cpurust;
    end if;
    LED <= iled;
  end process;
      
-- synthesis translate_off
  DM_STAT_SY.emmreq <= EM_MREQ;
  DM_STAT_SY.emsres <= EM_SRES;
  DM_STAT_SY.chit   <= CACHE_CHIT;
  
  TMU : pdp11_tmu_sb
    generic map (
      ENAPIN => 13)
    port map (
      CLK        => CLK,
      DM_STAT_DP => DM_STAT_DP,
      DM_STAT_VM => DM_STAT_VM,
      DM_STAT_CO => DM_STAT_CO,
      DM_STAT_SY => DM_STAT_SY
    );
-- synthesis translate_on
  
end syn;
