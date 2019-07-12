-- $Id: tst_mig.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2018- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tst_mig - syn
-- Description:    test of mig 
--
-- Dependencies:   -
--
-- Test bench:     arty/tb/tb_tst_mig_arty        (with ddr3 via mig)
--                 nexys4d/tb/tb_tst_mig_n4d      (with ddr2 via mig)
--
-- Target Devices: generic
-- Tool versions:  viv 2017.2; ghdl 0.34
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2018-12-28  1096   1.0    Initial version
-- 2018-12-23  1092   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers:
--
--    Addr    Bits  Name      r/w/f  Function
--  00000         cntl        -/-/f  Control register
--         15:13    cmd       0/w/-    commmand code for func=cmd
--            12    wren      0/w/-    wren option for func=cmd
--            11    dwend     0/w/-    disable wend for func=cmd,wren
--         03:00    func      0/-/f    function command
--                                      0000   noop
--                                      0001   rd    read  memory
--                                      0010   wr    write memory
--                                      0011   pat   sample rdy pattern
--                                      0100   ref   refresh
--                                      0101   cal   ZQ cal
--                                      0110   cmd   send command to mem
--                                      0111   wren  send wren strobe to mem
--  00001         stat        r/-/-  Status register
--            06    zqpend    r/-/-    ZQ cal  req pending
--            05    refpend   r/-/-    refresh req pending
--            04    rdend     r/-/-    RD_DATA_END seen
--            03    uirst     r/-/-    reset from ui
--            02    caco      r/-/-    calibration complete
--            01    wrdy      r/-/-    write ready
--            00    crdy      r/-/-    cmd ready
--  00010         conf        r/-/-  Configuration register
--          9:05    mawidth   r/-/-    MAWIDTH
--          4:00    mwidth    r/-/-    MWIDTH
--  00011  15:00  mask        r/w/-  Mask register
--  00100  15:00  addrl       r/w/-  Address register (low  part)
--  00101  15:00  addrh       r/w/-  Address register (high part)
--  00110  15:00  temp        r/-/-  Device temperature
--  00111  15:00  dvalcnt     r/-/-  Data valid counter
--  01000  15:00  crpat       r/-/-  Command ready pattern
--  01001  15:00  wrpat       r/-/-  Write   ready pattern
--  01010  15:00  cwait       r/-/-  Command wait
--  01011  15:00  rwait       r/-/-  Read wait
--  01100  15:00  xwait       r/-/-  Request wait
--  01101         ircnt       r/-/-  Init/Reset count
--          15:08    rstcnt    r/-/-    reset count
--           7:00    inicnt    r/-/-    init count
--  01110  15:00  rsttime     r/-/-  length of last reset
--  01111  15:00  initime     r/-/-  length of last init
--  10xxx         datrd[0-7]  r/-/-  Data read register
--  11xxx         datwr[0-7]  r/w/-  Data write register

-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rutil.all;
use work.memlib.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity tst_mig is                       -- tester for mig
  generic (
    RB_ADDR : slv16 := slv(to_unsigned(2#0000000000000000#,16));
    MAWIDTH : natural :=  28;
    MWIDTH  : natural :=  16);
  port (
    CLK     : in slbit;                 -- clock
    CE_USEC : in slbit;                 -- usec pulse
    RESET   : in slbit;                 -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_STAT : out slv4;                 -- rbus: status flags
    RB_LAM  : out slbit;                -- remote attention
    APP_ADDR            : out slv(MAWIDTH-1 downto 0); -- MIGUI address
    APP_CMD             : out slv3;                    -- MIGUI command
    APP_EN              : out slbit;                   -- MIGUI command enable
    APP_WDF_DATA        : out slv(8*MWIDTH-1 downto 0);-- MIGUI write data
    APP_WDF_END         : out slbit;                   -- MIGUI write end
    APP_WDF_MASK        : out slv(MWIDTH-1 downto 0);  -- MIGUI write mask
    APP_WDF_WREN        : out slbit;                   -- MIGUI write enable
    APP_RD_DATA         : in  slv(8*MWIDTH-1 downto 0);-- MIGUI read data
    APP_RD_DATA_END     : in  slbit;      -- MIGUI read end
    APP_RD_DATA_VALID   : in  slbit;      -- MIGUI read valid
    APP_RDY             : in  slbit;      -- MIGUI ready for cmd
    APP_WDF_RDY         : in  slbit;      -- MIGUI ready for data write
    APP_SR_REQ          : out slbit;      -- MIGUI reserved (tie to 0)
    APP_REF_REQ         : out slbit;      -- MIGUI refresh request
    APP_ZQ_REQ          : out slbit;      -- MIGUI ZQ calibrate request
    APP_SR_ACTIVE       : in  slbit;      -- MIGUI reserved (ignore)
    APP_REF_ACK         : in  slbit;      -- MIGUI refresh acknowledge
    APP_ZQ_ACK          : in  slbit;      -- MIGUI ZQ calibrate acknowledge    
    MIG_UI_CLK_SYNC_RST     : in  slbit;  -- MIGUI reset
    MIG_INIT_CALIB_COMPLETE : in  slbit;  -- MIGUI calibration done
    MIG_DEVICE_TEMP_I       : in  slv12   -- MIGUI xadc temperature
  );
end tst_mig;

architecture syn of tst_mig is

  type state_type is (
    s_idle,                             -- s_idle: wait for input
    s_rdcwait,                          -- s_rdcwait: read cmd wait
    s_rdrwait,                          -- s_rdrwait: read res wait
    s_wrcwait,                          -- s_wrcwait: write cmd wait
    s_cmdwait,                          -- s_cmdwait: cmd wait
    s_wrenwait                          -- s_wrenwait: wren wait
  );

  type regs_type is record
    state   : state_type;               -- state
    rbsel   : slbit;                    -- rbus select
    mask    : slv16;                    -- memory mask
    addr    : slv32;                    -- memory address
    datrd   : slv(127 downto 0);        -- memory data read
    datwr   : slv(127 downto 0);        -- memory data write
    dvalcnt : slv16;                    -- data valid counter
    crpat   : slv16;                    -- command ready pattern
    wrpat   : slv16;                    -- write   ready pattern
    cwait   : slv16;                    -- command wait counter
    rwait   : slv16;                    -- read    wait counter
    xwait   : slv16;                    -- request wait counter
    rstcnt  : slv8;                     -- reset counter
    inicnt  : slv8;                     -- init  counter
    rsttime : slv16;                    -- reset time counter
    initime : slv16;                    -- init  time counter
    crsreg  : slv15;                    -- command ready shift register
    wrsreg  : slv15;                    -- write   ready shift register
    rdend   : slbit;                    -- RD_DATA_END capture
    refpend : slbit;                    -- ref req pending
    zqpend  : slbit;                    -- zq  req pending
    caco_1  : slbit;                    -- last caco
    uirst_1 : slbit;                    -- last uirst
  end record regs_type;

  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- rbsel
    (others=>'0'),                      -- mask
    (others=>'0'),                      -- addr
    (others=>'0'),                      -- datrd
    (others=>'0'),                      -- datwr
    (others=>'0'),                      -- dvalcnt
    (others=>'0'),                      -- crpat
    (others=>'0'),                      -- wrpat
    (others=>'0'),                      -- cwait
    (others=>'0'),                      -- rwait
    (others=>'0'),                      -- xwait
    (others=>'0'),                      -- rstcnt
    (others=>'0'),                      -- inicnt
    (others=>'0'),                      -- rsttime
    (others=>'0'),                      -- initime
    (others=>'0'),                      -- crsreg
    (others=>'0'),                      -- wrsreg
    '0','0','0',                        -- rdend,refpend,zqpend
    '0','0'                             -- caco_1,uirst_1
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)

  constant rbaddr_cntl:    slv5 := "00000";  --  0    -/-/f
  constant rbaddr_stat:    slv5 := "00001";  --  1    r/-/-
  constant rbaddr_conf:    slv5 := "00010";  --  2    r/-/-
  constant rbaddr_mask:    slv5 := "00011";  --  3    r/w/-
  constant rbaddr_addrl:   slv5 := "00100";  --  4    r/w/-
  constant rbaddr_addrh:   slv5 := "00101";  --  5    r/w/-
  constant rbaddr_temp:    slv5 := "00110";  --  6    r/-/-
  constant rbaddr_dvalcnt: slv5 := "00111";  --  7    r/-/-
  constant rbaddr_crpat:   slv5 := "01000";  --  8    r/-/-
  constant rbaddr_wrpat:   slv5 := "01001";  --  9    r/-/-
  constant rbaddr_cwait:   slv5 := "01010";  -- 10    r/-/-
  constant rbaddr_rwait:   slv5 := "01011";  -- 11    r/-/-
  constant rbaddr_xwait:   slv5 := "01100";  -- 12    r/-/-
  constant rbaddr_ircnt:   slv5 := "01101";  -- 13    r/-/-
  constant rbaddr_rsttime: slv5 := "01110";  -- 14    r/-/-
  constant rbaddr_initime: slv5 := "01111";  -- 15    r/-/-
  constant rbaddr_datrd0:  slv5 := "10000";  -- 16    r/-/-
  constant rbaddr_datrd1:  slv5 := "10001";  -- 17    r/-/-
  constant rbaddr_datrd2:  slv5 := "10010";  -- 18    r/-/-
  constant rbaddr_datrd3:  slv5 := "10011";  -- 19    r/-/-
  constant rbaddr_datrd4:  slv5 := "10100";  -- 20    r/-/-
  constant rbaddr_datrd5:  slv5 := "10101";  -- 21    r/-/-
  constant rbaddr_datrd6:  slv5 := "10110";  -- 22    r/-/-
  constant rbaddr_datrd7:  slv5 := "10111";  -- 23    r/-/-
  constant rbaddr_datwr0:  slv5 := "11000";  -- 14    r/w/-
  constant rbaddr_datwr1:  slv5 := "11001";  -- 15    r/w/-
  constant rbaddr_datwr2:  slv5 := "11010";  -- 16    r/w/-
  constant rbaddr_datwr3:  slv5 := "11011";  -- 17    r/w/-
  constant rbaddr_datwr4:  slv5 := "11100";  -- 28    r/w/-
  constant rbaddr_datwr5:  slv5 := "11101";  -- 29    r/w/-
  constant rbaddr_datwr6:  slv5 := "11110";  -- 30    r/w/-
  constant rbaddr_datwr7:  slv5 := "11111";  -- 31    r/w/-

  subtype  cntl_rbf_cmd    is integer range  15 downto  13;
  constant cntl_rbf_wren    : integer :=  12;
  constant cntl_rbf_dwend   : integer :=  11;
  subtype  cntl_rbf_func   is integer range   3 downto   0;

  constant stat_rbf_zqpend  : integer :=   6;
  constant stat_rbf_refpend : integer :=   5;
  constant stat_rbf_rdend   : integer :=   4;
  constant stat_rbf_uirst   : integer :=   3;
  constant stat_rbf_caco    : integer :=   2;
  constant stat_rbf_wrdy    : integer :=   1;
  constant stat_rbf_crdy    : integer :=   0;

  subtype  conf_rbf_mawidth is integer range   9 downto   5;
  subtype  conf_rbf_mwidth  is integer range   4 downto   0;
  
  subtype  ircnt_rbf_rstcnt is integer range  15 downto   8;
  subtype  ircnt_rbf_inicnt is integer range   7 downto   0;
  
  constant func_noop   : slv4 := "0000";   -- func: noop
  constant func_rd     : slv4 := "0001";   -- func: rd   read  memory
  constant func_wr     : slv4 := "0010";   -- func: wr   write memory
  constant func_pat    : slv4 := "0011";   -- func: pat  sample rdy pattern
  constant func_ref    : slv4 := "0100";   -- func: ref  refresh
  constant func_cal    : slv4 := "0101";   -- func: cal  ZQ cal
  constant func_cmd    : slv4 := "0110";   -- func: cmd  send command to mem
  constant func_wren   : slv4 := "0111";   -- func: wren send wren strobe to mem
  
  subtype  df_word0        is integer range  15 downto   0;
  subtype  df_word1        is integer range  31 downto  16;
  subtype  df_word2        is integer range  47 downto  32;
  subtype  df_word3        is integer range  63 downto  48;
  subtype  df_word4        is integer range  79 downto  64;
  subtype  df_word5        is integer range  95 downto  80;
  subtype  df_word6        is integer range 111 downto  96;
  subtype  df_word7        is integer range 127 downto 112;

  constant migui_cmd_read  : slv3 := "001";
  constant migui_cmd_write : slv3 := "000";
  
begin

  assert MAWIDTH <= 32 
    report "assert(MAWIDTH <= 32): unsupported MAWIDTH"
    severity failure;
  assert MWIDTH = 8 or MWIDTH = 16
    report "assert(MWIDTH = 8 or 16): unsupported MWIDTH"
    severity failure;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, RB_MREQ, CE_USEC,
                      APP_RD_DATA, APP_RD_DATA_END, APP_RD_DATA_VALID,
                      APP_RDY, APP_WDF_RDY, APP_REF_ACK, APP_ZQ_ACK,
                      MIG_UI_CLK_SYNC_RST, MIG_INIT_CALIB_COMPLETE,
                      MIG_DEVICE_TEMP_I)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena   : slbit := '0';         -- re or we -> rbus request
    
    variable iappcmd  : slv3  := (others=>'0');
    variable iappen   : slbit := '0';
    variable iappwren : slbit := '0';
    variable iappwend : slbit := '0';
    variable iappref  : slbit := '0';
    variable iappzq   : slbit := '0';
    
    variable ncrpat : slv16 := (others=>'0');
    variable nwrpat : slv16 := (others=>'0');

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    iappcmd  := migui_cmd_read;
    iappen   := '0';
    iappwren := '0';
    iappwend := '0';
    iappref  := '0';
    iappzq   := '0';
    ncrpat := r.crsreg & APP_RDY;      -- current ready patterns
    nwrpat := r.wrsreg & APP_WDF_RDY;

    irbena  := RB_MREQ.re or RB_MREQ.we;

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 5)=RB_ADDR(15 downto 5) then
      n.rbsel := '1';
    end if;

    if r.rbsel='1' and irbena='1' then
      irb_ack  := '1';                  -- ack all (maybe rejected later)
    end if;
    
    case r.state is

      when s_idle =>                    -- s_idle: ---------------------------
        -- rbus transactions
        if r.rbsel = '1' then
          
          case RB_MREQ.addr(4 downto 0) is
            
            when rbaddr_cntl =>                 -- cntl ---------------
              if RB_MREQ.we = '1' then
                case RB_MREQ.din(cntl_rbf_func) is
                  when func_noop => null;           -- func: noop -----
                  when func_rd =>                   -- func: rd -------
                    n.rdend  := '0';
                    n.cwait  := (others=>'0');
                    n.rwait  := (others=>'0');
                    irb_busy := '1';
                    n.state  := s_rdcwait;
                    
                  when func_wr  =>                  -- func: wr -------
                    n.cwait  := (others=>'0');
                    n.rwait  := (others=>'0');
                    irb_busy := '1';
                    n.state  := s_wrcwait;
                                   
                  when func_pat =>                  -- func: pat ------
                    n.crpat := ncrpat;
                    n.wrpat := nwrpat;
                    
                  when func_ref =>                  -- func: ref ------
                    n.xwait := (others=>'0');
                    if r.refpend = '0' then
                      n.refpend := '1';
                      iappref   := '1';
                    else
                      irb_err := '1';
                    end if;              
                                   
                  when func_cal =>                  -- func: cal ------
                    n.xwait := (others=>'0');
                    if r.zqpend = '0' then
                      n.zqpend := '1';
                      iappzq   := '1';
                    else
                      irb_err := '1';
                    end if;              
 
                  when func_cmd =>                  -- func: cmd ------
                    n.cwait  := (others=>'0');
                    n.rwait  := (others=>'0');
                    irb_busy := '1';
                    n.state  := s_cmdwait;
                   
                  when func_wren =>                 -- func: wren -----
                    n.cwait  := (others=>'0');
                    n.rwait  := (others=>'0');
                    irb_busy := '1';
                    n.state  := s_wrenwait;
                   
                  when others =>                    -- <> not yet defined codes
                    irb_err := '1';
                end case;
              end if;
              
            when rbaddr_stat => irb_err := RB_MREQ.we;
            when rbaddr_conf => irb_err := RB_MREQ.we;
                                
            when rbaddr_mask =>                 -- mask ---------------
              if RB_MREQ.we = '1' then
                n.mask  := RB_MREQ.din;
              end if;
              
            when rbaddr_addrl =>                -- addrl --------------
              if RB_MREQ.we = '1' then n.addr(df_word0) := RB_MREQ.din; end if;
            when rbaddr_addrh =>                -- addrh --------------
              if RB_MREQ.we = '1' then n.addr(df_word1) := RB_MREQ.din; end if;
              
            when rbaddr_temp    => irb_err := RB_MREQ.we;
            when rbaddr_dvalcnt => irb_err := RB_MREQ.we;
            when rbaddr_crpat   => irb_err := RB_MREQ.we;
            when rbaddr_wrpat   => irb_err := RB_MREQ.we;
            when rbaddr_cwait   => irb_err := RB_MREQ.we;
            when rbaddr_rwait   => irb_err := RB_MREQ.we;
            when rbaddr_xwait   => irb_err := RB_MREQ.we;
            when rbaddr_ircnt   => irb_err := RB_MREQ.we;
            when rbaddr_rsttime => irb_err := RB_MREQ.we;
            when rbaddr_initime => irb_err := RB_MREQ.we;
                                 
            when rbaddr_datrd0|rbaddr_datrd1|  -- datrd* ----------------
              rbaddr_datrd2|rbaddr_datrd3|
              rbaddr_datrd4|rbaddr_datrd5|
              rbaddr_datrd6|rbaddr_datrd7 => irb_err := RB_MREQ.we;
                                             
            when rbaddr_datwr0 =>               -- datwr* ----------------
              if RB_MREQ.we = '1' then n.datwr(df_word0) := RB_MREQ.din; end if;
            when rbaddr_datwr1 =>
              if RB_MREQ.we = '1' then n.datwr(df_word1) := RB_MREQ.din; end if;
            when rbaddr_datwr2 =>
              if RB_MREQ.we = '1' then n.datwr(df_word2) := RB_MREQ.din; end if;
            when rbaddr_datwr3 =>
              if RB_MREQ.we = '1' then n.datwr(df_word3) := RB_MREQ.din; end if;
            when rbaddr_datwr4 =>
              if RB_MREQ.we = '1' then n.datwr(df_word4) := RB_MREQ.din; end if;
            when rbaddr_datwr5 =>
              if RB_MREQ.we = '1' then n.datwr(df_word5) := RB_MREQ.din; end if;
            when rbaddr_datwr6 =>
              if RB_MREQ.we = '1' then n.datwr(df_word6) := RB_MREQ.din; end if;
            when rbaddr_datwr7 =>
              if RB_MREQ.we = '1' then n.datwr(df_word7) := RB_MREQ.din; end if;
              
            when others =>                      -- <> --------------------
              irb_ack  := '0';
          end case;
        end if;
        
      when s_rdcwait =>                 -- s_rdcwait -------------------------
        iappcmd := migui_cmd_read;        -- setup cmd
        n.crpat := ncrpat;                -- follow RDY patterns
        n.wrpat := nwrpat;
        if r.rbsel='0' or irbena='0' then -- rbus cycle abort
          n.state  := s_idle;
        else
          if APP_RDY = '1' then
            iappen   := '1';
            irb_busy := '1';
            n.state  := s_rdrwait;
          else
            n.cwait := slv(unsigned(r.cwait) + 1);
            irb_busy := '1';
          end if;
        end if;

      when s_rdrwait =>                 -- s_rdrwait -------------------------
        n.rwait := slv(unsigned(r.rwait) + 1);
        if r.rbsel='0' or irbena='0' then -- rbus cycle abort
          n.state  := s_idle;
        else
          if APP_RD_DATA_VALID = '1' then
            n.state  := s_idle;
          else
            irb_busy := '1';
          end if;
        end if;
        
      when s_wrcwait =>                 -- s_wrcwait -------------------------
        iappcmd := migui_cmd_write;       -- setup cmd
        n.crpat := ncrpat;                -- follow RDY patterns
        n.wrpat := nwrpat;
        if r.rbsel='0' or irbena='0' then -- rbus cycle abort
          n.state  := s_idle;
        else
          if APP_RDY = '1' and APP_WDF_RDY = '1' then
            iappen   := '1';
            iappwren := '1';
            iappwend := '1';
            n.state  := s_idle;
          else
            n.cwait := slv(unsigned(r.cwait) + 1);
            irb_busy := '1';
          end if;
        end if;
        
      when s_cmdwait =>                 -- s_cmdwait -------------------------
        iappcmd := RB_MREQ.din(cntl_rbf_cmd);     -- setup cmd
        n.crpat := ncrpat;                -- follow RDY pattern
        if r.rbsel='0' or irbena='0' then -- rbus cycle abort
          n.state  := s_idle;
        else
          if APP_RDY = '1' then
            iappen   := '1';
            iappwren := RB_MREQ.din(cntl_rbf_wren);
            iappwend := RB_MREQ.din(cntl_rbf_wren) and
                          not RB_MREQ.din(cntl_rbf_dwend);
            n.state  := s_idle;
          else
            n.cwait := slv(unsigned(r.cwait) + 1);
            irb_busy := '1';
          end if;
        end if;
        
      when s_wrenwait =>                -- s_wrenwait ------------------------
        n.wrpat := nwrpat;                -- follow RDY pattern
        if r.rbsel='0' or irbena='0' then -- rbus cycle abort
          n.state  := s_idle;
        else
          if APP_WDF_RDY = '1' then
            iappwren := '1';
            iappwend := not RB_MREQ.din(cntl_rbf_dwend);
            n.state  := s_idle;
          else
            n.cwait := slv(unsigned(r.cwait) + 1);
            irb_busy := '1';
          end if;
        end if;
        
      when others => null;
                     
    end case;
    
 
    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(4 downto 0) is
        
        when rbaddr_stat =>
          irb_dout(stat_rbf_zqpend)  := r.zqpend;
          irb_dout(stat_rbf_refpend) := r.refpend;
          irb_dout(stat_rbf_rdend)   := r.rdend;
          irb_dout(stat_rbf_uirst)   := MIG_UI_CLK_SYNC_RST;
          irb_dout(stat_rbf_caco)    := MIG_INIT_CALIB_COMPLETE;
          irb_dout(stat_rbf_wrdy)    := APP_WDF_RDY;
          irb_dout(stat_rbf_crdy)    := APP_RDY;
        when rbaddr_conf =>
          irb_dout(conf_rbf_mawidth) := slv(to_unsigned(MAWIDTH,5));
          irb_dout(conf_rbf_mwidth)  := slv(to_unsigned(MWIDTH,5));
        when rbaddr_mask  => irb_dout := r.mask;                   
        when rbaddr_addrl => irb_dout := r.addr(df_word0);
        when rbaddr_addrh => irb_dout := r.addr(df_word1);
        when rbaddr_temp  =>
          irb_dout(MIG_DEVICE_TEMP_I'range) := MIG_DEVICE_TEMP_I;
        when rbaddr_dvalcnt => irb_dout := r.dvalcnt;
        when rbaddr_crpat   => irb_dout := r.crpat;
        when rbaddr_wrpat   => irb_dout := r.wrpat;
        when rbaddr_cwait   => irb_dout := r.cwait;
        when rbaddr_rwait   => irb_dout := r.rwait;
        when rbaddr_xwait   => irb_dout := r.xwait;
        when rbaddr_ircnt   =>
          irb_dout(ircnt_rbf_rstcnt) := r.rstcnt;
          irb_dout(ircnt_rbf_inicnt) := r.inicnt;
        when rbaddr_rsttime => irb_dout := r.rsttime;
        when rbaddr_initime => irb_dout := r.initime;
                              
        when rbaddr_datrd0  => irb_dout := r.datrd(df_word0);
        when rbaddr_datrd1  => irb_dout := r.datrd(df_word1);
        when rbaddr_datrd2  => irb_dout := r.datrd(df_word2);
        when rbaddr_datrd3  => irb_dout := r.datrd(df_word3);
        when rbaddr_datrd4  => irb_dout := r.datrd(df_word4);
        when rbaddr_datrd5  => irb_dout := r.datrd(df_word5);
        when rbaddr_datrd6  => irb_dout := r.datrd(df_word6);
        when rbaddr_datrd7  => irb_dout := r.datrd(df_word7);
                              
        when rbaddr_datwr0  => irb_dout := r.datwr(df_word0);
        when rbaddr_datwr1  => irb_dout := r.datwr(df_word1);
        when rbaddr_datwr2  => irb_dout := r.datwr(df_word2);
        when rbaddr_datwr3  => irb_dout := r.datwr(df_word3);
        when rbaddr_datwr4  => irb_dout := r.datwr(df_word4);
        when rbaddr_datwr5  => irb_dout := r.datwr(df_word5);
        when rbaddr_datwr6  => irb_dout := r.datwr(df_word6);
        when rbaddr_datwr7  => irb_dout := r.datwr(df_word7);
                              
        when others => null;
      end case;
    end if;

    -- update ready shift registers
    n.crsreg := ncrpat(n.crsreg'range);
    n.wrsreg := nwrpat(n.wrsreg'range);
    
    -- ready data capture
    if APP_RD_DATA_VALID = '1' then
      n.rdend := APP_RD_DATA_END;
      n.datrd(APP_RD_DATA'range) := APP_RD_DATA;
      n.dvalcnt := slv(unsigned(r.dvalcnt) + 1);
    end if;
    
    -- REF and ZQ handling
    if r.refpend = '1' or r.zqpend = '1' then
       n.xwait := slv(unsigned(r.xwait) + 1);
    end if;
    if APP_REF_ACK = '1' then           -- REF done
      n.refpend := '0';
      n.crpat := ncrpat;                  -- record RDY patterns too
      n.wrpat := nwrpat;
    end if;
    if APP_ZQ_ACK = '1' then            -- ZQ done
      n.zqpend := '0';
      n.crpat := ncrpat;                  -- record RDY patterns too
      n.wrpat := nwrpat;
    end if;

    -- CACO monitor (length in CE_USEC)
    n.caco_1 := MIG_INIT_CALIB_COMPLETE;
    if MIG_INIT_CALIB_COMPLETE = '0' then
      if r.caco_1 = '1' then
        n.initime := (others => '0');
        if r.inicnt /= x"ff" then
          n.inicnt := slv(unsigned(r.inicnt) + 1);
        end if;
      else
        if r.initime /= x"ffff" then
          if CE_USEC = '1' then
            n.initime := slv(unsigned(r.initime) + 1);
          end if;
        end if;
      end if;
    end if;
    
    -- UIRST monitor (length in CE_USC)
    n.uirst_1 := MIG_UI_CLK_SYNC_RST;
    if MIG_UI_CLK_SYNC_RST = '1' then
      if r.uirst_1 = '0' then
        n.rsttime := (others => '0');
        if r.rstcnt /= x"ff" then
          n.rstcnt := slv(unsigned(r.rstcnt) + 1);
        end if;
      else
        if r.rsttime /= x"ffff" then
          if CE_USEC = '1' then
            n.rsttime := slv(unsigned(r.rsttime) + 1);
          end if;
        end if;
      end if;
    end if;    

    N_REGS       <= n;

    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

    RB_LAM   <= '0';

    APP_ADDR     <= r.addr(APP_ADDR'range);
    APP_CMD      <= iappcmd;
    APP_EN       <= iappen;
    APP_WDF_DATA <= r.datwr(APP_WDF_DATA'range);
    APP_WDF_END  <= iappwend;
    APP_WDF_MASK <= r.mask(APP_WDF_MASK'range);
    APP_WDF_WREN <= iappwren;
    APP_REF_REQ  <= iappref;
    APP_ZQ_REQ   <= iappzq;

    APP_SR_REQ   <= '0';

  end process proc_next;

  RB_STAT(3) <= '0';
  RB_STAT(2) <= '0';
  RB_STAT(1) <= '0';
  RB_STAT(0) <= '0';    
  
end syn;
