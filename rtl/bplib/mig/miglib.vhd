-- $Id: miglib.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   miglib
-- Description:    MIG interface components - generic
--
-- Dependencies:   -
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-26  1094   1.0    Initial version 
-- 2018-11-11  1067   0.1    First draft
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;

package miglib is
  
constant c_migui_cmd_read  : slv3 := "001";
constant c_migui_cmd_write : slv3 := "000";

type sramif2migui_moni_type is record   -- sramif2migui monitor port
  rdrhit   : slbit;               -- read row hit
  wrrhit   : slbit;               -- write row hit
  wrflush  : slbit;               -- write row flush
  migcbusy : slbit;               -- mig not ready for command
  migwbusy : slbit;               -- mig not ready for data write
  miguirst : slbit;               -- mig UI_CLK_SYNC_RST asserted
  migcacow : slbit;               -- mig calibration complete wait
end record sramif2migui_moni_type;
  
constant sramif2migui_moni_init : sramif2migui_moni_type := (
  '0','0','0',                    -- rdrhit,wrrhit,wrflush
  '0','0','0','0'                 -- migcbusy,migwbusy,miguirst,migcacow
);

component sramif2migui_core is          -- SRAM to MIG interface core
  generic (
    BAWIDTH : positive :=  4;           -- byte address width
    MAWIDTH : positive := 28);          -- memory address width
  port (
    CLK   : in slbit;                   -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY  : out slbit;                  -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR  : in slv20;                   -- address  (32 bit word address)
    BE    : in slv4;                    -- byte enable
    DI    : in slv32;                   -- data in  (memory view)
    DO    : out slv32;                  -- data out (memory view)
    MONI  : out sramif2migui_moni_type; -- monitor signals
    UI_CLK              : in  slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : in  slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : in slbit;     -- MIGUI calibration done
    APP_RDY             : in  slbit;    -- MIGUI ready for cmd
    APP_EN              : out slbit;    -- MIGUI command enable
    APP_CMD             : out slv3;     -- MIGUI command
    APP_ADDR            : out slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_WDF_RDY         : in  slbit;      -- MIGUI ready for data write
    APP_WDF_WREN        : out slbit;      -- MIGUI data write enable
    APP_WDF_DATA        : out slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI write data
    APP_WDF_MASK        : out slv((2**BAWIDTH)-1 downto 0);  -- MIGUI write mask
    APP_WDF_END         : out slbit;                         -- MIGUI write end
    APP_RD_DATA_VALID   : in  slbit;                         -- MIGUI read valid
    APP_RD_DATA         : in  slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : in  slbit                          -- MIGUI read end
  );
end component;

component migui2bram is                 -- MIG to BRAM adapter
  generic (
    BAWIDTH    : positive :=  4;        -- byte address width
    MAWIDTH    : positive := 28;        -- memory address width
    RAWIDTH    : positive := 19;        -- BRAM memory address width
    RDELAY     : positive :=  5;        -- read response delay
    CLKMUI_MUL     : positive :=  6;    -- multiplier for MIG UI clock
    CLKMUI_DIV     : positive := 12;    -- divider for MIG UI clock
    CLKMSYS_PERIOD : real := 6.000);    -- MIG SYS_CLK period
  port (
    SYS_CLK             : in  slbit;    -- system clock
    SYS_RST             : in  slbit;    -- system reset
    UI_CLK              : out slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : out slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : out slbit;    -- MIGUI calibration done
    APP_RDY             : out slbit;    -- MIGUI ready for cmd
    APP_EN              : in  slbit;    -- MIGUI command enable
    APP_CMD             : in  slv3;     -- MIGUI command
    APP_ADDR            : in  slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_WDF_RDY         : out slbit;    -- MIGUI ready for data write
    APP_WDF_WREN        : in  slbit;    -- MIGUI data write enable
    APP_WDF_DATA        : in  slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI write data
    APP_WDF_MASK        : in  slv((2**BAWIDTH)-1 downto 0);  -- MIGUI write mask
    APP_WDF_END         : in  slbit;                         -- MIGUI write end
    APP_RD_DATA_VALID   : out slbit;                         -- MIGUI read valid
    APP_RD_DATA         : out slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : out slbit                          -- MIGUI read end
  );
end component;

component migui_core_gsim is            -- MIG interface simulation core
  generic (
    BAWIDTH    : positive :=  4;        -- byte address width
    MAWIDTH    : positive := 28;        -- memory address width
    SAWIDTH    : positive := 24;        -- simulator memory address width
    CLKMUI_MUL : positive :=  6;        -- multiplier for MIG UI clock
    CLKMUI_DIV : positive := 12;        -- divider for MIG UI clock
    CACO_WAIT  : positive := 50);       -- UI_CLK cycles till CALIB_COMP = 1
  port (
    SYS_CLK             : in  slbit;    -- system clock
    SYS_RST             : in  slbit;    -- system reset
    UI_CLK              : out slbit;    -- MIGUI clock
    UI_CLK_SYNC_RST     : out slbit;    -- MIGUI reset
    INIT_CALIB_COMPLETE : out slbit;    -- MIGUI calibration done
    APP_RDY             : out slbit;    -- MIGUI ready for cmd
    APP_EN              : in  slbit;    -- MIGUI command enable
    APP_CMD             : in  slv3;     -- MIGUI command
    APP_ADDR            : in  slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_WDF_RDY         : out slbit;    -- MIGUI ready for data write
    APP_WDF_WREN        : in  slbit;    -- MIGUI data write enable
    APP_WDF_DATA        : in  slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI write data
    APP_WDF_MASK        : in  slv((2**BAWIDTH)-1 downto 0);  -- MIGUI write mask
    APP_WDF_END         : in  slbit;                         -- MIGUI write end
    APP_RD_DATA_VALID   : out slbit;                         -- MIGUI read valid
    APP_RD_DATA         : out slv(8*(2**BAWIDTH)-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : out slbit;                         -- MIGUI read end
    APP_REF_REQ         : in  slbit;      -- MIGUI refresh request
    APP_ZQ_REQ          : in  slbit;      -- MIGUI ZQ calibrate request
    APP_REF_ACK         : out slbit;      -- MIGUI refresh acknowledge
    APP_ZQ_ACK          : out slbit       -- MIGUI ZQ calibrate acknowledge
  );
end component;

end package miglib;
