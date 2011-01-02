-- $Id: ibdr_maxisys.vhd 350 2010-12-28 16:40:11Z mueller $
--
-- Copyright 2009-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    ibdr_maxisys - syn
-- Description:    ibus(rem) devices for full system
--
-- Dependencies:   ibd_iist
--                 ibd_kw11l
--                 ibdr_rk11
--                 ibdr_dl11
--                 ibdr_pc11
--                 ibdr_lp11
--                 ibdr_sdreg
--                 ib_sres_or_4
--                 ib_sres_or_3
--                 ib_intmap
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 12.1; ghdl 0.18-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2010-10-17   333 12.1    M53d xc3s1000-4   312 1058   16  617 s 10.3
-- 2010-10-17   314 12.1    M53d xc3s1000-4   300 1094   16  626 s 10.4
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-10-23   335   1.1.1  rename RRI_LAM->RB_LAM;
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.4  reorder ports; add RESET, CE_USEC to _dl11
-- 2009-06-20   227   1.0.3  rename generate labels.
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
-- 172540  104   ?7 14 17    -  1/1  KW11-P
-- 177500  260    6 13 16    -  1/2  IIST
-- 177546  100    6 12 15    -  1/3  KW11-L
-- 174510  120    5    14    9  1/4  DEUNA
-- 176700  254    5    13    6  2/1  RH70/RP06
-- 174400  160    5 11 12    5  2/2  RL11
-- 177400  220    5 10 11    4  2/3  RK11
-- 172520  224    5    10    7  2/4  TM11
-- 160100  310?   5  9  9    3  3/1  DZ11-RX
--         314?   5  8  8    ^       DZ11-TX
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
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.iblib.all;
use work.ibdlib.all;

-- ----------------------------------------------------------------------------
entity ibdr_maxisys is                  -- ibus(rem) full system
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- reset
    BRESET : in slbit;                  -- ibus reset
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

  constant conf_intmap : intmap_array_type :=
    (intmap_init,                       -- line 15
     (8#104#,6),                        -- line 14  KW11-P
     (8#260#,6),                        -- line 13  IIST
     (8#100#,6),                        -- line 12  KW11-L
     (8#160#,5),                        -- line 11  RL11
     (8#220#,5),                        -- line 10  RK11
     (8#310#,5),                        -- line  9  DZ11-RX
     (8#314#,5),                        -- line  8  DZ11-TX
     (8#060#,4),                        -- line  7  DL11-RX 1st
     (8#064#,4),                        -- line  6  DL11-TX 1st
     (8#300#,4),                        -- line  5  DL11-RX 2nd
     (8#304#,4),                        -- line  4  DL11-TX 2nd
     (8#070#,4),                        -- line  3  PC11-PTR
     (8#074#,4),                        -- line  2  PC11-PTP
     (8#200#,4),                        -- line  1  LP11
     intmap_init                        -- line  0
     );

  signal RB_LAM_DENUA  : slbit := '0';
  signal RB_LAM_RP06   : slbit := '0';
  signal RB_LAM_RL11   : slbit := '0';
  signal RB_LAM_RK11   : slbit := '0';
  signal RB_LAM_TM11   : slbit := '0';
  signal RB_LAM_DZ11   : slbit := '0';
  signal RB_LAM_DL11_0 : slbit := '0';
  signal RB_LAM_DL11_1 : slbit := '0';
  signal RB_LAM_PC11   : slbit := '0';
  signal RB_LAM_LP11   : slbit := '0';

  signal IB_SRES_IIST   : ib_sres_type := ib_sres_init;
  signal IB_SRES_KW11P  : ib_sres_type := ib_sres_init;
  signal IB_SRES_KW11L  : ib_sres_type := ib_sres_init;
  signal IB_SRES_DEUNA  : ib_sres_type := ib_sres_init;
  signal IB_SRES_RP06   : ib_sres_type := ib_sres_init;
  signal IB_SRES_RL11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_RK11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_TM11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_DZ11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_DL11_0 : ib_sres_type := ib_sres_init;
  signal IB_SRES_DL11_1 : ib_sres_type := ib_sres_init;
  signal IB_SRES_PC11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_LP11   : ib_sres_type := ib_sres_init;
  signal IB_SRES_SDREG  : ib_sres_type := ib_sres_init;

  signal IB_SRES_1      : ib_sres_type := ib_sres_init;
  signal IB_SRES_2      : ib_sres_type := ib_sres_init;
  signal IB_SRES_3      : ib_sres_type := ib_sres_init;
  signal IB_SRES_4      : ib_sres_type := ib_sres_init;
  
  signal EI_REQ  : slv16_1 := (others=>'0');
  signal EI_ACK  : slv16_1 := (others=>'0');

  signal EI_REQ_IIST     : slbit := '0';
  signal EI_REQ_KW11P    : slbit := '0';
  signal EI_REQ_KW11L    : slbit := '0';
  signal EI_REQ_DEUNA    : slbit := '0';
  signal EI_REQ_RP06     : slbit := '0';
  signal EI_REQ_RL11     : slbit := '0';
  signal EI_REQ_RK11     : slbit := '0';
  signal EI_REQ_TM11     : slbit := '0';
  signal EI_REQ_DZ11RX   : slbit := '0';
  signal EI_REQ_DZ11TX   : slbit := '0';
  signal EI_REQ_DL11RX_0 : slbit := '0';
  signal EI_REQ_DL11TX_0 : slbit := '0';
  signal EI_REQ_DL11RX_1 : slbit := '0';
  signal EI_REQ_DL11TX_1 : slbit := '0';
  signal EI_REQ_PC11PTR  : slbit := '0';
  signal EI_REQ_PC11PTP  : slbit := '0';
  signal EI_REQ_LP11     : slbit := '0';
  
  signal EI_ACK_IIST     : slbit := '0';
  signal EI_ACK_KW11P    : slbit := '0';
  signal EI_ACK_KW11L    : slbit := '0';
  signal EI_ACK_DEUNA    : slbit := '0';
  signal EI_ACK_RP06     : slbit := '0';
  signal EI_ACK_RL11     : slbit := '0';
  signal EI_ACK_RK11     : slbit := '0';
  signal EI_ACK_TM11     : slbit := '0';
  signal EI_ACK_DZ11RX   : slbit := '0';
  signal EI_ACK_DZ11TX   : slbit := '0';
  signal EI_ACK_DL11RX_0 : slbit := '0';
  signal EI_ACK_DL11TX_0 : slbit := '0';
  signal EI_ACK_DL11RX_1 : slbit := '0';
  signal EI_ACK_DL11TX_1 : slbit := '0';
  signal EI_ACK_PC11PTR  : slbit := '0';
  signal EI_ACK_PC11PTP  : slbit := '0';
  signal EI_ACK_LP11     : slbit := '0';

  signal IIST_BUS        : iist_bus_type := iist_bus_init;
  signal IIST_OUT_0      : iist_line_type := iist_line_init;
  signal IIST_MREQ       : iist_mreq_type := iist_mreq_init;
  signal IIST_SRES       : iist_sres_type := iist_sres_init;

begin

  IIST: if true generate
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
      IB_MREQ => IB_MREQ,
      IB_SRES => IB_SRES_KW11L,
      EI_REQ  => EI_REQ_KW11L,
      EI_ACK  => EI_ACK_KW11L
    );

  RK11: if true generate
  begin
    I0 : ibdr_rk11
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

  DL11_0 : ibdr_dl11
    port map (
      CLK       => CLK,
      CE_USEC   => CE_USEC,
      RESET     => RESET,
      BRESET    => BRESET,
      RB_LAM    => RB_LAM_DL11_0,
      IB_MREQ   => IB_MREQ,
      IB_SRES   => IB_SRES_DL11_0,
      EI_REQ_RX => EI_REQ_DL11RX_0,
      EI_REQ_TX => EI_REQ_DL11TX_0,
      EI_ACK_RX => EI_ACK_DL11RX_0,
      EI_ACK_TX => EI_ACK_DL11TX_0
    );
  
  DL11_1: if true generate
  begin
    I0 : ibdr_dl11
      generic map (
        IB_ADDR   => conv_std_logic_vector(8#176500#,16))
      port map (
        CLK       => CLK,
        CE_USEC   => CE_USEC,
        RESET     => RESET,
        BRESET    => BRESET,
        RB_LAM    => RB_LAM_DL11_1,
        IB_MREQ   => IB_MREQ,
        IB_SRES   => IB_SRES_DL11_1,
        EI_REQ_RX => EI_REQ_DL11RX_1,
        EI_REQ_TX => EI_REQ_DL11TX_1,
        EI_ACK_RX => EI_ACK_DL11RX_1,
        EI_ACK_TX => EI_ACK_DL11TX_1
      );
  end generate DL11_1;

  PC11: if true generate
  begin
    I0 : ibdr_pc11
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

  LP11: if true generate
  begin
    I0 : ibdr_lp11
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
      IB_SRES_1  => IB_SRES_RP06,
      IB_SRES_2  => IB_SRES_RL11,
      IB_SRES_3  => IB_SRES_RK11,
      IB_SRES_4  => IB_SRES_TM11,
      IB_SRES_OR => IB_SRES_2
    );

  SRES_OR_3 : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_DZ11,
      IB_SRES_2  => IB_SRES_DL11_0,
      IB_SRES_3  => IB_SRES_DL11_1,
      IB_SRES_OR => IB_SRES_3
    );

  SRES_OR_4 : ib_sres_or_3
    port map (
      IB_SRES_1  => IB_SRES_PC11,
      IB_SRES_2  => IB_SRES_LP11,
      IB_SRES_3  => IB_SRES_SDREG,
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

  INTMAP : ib_intmap
    generic map (
      INTMAP => conf_intmap)
    port map (
      EI_REQ  => EI_REQ,
      EI_ACKM => EI_ACKM,
      EI_ACK  => EI_ACK,
      EI_PRI  => EI_PRI,
      EI_VECT => EI_VECT
    );
   
  EI_REQ(14) <= EI_REQ_KW11P;
  EI_REQ(13) <= EI_REQ_IIST;
  EI_REQ(12) <= EI_REQ_KW11L;
  EI_REQ(11) <= EI_REQ_RL11;
  EI_REQ(10) <= EI_REQ_RK11;
  EI_REQ( 9) <= EI_REQ_DZ11RX;
  EI_REQ( 8) <= EI_REQ_DZ11TX;
  EI_REQ( 7) <= EI_REQ_DL11RX_0;
  EI_REQ( 6) <= EI_REQ_DL11TX_0;
  EI_REQ( 5) <= EI_REQ_DL11RX_1;
  EI_REQ( 4) <= EI_REQ_DL11TX_1;
  EI_REQ( 3) <= EI_REQ_PC11PTR;
  EI_REQ( 2) <= EI_REQ_PC11PTP;
  EI_REQ( 1) <= EI_REQ_LP11;

  EI_ACK_KW11P    <= EI_ACK(14);
  EI_ACK_IIST     <= EI_ACK(13);
  EI_ACK_KW11L    <= EI_ACK(12);
  EI_ACK_RL11     <= EI_ACK(11);
  EI_ACK_RK11     <= EI_ACK(10);
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
  RB_LAM( 9) <= RB_LAM_DENUA;
  RB_LAM( 8) <= RB_LAM_LP11;
  RB_LAM( 7) <= RB_LAM_TM11;
  RB_LAM( 6) <= RB_LAM_RP06;
  RB_LAM( 5) <= RB_LAM_RL11;
  RB_LAM( 4) <= RB_LAM_RK11;
  RB_LAM( 3) <= RB_LAM_DZ11;
  RB_LAM( 2) <= RB_LAM_DL11_1;
  RB_LAM( 1) <= RB_LAM_DL11_0;
    
end syn;
