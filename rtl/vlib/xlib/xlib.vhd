-- $Id: xlib.vhd 1247 2022-07-06 07:04:33Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   xlib
-- Description:    Xilinx specific components
--
-- Dependencies:   -
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-07-05  1247   1.1.2  add bufg_unisim
-- 2018-11-18  1072   1.1.1  add s7_cmt_sfs_3 and s7_cmt_sfs_2
-- 2018-11-03  1064   1.1    add sfs_gsim_core
-- 2016-04-02   758   1.0.11 add usr_access_unisim
-- 2013-10-06   538   1.0.10 add s6_cmt_sfs
-- 2013-09-28   535   1.0.9  add s7_cmt_sfs
-- 2011-11-24   432   1.0.8  add iob_oddr2_simple
-- 2011-11-17   426   1.0.7  rename dcm_sp_sfs -> dcm_sfs; remove family generic
-- 2011-11-10   423   1.0.6  add family generic for dcm_sp_sfs
-- 2010-11-07   337   1.0.5  add dcm_sp_sfs
-- 2008-05-23   149   1.0.4  add iob_io(_gen)
-- 2008-05-22   148   1.0.3  add iob_keeper(_gen);
-- 2008-05-18   147   1.0.2  add PULL generic to iob_reg_io(_gen)
-- 2007-12-16   101   1.0.1  add INIT generic ports
-- 2007-12-08   100   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package xlib is

component iob_reg_i is                  -- registered IOB, input
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DI   : out slbit;                   -- input data
    PAD  : in slbit                     -- i/o pad
  );
end component;

component iob_reg_i_gen is              -- registered IOB, input, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data
    PAD  : in slv(DWIDTH-1 downto 0)    -- i/o pad
  );
end component;

component iob_reg_o is                  -- registered IOB, output
  generic (
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slbit;                    -- output data
    PAD  : out slbit                    -- i/o pad
  );
end component;

component iob_reg_o_gen is              -- registered IOB, output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO   : in slv(DWIDTH-1 downto 0);   -- output data
    PAD  : out slv(DWIDTH-1 downto 0)   -- i/o pad
  );
end component;

component iob_reg_io is                 -- registered IOB, in/output
  generic (
    INITI : slbit := '0';               -- initial state ( in flop)
    INITO : slbit := '0';               -- initial state (out flop)
    INITE : slbit := '0';               -- initial state ( oe flop)
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    CLK  : in slbit;                    -- clock
    CEI  : in slbit := '1';             -- clock enable ( in flops)
    CEO  : in slbit := '1';             -- clock enable (out flops)
    OE   : in slbit;                    -- output enable
    DI   : out slbit;                   -- input data   (read from pad)
    DO   : in slbit;                    -- output data  (write  to pad)
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_reg_io_gen is             -- registered IOB, in/output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    INITI : slbit := '0';               -- initial state ( in flop)
    INITO : slbit := '0';               -- initial state (out flop)
    INITE : slbit := '0';               -- initial state ( oe flop)
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    CLK  : in slbit;                    -- clock
    CEI  : in slbit := '1';             -- clock enable ( in flops)
    CEO  : in slbit := '1';             -- clock enable (out flops)
    OE   : in slbit;                    -- output enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data   (read from pad)
    DO   : in slv(DWIDTH-1 downto 0);   -- output data  (write  to pad)
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component iob_io is                     -- un-registered IOB, in/output
  generic (
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    OE   : in slbit;                    -- output enable
    DI   : out slbit;                   -- input data   (read from pad)
    DO   : in slbit;                    -- output data  (write  to pad)
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_oddr2_simple is           -- DDR2 output I/O pad
  generic (
    ALIGN : string := "NONE";           -- ddr_alignment
    INIT : slbit := '0');               -- initial state
  port (
    CLK  : in slbit;                    -- clock
    CE   : in slbit := '1';             -- clock enable
    DO0  : in slbit;                    -- output data
    DO1  : in slbit;                    -- output data
    PAD  : out slbit                    -- i/o pad
  );
end component;

component iob_io_gen is                 -- un-registered IOB, in/output, vector
  generic (
    DWIDTH : positive := 16;            -- data port width
    PULL : string := "NONE");           -- pull-up,-down or keeper
  port (
    OE   : in slbit;                    -- output enable
    DI   : out slv(DWIDTH-1 downto 0);  -- input data   (read from pad)
    DO   : in slv(DWIDTH-1 downto 0);   -- output data  (write  to pad)
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component iob_keeper is                 -- keeper for IOB
  port (
    PAD  : inout slbit                  -- i/o pad
  );
end component;

component iob_keeper_gen is             -- keeper for IOB, vector
  generic (
    DWIDTH : positive := 16);           -- data port width
  port (
    PAD  : inout slv(DWIDTH-1 downto 0)  -- i/o pad
  );
end component;

component dcm_sfs is                    -- DCM for simple frequency synthesis
  generic (
    CLKFX_DIVIDE   : positive := 2;     -- FX clock divide (1-32)
    CLKFX_MULTIPLY : positive := 2;     -- FX clock multiply (2-32) (1->no DCM)
    CLKIN_PERIOD   : real := 20.0);     -- CLKIN period (def is 20.0 ns)
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- dcm locked
  );
end component;

component s7_cmt_sfs is                 -- 7-Series CMT for simple freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE   : positive := 1;       -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or MMCM
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/mmcm locked
  );
end component;

component s7_cmt_sfs_2 is               -- 7-Series CMT for dual freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT0_DIVIDE  : positive := 1;       -- output 0 divide
    OUT1_DIVIDE  : positive := 1;       -- output 1 divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or MMCM
  port (
    CLKIN   : in slbit;                 -- clock input
    CLKOUT0 : out slbit;                -- clock output 0
    CLKOUT1 : out slbit;                -- clock output 1
    LOCKED  : out slbit                 -- pll/mmcm locked
  );
end component;

component s7_cmt_sfs_3 is               -- 7-Series CMT for tripple freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT0_DIVIDE  : positive := 1;       -- output 0 divide
    OUT1_DIVIDE  : positive := 1;       -- output 1 divide
    OUT2_DIVIDE  : positive := 1;       -- output 2 divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or MMCM
  port (
    CLKIN   : in slbit;                 -- clock input
    CLKOUT0 : out slbit;                -- clock output 0
    CLKOUT1 : out slbit;                -- clock output 1
    CLKOUT2 : out slbit;                -- clock output 2
    LOCKED  : out slbit                 -- pll/mmcm locked
  );
end component;

component s6_cmt_sfs is                 -- Spartan-6 CMT for simple freq. synth.
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE   : positive := 1;       -- output divide
    CLKIN_PERIOD : real := 10.0;        -- CLKIN period (def is 10.0 ns)
    CLKIN_JITTER : real := 0.01;        -- CLKIN jitter (def is 10 ps)
    STARTUP_WAIT : boolean := false;    -- hold FPGA startup till LOCKED
    GEN_TYPE     : string := "PLL");    -- PLL or DCM
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- pll/mmcm locked
  );
end component;

component sfs_gsim_core is              -- frequency synthesis for simulation
  generic (
    VCO_DIVIDE   : positive := 1;       -- vco clock divide
    VCO_MULTIPLY : positive := 1;       -- vco clock multiply 
    OUT_DIVIDE   : positive := 1);      -- output divide
  port (
    CLKIN  : in slbit;                  -- clock input
    CLKFX  : out slbit;                 -- clock output (synthesized freq.) 
    LOCKED : out slbit                  -- clkin locked
  );
end component;

component usr_access_unisim is          -- wrapper for USR_ACCESS family
  port (
    DATA : out slv32                    -- usr_access register value
  );
end component;

component bufg_unisim is                -- wrapper for bufg
  port (
    O : out std_ulogic;                 -- input
    I : in std_ulogic                   -- output
  );
end component;

end package xlib;
