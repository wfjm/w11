-- $Id: iblib.vhd 346 2010-12-22 22:59:26Z mueller $
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
-- Package Name:   iblib
-- Description:    Definitions for ibus interface and bus entities
--
-- Dependencies:   -
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 12.1; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-10-23   335   2.0.1  add ib_sel; add ib_sres_or_mon
-- 2010-10-17   333   2.0    ibus V2 interface: use aval,re,we,rmw
-- 2010-06-11   303   1.1    added racc,cacc signals to ib_mreq_type
-- 2009-06-01   221   1.0.1  added dip signal to ib_mreq_type
-- 2008-08-22   161   1.0    Initial version (extracted from pdp11.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

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
  vec : integer;                        -- vector address
  pri : integer;                        -- priority
end record intmap_type;
constant intmap_init : intmap_type := (0,0);

type intmap_array_type is array (15 downto 0) of intmap_type;
constant intmap_array_init : intmap_array_type := (others=>intmap_init);

component ib_intmap is                  -- external interrupt mapper
  generic (
    INTMAP : intmap_array_type := intmap_array_init);                       
  port (
    EI_REQ : in slv16_1;                -- interrupt request lines
    EI_ACKM : in slbit;                 -- interrupt acknowledge (from master)
    EI_ACK : out slv16_1;               -- interrupt acknowledge (to requestor)
    EI_PRI : out slv3;                  -- interrupt priority
    EI_VECT : out slv9_2                -- interrupt vector
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
