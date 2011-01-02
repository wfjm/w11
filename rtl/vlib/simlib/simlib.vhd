-- $Id: simlib.vhd 346 2010-12-22 22:59:26Z mueller $
--
-- Copyright 2006-2010 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    simlib - sim
-- Description:    Support routines for test benches
--
-- Dependencies:   -
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 12.1; ghdl 0.18-0.29
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2010-12-22   346   1.3.7  rename readcommand -> readdotcomm
-- 2010-11-13   338   1.3.6  add simclkcnt; xx.x ns time in writetimestamp()
-- 2008-03-24   129   1.3.5  CLK_CYCLE now 31 bits
-- 2008-03-02   121   1.3.4  added readempty (to discard rest of line)
-- 2007-12-27   106   1.3.3  added simclk2v
-- 2007-12-15   101   1.3.2  add read_ea(time), readtagval[_ea](std_logic)
-- 2007-10-12    88   1.3.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-08-28    76   1.3    added writehex and writegen
-- 2007-08-10    72   1.2.2  remove entity simclk, put into separate source
-- 2007-08-03    71   1.2.1  readgen, readtagval, readtagval2: add base arg
-- 2007-07-29    70   1.2    readtagval2: add tag=- support; add readword_ea,
--                           readoptchar, writetimestamp
-- 2007-07-28    69   1.1.1  rename readrest -> testempty; add readgen
--                           use readgen in readtagval() and readtagval2()
-- 2007-07-22    68   1.1    add readrest, readtagval, readtagval2
-- 2007-06-30    62   1.0.1  remove clock_period ect constant defs
-- 2007-06-14    56   1.0    Initial version (renamed from pdp11_sim.vhd)
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use std.textio.all;

use work.slvtypes.all;

package simlib is

constant null_char : character := character'val(0);            -- '\0'
constant null_string : string(1 to 1) := (others=>null_char);  -- "\0"
  
procedure readwhite(                    -- read over white space
  L: inout line);                       -- line

procedure readoct(                      -- read slv in octal base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean);                   -- success flag

procedure readhex(                      -- read slv in hex base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean);                   -- success flag

procedure readgen(                      -- read slv generic base
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean;                    -- success flag
  base: in integer:= 2);                -- default base

procedure readcomment(
  L: inout line;
  good: out boolean);

procedure readdotcomm(
  L: inout line;
  name: out string;
  good: out boolean);

procedure readword(
  L: inout line;
  name: out string;
  good: out boolean);

procedure readoptchar(
  L: inout line;
  char: in character;
  good: out boolean);

procedure readempty(
  L: inout line);

procedure testempty(
  L: inout line;
  good: out boolean);

procedure testempty_ea(
  L: inout line);

procedure read_ea(
  L: inout line;
  value: out integer);
procedure read_ea(
  L: inout line;
  value: out time);

procedure read_ea(
  L: inout line;
  value: out std_logic);
procedure read_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readoct_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readhex_ea(
  L: inout line;
  value: out std_logic_vector);

procedure readgen_ea(
  L: inout line;
  value: out std_logic_vector;
  base: in integer:= 2);

procedure readword_ea(
  L: inout line;
  name: out string);

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2);
procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  base: in integer:= 2);

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic;
  good: out boolean);
procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic);

procedure readtagval2(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2);
procedure readtagval2_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  base: in integer:= 2);

procedure writeoct(                     -- write slv in octal base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0);                  -- field width

procedure writehex(                     -- write slv in hex base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0);                  -- field width

procedure writegen(                     -- write slv in generic base (arb. lth)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0;                   -- field width
  base: in integer:= 2);                -- default base

procedure writetimestamp(
  L: inout line;
  clkcyc: in slv31;
  str : in string := null_string);

-- ----------------------------------------------------------------------------

component simclk is                   -- test bench clock generator
  generic (
    PERIOD : time := 20 ns;           -- clock period
    OFFSET : time := 200 ns);         -- clock offset (first up transition)
  port (
    CLK  : out slbit;                 -- clock
    CLK_CYCLE  : out slv31;           -- clock cycle number
    CLK_STOP : in slbit               -- clock stop trigger
  );
end component;

component simclkv is                  -- test bench clock generator
                                      --  with variable periods
  port (
    CLK  : out slbit;                 -- clock
    CLK_CYCLE  : out slv31;           -- clock cycle number
    CLK_PERIOD : in time;             -- clock period
    CLK_HOLD : in slbit;              -- if 1, hold clocks in 0 state
    CLK_STOP : in slbit               -- clock stop trigger
  );
end component;

component simclkcnt is                -- test bench system clock cycle counter
  port (
    CLK  : in slbit;                  -- clock
    CLK_CYCLE  : out slv31            -- clock cycle number
  );
end component;

end package simlib;

-- ----------------------------------------------------------------------------

package body simlib is

procedure readwhite(                  -- read over white space
  L: inout line) is                   -- line
  variable ch : character;
begin
  while L'length>0 loop
    ch := L(L'left);
    exit when (ch/=' ' and ch/=HT);
    read(L,ch);
  end loop;
  
end procedure readwhite;
  
-- -------------------------------------

procedure readoct(                      -- read slv in octal base (arb. length)
  L: inout line;                        -- line 
  value: out std_logic_vector;          -- value to be read
  good: out boolean) is                 -- success flag
  
  variable nibble : std_logic_vector(2 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable ndig : integer;              -- number of digits
  variable ok : boolean;
  variable ichar : character;
  
begin
  
  assert not value'ascending(1)
    report "readoct called with ascending range"
    severity failure;
  assert value'length<=32
    report "readoct called with value'length > 32"
    severity failure; 
  
  readwhite(L);
  
  ndig := 0;
  sum := (others=>'U');
  
  while L'length>0 loop
    ok := true;
    case L(L'left) is
      when '0' => nibble := "000";
      when '1' => nibble := "001";
      when '2' => nibble := "010";
      when '3' => nibble := "011";
      when '4' => nibble := "100";
      when '5' => nibble := "101";
      when '6' => nibble := "110";
      when '7' => nibble := "111";
      when 'u'|'U' => nibble := "UUU";
      when 'x'|'X' => nibble := "XXX";
      when 'z'|'Z' => nibble := "ZZZ";
      when '-' => nibble := "---";
      when others => ok := false;
    end case;
    
    exit when not ok;
    read(L,ichar);
    ndig := ndig + 1;
    sum(sum'left downto 3) := sum(sum'left-3 downto 0);
    sum(2 downto 0) := nibble;
  end loop;
  
  ok := ndig>0;
  value := sum(value'range);
  good := ok;
  
end procedure readoct;

-- -------------------------------------

procedure readhex(                      -- read slv in hex base (arb. length)
  L: inout line;                        -- line
  value: out std_logic_vector;          -- value to be read
  good: out boolean) is                 -- success flag
  
  variable nibble : std_logic_vector(3 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable ndig : integer;              -- number of digits
  variable ok : boolean;
  variable ichar : character;
  
begin
  
  assert not value'ascending(1)
    report "readhex called with ascending range"
    severity failure;
  assert value'length<=32
    report "readhex called with value'length > 32"
    severity failure; 
    
  readwhite(L);
  
  ndig := 0;
  sum := (others=>'U');
  
  while L'length>0 loop
    ok := true;
    case L(L'left) is
      when '0'     => nibble := "0000";
      when '1'     => nibble := "0001";
      when '2'     => nibble := "0010";
      when '3'     => nibble := "0011";
      when '4'     => nibble := "0100";
      when '5'     => nibble := "0101";
      when '6'     => nibble := "0110";
      when '7'     => nibble := "0111";
      when '8'     => nibble := "1000";
      when '9'     => nibble := "1001";
      when 'a'|'A' => nibble := "1010";
      when 'b'|'B' => nibble := "1011";
      when 'c'|'C' => nibble := "1100";
      when 'd'|'D' => nibble := "1101";
      when 'e'|'E' => nibble := "1110";
      when 'f'|'F' => nibble := "1111";
      when 'u'|'U' => nibble := "UUUU";
      when 'x'|'X' => nibble := "XXXX";
      when 'z'|'Z' => nibble := "ZZZZ";
      when '-'     => nibble := "----";
      when others  => ok := false;
    end case;
    
    exit when not ok;
    read(L,ichar);
    ndig := ndig + 1;
    sum(sum'left downto 4) := sum(sum'left-4 downto 0);
    sum(3 downto 0) := nibble;
  end loop;
  
  ok := ndig>0;
  value := sum(value'range);
  good := ok;
  
end procedure readhex;

-- -------------------------------------

procedure readgen(                    -- read slv generic base
  L: inout line;            -- line
  value: out std_logic_vector;  -- value to be read
  good: out boolean;            -- success flag
  base: in integer := 2) is     -- default base
  
  variable nibble : std_logic_vector(3 downto 0);
  variable sum : std_logic_vector(31 downto 0);
  variable lbase : integer;           -- local base
  variable cbase : integer;           -- current base
  variable ok : boolean;
  variable ivalue : integer;
  variable ichar : character;
  
begin
  
  assert not value'ascending(1)
    report "readgen called with ascending range"
    severity failure;
  assert value'length<=32
    report "readgen called with value'length > 32"
    severity failure;
  assert base=2 or base=8 or base=10 or base=16
    report "readgen base not 2,8,10, or 16"
    severity failure;
    
  readwhite(L);
  
  cbase := base;
  lbase := 0;
  ok := true;
  
  if L'length >= 2 then
    if L(L'left+1) = '"' then
      case L(L'left) is
        when 'b'|'B' => lbase :=  2;
        when 'o'|'O' => lbase :=  8;
        when 'd'|'D' => lbase := 10;
        when 'x'|'X' => lbase := 16;
        when others => ok := false;
      end case;
    end if;
    if lbase /= 0 then
      read(L, ichar);
      read(L, ichar);
      cbase := lbase;
    end if;
  end if;

  if ok then
    case cbase is
      when  2 => read(L, value, ok);
      when  8 => readoct(L, value, ok);
      when 16 => readhex(L, value, ok);
      when 10 =>
        read(L, ivalue, ok);
        value := conv_std_logic_vector(ivalue, value'length);
      when others => null;
    end case;
  end if;
  
  if ok and lbase/=0 then
    if L'length>0 and  L(L'left)='"' then
      read(L, ichar);
    else
      ok := false;
    end if;
  end if;

  good := ok;
    
end procedure readgen;

-- -------------------------------------
  
procedure readcomment(
  L: inout line;
  good: out boolean) is
  variable ichar : character;
begin
  
  readwhite(L);
  
  good := true;
  if L'length > 0 then
    good := false;
    if L(L'left) = '#' then
      good := true;
    elsif L(L'left) = 'C' then
      good := true;
      writeline(output, L);
    end if;
  end if;
  
end procedure readcomment;

-- -------------------------------------
  
procedure readdotcomm(
  L: inout line;
  name: out string;
  good: out boolean) is
begin

  for i in name'range loop
    name(i) := ' ';
  end loop;
  good := false;
  
  if L'length>0 and L(L'left)='.' then
    readword(L, name, good);
  end if;
  
end procedure readdotcomm;
  
-- -------------------------------------
  
procedure readword(
  L: inout line;
  name: out string;
  good: out boolean) is

  variable ichar : character;
  variable ind : integer;

begin

  assert name'ascending(1)
    report "readword called with descending range for name"
    severity failure;

  readwhite(L);
  
  for i in name'range loop
    name(i) := ' ';
  end loop;
  ind := name'left;
  
  while L'length>0 and ind<=name'right loop
    ichar := L(L'left);
    exit when ichar=' ' or ichar=',' or ichar='|';
    read(L,ichar);
    name(ind) := ichar;
    ind := ind + 1;
  end loop;

  good := ind /= name'left;             -- ok if one non-blank found
  
end procedure readword;

-- -------------------------------------

procedure readoptchar(
  L: inout line;
  char: in character;
  good: out boolean) is

  variable ichar : character;

begin

  good := false;
  if L'length > 0 then
    if L(L'left) = char then
      read(L, ichar);
      good := true;
    end if;
  end if;
  
end procedure readoptchar;

-- -------------------------------------
  
procedure readempty(
  L: inout line) is

  variable ch : character;

begin

  while L'length>0 loop               -- anything left ?
    read(L,ch);                         -- read and discard it
  end loop;
  
end procedure readempty;

-- -------------------------------------
  
procedure testempty(
  L: inout line;
  good: out boolean) is

begin

  readwhite(L);                       -- discard white space
  good := true;                       -- good if now empty
  
  if L'length > 0 then                -- anything left ?
    good := false;                    -- assume bad
    if L'length >= 2 and              -- check for "--"
      L(L'left)='-' and L(L'left+1)='-' then
      good := true;                   -- in that case comment -> good
    end if;
  end if;
  
end procedure testempty;

-- -------------------------------------

procedure testempty_ea(
  L: inout line) is

  variable ok : boolean := false;

begin

  testempty(L, ok);
  assert ok report "extra chars in """ & L.all & """" severity failure;
  
end procedure testempty_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out integer) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(integer) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out time) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(time) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;

-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out std_logic) is

  variable ok : boolean := false;

begin
  
  read(L, value, ok);
  assert ok report "read(std_logic) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;
  
-- -------------------------------------

procedure read_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
    
  read(L, value, ok);
  assert ok report "read(std_logic_vector) conversion error in """ &
                   L.all & """" severity failure;
  
end procedure read_ea;
  
-- -------------------------------------

procedure readoct_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
  
  readoct(L, value, ok);
  assert ok report "readoct() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readoct_ea;
  
-- -------------------------------------

procedure readhex_ea(
  L: inout line;
  value: out std_logic_vector) is

  variable ok : boolean := false;

begin
  
  readhex(L, value, ok);
  assert ok report "readhex() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readhex_ea;
  
-- -------------------------------------

procedure readgen_ea(
  L: inout line;
  value: out std_logic_vector;
  base: in integer := 2) is

  variable ok : boolean := false;

begin
  
  readgen(L, value, ok, base);
  assert ok report "readgen() conversion error in """ &
                   L.all & """" severity failure;
  
end procedure readgen_ea;

-- -------------------------------------

procedure readword_ea(
  L: inout line;
  name: out string) is

  variable ok : boolean := false;

begin
    
  readword(L, name, ok);
  assert ok report "readword() read error in """ &
                   L.all & """" severity failure;
  
end procedure readword_ea;
  
-- -------------------------------------

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2) is
  
  variable itag : string(tag'range);
  variable ichar : character;
  variable imatch : boolean;
  
begin
  
  readwhite(L);
  
  for i in val'range loop
    val(i) := '0';
  end loop;
  good := true;
  imatch := false;
  
  if L'length > tag'length then
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';
    if imatch then
      read(L, itag);
      read(L, ichar);
      readgen(L, val, good, base);
    end if;
  end if;
  match := imatch;
  
end procedure readtagval;

-- -------------------------------------

procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic_vector;
  base: in integer:= 2) is

  variable ok : boolean := false;

begin
  readtagval(L, tag, match, val, ok, base);
  assert ok report "readtagval(std_logic_vector) conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval_ea;
    
-- -------------------------------------

procedure readtagval(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic;
  good: out boolean) is
  
  variable itag : string(tag'range);
  variable ichar : character;
  variable imatch : boolean;
  
begin
  
  readwhite(L);
  
  val := '0';
  good := true;
  imatch := false;
  
  if L'length > tag'length then
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';
    if imatch then
      read(L, itag);
      read(L, ichar);
      read(L, val, good);
    end if;
  end if;
  match := imatch;
  
end procedure readtagval;

-- -------------------------------------

procedure readtagval_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val: out std_logic) is

  variable ok : boolean := false;

begin
  readtagval(L, tag, match, val, ok);
  assert ok report "readtagval(std_logic) conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval_ea;
    
-- -------------------------------------

procedure readtagval2(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  good: out boolean;
  base: in integer:= 2) is
  
  variable itag : string(tag'range);
  variable imatch : boolean;
  variable igood : boolean;
  variable ichar : character;
  variable ok : boolean;
  
begin

  readwhite(L);

  for i in val1'range loop            -- zero val1
    val1(i) := '0';
  end loop;
  for i in val2'range loop            -- zero val2
    val2(i) := '0';
  end loop;
  igood := true;
  imatch := false;
    
  if L'length > tag'length then       -- check for tag
    imatch := L(L'left to L'left+tag'length-1) = tag and
              L(L'left+tag'length) = '=';

    if imatch then                      -- if found
      read(L, itag);                    -- remove tag
      read(L, ichar);                   -- remove =
      
      igood := false;
      readoptchar(L, '-', ok);          -- check for tag=-
      if ok then
        for i in val2'range loop        -- set mask to all 1 (ignore)
          val2(i) := '1';
        end loop;
        igood := true;
      else                              -- here if tag=bit[,bit]
        readgen(L, val1, igood, base);  -- read val1
        if igood then
          readoptchar(L, ',', ok);      -- check(and remove) ,
          if ok then
            readgen(L, val2, igood, base); -- and read val2
          end if;
        end if;
      end if;
    end if;
  end if;
    
  match := imatch;
  good := igood;
  
end procedure readtagval2;

-- -------------------------------------

procedure readtagval2_ea(
  L: inout line;
  tag: in string;
  match: out boolean;
  val1: out std_logic_vector;
  val2: out std_logic_vector;
  base: in integer:= 2) is

  variable ok : boolean := false;

begin
  readtagval2(L, tag, match, val1, val2, ok, base);
  assert ok report "readtagval2() conversion error in """ &
                   L.all & """" severity failure;
end procedure readtagval2_ea;
    
-- -------------------------------------

procedure writeoct(                     -- write slv in octal base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0) is                -- field width
  
  variable nbit : integer;              -- number of bits
  variable ndig : integer;              -- number of digits
  variable iwidth : integer;
  variable ioffset : integer;
  variable nibble : std_logic_vector(2 downto 0);
  variable ochar : character;
  
begin
  
  assert not value'ascending(1)
    report "writeoct called with ascending range"
    severity failure;
  
  nbit := value'length(1);
  ndig := (nbit+2)/3;
  iwidth := nbit mod 3;
  if iwidth = 0 then
    iwidth := 3;
  end if;
  ioffset := value'left(1) - iwidth+1;
  if justified=right and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
  for i in 0 to ndig-1 loop
    nibble := "000";
    nibble(iwidth-1 downto 0) := value(ioffset+iwidth-1 downto ioffset);
    ochar := ' ';
    for i in nibble'range loop
      case nibble(i) is
        when 'U' => ochar := 'U';
        when 'X' => ochar := 'X';
        when 'Z' => ochar := 'Z';
        when '-' => ochar := '-';
        when others => null;
      end case;
    end loop;  -- i
    if ochar = ' ' then
      write(L,conv_integer(unsigned(nibble)));
    else
      write(L,ochar);
    end if;
    iwidth := 3;
    ioffset := ioffset - 3;
  end loop;  -- i
  if justified=left and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
end procedure writeoct;

-- -------------------------------------

procedure writehex(                     -- write slv in hex base (arb. length)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0) is                -- field width
  
  variable nbit : integer;              -- number of bits
  variable ndig : integer;              -- number of digits
  variable iwidth : integer;
  variable ioffset : integer;
  variable nibble : std_logic_vector(3 downto 0);
  variable ochar : character;
  variable hextab : string(1 to 16) := "0123456789abcdef";
  
begin
  
  assert not value'ascending(1)
    report "writehex called with ascending range"
    severity failure;
  
  nbit := value'length(1);
  ndig := (nbit+3)/4;
  iwidth := nbit mod 4;
  if iwidth = 0 then
    iwidth := 4;
  end if;
  ioffset := value'left(1) - iwidth+1;
  if justified=right and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
  for i in 0 to ndig-1 loop
    nibble := "0000";
    nibble(iwidth-1 downto 0) := value(ioffset+iwidth-1 downto ioffset);
    ochar := ' ';
    for i in nibble'range loop
      case nibble(i) is
        when 'U' => ochar := 'U';
        when 'X' => ochar := 'X';
        when 'Z' => ochar := 'Z';
        when '-' => ochar := '-';
        when others => null;
      end case;
    end loop;  -- i
    if ochar = ' ' then
      write(L,hextab(conv_integer(unsigned(nibble))+1));
    else
      write(L,ochar);
    end if;
    iwidth := 4;
    ioffset := ioffset - 4;
  end loop;  -- i
  if justified=left and field>ndig then
    for i in ndig+1 to field loop
      write(L,' ');
    end loop;  -- i
  end if;
end procedure writehex;

-- -------------------------------------

procedure writegen(                     -- write slv in generic base (arb. lth)
  L: inout line;                        -- line
  value: in std_logic_vector;           -- value to be written
  justified: in side:=right;            -- justification (left/right)
  field: in width:=0;                   -- field width
  base: in integer:=2) is               -- default base

begin

  case base is
    when  2 => write(L, value, justified, field);
    when  8 => writeoct(L, value, justified, field);
    when 16 => writehex(L, value, justified, field);
    when others => report "writegen base not 2,8, or 16"
                     severity failure;
  end case;
  
end procedure writegen;

-- -------------------------------------

procedure writetimestamp(
  L: inout line;
  clkcyc: in slv31;
  str: in string := null_string) is

  variable t_nsec  : integer := 0;
  variable t_psec  : integer := 0;
  variable t_dnsec : integer := 0;

begin

  t_nsec  := now / 1 ns;
  t_psec  := (now - t_nsec * 1 ns) / 1 ps;
  t_dnsec := t_psec/100;
  
  -- write(L, now, right, 12);
  write(L, t_nsec, right, 8);
  write(L,'.');
  write(L, t_dnsec, right, 1);
  write(L, string'(" ns"));
  
  write(L, conv_integer(unsigned(clkcyc)), right, 7);
  if str /= null_string then
    write(L, str);
  end if;

end procedure writetimestamp;

end package body simlib;

