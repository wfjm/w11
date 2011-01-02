-- $Id: rbdlib.vhd 351 2010-12-30 21:50:54Z mueller $
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
-- Package Name:   rbdlib
-- Description:    Definitions for rbus devices
--
-- Dependencies:   -
-- Tool versions:  xst 12.1; ghdl 0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
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
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.rblib.all;

package rbdlib is

component rbd_tester is                 -- rbus dev: rbus tester
                                        -- complete rbus_aif interface
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11110000#,8));
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
    RB_ADDR : slv8 := conv_std_logic_vector(2#11110100#,8));
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type          -- rbus: response
  );
end component;

component rbd_rbmon is                  -- rbus dev: rbus monitor
  generic (
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111100#,8);
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
    RB_ADDR : slv8 := conv_std_logic_vector(2#11111000#,8);
    RDIV : slv8 := conv_std_logic_vector(0,8));
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
    RB_ADDR : slv8 := conv_std_logic_vector(2#00000000#,8));
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
