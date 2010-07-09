-- $Id: pdp11_sys70.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2008- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_sys70 - syn
-- Description:    pdp11: 11/70 system registers
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2008-08-22   161   1.0.1  use iblib
-- 2008-04-20   137   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.pdp11.all;
use work.iblib.all;
use work.sys_conf.all;

-- ----------------------------------------------------------------------------

entity pdp11_sys70 is                   -- 11/70 memory system registers
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- console reset
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_sys70;

architecture syn of pdp11_sys70 is
  
  constant ibaddr_mbrk   : slv16 := conv_std_logic_vector(8#177770#,16);
  constant ibaddr_sysid  : slv16 := conv_std_logic_vector(8#177764#,16);

  type regs_type is record              -- state registers
    mbrk    : slv8;                     -- status of mbrk register
  end record regs_type;

  constant regs_init : regs_type := (
    mbrk=>(others=>'0')                 -- mbrk
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type := regs_init;

begin

  proc_regs: process (CLK)
  begin
    if CLK'event and CLK='1' then
      if CRESET = '1' then
        R_REGS <= regs_init;
     else
        R_REGS <= N_REGS;
      end if;
    end if;
  end process proc_regs;

  proc_next: process (R_REGS, IB_MREQ)
    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibsel_mbrk  : slbit := '0';   -- mbrk
    variable ibsel_sysid : slbit := '0';   -- sysid
    variable ibsel : slbit := '0';
    variable idout : slv16 := (others=>'0');
  begin
    
    r := R_REGS;
    n := R_REGS;

    ibsel_mbrk  := '0';
    ibsel_sysid := '0';
    ibsel := '0';
    idout := (others=>'0');

    if IB_MREQ.req = '1' then
      if IB_MREQ.addr = ibaddr_mbrk(12 downto 1) then
        ibsel_mbrk  := '1';
      end if;
      if IB_MREQ.addr = ibaddr_sysid(12 downto 1) then
        ibsel_sysid := '1';
      end if;
    end if;

    ibsel := ibsel_mbrk or ibsel_sysid;
    
    if ibsel_mbrk = '1' then
      idout(r.mbrk'range) := r.mbrk;
    end if;
    if ibsel_sysid = '1' then
      idout := conv_std_logic_vector(8#123456#,16);
    end if;

    if ibsel_mbrk='1' and IB_MREQ.we='1' and IB_MREQ.be0='1' then
      n.mbrk := IB_MREQ.din(n.mbrk'range);
    end if;

    N_REGS <= n;

    IB_SRES.ack  <= ibsel;
    IB_SRES.busy <= '0';
    IB_SRES.dout <= idout;

  end process proc_next;
    
end syn;
