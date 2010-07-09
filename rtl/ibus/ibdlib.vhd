-- $Id: ibdlib.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2008-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   ibdlib
-- Description:    Definitions for ibus devices
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-11   303   1.1    use IB_MREQ.racc instead of RRI_REQ
-- 2009-07-12   233   1.0.5  add RESET, CE_USEC to _dl11, CE_USEC to _minisys
-- 2009-06-07   224   1.0.4  add iist_mreq and iist_sreq;
-- 2009-06-01   221   1.0.3  add RESET to kw11l; add iist;
-- 2009-05-30   220   1.0.2  add most additional device def's
-- 2009-05-24   219   1.0.1  add CE_MSEC to _rk11; add _maxisys
-- 2008-08-22   161   1.0    Initial version (extracted from pdp11.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.iblib.all;

package ibdlib is

type iist_line_type is record         -- iist line
  dcf : slbit;                        -- disconnect flag
  req : slbit;                        -- request
  stf : slbit;                        -- sanity timer flag
  imask : slv4;                       -- interrupt mask
  bmask : slv4;                       -- boot mask
  par : slbit;                        -- parity (odd)
  frm : slbit;                        -- frame error flag
end record iist_line_type;

constant iist_line_init : iist_line_type := ('1','0','0',"0000","0000",'0','0');

type iist_bus_type is array (3 downto 0) of iist_line_type;
constant iist_bus_init : iist_bus_type := (others=>iist_line_init);

type iist_mreq_type is record         -- iist->cpu requests
  lock : slbit;                       -- lock-up CPU
  boot : slbit;                       -- boot-up CPU
end record iist_mreq_type;

constant iist_mreq_init : iist_mreq_type := ('0','0');

type iist_sres_type is record         -- cpu->iist responses
  ack_lock : slbit;                   -- release lock 
  ack_boot : slbit;                   -- boot started
end record iist_sres_type;

constant iist_sres_init : iist_sres_type := ('0','0');

component ibd_iist is                   -- ibus dev(loc): IIST
                                        -- fixed address: 177500
  generic (
    SID : slv2 := "00");                -- self id
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit;                  -- interrupt acknowledge
    IIST_BUS : in iist_bus_type;        -- iist bus (input from all iist's)
    IIST_OUT : out iist_line_type;      -- iist output
    IIST_MREQ : out iist_mreq_type;     -- iist->cpu requests
    IIST_SRES : in iist_sres_type       -- cpu->iist responses
  );
end component;

component ibd_kw11p is                  -- ibus dev(loc): KW11-P (line clock)
                                        -- fixed address: 172540
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibd_kw11l is                  -- ibus dev(loc): KW11-L (line clock)
                                        -- fixed address: 177546
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibdr_rl11 is                  -- ibus dev(rem): RL11
                                        -- fixed address: 174400
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibdr_rk11 is                  -- ibus dev(rem): RK11
                                        -- fixed address: 177400
  port (
    CLK : in slbit;                     -- clock
    CE_MSEC : in slbit;                 -- msec pulse
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibdr_tm11 is                  -- ibus dev(rem): TM11
                                        -- fixed address: 172520
  port (
    CLK : in slbit;                     -- clock
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibdr_dz11 is                  -- ibus dev(rem): DZ11
  generic (
    IB_ADDR : slv16 := conv_std_logic_vector(8#160100#,16));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_RX : out slbit;              -- interrupt request, receiver
    EI_REQ_TX : out slbit;              -- interrupt request, transmitter
    EI_ACK_RX : in slbit;               -- interrupt acknowledge, receiver
    EI_ACK_TX : in slbit                -- interrupt acknowledge, transmitter
  );
end component;

component ibdr_dl11 is                  -- ibus dev(rem): DL11-A/B
  generic (
    IB_ADDR : slv16 := conv_std_logic_vector(8#177560#,16));
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_RX : out slbit;              -- interrupt request, receiver
    EI_REQ_TX : out slbit;              -- interrupt request, transmitter
    EI_ACK_RX : in slbit;               -- interrupt acknowledge, receiver
    EI_ACK_TX : in slbit                -- interrupt acknowledge, transmitter
  );
end component;

component ibdr_pc11 is                  -- ibus dev(rem): PC11
                                        -- fixed address: 177550
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ_PTR : out slbit;             -- interrupt request, reader
    EI_REQ_PTP : out slbit;             -- interrupt request, punch
    EI_ACK_PTR : in slbit;              -- interrupt acknowledge, reader
    EI_ACK_PTP : in slbit               -- interrupt acknowledge, punch
  );
end component;

component ibdr_lp11 is                  -- ibus dev(rem): LP11
                                        -- fixed address: 177514
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slbit;                -- remote attention
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_REQ : out slbit;                 -- interrupt request
    EI_ACK : in slbit                   -- interrupt acknowledge
  );
end component;

component ibdr_sdreg is                 -- ibus dev(rem): Switch/Display regs
                                        -- fixed address: 177570
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    DISPREG : out slv16                 -- display register
  );
end component;

component ibdr_minisys is               -- ibus(rem) minimal sys:SDR+KW+DL+RK
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slv16_1;              -- remote attention vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_PRI : out slv3;                  -- interrupt priority (to cpu)
    EI_VECT : out slv9_2;               -- interrupt vector   (to cpu)
    DISPREG : out slv16                 -- display register
  );
end component;
  
component ibdr_maxisys is               -- ibus(rem) full system
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    CE_MSEC : in slbit;                 -- msec pulse
    RESET : in slbit;                   -- reset
    BRESET : in slbit;                  -- ibus reset
    RRI_LAM : out slv16_1;              -- remote attention vector
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type;         -- ibus response
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_PRI : out slv3;                  -- interrupt priority (to cpu)
    EI_VECT : out slv9_2;               -- interrupt vector   (to cpu)
    DISPREG : out slv16                 -- display register
  );
end component;
  
end package ibdlib;
