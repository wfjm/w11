-- $Id: rbdlib.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2010-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   rbdlib
-- Description:    Definitions for rbus devices
--
-- Dependencies:   -
-- Tool versions:  xst 12.1, 13.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-11-19   427   1.2.1  now numeric_std clean
-- 2010-12-29   351   1.2    new address layout; add rbd_timer
-- 2010-12-27   349   1.1    now correct defs for _rbmon and _eyemon
-- 2010-12-04   343   1.0    Initial version
------------------------------------------------------------------------------
--
-- base addresses of some standard rbus devices
--
--   rbd_rbmon     111111xx  -++--   these three used as monitors
--   rbd_eyemon    111110xx   / 
--   rbd_rlstat    1111011x  /   
--   rbd_bram      1111010x      \
--   rbd_tester    111100xx       +- all five used in test benchs
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rblib.all;

package rbdlib is
  
-- ise 13.1 xst can bug check if generic defaults in a package are defined via 
-- 'slv(to_unsigned())'. The conv_ construct prior to numeric_std was ok.
-- As workaround the ibus default addresses are defined here as constant.
constant rbaddr_tester : slv8 := slv(to_unsigned(2#11110000#,8));
constant rbaddr_bram   : slv8 := slv(to_unsigned(2#11110100#,8));
constant rbaddr_rbmon  : slv8 := slv(to_unsigned(2#11111100#,8));
constant rbaddr_eyemon : slv8 := slv(to_unsigned(2#11111000#,8));
constant rbaddr_timer  : slv8 := slv(to_unsigned(2#00000000#,8));

component rbd_tester is                 -- rbus dev: rbus tester
                                        -- complete rbus_aif interface
  generic (
    RB_ADDR : slv8 := rbaddr_tester);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_LAM : out slv16;                 -- rbus: look at me
    RB_STAT : out slv3                  -- rbus: status flags
  );
end component;

component rbd_bram is                   -- rbus dev: bram test target
                                        -- incomplete rbus_aif interface
  generic (
    RB_ADDR : slv8 := rbaddr_bram);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type          -- rbus: response
  );
end component;

component rbd_rbmon is                  -- rbus dev: rbus monitor
  generic (
    RB_ADDR : slv8 := rbaddr_rbmon;
    AWIDTH : positive := 9);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_SRES_SUM : in rb_sres_type       -- rbus: response (sum for monitor)
  );
end component;

component rbd_eyemon is                 -- rbus dev: eye monitor for serport's
  generic (
    RB_ADDR : slv8 := rbaddr_eyemon;
    RDIV : slv8 := (others=>'0'));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RXSD : in slbit;                    -- rx: serial data
    RXACT : in slbit                    -- rx: active (start seen)
  );
end component;

component rbd_timer is                  -- rbus dev: usec precision timer
  generic (
    RB_ADDR : slv8 := rbaddr_timer);
  port (
    CLK  : in slbit;                    -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DONE : out slbit;                   -- mark last timer cycle
    BUSY : out slbit                    -- timer running
  );
end component;

end package rbdlib;
