-- $Id: comlib.vhd 427 2011-11-19 21:04:11Z mueller $
--
-- Copyright 2007-2011 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Package Name:   comlib
-- Description:    communication components
--
-- Dependencies:   -
-- Tool versions:  xst 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-09-17   410   1.4    now numeric_std clean; use for crc8 'A6' polynomial
--                           of Koopman et al.; crc8_update(_tbl) now function
-- 2011-07-30   400   1.3    added byte2word, word2byte
-- 2007-10-12    88   1.2.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.2    added procedure crc8_update_tbl
-- 2007-06-29    61   1.1.1  rename for crc8 SALT->INIT 
-- 2007-06-17    58   1.1    add crc8 
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;

package comlib is

component byte2word is                  -- 2 byte -> 1 word stream converter
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data (byte)
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv16;                     -- output data (word)
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    ODD : out slbit                     -- odd byte pending
  );
end component;

component word2byte is                  -- 1 word -> 2 byte stream converter
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv16;                      -- input data (word)
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv8;                      -- output data (byte)
    VAL : out slbit;                    -- read valid
    HOLD : in slbit;                    -- read hold
    ODD : out slbit                     -- odd byte pending
  );
end component;

component cdata2byte is                 -- 9bit comma,data -> byte stream
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    NCOMM : positive :=  4);            -- number of comma chars
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv9;                       -- input data; bit 8 = komma flag
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv8;                      -- output data
    VAL : out slbit;                    -- read valid
    HOLD : in slbit                     -- read hold
  );
end component;

component byte2cdata is                 -- byte stream -> 9bit comma,data
  generic (
    CPREF : slv4 :=  "1000";            -- comma prefix
    NCOMM : positive :=  4);            -- number of comma chars
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    DI : in slv8;                       -- input data
    ENA : in slbit;                     -- write enable
    BUSY : out slbit;                   -- write port hold    
    DO : out slv9;                      -- output data; bit 8 = komma flag
    VAL : out slbit;                    -- read valid
    HOLD : in slbit                     -- read hold
  );
end component;

component crc8 is                       -- crc-8 generator, checker
  generic (
    INIT: slv8 :=  "00000000");         -- initial state of crc register
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    ENA : in slbit;                     -- update enable
    DI : in slv8;                       -- input data
    CRC : out slv8                      -- crc code
  );
end component;

  function crc8_update     (crc : in slv8; data : in slv8) return slv8;
  function crc8_update_tbl (crc : in slv8; data : in slv8) return slv8;

end package comlib;

-- ----------------------------------------------------------------------------

package body comlib is
  
  function crc8_update (crc: in slv8; data: in slv8) return slv8 is
    variable t : slv8 := (others=>'0');
    variable n : slv8 := (others=>'0');
  begin

    t := data xor crc;

    n(0) := t(5) xor t(4) xor t(2) xor t(0);
    n(1) := t(6) xor t(5) xor t(3) xor t(1);
    n(2) := t(7) xor t(6) xor t(5) xor t(0);
    n(3) := t(7) xor t(6) xor t(5) xor t(4) xor t(2) xor t(1) xor t(0);
    n(4) := t(7) xor t(6) xor t(5) xor t(3) xor t(2) xor t(1);
    n(5) := t(7) xor t(6) xor t(4) xor t(3) xor t(2);
    n(6) := t(7) xor t(3) xor t(2) xor t(0);
    n(7) := t(4) xor t(3) xor t(1);

    return n;
    
  end function crc8_update;
  
  function crc8_update_tbl (crc: in slv8; data: in slv8) return slv8 is
    
    type crc8_tbl_type is array (0 to 255) of integer;
    variable crc8_tbl : crc8_tbl_type :=        -- generated with gen_crc8_tbl
      (  0,  77, 154, 215, 121,  52, 227, 174,    -- 00-07
       242, 191, 104,  37, 139, 198,  17,  92,    -- 00-0f
       169, 228,  51, 126, 208, 157,  74,   7,    -- 10-17
        91,  22, 193, 140,  34, 111, 184, 245,    -- 10-1f
        31,  82, 133, 200, 102,  43, 252, 177,    -- 20-27
       237, 160, 119,  58, 148, 217,  14,  67,    -- 20-2f
       182, 251,  44,  97, 207, 130,  85,  24,    -- 30-37
        68,   9, 222, 147,  61, 112, 167, 234,    -- 30-3f
        62, 115, 164, 233,  71,  10, 221, 144,    -- 40-47
       204, 129,  86,  27, 181, 248,  47,  98,    -- 40-4f
       151, 218,  13,  64, 238, 163, 116,  57,    -- 50-57
       101,  40, 255, 178,  28,  81, 134, 203,    -- 50-5f
        33, 108, 187, 246,  88,  21, 194, 143,    -- 60-67
       211, 158,  73,   4, 170, 231,  48, 125,    -- 60-6f
       136, 197,  18,  95, 241, 188, 107,  38,    -- 70-70
       122,  55, 224, 173,   3,  78, 153, 212,    -- 70-7f
       124,  49, 230, 171,   5,  72, 159, 210,    -- 80-87
       142, 195,  20,  89, 247, 186, 109,  32,    -- 80-8f
       213, 152,  79,   2, 172, 225,  54, 123,    -- 90-97
        39, 106, 189, 240,  94,  19, 196, 137,    -- 90-9f
        99,  46, 249, 180,  26,  87, 128, 205,    -- a0-a7
       145, 220,  11,  70, 232, 165, 114,  63,    -- a0-af
       202, 135,  80,  29, 179, 254,  41, 100,    -- b0-b7
        56, 117, 162, 239,  65,  12, 219, 150,    -- b0-bf
        66,  15, 216, 149,  59, 118, 161, 236,    -- c0-c7
       176, 253,  42, 103, 201, 132,  83,  30,    -- c0-cf
       235, 166, 113,  60, 146, 223,   8,  69,    -- d0-d7
        25,  84, 131, 206,  96,  45, 250, 183,    -- d0-df
        93,  16, 199, 138,  36, 105, 190, 243,    -- e0-e7
       175, 226,  53, 120, 214, 155,  76,   1,    -- e0-ef
       244, 185, 110,  35, 141, 192,  23,  90,    -- f0-f7
         6,  75, 156, 209, 127,  50, 229, 168     -- f0-ff
      );
    
  begin

    return slv(to_unsigned(crc8_tbl(to_integer(unsigned(data xor crc))), 8));
    
  end function crc8_update_tbl;
  
end package body comlib;
