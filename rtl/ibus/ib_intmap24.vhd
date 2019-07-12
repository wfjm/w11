-- $Id: ib_intmap24.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2017-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    ib_intmap24 - syn
-- Description:    pdp11: external interrupt mapper (23 line)
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2016.4-2017.2; ghdl 0.33-0.35
--
-- Synthesized:
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic MHz
-- 2016-05-26   641 2016.4  xc7a100t-1      0    48     0     0     -   -
-- 2015-02-22   641 i 14.7  xc6slx16-2      0    38     0     0    20   -
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-04-23  1136   1.1    BUGFIX: ensure ACK send to correct device
-- 2017-01-28   846   1.0    Initial version (cloned from ib_intmap.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.iblib.all;

-- ----------------------------------------------------------------------------

entity ib_intmap24 is                   -- external interrupt mapper (23 line)
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
end ib_intmap24;

architecture syn of ib_intmap24 is

  signal EI_LINE : slv5 := (others=>'0');    -- external interrupt line
  signal R_LINE :  slv5 := (others=>'0');    -- line on last cycle

  type intp_type is array (23 downto 0) of slv3;
  type intv_type is array (23 downto 0) of slv9;

  constant conf_intp : intp_type :=
    (slv(to_unsigned(INTMAP(23).pri,3)),  -- line 23
     slv(to_unsigned(INTMAP(22).pri,3)),  -- line 22
     slv(to_unsigned(INTMAP(21).pri,3)),  -- line 21
     slv(to_unsigned(INTMAP(20).pri,3)),  -- line 20
     slv(to_unsigned(INTMAP(19).pri,3)),  -- line 19
     slv(to_unsigned(INTMAP(18).pri,3)),  -- line 18
     slv(to_unsigned(INTMAP(17).pri,3)),  -- line 17
     slv(to_unsigned(INTMAP(16).pri,3)),  -- line 16
     slv(to_unsigned(INTMAP(15).pri,3)),  -- line 15
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
    (
     slv(to_unsigned(INTMAP(23).vec,9)),  -- line 23
     slv(to_unsigned(INTMAP(22).vec,9)),  -- line 22
     slv(to_unsigned(INTMAP(21).vec,9)),  -- line 21
     slv(to_unsigned(INTMAP(20).vec,9)),  -- line 20
     slv(to_unsigned(INTMAP(19).vec,9)),  -- line 19
     slv(to_unsigned(INTMAP(18).vec,9)),  -- line 18
     slv(to_unsigned(INTMAP(17).vec,9)),  -- line 17
     slv(to_unsigned(INTMAP(16).vec,9)),  -- line 16
     slv(to_unsigned(INTMAP(15).vec,9)),  -- line 15
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

  EI_LINE <= "10111" when EI_REQ(23)='1' else
             "10110" when EI_REQ(22)='1' else
             "10101" when EI_REQ(21)='1' else
             "10100" when EI_REQ(20)='1' else
             "10011" when EI_REQ(19)='1' else
             "10010" when EI_REQ(18)='1' else
             "10001" when EI_REQ(17)='1' else
             "10000" when EI_REQ(16)='1' else
             "01111" when EI_REQ(15)='1' else
             "01110" when EI_REQ(14)='1' else
             "01101" when EI_REQ(13)='1' else
             "01100" when EI_REQ(12)='1' else
             "01011" when EI_REQ(11)='1' else
             "01010" when EI_REQ(10)='1' else
             "01001" when EI_REQ( 9)='1' else
             "01000" when EI_REQ( 8)='1' else
             "00111" when EI_REQ( 7)='1' else
             "00110" when EI_REQ( 6)='1' else
             "00101" when EI_REQ( 5)='1' else
             "00100" when EI_REQ( 4)='1' else
             "00011" when EI_REQ( 3)='1' else
             "00010" when EI_REQ( 2)='1' else
             "00001" when EI_REQ( 1)='1' else
             "00000";

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
    variable iei_ack  : slv24 := (others=>'0');
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
