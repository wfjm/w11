-- $Id: rritblib.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2007-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rritblib
-- Description:    Remote Register Interface test environment components
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-06-26   309   2.5.1  add rritb_sres_or_mon
-- 2010-06-06   302   2.5    use sop/eop framing instead of soc+chaining
-- 2010-06-05   301   2.1.2  renamed _rpmon -> _rbmon
-- 2010-05-02   287   2.1.1  rename CE_XSEC->CE_INT,RP_STAT->RB_STAT
--                           drop RP_IINT signal from interfaces
--                           add sbcntl_sbf_(cp|rp)mon defs
-- 2010-04-24   282   2.1    add rritb_core
-- 2008-08-24   162   2.0    all with new rb_mreq/rb_sres interface
-- 2008-03-24   129   1.1.5  CLK_CYCLE now 31 bits
-- 2007-12-23   105   1.1.4  add AP_LAM  for rritb_rpmon(_sb)
-- 2007-11-24    98   1.1.3  add RP_IINT for rritb_rpmon(_sb)
-- 2007-09-01    78   1.1.2  add rricp_rp
-- 2007-08-25    75   1.1.1  add rritb_cpmon_sb, rritb_rpmon_sb
-- 2007-08-16    74   1.1    remove rritb_tt* component; some interface changes
-- 2007-08-03    71   1.0.2  use rrirp_acif; change generics for rritb_[cr]pmon
-- 2007-07-22    68   1.0.1  add rritb_cpmon rritb_rpmon monitors
-- 2007-07-15    66   1.0    Initial version
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.rrilib.all;

package rritblib is

-- simbus sb_cntl field usage for rri
  constant sbcntl_sbf_cpmon : integer := 15;
  constant sbcntl_sbf_rbmon : integer := 14;


component rritb_cpmon is                -- rritb, rri comm port monitor
  generic (
    DWIDTH : positive :=  9);           -- data port width (8 or 9)
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in slv31 := (others=>'0');  -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    CP_DI : in slv(DWIDTH-1 downto 0);  -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv(DWIDTH-1 downto 0);  -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : in slbit                  -- comm port: data hold
  );
end component;

component rritb_cpmon_sb is             -- simbus wrap for rri comm port monitor
  generic (
    DWIDTH : positive :=  9;            -- data port width (8 or 9)
    ENAPIN : integer := sbcntl_sbf_cpmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    CP_DI : in slv(DWIDTH-1 downto 0);  -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : in slbit;                 -- comm port: data busy
    CP_DO : in slv(DWIDTH-1 downto 0);  -- comm port: data out
    CP_VAL : in slbit;                  -- comm port: data valid
    CP_HOLD : in slbit                  -- comm port: data hold
  );
end component;

component rritb_rbmon is                -- rritb, rri rbus monitor
  generic (
    DBASE : positive :=  2);            -- base for writing data values
  port (
    CLK  : in slbit;                    -- clock
    CLK_CYCLE : in slv31 := (others=>'0');  -- clock cycle number
    ENA  : in slbit := '1';             -- enable monitor output
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  ); 
end component;

component rritb_rbmon_sb is             -- simbus wrap for rri rbus monitor
  generic (
    DBASE : positive :=  2;             -- base for writing data values
    ENAPIN : integer := sbcntl_sbf_rbmon); -- SB_CNTL signal to use for enable
  port (
    CLK  : in slbit;                    -- clock
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : in rb_sres_type;          -- rbus: response
    RB_LAM : in slv16 := (others=>'0'); -- rbus: look at me
    RB_STAT : in slv3                   -- rbus: status flags
  );
end component;

component rritb_sres_or_mon is          -- rribus result or monitor
  port (
    RB_SRES_1  :  in rb_sres_type;      -- rb_sres input 1
    RB_SRES_2  :  in rb_sres_type;      -- rb_sres input 2
    RB_SRES_3  :  in rb_sres_type := rb_sres_init; -- rb_sres input 3
    RB_SRES_4  :  in rb_sres_type := rb_sres_init  -- rb_sres input 4
  );
end component;

component rritb_core is                 -- core of rri/cext based test bench
  generic (
    CLK_PERIOD : time :=  20 ns;        -- clock period
    CLK_OFFSET : time := 200 ns;        -- clock offset (time to start clock)
    SETUP_TIME : time :=   5 ns;        -- setup time
    C2OUT_TIME : time :=  10 ns);       -- clock to output time
  port (
    CLK : out slbit;                    -- main clock
    RX_DATA : out slv8;                 -- read data         (data ext->tb)
    RX_VAL : out slbit;                 -- read data valid   (data ext->tb)
    RX_HOLD : in slbit;                 -- read data hold    (data ext->tb)
    TX_DATA : in slv8;                  -- write data        (data tb->ext)
    TX_ENA : in slbit                   -- write data enable (data tb->ext)
  );
end component;

component rricp_rp is                   -- rri comm->reg port aif forwarder
                                        -- implements rricp_aif, uses rrirp_aif
  port (
    CLK  : in slbit;                    -- clock
    CE_INT : in slbit := '0';           -- rri ito time unit clock enable
    RESET  : in slbit :='0';            -- reset
    CP_DI : in slv9;                    -- comm port: data in
    CP_ENA : in slbit;                  -- comm port: data enable
    CP_BUSY : out slbit;                -- comm port: data busy
    CP_DO : out slv9;                   -- comm port: data out
    CP_VAL : out slbit;                 -- comm port: data valid
    CP_HOLD : in slbit := '0'           -- comm port: data hold
  );
end component;

end rritblib;
