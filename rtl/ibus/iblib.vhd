-- $Id: iblib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2008-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   iblib
-- Description:    Definitions for ibus interface and bus entities
--
-- Dependencies:   -
-- Tool versions:  ise 8.1-14.7; viv 2014.4-2018.3; ghdl 0.18-0.35
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-23  1136   2.2.4  add CLK port to ib_intmap,ib_intmap24
-- 2019-04-14  1131   2.2.3  ib_rlim_gen: add CPUSUSP port; RLIM_CEV now slv8
-- 2019-03-17  1123   2.2.2  add ib_rlim_gen,ib_rlim_slv
-- 2019-02-10  1111   2.2.1  add ibd_ibtst
-- 2017-01-28   846   2.2    add ib_intmap24
-- 2016-05-28   770   2.1.1  use type natural for vec,pri fields of intmap_type
-- 2015-04-24   668   2.1    add ibd_ibmon
-- 2010-10-23   335   2.0.1  add ib_sel; add ib_sres_or_mon
-- 2010-10-17   333   2.0    ibus V2 interface: use aval,re,we,rmw
-- 2010-06-11   303   1.1    added racc,cacc signals to ib_mreq_type
-- 2009-06-01   221   1.0.1  added dip signal to ib_mreq_type
-- 2008-08-22   161   1.0    Initial version (extracted from pdp11.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

package iblib is

type ib_mreq_type is record             -- ibus - master request
  aval : slbit;                         -- address valid
  re   : slbit;                         -- read enable
  we   : slbit;                         -- write enable
  rmw  : slbit;                         -- read-modify-write
  be0  : slbit;                         -- byte enable low
  be1  : slbit;                         -- byte enable high
  cacc : slbit;                         -- console access
  racc : slbit;                         -- remote access
  addr : slv13_1;                       -- address bit(12:1)
  din  : slv16;                         -- data (input to slave)
end record ib_mreq_type;

constant ib_mreq_init : ib_mreq_type :=
  ('0','0','0','0',                     -- aval, re, we, rmw
   '0','0','0','0',                     -- be0, be1, cacc, racc
   (others=>'0'),                       -- addr
   (others=>'0'));                      -- din

type ib_sres_type is record             -- ibus - slave response
  ack  : slbit;                         -- acknowledge
  busy : slbit;                         -- busy
  dout : slv16;                         -- data (output from slave)
end record ib_sres_type;

constant ib_sres_init : ib_sres_type :=
  ('0','0',                             -- ack, busy
   (others=>'0'));                      -- dout

type ib_sres_vector is array (natural range <>) of ib_sres_type;

subtype ibf_byte1  is integer range 15 downto 8;
subtype ibf_byte0  is integer range  7 downto 0;

component ib_sel is                     -- ibus address select logic
  generic (
    IB_ADDR : slv16;                    -- ibus address base
    SAWIDTH : natural := 0);            -- device subaddress space width
  port (
    CLK : in slbit;                     -- clock
    IB_MREQ : in ib_mreq_type;          -- ibus request
    SEL : out slbit                     -- select state bit
  );
end component;

component ib_sres_or_2 is               -- ibus result or, 2 input
  port (
    IB_SRES_1 :  in ib_sres_type;                 -- ib_sres input 1
    IB_SRES_2 :  in ib_sres_type := ib_sres_init; -- ib_sres input 2
    IB_SRES_OR : out ib_sres_type       -- ib_sres or'ed output
  );
end component;
component ib_sres_or_3 is               -- ibus result or, 3 input
  port (
    IB_SRES_1 :  in ib_sres_type;                 -- ib_sres input 1
    IB_SRES_2 :  in ib_sres_type := ib_sres_init; -- ib_sres input 2
    IB_SRES_3 :  in ib_sres_type := ib_sres_init; -- ib_sres input 3
    IB_SRES_OR : out ib_sres_type       -- ib_sres or'ed output
  );
end component;
component ib_sres_or_4 is               -- ibus result or, 4 input
  port (
    IB_SRES_1 :  in ib_sres_type;                 -- ib_sres input 1
    IB_SRES_2 :  in ib_sres_type := ib_sres_init; -- ib_sres input 2
    IB_SRES_3 :  in ib_sres_type := ib_sres_init; -- ib_sres input 3
    IB_SRES_4 :  in ib_sres_type := ib_sres_init; -- ib_sres input 4
    IB_SRES_OR : out ib_sres_type       -- ib_sres or'ed output
  );
end component;

component ib_sres_or_gen is             -- ibus result or, generic
  generic (
    WIDTH : natural := 4);              -- number of input ports
  port (
    IB_SRES_IN : in ib_sres_vector(1 to WIDTH); -- ib_sres input array
    IB_SRES_OR : out ib_sres_type               -- ib_sres or'ed output
  );
end component;

type intmap_type is record              -- interrupt map entry type
  vec : natural;                        -- vector address
  pri : natural;                        -- priority
end record intmap_type;
constant intmap_init : intmap_type := (0,0);

type intmap_array_type is array (15 downto 0) of intmap_type;
constant intmap_array_init : intmap_array_type := (others=>intmap_init);

component ib_intmap is                  -- external interrupt mapper (15 line)
  generic (
    INTMAP : intmap_array_type := intmap_array_init);                       
  port (
    CLK : in slbit;                     -- clock
    EI_REQ : in slv16_1;                -- interrupt request lines
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_ACK : out slv16_1;               -- interrupt acknowledge (to requestor)
    EI_PRI : out slv3;                  -- interrupt priority
    EI_VECT : out slv9_2                -- interrupt vector
  );
end component;

type intmap24_array_type is array (23 downto 0) of intmap_type;
constant intmap24_array_init : intmap24_array_type := (others=>intmap_init);

component ib_intmap24 is                -- external interrupt mapper (23 line)
  generic (
    INTMAP : intmap24_array_type := intmap24_array_init);                       
  port (
    CLK : in slbit;                     -- clock
    EI_REQ : in slv24_1;                -- interrupt request lines
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_ACK : out slv24_1;               -- interrupt acknowledge (to requestor)
    EI_PRI : out slv3;                  -- interrupt priority
    EI_VECT : out slv9_2                -- interrupt vector
  );
end component;

component ibd_ibmon is                  -- ibus dev: ibus monitor
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#160000#,16));
    AWIDTH : natural := 9);
  port (
    CLK  : in slbit;                    -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus: request
    IB_SRES : out ib_sres_type;         -- ibus: response
    IB_SRES_SUM : in ib_sres_type       -- ibus: response (sum for monitor)
  );
end component;

component ibd_ibtst is                  -- ibus dev(rem): ibus tester
  generic (
    IB_ADDR : slv16 := slv(to_unsigned(8#170000#,16)));
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end component;

component ib_rlim_gen is                -- ibus rate limter - master
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET : in slbit;                   -- system reset
    CPUSUSP : in slbit;                 -- cpu suspended
    RLIM_CEV : out slv8                 -- clock enable vector
  );
end component;

component ib_rlim_slv is                -- ibus rate limter - slave
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- system reset
    RLIM_CEV : in  slv8;                -- clock enable vector
    SEL : in  slv3;                     -- rlim select
    START : in slbit;                   -- start timer
    STOP : in slbit;                    -- stop timer
    DONE : out slbit;                   -- 1 cycle pulse when expired 
    BUSY : out slbit                    -- timer running
  );
end component;

--
-- components for use in test benches (not synthesizable)
--
  
component ib_sres_or_mon is             -- ibus result or monitor
  port (
    IB_SRES_1 :  in ib_sres_type;                 -- ib_sres input 1
    IB_SRES_2 :  in ib_sres_type := ib_sres_init; -- ib_sres input 2
    IB_SRES_3 :  in ib_sres_type := ib_sres_init; -- ib_sres input 3
    IB_SRES_4 :  in ib_sres_type := ib_sres_init  -- ib_sres input 4
  );
end component;

end package iblib;
