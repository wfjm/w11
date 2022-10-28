-- $Id: pdp11_gr.vhd 1310 2022-10-27 16:15:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2006-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_gr - syn
-- Description:    pdp11: general registers
--
-- Dependencies:   memlib/ram_1swar_1ar_gen
--
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  ise 8.2-14.7; viv 2014.4-2022.1; ghdl 0.18-2.0.0
-- Revision History: 
-- Date         Rev Version  Comment
-- 2022-10-25  1309   1.0.3  rename _gpr -> _gr
-- 2019-08-17  1203   1.0.2  fix for ghdl V0.36 -Whide warnings
-- 2011-11-18   427   1.0.4  now numeric_std clean
-- 2008-08-22   161   1.0.3  rename ubf_ -> ibf_; use iblib
-- 2007-12-30   108   1.0.2  use ubf_byte[01]
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_gr is                      -- general registers
  port (
    CLK    : in slbit;                  -- clock
    DIN   : in slv16;                   -- input data
    ASRC   : in slv3;                   -- source register number
    ADST   : in slv3;                   -- destination register number
    MODE   : in slv2;                   -- processor mode (k=>00,s=>01,u=>11)
    RSET   : in slbit;                  -- register set
    WE     : in slbit;                  -- write enable
    BYTOP  : in slbit;                  -- byte operation (write low byte only)
    PCINC  : in slbit;                  -- increment PC
    DSRC : out slv16;                   -- source register data
    DDST : out slv16;                   -- destination register data
    PC     : out slv16                  -- current PC value
  );
end pdp11_gr;

architecture syn of pdp11_gr is

-- --------------------------------------
-- the register map determines the internal register file storage address
-- of a register. The mapping is
--    ADDR  RNUM SET MODE
--    0000   000  0  --    R0 set 0
--    0001   001  0  --    R1 set 0
--    0010   010  0  --    R2 set 0
--    0011   011  0  --    R3 set 0
--    0100   100  0  --    R4 set 0
--    0101   101  0  --    R5 set 0
--    0110   110  -  00    SP kernel mode
--    0111   110  -  01    SP supervisor mode
--    1000   000  1  --    R0 set 1
--    1001   001  1  --    R1 set 1
--    1010   010  1  --    R2 set 1
--    1011   011  1  --    R3 set 1
--    1100   100  1  --    R4 set 1
--    1101   101  1  --    R5 set 1
--    1110   111  -  --    PC 
--    1111   110  -  11    SP user mode

  procedure do_regmap (
      signal PRNUM : in slv3;           -- register number
      signal PMODE : in slv2;           -- processor mode (k=>00,s=>01,u=>11)
      signal PRSET : in slbit;          -- register set
      signal PADDR : out slv4           -- internal address in regfile
    ) is
  begin
    if PRNUM = c_gr_pc then
      PADDR <= "1110";
    elsif PRNUM = c_gr_sp then
      PADDR <= PMODE(1) & "11" & PMODE(0);
    else
      PADDR <= PRSET & PRNUM;
    end if;
  end procedure do_regmap;

-- --------------------------------------

  signal MASRC : slv4 := (others=>'0'); -- mapped source register address
  signal MADST : slv4 := (others=>'0'); -- mapped destination register address
  signal WE1 : slbit := '0';            -- write enable high byte
  signal MEMSRC : slv16 := (others=>'0');-- source reg data from memory
  signal MEMDST : slv16 := (others=>'0');-- destination reg data from memory
  signal R_PC : slv16 := (others=>'0'); -- PC register

begin

  do_regmap(PRNUM => ASRC, PMODE => MODE, PRSET => RSET, PADDR => MASRC);
  do_regmap(PRNUM => ADST, PMODE => MODE, PRSET => RSET, PADDR => MADST);

  WE1 <= WE and not BYTOP;

  GR_LOW : ram_1swar_1ar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      WE    => WE,
      ADDRA => MADST,
      ADDRB => MASRC,
      DI    => DIN(ibf_byte0),
      DOA   => MEMDST(ibf_byte0),
      DOB   => MEMSRC(ibf_byte0));

  GR_HIGH : ram_1swar_1ar_gen
    generic map (
      AWIDTH => 4,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      WE    => WE1,
      ADDRA => MADST,
      ADDRB => MASRC,
      DI    => DIN(ibf_byte1),
      DOA   => MEMDST(ibf_byte1),
      DOB   => MEMSRC(ibf_byte1));

  proc_pc : process (CLK)
    alias R_PC15 : slv15 is R_PC(15 downto 1);  -- upper 15 bit of PC
  begin 
    if rising_edge(CLK) then
      if WE='1' and ADST=c_gr_pc then
        R_PC(ibf_byte0) <= DIN(ibf_byte0);
        if BYTOP = '0' then
          R_PC(ibf_byte1) <= DIN(ibf_byte1);
        end if;
      elsif PCINC = '1' then
        R_PC15 <= slv(unsigned(R_PC15) + 1);
      end if;
    end if;
  end process proc_pc;

  DSRC <= R_PC when ASRC=c_gr_pc else MEMSRC;
  DDST <= R_PC when ADST=c_gr_pc else MEMDST;
  PC <= R_PC;
    
end syn;
