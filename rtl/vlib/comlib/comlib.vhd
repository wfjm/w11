-- $Id: comlib.vhd 400 2011-07-31 09:02:16Z mueller $
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
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2, 11.4, 12.1; ghdl 0.18-0.29
-- Revision History: 
-- Date         Rev Version  Comment
-- 2011-07-30   400   1.3    added byte2word, word2byte
-- 2007-10-12    88   1.2.1  avoid ieee.std_logic_unsigned, use cast to unsigned
-- 2007-07-08    65   1.2    added procedure crc8_update_tbl
-- 2007-06-29    61   1.1.1  rename for crc8 SALT->INIT 
-- 2007-06-17    58   1.1    add crc8 
-- 2007-06-03    45   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

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

  procedure crc8_update (crc : inout slv8;
                         data : in slv8);
  procedure crc8_update_tbl (crc : inout slv8;
                             data : in slv8);

end package comlib;

-- ----------------------------------------------------------------------------

package body comlib is
  
  procedure crc8_update (crc : inout slv8;
                         data : in slv8) is
    variable t : slv8 := (others=>'0');
  begin

    t := data xor crc;
    crc(0) := t(0) xor t(4) xor t(5) xor t(6);
    crc(1) := t(1) xor t(5) xor t(6) xor t(7);
    crc(2) := t(0) xor t(2) xor t(4) xor t(5) xor t(7);
    crc(3) := t(0) xor t(1) xor t(3) xor t(4);
    crc(4) := t(0) xor t(1) xor t(2) xor t(6);
    crc(5) := t(1) xor t(2) xor t(3) xor t(7);
    crc(6) := t(2) xor t(3) xor t(4);
    crc(7) := t(3) xor t(4) xor t(5);
    
  end procedure crc8_update;
  
  procedure crc8_update_tbl (crc : inout slv8;
                             data : in slv8) is
    
    type crc8_tbl_type is array (0 to 255) of integer;
    variable crc8_tbl : crc8_tbl_type :=        -- generated with gen_crc8_tbl
      (   0,  29,  58,  39, 116, 105,  78,  83,
        232, 245, 210, 207, 156, 129, 166, 187,
        205, 208, 247, 234, 185, 164, 131, 158,
         37,  56,  31,   2,  81,  76, 107, 118,
        135, 154, 189, 160, 243, 238, 201, 212,
        111, 114,  85,  72,  27,   6,  33,  60,
         74,  87, 112, 109,  62,  35,   4,  25,
        162, 191, 152, 133, 214, 203, 236, 241,
         19,  14,  41,  52, 103, 122,  93,  64,
        251, 230, 193, 220, 143, 146, 181, 168,
        222, 195, 228, 249, 170, 183, 144, 141,
         54,  43,  12,  17,  66,  95, 120, 101,
        148, 137, 174, 179, 224, 253, 218, 199,
        124,  97,  70,  91,   8,  21,  50,  47,
         89,  68,  99, 126,  45,  48,  23,  10,
        177, 172, 139, 150, 197, 216, 255, 226,
         38,  59,  28,   1,  82,  79, 104, 117,
        206, 211, 244, 233, 186, 167, 128, 157,
        235, 246, 209, 204, 159, 130, 165, 184,
          3,  30,  57,  36, 119, 106,  77,  80,
        161, 188, 155, 134, 213, 200, 239, 242,
         73,  84, 115, 110,  61,  32,   7,  26,
        108, 113,  86,  75,  24,   5,  34,  63,
        132, 153, 190, 163, 240, 237, 202, 215,
         53,  40,  15,  18,  65,  92, 123, 102,
        221, 192, 231, 250, 169, 180, 147, 142,
        248, 229, 194, 223, 140, 145, 182, 171,
         16,  13,  42,  55, 100, 121,  94,  67,
        178, 175, 136, 149, 198, 219, 252, 225,
         90,  71,  96, 125,  46,  51,  20,   9,
        127,  98,  69,  88,  11,  22,  49,  44,
        151, 138, 173, 176, 227, 254, 217, 196
       );
    
  begin

    crc := conv_std_logic_vector(
             crc8_tbl(conv_integer(unsigned(data xor crc))), 8);
    
  end procedure crc8_update_tbl;
  
end package body comlib;
