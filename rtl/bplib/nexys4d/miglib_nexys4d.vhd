-- $Id: miglib_nexys4d.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Package Name:   miglib_nexys4d
-- Description:    MIG interface components - for nexys4d
--
-- Dependencies:   -
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-30  1099   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.slvtypes.all;
use work.miglib.all;

package miglib_nexys4d is
  
constant mig_bawidth : positive :=  4;               -- byte addr width
constant mig_mawidth : positive := 27;               -- mem addr width    
constant mig_mwidth  : positive := 2**mig_bawidth;   -- mask width ( 16)
constant mig_dwidth  : positive := 8*mig_mwidth;     -- data width (128)

component sramif_mig_nexys4d is         -- SRAM to DDR via MIG for nexys4d
  port (
    CLK    : in slbit;                  -- clock
    RESET  : in slbit;                  -- reset
    REQ    : in slbit;                  -- request
    WE     : in slbit;                  -- write enable
    BUSY   : out slbit;                 -- controller busy
    ACK_R  : out slbit;                 -- acknowledge read
    ACK_W  : out slbit;                 -- acknowledge write
    ACT_R  : out slbit;                 -- signal active read
    ACT_W  : out slbit;                 -- signal active write
    ADDR   : in slv20;                  -- address  (32 bit word address)
    BE     : in slv4;                   -- byte enable
    DI     : in slv32;                  -- data in  (memory view)
    DO     : out slv32;                 -- data out (memory view)
    CLKMIG : in slbit;                  -- sys clock for mig core
    CLKREF : in slbit;                  -- ref clock for mig core
    TEMP   : in slv12;                  -- die temperature
    MONI   : out sramif2migui_moni_type;-- monitor signals
    DDR2_DQ      : inout slv16;         -- dram: data in/out
    DDR2_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR2_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR2_ADDR    : out   slv13;         -- dram: address
    DDR2_BA      : out   slv3;          -- dram: bank address
    DDR2_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR2_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR2_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR2_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR2_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR2_CKE     : out   slv1;          -- dram: clock enable
    DDR2_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR2_DM      : out   slv2;          -- dram: data input mask
    DDR2_ODT     : out   slv1           -- dram: on-die termination
  );
end component;

component migui_nexys4d is              -- MIG generated for nexys4d
  port (
    DDR2_DQ      : inout slv16;         -- dram: data in/out
    DDR2_DQS_P   : inout slv2;          -- dram: data strobe (diff-p)
    DDR2_DQS_N   : inout slv2;          -- dram: data strobe (diff-n)
    DDR2_ADDR    : out   slv13;         -- dram: address
    DDR2_BA      : out   slv3;          -- dram: bank address
    DDR2_RAS_N   : out   slbit;         -- dram: row addr strobe    (act.low)
    DDR2_CAS_N   : out   slbit;         -- dram: column addr strobe (act.low)
    DDR2_WE_N    : out   slbit;         -- dram: write enable       (act.low)
    DDR2_CK_P    : out   slv1;          -- dram: clock (diff-p)
    DDR2_CK_N    : out   slv1;          -- dram: clock (diff-n)
    DDR2_CKE     : out   slv1;          -- dram: clock enable
    DDR2_CS_N    : out   slv1;          -- dram: chip select        (act.low)
    DDR2_DM      : out   slv2;          -- dram: data input mask
    DDR2_ODT     : out   slv1;          -- dram: on-die termination
    APP_ADDR            : in  slv(mig_mawidth-1 downto 0); -- MIGUI address
    APP_CMD             : in  slv3;       -- MIGUI command
    APP_EN              : in  slbit;      -- MIGUI command enable
    APP_WDF_DATA        : in  slv(mig_dwidth-1 downto 0); -- MIGUI write data
    APP_WDF_END         : in  slbit;                      -- MIGUI write end
    APP_WDF_MASK        : in  slv(mig_mwidth-1 downto 0); -- MIGUI write mask
    APP_WDF_WREN        : in  slbit;                      -- MIGUI write enable
    APP_RD_DATA         : out slv(mig_dwidth-1 downto 0); -- MIGUI read data
    APP_RD_DATA_END     : out slbit;                      -- MIGUI read end
    APP_RD_DATA_VALID   : out slbit;                      -- MIGUI read valid
    APP_RDY             : out slbit;      -- MIGUI ready for cmd
    APP_WDF_RDY         : out slbit;      -- MIGUI ready for data write
    APP_SR_REQ          : in  slbit;      -- MIGUI reserved (tie to 0)
    APP_REF_REQ         : in  slbit;      -- MIGUI refresh reques
    APP_ZQ_REQ          : in  slbit;      -- MIGUI ZQ calibrate request
    APP_SR_ACTIVE       : out slbit;      -- MIGUI reserved (ignore)
    APP_REF_ACK         : out slbit;      -- MIGUI refresh acknowledge
    APP_ZQ_ACK          : out slbit;      -- MIGUI ZQ calibrate acknowledge
    UI_CLK              : out slbit;      -- MIGUI clock
    UI_CLK_SYNC_RST     : out slbit;      -- MIGUI reset
    INIT_CALIB_COMPLETE : out slbit;      -- MIGUI calibration done
    SYS_CLK_I           : in  slbit;      -- MIGUI system clock
    CLK_REF_I           : in  slbit;      -- MIGUI reference clock
    DEVICE_TEMP_I       : in  slv12;      -- MIGUI xadc temperature
    SYS_RST             : in  slbit       -- MIGUI system reset
  );
end component;

end package miglib_nexys4d;
