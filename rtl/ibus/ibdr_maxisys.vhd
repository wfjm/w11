-- $Id: ibdr_maxisys.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2009-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ibdr_maxisys - syn
-- Description:    ibus(rem) devices for full system
--
-- Dependencies:   ib_rlim_gen
--                 ibd_iist
--                 ibd_kw11l
--                 ibd_kw11p
--                 ibdr_deuna
--                 ibdr_rhrp
--                 ibdr_rl11
--                 ibdr_rk11
--                 ibdr_tm11
--                 ibdr_dl11
--                 ibdr_dl11_buf
--                 ibdr_dz11
--                 ibdr_pc11
--                 ibdr_pc11_buf
--                 ibdr_lp11
--                 ibdr_lp11_buf
--                 ibd_m9312
--                 ibdr_sdreg
--                 ib_sres_or_4
--                 ib_sres_or_3
--                 ib_intmap24
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2018.3; ghdl 0.18-0.35
--
-- Synthesized:
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2018-10-13  1055 14.7  131013 xc6slx16-2   774 1720   30  584 s  8.5 +KW11P
-- 2017-01-29   847 14.7  131013 xc6slx16-2   712 1628   30  599 s  8.5 +DEUNA
-- 2017-01-28   846 14.7  131013 xc6slx16-2   668 1562   30  577 s  8.5 intmap24
-- 2017-01-28   683 viv 2016.4   xc7a100t-1   683 1684   48    - -           
-- 2017-01-28   683 14.7  131013 xc6slx16-2   668 1557   30  576 s  8.5 +TM11
-- 2015-04-06   664 14.7  131013 xc6slx16-2   559 1068   29  410 s  9.1 +RHRP
-- 2015-01-04   630 14.7  131013 xc6slx16-2   388  761   20  265 s  8.0 +RL11
-- 2014-06-08   560 14.7  131013 xc6slx16-2   311  615    8  216 s  7.1
-- 2010-10-17   333 12.1    M53d xc3s1000-4   312 1058   16  617 s 10.3
-- 2010-10-17   314 12.1    M53d xc3s1000-4   300 1094   16  626 s 10.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-05-04  1146   1.6.9  add ibdr_dz11
-- 2019-04-28  1142   1.6.8  add ibd_m9312
-- 2019-04-26  1139   1.6.7  add ibdr_dl11_buf
-- 2019-04-23  1136   1.6.6  add CLK port to ib_intmap24
-- 2019-04-14  1131   1.6.5  ib_rlim_gen has CPUSUSP port; RLIM_CEV now slv8
-- 2019-04-07  1129   1.6.4  add ibdr_pc11_buf
-- 2019-04-07  1127   1.6.3  ibdr_dl11: use RLIM_CEV, drop CE_USEC
-- 2019-03-17  1123   1.6.2  add ib_rlim_gen, use with ibdr_lp11_buf
-- 2019-03-09  1121   1.6.1  add ibdr_lp11_buf
-- 2019-02-10  1111   1.6    use typ for DL,PC,LP
-- 2019-01-29  1108   1.5.1  move IIST signals into generate
-- 2018-10-13  1055   1.5    add IDEC port, connect to EXTEVT of KW11P
-- 2018-09-08  1043   1.4.2  add KW11P;
-- 2017-01-29   847   1.4.1  add DEUNA; rename generic labels
-- 2017-01-28   846   1.4    use ib_intmap24
-- 2015-05-15   683   1.3.1  add TM11
-- 2015-05-10   678   1.3    start/stop/suspend overhaul
-- 2015-04-06   664   1.2.3  rename RPRM to RHRP
-- 2015-03-14   658   1.2.2  add RPRM; rearrange intmap (+rhrp,tm11,-kw11-p)
--                           use sys_conf, make most devices configurable
-- 2015-01-04   630   1.2.1  RL11 back in
-- 2014-06-27   565   1.2.1  temporarily hide RL11
-- 2014-06-08   561   1.2    add RL11
-- 2011-11-18   427   1.1.2  now numeric_std clean
-- 2010-10-23   335   1.1.1  rename RRI_LAM->RB_LAM
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.4  reorder ports; add RESET, CE_USEC to _dl11
-- 2009-06-20   227   1.0.3  rename generate labels
-- 2009-06-07   224   1.0.2  add iist_mreq and iist_sres interfaces
-- 2009-06-01   221   1.0.1  add CE_USEC; add RESET to kw11l; add _pc11, _iist
-- 2009-05-24   219   1.0    Initial version
------------------------------------------------------------------------------
-- 
-- 
-- full system setup
--
-- ibbase  vec  pri  slot attn  sror device name
--
-- 172540  104    6    17    -  1/1  KW11-P
-- 177500  260    6 15 16    -  1/2  IIST
-- 177546  100    6 14 15    -  1/3  KW11-L
-- 174510  120    5    14    9  1/4  DEUNA
-- 176700  254    5 13 13    6  2/1  RHRP
-- 174400  160    5 12 12    5  2/2  RL11
-- 177400  220    5 11 11    4  2/3  RK11
-- 172520  224    5 10 10    7  2/4  TM11
-- 160100  310    5  9  9    3  3/1  DZ11-RX
--         314    5  8  8    ^       DZ11-TX
-- 177560  060    4  7  7    1  3/2  DL11-RX  1st
--         064    4  6  6    ^       DL11-TX  1st
-- 176500  300    4  5  5    2  3/3  DL11-RX  2nd
--         304    4  4  4    ^       DL11-TX  2nd
-- 177550  070    4  3  3   10  4/1  PC11/PTR
--         074    4  2  2    ^       PC11/PTP
-- 177514  200    4  1  1    8  4/2  LP11
-- 177570    -    -     -    -  4/3  sdreg
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;
use work.ibdlib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------
entity ibdr_maxisys is                  -- ibus(rem) full system
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- reset
    BRESET : in slbit;                  -- ibus reset
    ITIMER : in slbit;                  -- instruction timer
    IDEC : in slbit;                    -- instruction decode
    CPUSUSP : in slbit;                 -- cpu suspended
    RB_LAM : out slv16_1;               -- remote attention vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_PRI : out slv3;                  -- interrupt priority (to cpu)
    EI_VECT : out slv9_2;               -- interrupt vector   (to cpu)
    DISPREG : out slv16                 -- display register
  );
end ibdr_maxisys;

architecture syn of ibdr_maxisys is

  constant ibaddr_dl11_1 : slv16 := slv(to_unsigned(8#176500#,16));
  constant ibaddr_dz11   : slv16 := slv(to_unsigned(8#160100#,16));
  
  constant conf_intmap24 : intmap24_array_type :=
    (intmap_init,                       -- line 23  (unused)
     intmap_init,                       -- line 22  (unused)
     intmap_init,                       -- line 21  (unused)
     intmap_init,                       -- line 20  (unused)
     intmap_init,                       -- line 19  (unused)
     intmap_init,                       -- line 18  (unused)
     (8#104#,6),                        -- line 17  KW11-P
     (8#260#,6),                        -- line 16  IIST
     (8#100#,6),                        -- line 15  KW11-L
     (8#120#,5),                        -- line 14  DENUA
     (8#254#,5),                        -- line 13  RHRP
     (8#160#,5),                        -- line 12  RL11
     (8#220#,5),                        -- line 11  RK11
     (8#224#,5),                        -- line 10  TM11
     (8#310#,5),                        -- line  9  DZ11-RX
     (8#314#,5),                        -- line  8  DZ11-TX
     (8#060#,4),                        -- line  7  DL11-RX 1st
     (8#064#,4),                        -- line  6  DL11-TX 1st
     (8#300#,4),                        -- line  5  DL11-RX 2nd
     (8#304#,4),                        -- line  4  DL11-TX 2nd
     (8#070#,4),                        -- line  3  PC11-PTR
     (8#074#,4),                        -- line  2  PC11-PTP
     (8#200#,4),                        -- line  1  LP11
     intmap_init                        -- line  0  (must be unused!)
    );

  signal RB_LAM_DEUNA  : slbit := '0';
  signal RB_LAM_RHRP   : slbit := '0';
  signal RB_LAM_RL11   : slbit := '0';
  signal RB_LAM_RK11   : slbit := '0';
  signal RB_LAM_TM11   : slbit := '0';
  signal RB_LAM_DL11_0 : slbit := '0';
  signal RB_LAM_DL11_1 : slbit := '0';
  signal RB_LAM_DZ11   : slbit := '0';
  signal RB_LAM_PC11   : slbit := '0';
  signal RB_LAM_LP11   : slbit := '0';

  signal IB_SRES_IIST   : ib_sres_type := ib_sres_init;
  signal IB_SRES_KW11P  : ib_sres_type := ib_sres_init;
  signal IB_SRES_KW11L  : ib_sres_type := ib_sres_init;
  signal IB_SRES_DEUNA  : ib_sres_type := ib_sres_init;
  signal IB_SRES_RHRP   : ib_sres_type := ib_sres_init;
  signal IB_SRES_RL11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_RK11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_TM11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_DL11_0 : ib_sres_type := ib_sres_init;
  signal IB_SRES_DL11_1 : ib_sres_type := ib_sres_init;
  signal IB_SRES_DZ11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_PC11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_LP11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_M9312  : ib_sres_type := ib_sres_init;
  signal IB_SRES_SDREG  : ib_sres_type := ib_sres_init;

  signal IB_SRES_1      : ib_sres_type := ib_sres_init;
  signal IB_SRES_2      : ib_sres_type := ib_sres_init;
  signal IB_SRES_3      : ib_sres_type := ib_sres_init;
  signal IB_SRES_4      : ib_sres_type := ib_sres_init;
  
  signal EI_REQ  : slv24_1 := (others=>'0');
  signal EI_ACK  : slv24_1 := (others=>'0');

  signal EI_REQ_IIST     : slbit := '0';
  signal EI_REQ_KW11P    : slbit := '0';
  signal EI_REQ_KW11L    : slbit := '0';
  signal EI_REQ_DEUNA    : slbit := '0';
  signal EI_REQ_RHRP     : slbit := '0';
  signal EI_REQ_RL11     : slbit := '0';
  signal EI_REQ_RK11     : slbit := '0';
  signal EI_REQ_TM11     : slbit := '0';
  signal EI_REQ_DL11RX_0 : slbit := '0';
  signal EI_REQ_DL11TX_0 : slbit := '0';
  signal EI_REQ_DL11RX_1 : slbit := '0';
  signal EI_REQ_DL11TX_1 : slbit := '0';
  signal EI_REQ_DZ11RX   : slbit := '0';
  signal EI_REQ_DZ11TX   : slbit := '0';
  signal EI_REQ_PC11PTR  : slbit := '0';
  signal EI_REQ_PC11PTP  : slbit := '0';
  signal EI_REQ_LP11     : slbit := '0';
  
  signal EI_ACK_IIST     : slbit := '0';
  signal EI_ACK_KW11P    : slbit := '0';
  signal EI_ACK_KW11L    : slbit := '0';
  signal EI_ACK_DEUNA    : slbit := '0';
  signal EI_ACK_RHRP     : slbit := '0';
  signal EI_ACK_RL11     : slbit := '0';
  signal EI_ACK_RK11     : slbit := '0';
  signal EI_ACK_TM11     : slbit := '0';
  signal EI_ACK_DL11RX_0 : slbit := '0';
  signal EI_ACK_DL11TX_0 : slbit := '0';
  signal EI_ACK_DL11RX_1 : slbit := '0';
  signal EI_ACK_DL11TX_1 : slbit := '0';
  signal EI_ACK_DZ11RX   : slbit := '0';
  signal EI_ACK_DZ11TX   : slbit := '0';
  signal EI_ACK_PC11PTR  : slbit := '0';
  signal EI_ACK_PC11PTP  : slbit := '0';
  signal EI_ACK_LP11     : slbit := '0';
  
  signal RLIM_CEV : slv8 := (others=>'0');

begin

  RLIM : ib_rlim_gen
    port map (
      CLK      => CLK,
      CE_USEC  => CE_USEC,
      RESET    => '0',
      CPUSUSP  => CPUSUSP,
      RLIM_CEV => RLIM_CEV
    );

  IIST: if sys_conf_ibd_iist generate
    signal IIST_BUS        : iist_bus_type := iist_bus_init;
    signal IIST_OUT_0      : iist_line_type := iist_line_init;
    signal IIST_MREQ       : iist_mreq_type := iist_mreq_init;
    signal IIST_SRES       : iist_sres_type := iist_sres_init;
  begin
    I0 : ibd_iist
      port map (
        CLK       => CLK,
        CE_USEC   => CE_USEC,
        RESET     => RESET,
        BRESET    => BRESET,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_IIST,
        EI_REQ    => EI_REQ_IIST,
        EI_ACK    => EI_ACK_IIST,
        IIST_BUS  => IIST_BUS,
        IIST_OUT  => IIST_OUT_0,
        IIST_MREQ => IIST_MREQ,
        IIST_SRES => IIST_SRES
      );
    
    IIST_BUS(0) <= IIST_OUT_0;
    IIST_BUS(1) <= iist_line_init;
    IIST_BUS(2) <= iist_line_init;
    IIST_BUS(3) <= iist_line_init;
    
  end generate IIST;

  KW11L : ibd_kw11l
    port map (
      CLK     => CLK,
      CE_MSEC => CE_MSEC,
      RESET   => RESET,
      BRESET  => BRESET,
      CPUSUSP => CPUSUSP,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_KW11L,
      EI_REQ  => EI_REQ_KW11L,
      EI_ACK  => EI_ACK_KW11L
    );

  KW11P: if sys_conf_ibd_kw11p generate
  begin
    I0 : ibd_kw11p
      port map (
        CLK     => CLK,
        CE_USEC => CE_USEC,
        CE_MSEC => CE_MSEC,
        RESET   => RESET,
        BRESET  => BRESET,
        EXTEVT  => IDEC,
        CPUSUSP => CPUSUSP,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_KW11P,
        EI_REQ  => EI_REQ_KW11P,
        EI_ACK  => EI_ACK_KW11P
      );
  end generate KW11P;

  DEUNA: if sys_conf_ibd_deuna generate
  begin
    XUA : ibdr_deuna
      port map (
        CLK     => CLK,
        BRESET  => BRESET,
        RB_LAM  => RB_LAM_DEUNA,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_DEUNA,
        EI_REQ  => EI_REQ_DEUNA,
        EI_ACK  => EI_ACK_DEUNA
      );
  end generate DEUNA;

  RHRP: if sys_conf_ibd_rhrp generate
  begin
    RPA : ibdr_rhrp
      port map (
        CLK     => CLK,
        CE_USEC => CE_USEC,
        BRESET  => BRESET,
        ITIMER  => ITIMER,
        RB_LAM  => RB_LAM_RHRP,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_RHRP,
        EI_REQ  => EI_REQ_RHRP,
        EI_ACK  => EI_ACK_RHRP
      );
  end generate RHRP;

  RL11: if sys_conf_ibd_rl11 generate
  begin
    RLA : ibdr_rl11
      port map (
        CLK     => CLK,
        CE_MSEC => CE_MSEC,
        BRESET  => BRESET,
        RB_LAM  => RB_LAM_RL11,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_RL11,
        EI_REQ  => EI_REQ_RL11,
        EI_ACK  => EI_ACK_RL11
      );
  end generate RL11;

  RK11: if sys_conf_ibd_rk11 generate
  begin
    RKA : ibdr_rk11
      port map (
        CLK     => CLK,
        CE_MSEC => CE_MSEC,
        BRESET  => BRESET,
        RB_LAM  => RB_LAM_RK11,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_RK11,
        EI_REQ  => EI_REQ_RK11,
        EI_ACK  => EI_ACK_RK11
      );
  end generate RK11;

  TM11: if sys_conf_ibd_tm11 generate
  begin
    TMA : ibdr_tm11
      port map (
        CLK     => CLK,
        BRESET  => BRESET,
        RB_LAM  => RB_LAM_TM11,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_TM11,
        EI_REQ  => EI_REQ_TM11,
        EI_ACK  => EI_ACK_TM11
      );
  end generate TM11;

  DL11_0: if sys_conf_ibd_dl11_0 = 0 generate
    TTA : ibdr_dl11
      port map (
        CLK       => CLK,
        RESET     => RESET,
        BRESET    => BRESET,
        RLIM_CEV  => RLIM_CEV,
        RB_LAM    => RB_LAM_DL11_0,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DL11_0,
        EI_REQ_RX => EI_REQ_DL11RX_0,
        EI_REQ_TX => EI_REQ_DL11TX_0,
        EI_ACK_RX => EI_ACK_DL11RX_0,
        EI_ACK_TX => EI_ACK_DL11TX_0
      );
  end generate DL11_0;
  
  DL11_0BUF: if sys_conf_ibd_dl11_0 > 0 generate
    TTA : ibdr_dl11_buf
      generic map (
        AWIDTH  => sys_conf_ibd_dl11_0)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        BRESET    => BRESET,
        RLIM_CEV  => RLIM_CEV,
        RB_LAM    => RB_LAM_DL11_0,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DL11_0,
        EI_REQ_RX => EI_REQ_DL11RX_0,
        EI_REQ_TX => EI_REQ_DL11TX_0,
        EI_ACK_RX => EI_ACK_DL11RX_0,
        EI_ACK_TX => EI_ACK_DL11TX_0
      );
  end generate DL11_0BUF;
  
  DL11_1: if sys_conf_ibd_dl11_1 = 0 generate
  begin
    TTB : ibdr_dl11
      generic map (
        IB_ADDR   => ibaddr_dl11_1)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        BRESET    => BRESET,
        RLIM_CEV  => RLIM_CEV,
        RB_LAM    => RB_LAM_DL11_1,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DL11_1,
        EI_REQ_RX => EI_REQ_DL11RX_1,
        EI_REQ_TX => EI_REQ_DL11TX_1,
        EI_ACK_RX => EI_ACK_DL11RX_1,
        EI_ACK_TX => EI_ACK_DL11TX_1
      );
  end generate DL11_1;

  DL11_1BUF: if sys_conf_ibd_dl11_1 > 0 generate
  begin
    TTB : ibdr_dl11_buf
      generic map (
        IB_ADDR => ibaddr_dl11_1,
        AWIDTH  => sys_conf_ibd_dl11_1)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        BRESET    => BRESET,
        RLIM_CEV  => RLIM_CEV,
        RB_LAM    => RB_LAM_DL11_1,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DL11_1,
        EI_REQ_RX => EI_REQ_DL11RX_1,
        EI_REQ_TX => EI_REQ_DL11TX_1,
        EI_ACK_RX => EI_ACK_DL11RX_1,
        EI_ACK_TX => EI_ACK_DL11TX_1
      );
  end generate DL11_1BUF;

  DZ11: if sys_conf_ibd_dz11 > 0 generate
    DZA : ibdr_dz11
      generic map (
        IB_ADDR   => ibaddr_dz11,
        AWIDTH  => sys_conf_ibd_dz11)
      port map (
        CLK       => CLK,
        RESET     => RESET,
        BRESET    => BRESET,
        RLIM_CEV  => RLIM_CEV,
        RB_LAM    => RB_LAM_DZ11,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DZ11,
        EI_REQ_RX => EI_REQ_DZ11RX,
        EI_REQ_TX => EI_REQ_DZ11TX,
        EI_ACK_RX => EI_ACK_DZ11RX,
        EI_ACK_TX => EI_ACK_DZ11TX
      );
  end generate DZ11;

  PC11: if sys_conf_ibd_pc11 = 0 generate
  begin
    PCA : ibdr_pc11
      port map (
        CLK        => CLK,
        RESET      => RESET,
        BRESET     => BRESET,
        RB_LAM     => RB_LAM_PC11,
        IB_MREQ    => IB_MREQ,
        IB_SRES    => IB_SRES_PC11,
        EI_REQ_PTR => EI_REQ_PC11PTR,
        EI_REQ_PTP => EI_REQ_PC11PTP,
        EI_ACK_PTR => EI_ACK_PC11PTR,
        EI_ACK_PTP => EI_ACK_PC11PTP
      );
  end generate PC11;

  PC11BUF: if sys_conf_ibd_pc11 > 0 generate
  begin
    PCA : ibdr_pc11_buf
      generic map (
        AWIDTH  => sys_conf_ibd_pc11)
      port map (
        CLK        => CLK,
        RESET      => RESET,
        BRESET     => BRESET,
        RLIM_CEV   => RLIM_CEV,
        RB_LAM     => RB_LAM_PC11,
        IB_MREQ    => IB_MREQ,
        IB_SRES    => IB_SRES_PC11,
        EI_REQ_PTR => EI_REQ_PC11PTR,
        EI_REQ_PTP => EI_REQ_PC11PTP,
        EI_ACK_PTR => EI_ACK_PC11PTR,
        EI_ACK_PTP => EI_ACK_PC11PTP
      );
  end generate PC11BUF;

  LP11: if sys_conf_ibd_lp11 = 0 generate
  begin
    LPA : ibdr_lp11
      port map (
        CLK     => CLK,
        RESET   => RESET,
        BRESET  => BRESET,
        RB_LAM  => RB_LAM_LP11,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_LP11,
        EI_REQ  => EI_REQ_LP11,
        EI_ACK  => EI_ACK_LP11
      );
  end generate LP11;

  LP11BUF: if sys_conf_ibd_lp11 > 0 generate
  begin
    LPA : ibdr_lp11_buf
      generic map (
        AWIDTH  => sys_conf_ibd_lp11)
      port map (
        CLK      => CLK,
        RESET    => RESET,
        BRESET   => BRESET,
        RLIM_CEV => RLIM_CEV,
        RB_LAM   => RB_LAM_LP11,
        IB_MREQ  => IB_MREQ,
        IB_SRES  => IB_SRES_LP11,
        EI_REQ   => EI_REQ_LP11,
        EI_ACK   => EI_ACK_LP11
      );
  end generate LP11BUF;

  M9312: if sys_conf_ibd_m9312 generate
  begin
    ROM : ibd_m9312
      port map (
        CLK     => CLK,
        RESET   => RESET,
        IB_MREQ => IB_MREQ,
        IB_SRES => IB_SRES_M9312
      );
  end generate M9312;

  SDREG : ibdr_sdreg
    port map (
      CLK     => CLK,
      RESET   => RESET,
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_SDREG,
      DISPREG => DISPREG
    );

  SRES_OR_1 : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_KW11P,
      IB_SRES_2  => IB_SRES_IIST,
      IB_SRES_3  => IB_SRES_KW11L,
      IB_SRES_4  => IB_SRES_DEUNA,
      IB_SRES_OR => IB_SRES_1
    );

  SRES_OR_2 : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_RHRP,
      IB_SRES_2  => IB_SRES_RL11,
      IB_SRES_3  => IB_SRES_RK11,
      IB_SRES_4  => IB_SRES_TM11,
      IB_SRES_OR => IB_SRES_2
    );

  SRES_OR_3 : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_DL11_0,
      IB_SRES_2  => IB_SRES_DL11_1,
      IB_SRES_3  => IB_SRES_DZ11,
      IB_SRES_OR => IB_SRES_3
    );

  SRES_OR_4 : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_PC11,
      IB_SRES_2  => IB_SRES_LP11,
      IB_SRES_3  => IB_SRES_M9312,
      IB_SRES_4  => IB_SRES_SDREG,
      IB_SRES_OR => IB_SRES_4
    );

  SRES_OR : ib_sres_or_4
    port map (
      IB_SRES_1  => IB_SRES_1,
      IB_SRES_2  => IB_SRES_2,
      IB_SRES_3  => IB_SRES_3,
      IB_SRES_4  => IB_SRES_4,
      IB_SRES_OR => IB_SRES
    );

  INTMAP : ib_intmap24
    generic map (
      INTMAP => conf_intmap24)
    port map (
      CLK     => CLK,
      EI_REQ  => EI_REQ,
      EI_ACKM => EI_ACKM,
      EI_ACK  => EI_ACK,
      EI_PRI  => EI_PRI,
      EI_VECT => EI_VECT
    );
   
  EI_REQ(23 downto 18) <= (others=>'0');
  EI_REQ(17) <= EI_REQ_KW11P;
  EI_REQ(16) <= EI_REQ_IIST;
  EI_REQ(15) <= EI_REQ_KW11L;
  EI_REQ(14) <= EI_REQ_DEUNA;
  EI_REQ(13) <= EI_REQ_RHRP;
  EI_REQ(12) <= EI_REQ_RL11;
  EI_REQ(11) <= EI_REQ_RK11;
  EI_REQ(10) <= EI_REQ_TM11;
  EI_REQ( 9) <= EI_REQ_DZ11RX;
  EI_REQ( 8) <= EI_REQ_DZ11TX;
  EI_REQ( 7) <= EI_REQ_DL11RX_0;
  EI_REQ( 6) <= EI_REQ_DL11TX_0;
  EI_REQ( 5) <= EI_REQ_DL11RX_1;
  EI_REQ( 4) <= EI_REQ_DL11TX_1;
  EI_REQ( 3) <= EI_REQ_PC11PTR;
  EI_REQ( 2) <= EI_REQ_PC11PTP;
  EI_REQ( 1) <= EI_REQ_LP11;

  EI_ACK_KW11P    <= EI_ACK(17);
  EI_ACK_IIST     <= EI_ACK(16);
  EI_ACK_KW11L    <= EI_ACK(15);
  EI_ACK_DEUNA    <= EI_ACK(14);
  EI_ACK_RHRP     <= EI_ACK(13);
  EI_ACK_RL11     <= EI_ACK(12);
  EI_ACK_RK11     <= EI_ACK(11);
  EI_ACK_TM11     <= EI_ACK(10);
  EI_ACK_DZ11RX   <= EI_ACK( 9);
  EI_ACK_DZ11TX   <= EI_ACK( 8);
  EI_ACK_DL11RX_0 <= EI_ACK( 7);
  EI_ACK_DL11TX_0 <= EI_ACK( 6);
  EI_ACK_DL11RX_1 <= EI_ACK( 5);
  EI_ACK_DL11TX_1 <= EI_ACK( 4);
  EI_ACK_PC11PTR  <= EI_ACK( 3);
  EI_ACK_PC11PTP  <= EI_ACK( 2);
  EI_ACK_LP11     <= EI_ACK( 1);

  RB_LAM(15 downto 11) <= (others=>'0'); 
  RB_LAM(10) <= RB_LAM_PC11;
  RB_LAM( 9) <= RB_LAM_DEUNA;
  RB_LAM( 8) <= RB_LAM_LP11;
  RB_LAM( 7) <= RB_LAM_TM11;
  RB_LAM( 6) <= RB_LAM_RHRP;
  RB_LAM( 5) <= RB_LAM_RL11;
  RB_LAM( 4) <= RB_LAM_RK11;
  RB_LAM( 3) <= RB_LAM_DZ11;
  RB_LAM( 2) <= RB_LAM_DL11_1;
  RB_LAM( 1) <= RB_LAM_DL11_0;
    
end syn;
