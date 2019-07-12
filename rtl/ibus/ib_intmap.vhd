-- $Id: ib_intmap.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ib_intmap - syn
-- Description:    pdp11: external interrupt mapper (15 line)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2017.2; ghdl 0.18-0.35
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic MHz
-- 2016-05-26   641 2016.4  xc7a100t-1      0    30     0     0     -   -
-- 2015-02-22   641 i 14.7  xc6slx16-2      0    20     0     0     9   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-23  1136   1.2    BUGFIX: ensure ACK send to correct device
-- 2011-11-18   427   1.2.2  now numeric_std clean
-- 2008-08-22   161   1.2.1  renamed pdp11_ -> ib_; use iblib
-- 2008-01-20   112   1.2    add INTMAP generic to externalize config
-- 2008-01-06   111   1.1    add EI_ACK output lines, remove EI_LINE
-- 2007-10-12    88   1.0.2  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------

entity ib_intmap is                     -- external interrupt mapper
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
end ib_intmap;

architecture syn of ib_intmap is

  signal EI_LINE : slv4 := (others=>'0');    -- external interrupt line
  signal R_LINE :  slv4 := (others=>'0');    -- line on last cycle

  type intp_type is array (15 downto 0) of slv3;
  type intv_type is array (15 downto 0) of slv9;

  constant conf_intp : intp_type :=
    (slv(to_unsigned(INTMAP(15).pri,3)),  -- line 15
     slv(to_unsigned(INTMAP(14).pri,3)),  -- line 14
     slv(to_unsigned(INTMAP(13).pri,3)),  -- line 13
     slv(to_unsigned(INTMAP(12).pri,3)),  -- line 12
     slv(to_unsigned(INTMAP(11).pri,3)),  -- line 11
     slv(to_unsigned(INTMAP(10).pri,3)),  -- line 10
     slv(to_unsigned(INTMAP( 9).pri,3)),  -- line  9
     slv(to_unsigned(INTMAP( 8).pri,3)),  -- line  8
     slv(to_unsigned(INTMAP( 7).pri,3)),  -- line  7
     slv(to_unsigned(INTMAP( 6).pri,3)),  -- line  6
     slv(to_unsigned(INTMAP( 5).pri,3)),  -- line  5
     slv(to_unsigned(INTMAP( 4).pri,3)),  -- line  4
     slv(to_unsigned(INTMAP( 3).pri,3)),  -- line  3
     slv(to_unsigned(INTMAP( 2).pri,3)),  -- line  2
     slv(to_unsigned(INTMAP( 1).pri,3)),  -- line  1     
     slv(to_unsigned(             0,3))   -- line  0 (always 0 !!)
     ); 

  constant conf_intv : intv_type :=
    (slv(to_unsigned(INTMAP(15).vec,9)),  -- line 15
     slv(to_unsigned(INTMAP(14).vec,9)),  -- line 14
     slv(to_unsigned(INTMAP(13).vec,9)),  -- line 13
     slv(to_unsigned(INTMAP(12).vec,9)),  -- line 12
     slv(to_unsigned(INTMAP(11).vec,9)),  -- line 11
     slv(to_unsigned(INTMAP(10).vec,9)),  -- line 10
     slv(to_unsigned(INTMAP( 9).vec,9)),  -- line  9
     slv(to_unsigned(INTMAP( 8).vec,9)),  -- line  8
     slv(to_unsigned(INTMAP( 7).vec,9)),  -- line  7
     slv(to_unsigned(INTMAP( 6).vec,9)),  -- line  6
     slv(to_unsigned(INTMAP( 5).vec,9)),  -- line  5
     slv(to_unsigned(INTMAP( 4).vec,9)),  -- line  4
     slv(to_unsigned(INTMAP( 3).vec,9)),  -- line  3
     slv(to_unsigned(INTMAP( 2).vec,9)),  -- line  2
     slv(to_unsigned(INTMAP( 1).vec,9)),  -- line  1     
     slv(to_unsigned(             0,9))   -- line  0 (always 0 !!)
     ); 

--  attribute PRIORITY_EXTRACT : string;
--  attribute PRIORITY_EXTRACT of EI_LINE : signal is "force";
  
begin

  EI_LINE <= "1111" when EI_REQ(15)='1' else
             "1110" when EI_REQ(14)='1' else
             "1101" when EI_REQ(13)='1' else
             "1100" when EI_REQ(12)='1' else
             "1011" when EI_REQ(11)='1' else
             "1010" when EI_REQ(10)='1' else
             "1001" when EI_REQ( 9)='1' else
             "1000" when EI_REQ( 8)='1' else
             "0111" when EI_REQ( 7)='1' else
             "0110" when EI_REQ( 6)='1' else
             "0101" when EI_REQ( 5)='1' else
             "0100" when EI_REQ( 4)='1' else
             "0011" when EI_REQ( 3)='1' else
             "0010" when EI_REQ( 2)='1' else
             "0001" when EI_REQ( 1)='1' else
             "0000";

  proc_line: process (CLK)
  begin
    if rising_edge(CLK) then
        R_LINE <= EI_LINE;
    end if;
  end process proc_line;
  
  -- Note: EI_ACKM comes one cycle after vector is latched ! Therefore
  -- - use EI_LINE to select vector to send to EI_PRI and EI_VECT
  -- - use  R_LINE to select EI_ACM line for acknowledge
  proc_intmap : process (EI_LINE, EI_ACKM, R_LINE)
    variable ilinecur : integer := 0;
    variable ilinelst : integer := 0;
    variable iei_ack : slv16 := (others=>'0');
  begin

    ilinecur := to_integer(unsigned(EI_LINE));
    ilinelst := to_integer(unsigned(R_LINE));

    -- send info of currently highest priority request
    EI_PRI  <= conf_intp(ilinecur);
    EI_VECT <= conf_intv(ilinecur)(8 downto 2);
    
    -- route acknowledge back to winner line of last cycle
    iei_ack := (others=>'0');
    if EI_ACKM = '1' then
      iei_ack(ilinelst) := '1';
    end if;
    EI_ACK  <= iei_ack(EI_ACK'range);
    
  end process proc_intmap;
  
end syn;
