-- $Id: migui_core_gsim.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    migui_core_gsim - sim
-- Description:    MIG interface simulation core
--
-- Dependencies:   sfs_gsim_core
-- Test bench:     tb/tb_sramif2migui_core
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-28  1096   1.0    Initial version
-- 2018-11-10  1067   0.1    First draft 
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.miglib.all;

entity migui_core_gsim is               -- MIG interface simulation core
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
    APP_WDF_RDY         : out slbit;      -- MIGUI ready for data write
    APP_WDF_WREN        : in  slbit;      -- MIGUI data write enable
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
end migui_core_gsim;


architecture sim of migui_core_gsim is
  
  constant mwidth : positive   := 2**BAWIDTH;    -- mask width (8 or 16)
  constant dwidth : positive   := 8*mwidth;      -- data width (64 or 128)

  -- row/col split only relevant for timing simulation
  -- use 16kbit->2kByte column width as used in MT41K128M16 on arty board
  constant colwidth : positive := 11;
  constant rowwidth : positive := MAWIDTH-colwidth;
  subtype  addr_f_row is integer range MAWIDTH-1 downto colwidth;

  subtype bv8 is bit_vector(7 downto 0);
  constant memsize : positive := 2**SAWIDTH;
  constant datzero : bv8 := (others=>'0');
  type ram_type is array (0 to memsize-1) of bv8;
  
  -- timing constants
  constant c_rdwait_rhit : positive :=  2; -- read wait row match
  constant c_rdwait_rmis : positive :=  5; -- read wait row miss
  constant c_wrwait_rhit : positive :=  2; -- write wait row match
  constant c_wrwait_rmis : positive :=  5; -- write wait row miss
  constant c_wrwait_max  : positive := c_wrwait_rmis; -- write wait maximum
  -- the REF and ZQ delays are as observed for arty board
  constant c_refwait     : positive := 10;    -- REF_REQ to REF_ACK delay
  constant c_zqwait      : positive :=  8;    -- ZQ_REQ  to ZQ_ACK  delay
  -- the RDY pattern gives 23% busy (4 out of 13 cycles)
  -- good enough for simulation; observed pattern on arty shows ~6% busy,
  constant c_crdy_init   : slv13    := "0001111110111";  -- block 4 of 13;

  type regs_type is record
    cacowait : natural;                  -- CACO wait down counter
    enacaco  : slbit;                    -- CACO enable
    enardy   : slbit;                    -- RDY  enable
    rowaddr  : slv(rowwidth-1 downto 0); -- current row address
    rdwait   : natural;                  -- read wait cycles pending
    wrwait   : natural;                  -- write wait cycles pending
    crdypat  : slv13;                    -- crdy pattern
    refwait  : natural;                  -- req_ack wait counter
    zqwait   : natural;                  -- zq_ack  wait counter
  end record regs_type;
  
  constant rowaddr_init   : slv(rowwidth-1 downto 0) := (others=>'1');

  constant regs_init : regs_type := (
    CACO_WAIT,'0','0',                  -- cacowait,enacaco,enardy
    rowaddr_init,                       -- rowaddr
    0,0,                                -- rdwait,wrwait
    c_crdy_init,                        -- crdypat
    0,0                                 -- refwait,zqwait
  );

  signal CLK : slbit;                   -- local copy of UI_CLK

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)
  
  signal CLKFX : slbit;

  signal MEM_EN : slbit := '0';         -- sim mem enable
  signal MEM_WE : slbit := '0';         -- sim mem write enable
  signal MEM_ADDR : slv(SAWIDTH-BAWIDTH-1 downto 0); -- sim mem base address
  signal R_MEMDO  : slv(dwidth-1 downto 0) := (others=>'0');


begin
  
  assert BAWIDTH = 3 or BAWIDTH = 4
    report "assert( BAWIDTH = 3 or 4 )"
    severity failure;
  
  UICLKGEN : sfs_gsim_core              -- mig ui clock generator
    generic map (
      VCO_DIVIDE   => 1,
      VCO_MULTIPLY => CLKMUI_MUL,
      OUT_DIVIDE   => CLKMUI_DIV)
    port map (
      CLKIN  => SYS_CLK,
      CLKFX  => CLKFX,
      LOCKED => open
    );

  CLK    <= CLKFX;                      -- !! copy both local CLK and exported 
  UI_CLK <= CLKFX;                      -- !! UI_CLK to avoid delta cycle diff
  UI_CLK_SYNC_RST <= '0';
  
  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if SYS_RST = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, APP_EN, APP_ADDR, APP_CMD,
                      APP_WDF_WREN, APP_WDF_END,
                      APP_REF_REQ,APP_ZQ_REQ, R_MEMDO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable iappcrdy   : slbit := '0';
    variable iappwrdy   : slbit := '0';
    variable iapprefack : slbit := '0';
    variable iappzqack  : slbit := '0';
    variable imemen  : slbit := '0';
    variable imemwe  : slbit := '0';
    variable irdval  : slbit := '0';

  begin

    r := R_REGS;
    n := R_REGS;

    iappcrdy   := '1';
    iappwrdy   := '1';
    iapprefack := '0';
    iappzqack  := '0';
    imemen   := '0';
    imemwe   := '0';
    irdval   := '0';

    n.crdypat := r.crdypat(11 downto 0) & r.crdypat(12); -- circular right shift

    -- simulate CACO wait
    if r.cacowait > 0 then
      n.cacowait := r.cacowait - 1;
      if r.cacowait <= CACO_WAIT/2 then         -- half of CACO wait reached ?
        n.enardy := '1';                          -- enable RDY's
      end if;
      if r.cacowait = 1 then                    -- CACO wait ended ?
        n.enacaco := '1';                         -- assert CACO
      end if;
    end if;
    
    -- process cmd requests
    if r.wrwait >= c_wrwait_max then
      iappcrdy := '0';
      iappwrdy := '0';
    elsif r.rdwait > 0 then
      iappcrdy := '0';
    elsif r.enardy='0' or r.crdypat(0)='0' then
      iappcrdy := '0';
      
    else      
      if APP_EN = '1' then
        if APP_CMD = c_migui_cmd_read then
          imemen := '1';
          if r.rowaddr = APP_ADDR(addr_f_row) then
            n.rdwait  := r.rdwait + c_rdwait_rhit;
          else
            n.rdwait  := r.rdwait + c_rdwait_rmis;
            n.rowaddr := APP_ADDR(addr_f_row);
          end if;
        elsif APP_CMD = c_migui_cmd_write then
          imemen := '1';
          imemwe := '1';
          if r.rowaddr = APP_ADDR(addr_f_row) then
            n.wrwait  := r.wrwait + c_wrwait_rhit;
          else
            n.wrwait  := r.wrwait + c_wrwait_rmis;
            n.rowaddr := APP_ADDR(addr_f_row);
          end if;
        else
        end if;
      end if;      
    end if;

    -- handle cmd waits, issue read responses
    if r.enacaco = '1' then               -- process commands only after CACO
      if r.wrwait > 0 then                  -- first wait for pending writes
        n.wrwait := r.wrwait - 1;
      else
        if r.rdwait > 0 then                -- next of for pending reads
          n.rdwait := r.rdwait - 1;
          if r.rdwait = 1 then
            irdval := '1';
          end if;
        end if;
      end if;      
    end if;
    
    -- process ref_req requests
    if APP_REF_REQ = '1' then
      n.refwait := c_refwait;
    else
      if r.refwait > 0 then
        n.refwait := r.refwait -1;
        if r.refwait = 1 then
          iapprefack := '1';
        end if;
      end if;
    end if;
    
    -- process zq_req requests
    if APP_ZQ_REQ = '1' then
      n.zqwait := c_zqwait;
    else
      if r.zqwait > 0 then
        n.zqwait := r.zqwait -1;
        if r.zqwait = 1 then
          iappzqack := '1';
        end if;
      end if;
    end if;
    
    N_REGS <= n;

    INIT_CALIB_COMPLETE <= r.enacaco;
    
    APP_RDY           <= iappcrdy;
    APP_WDF_RDY       <= iappwrdy;
    APP_RD_DATA_VALID <= irdval;
    APP_RD_DATA_END   <= irdval;
    APP_REF_ACK       <= iapprefack;
    APP_ZQ_ACK        <= iappzqack;
    if irdval = '1' then                -- only in the RD_DATA_END cycle
      APP_RD_DATA <= R_MEMDO;             -- export the data
    else                                -- otherwise
      APP_RD_DATA <= (others=>'1');       -- send all ones
    end if;
    MEM_EN     <= imemen;
    MEM_WE     <= imemwe;
    MEM_ADDR   <= APP_ADDR(SAWIDTH-1 downto BAWIDTH);

  end process proc_next;

  proc_mem: process (CLK)
    variable ram : ram_type := (others=>datzero);
    variable membase : integer := 0;
  begin
    if rising_edge(CLK) then
      if MEM_EN = '1' then
        membase := mwidth*to_integer(unsigned(MEM_ADDR));
        -- write to memory
        if APP_WDF_WREN = '1' then
          for i in 0 to mwidth-1 loop
            if APP_WDF_MASK(i) = '0'  then      -- WE = not MASK !!
              ram(membase + i) :=
                to_bitvector(to_x01(APP_WDF_DATA(8*i+7 downto 8*i)));
            end if;
          end loop;
        end if;
        -- read from memory
        for i in 0 to mwidth-1 loop
          R_MEMDO(8*i+7 downto 8*i) <= to_stdlogicvector(ram(membase + i));
        end loop;
        
      end if;
    end if;
  end process proc_mem;

  proc_moni: process (CLK)
  begin
    if rising_edge(CLK) then
      if SYS_RST = '0' then
        if APP_EN = '1' then
          assert APP_CMD = c_migui_cmd_read or
                 APP_CMD = c_migui_cmd_write
            report "migui_core_gsim: FAIL: APP_CMD not 000 or 001"
            severity error;
          
          assert unsigned(APP_ADDR(MAWIDTH-1 downto SAWIDTH)) = 0
            report "migui_core_gsim: FAIL: out of sim-memory size access"
            severity error;
        end if;

        if APP_EN = '1' and APP_CMD = c_migui_cmd_write then 
          assert APP_WDF_WREN='1' and APP_WDF_END='1'
            report "migui_core_gsim: FAIL: APP_WDF_(END,WREN) missed on write"
            severity error;
        else
          assert APP_WDF_WREN='0' and APP_WDF_END='0'
            report "migui_core_gsim: FAIL: spurious APP_WDF_(END,WREN)"
            severity error;
        end if;
      end if;
    end if;
  end process proc_moni;

end sim;
