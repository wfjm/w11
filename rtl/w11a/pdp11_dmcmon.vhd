-- $Id: pdp11_dmcmon.vhd 1330 2022-12-16 17:52:40Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2015-2022 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    pdp11_dmcmon- syn
-- Description:    pdp11: debug&moni: cpu monitor
--
-- Dependencies:   memlib/ram_2swsr_rfirst_gen
--                 memlib/ram_1swar_1ar_gen
-- Test bench:     -
--
-- Target Devices: generic
-- Tool versions:  ise 14.7; viv 2014.4-2019.1; ghdl 0.31-0.35
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2015-08-02   707 14.7  131013 xc6slx16-2   213  233   16  151 s  5.9
--
-- Revision History: -
-- Date         Rev Version  Comment
-- 2022-12-12  1330   2.0.3  dm_stat_se_type: rename vfetch -> vstart
-- 2022-10-25  1309   2.0.2  rename _gpr -> _gr
-- 2019-06-02  1159   2.0.1  use rbaddr_ constants
-- 2017-04-22   884   2.0    use DM_STAT_SE.idle; revised interface, add suspend
-- 2015-08-03   709   1.0    Initial version
-- 2015-07-05   697   0.1    First draft
------------------------------------------------------------------------------
--
-- rbus registers:
--
--  Addr   Bits  Name       r/w/f  Function
--  000         cntl        r/w/f  Control register
--          05    mwsup     r/w/-    mem wait suppress
--          04    imode     r/w/-    instruction mode
--          03    wstop     r/w/-    stop on wrap
--       02:00    func      0/-/f    change run status if != noop
--                                     0xx  noop
--                                     100  sto  stop
--                                     101  sta  start and latch all options
--                                     110  sus  suspend  (noop if not started)
--                                     111  res  resume   (noop if not started)
--  001         stat        r/-/-  Status register
--       15:13    bsize     r/-/-    buffer size (AWIDTH-8)
--       12:09    malcnt    r/-/-    valid entries in memory access log
--          08    snum      r/-/-    snum support
--          02    wrap      r/-/-    line address wrapped (cleared on start)
--          01    susp      r/-/-    suspended
--          00    run       r/-/-    running (can be suspended)
--  010         addr        r/w/-  Address register    (writable when stopped)
--        *:04    laddr     r/w/-    line address
--       03:00    waddr     r/w/-    word address (0000 to 1000)
--  011         data        r/w/-  Data register
--  100         iaddr       r/-/-  Last instruction cmon address
--        *:04    laddr     r/-/-    line address
--       03:00              r/-/-    -always zero-
--  101         ipc         r/-/-  Last instruction pc
--  110         ireg        r/-/-  Last instruction 
--  111         imal        r/-/-  Last instruction memory access log
--
--     data format:
--     word 8     15 : vm.vmcntl.req
--        if req = 1
--                14 : vm.vmcntl.wacc
--                13 : vm.vmcntl.macc
--                12 : vm.vmcntl.cacc
--                11 : vm.vmcntl.bytop
--                10 : vm.vmcntl.dspace
--        if req = 0
--                14 : vm.vmcntl.ack
--                13 : vm.vmcntl.err
--          if ack = 1 and err = 0 
--                12 : vm.vmcntl.trap_ysv
--                11 : vm.vmcntl.trap_mmu
--                10 : mwdrop    (signals memwait suppress when mwsup=1)
--          if ack = 0 and err = 1
--             12:10 : vm error code (priority encoded, but only one anyone)
--                       000      err_odd   = 1
--                       001      err_mmu   = 1
--                       010      err_nxm   = 1
--                       011      err_iobto = 1
--                       100      err_rsv   = 1
--
--                09 : se.istart
--                08 : se.idone
--
--        if imode = 0
--             07:00 : se.snum
--        if imode = 1
--             07:00 : cnum
--
--     word 7  15:01 : dp.pc   (captured at se.istart)
--                00 : idecode (is dp.ireg_we delayed by 1 cycle)

--     word 6  15:00 : dp.ireg

--     word 5  15:14 : dp.psw.cmode
--             13:12 : dp.psw.pmode
--                11 : dp.psw.rset
--        if imode = 0
--                10 : dp.dres valid
--                09 : dp.ddst_we
--                08 : dp.dsrc_we
--        if imode = 1
--                10 : -- unused --
--                09 : -- unused --
--                08 : se.vstart
--        always
--             07:05 : dp.psw.pri
--                04 : dp.psw.tflag
--             03:00 : dp.psw.cc

--     word 4  15:00 : dp.dsrc
--     word 3  15:00 : dp.ddst
--     word 2  15:00 : dp.dres (reged)
--     word 1  15:00 : vm.vmaddr             (captured at vm.vmcntl.req)
--     word 0  15:00 : vm.vmdin or vm.vmdout (captured at req or ack)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.memlib.all;
use work.rblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

-- Note: AWIDTH has type natural to allow AWIDTH=0 can be used in if generates
--       to control the instantiation. ghdl checks even for not instantiated
--       entities the validity of generics, that's why natural needed here ....

entity pdp11_dmcmon is                  -- debug&moni: cpu monitor
  generic (
    RB_ADDR : slv16 := rbaddr_dmcmon_off;
    AWIDTH : natural := 8;
    SNUM : boolean := false);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    DM_STAT_SE : in dm_stat_se_type;    -- debug and monitor status - sequencer
    DM_STAT_DP : in dm_stat_dp_type;    -- debug and monitor status - data path
    DM_STAT_VM : in dm_stat_vm_type;    -- debug and monitor status - vmbox
    DM_STAT_CO : in dm_stat_co_type     -- debug and monitor status - core
  );
end pdp11_dmcmon;


architecture syn of pdp11_dmcmon is

  constant rbaddr_cntl  : slv3 := "000";  -- cntl  address offset
  constant rbaddr_stat  : slv3 := "001";  -- stat  address offset
  constant rbaddr_addr  : slv3 := "010";  -- addr  address offset
  constant rbaddr_data  : slv3 := "011";  -- data  address offset
  constant rbaddr_iaddr : slv3 := "100";  -- iaddr address offset
  constant rbaddr_ipc   : slv3 := "101";  -- ipc   address offset
  constant rbaddr_ireg  : slv3 := "110";  -- ireg  address offset
  constant rbaddr_imal  : slv3 := "111";  -- imal  address offset
  
  constant cntl_rbf_mwsup    : integer :=     5;
  constant cntl_rbf_imode    : integer :=     4;
  constant cntl_rbf_wstop    : integer :=     3;
  subtype  cntl_rbf_func    is integer range  2 downto  0;

  subtype  stat_rbf_bsize   is integer range 15 downto 13;
  subtype  stat_rbf_malcnt  is integer range 12 downto  9;
  constant stat_rbf_snum     : integer :=     8;
  constant stat_rbf_wrap     : integer :=     2;
  constant stat_rbf_susp     : integer :=     1;
  constant stat_rbf_run      : integer :=     0;

  subtype  addr_rbf_laddr   is integer range 4+AWIDTH-1 downto  4;
  subtype  addr_rbf_waddr   is integer range  3 downto  0;

  subtype  bram_mf_port11   is integer range 143 downto 108;
  subtype  bram_mf_port10   is integer range 107 downto  72;
  subtype  bram_mf_port01   is integer range  71 downto  36;
  subtype  bram_mf_port00   is integer range  35 downto   0;

  subtype  bram_df_word8    is integer range 143 downto 128;
  subtype  bram_df_word7    is integer range 127 downto 112;
  subtype  bram_df_word6    is integer range 111 downto  96;
  subtype  bram_df_word5    is integer range  95 downto  80;
  subtype  bram_df_word4    is integer range  79 downto  64;
  subtype  bram_df_word3    is integer range  63 downto  48;
  subtype  bram_df_word2    is integer range  47 downto  32;
  subtype  bram_df_word1    is integer range  31 downto  16;
  subtype  bram_df_word0    is integer range  15 downto   0;
  
  constant dat8_rbf_req      : integer :=    15;
  constant dat8_rbf_wacc     : integer :=    14;  -- if req=1
  constant dat8_rbf_macc     : integer :=    13;  -- "
  constant dat8_rbf_cacc     : integer :=    12;  -- "
  constant dat8_rbf_bytop    : integer :=    11;  -- "
  constant dat8_rbf_dspace   : integer :=    10;  -- "
  constant dat8_rbf_ack      : integer :=    14;  -- if req=0
  constant dat8_rbf_err      : integer :=    13;  -- "
  constant dat8_rbf_trap_ysv : integer :=    12;  -- if req=0 ack=1 err=0
  constant dat8_rbf_trap_mmu : integer :=    11;  -- "
  constant dat8_rbf_mwdrop   : integer :=    10;  -- "
  subtype  dat8_rbf_vmerr   is integer range 12 downto 10;-- if req=0 ack=0 err=1
  constant dat8_rbf_istart   : integer :=     9;  -- always
  constant dat8_rbf_idone    : integer :=     8;  -- "

  constant vmerr_odd   : slv3 := "001";  -- vm error code:  err_odd
  constant vmerr_mmu   : slv3 := "010";  -- vm error code:  err_mmu
  constant vmerr_nxm   : slv3 := "011";  -- vm error code:  err_nxm
  constant vmerr_iobto : slv3 := "100";  -- vm error code:  err_iobto
  constant vmerr_rsv   : slv3 := "101";  -- vm error code:  err_rsv
  
  subtype  dat8_rbf_snum    is integer range  7 downto  0;

  subtype  dat8_rbf_cnum    is integer range  7 downto  0;

  subtype  dat7_rbf_pc      is integer range 15 downto  1;
  constant dat7_rbf_idecode  : integer :=     0;

  subtype  dat5_rbf_cmode   is integer range 15 downto 14;
  subtype  dat5_rbf_pmode   is integer range 13 downto 12; 
  constant dat5_rbf_rset     : integer :=    11;

  constant dat5_rbf_dres_val : integer :=    10; -- if imode=0
  constant dat5_rbf_ddst_we  : integer :=     9;
  constant dat5_rbf_dsrc_we  : integer :=     8;

  constant dat5_rbf_vstart   : integer :=     8; -- if imode=1

  subtype  dat5_rbf_pri     is integer range  7 downto  5;
  constant dat5_rbf_tflag    : integer :=     4;
  subtype  dat5_rbf_cc      is integer range  3 downto  0;

  constant func_sto : slv3 := "100";    -- func: stop
  constant func_sta : slv3 := "101";    -- func: start
  constant func_sus : slv3 := "110";    -- func: suspend
  constant func_res : slv3 := "111";    -- func: resume

  constant laddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  constant laddrlast : slv(AWIDTH-1 downto 0) := (others=>'1');

  type regs_type is record
    rbsel : slbit;                      -- rbus select
    mwsup : slbit;                      -- mwsup flag (mem wait suppress)
    imode : slbit;                      -- imode flag
    wstop : slbit;                      -- wstop flag (stop on wrap)
    susp   : slbit;                     -- suspended flag
    go : slbit;                         -- go flag (actively running)
    active : slbit;                     -- active flag
    wrap : slbit;                       -- laddr wrap flag
    laddr : slv(AWIDTH-1 downto 0);     -- line address
    waddr : slv4;                       -- word address
    cnum : slv8;                        -- clk counter
    mal_waddr    : slv4;                -- mem acc log: write address
    mal_raddr    : slv4;                -- mem acc log: read address
    dp_pc_fet    : slv16_1;             -- dp.pc_fet (capture on se.istart)
    dp_pc_dec    : slv16_1;             -- dp.pc_dec (capture on dp.ireg_we + 1)
    dp_ireg      : slv16;               -- dp.ireg
    dp_ireg_we   : slbit;               -- dp.ireg_we
    dp_ireg_we_1 : slbit;               -- dp.ireg_we last cycle
    dp_dres      : slv16;               -- dp.dres
    dp_dsrc_we   : slbit;               -- dp.dsrc_we
    dp_ddst_we   : slbit;               -- dp.ddst_we
    dp_dres_val  : slbit;               -- dp.dres valid
    vm_addr      : slv16;               -- vm.vmaddr
    vm_din       : slv16;               -- vm.vmdin
    vm_dout      : slv16;               -- vm.vmdout
    vm_req       : slbit;               -- vm.vmcntl.req
    vm_wacc      : slbit;               -- vm.vmcntl.wacc
    vm_macc      : slbit;               -- vm.vmcntl.macc
    vm_cacc      : slbit;               -- vm.vmcntl.cacc
    vm_bytop     : slbit;               -- vm.vmcntl.bytop
    vm_dspace    : slbit;               -- vm.vmcntl.dspace
    vm_addr_1    : slv16;               -- vm.vmaddr        last request
    vm_dout_1    : slv16;               -- vm.vmdout        last request
    vm_wacc_1    : slbit;               -- vm.vmcntl.wacc   last request
    vm_macc_1    : slbit;               -- vm.vmcntl.macc   last request
    vm_cacc_1    : slbit;               -- vm.vmcntl.cacc   last request
    vm_bytop_1   : slbit;               -- vm.vmcntl.bytop  last request
    vm_dspace_1  : slbit;               -- vm.vmcntl.dspace last request
    vm_ack       : slbit;               -- vm.vmstat.ack
    vm_err       : slbit;               -- vm.vmstat.err
    vm_err_odd   : slbit;               -- vm.vmstat.err_odd
    vm_err_mmu   : slbit;               -- vm.vmstat.err_mmu
    vm_err_nxm   : slbit;               -- vm.vmstat.err_nxm
    vm_err_iobto : slbit;               -- vm.vmstat.err_iobto
    vm_err_rsv   : slbit;               -- vm.vmstat.err_rsv
    vm_trap_ysv  : slbit;               -- vm.vmstat.trap_ysv
    vm_trap_mmu  : slbit;               -- vm.vmstat.trap_mmu
    vm_pend      : slbit;               -- vm req pending
    se_idle      : slbit;               -- se.idle
    se_istart    : slbit;               -- se.istart
    se_istart_1  : slbit;               -- se.istart last cycle
    se_idone     : slbit;               -- se.idone
    se_vstart    : slbit;               -- se.vstart
    se_snum      : slv8;                -- se.snum
    mwdrop       : slbit;               -- mem wait drop flag
  end record regs_type;
  constant regs_init : regs_type := (
    '0',                                -- rbsel
    '0','1','0',                        -- mwsup,imode,wstop
    '0','1','0',                        -- susp,go,active
    '0',                                -- wrap
    laddrzero,                          -- laddr
    "0000",                             -- waddr
    (others=>'0'),                      -- cnum
    (others=>'0'),                      -- macwaddr
    (others=>'0'),                      -- macraddr
    (others=>'0'),                      -- dp_pc_fet
    (others=>'0'),                      -- dp_pc_dec
    (others=>'0'),                      -- dp_ireq
    '0','0',                            -- dp_ireq_we,dp_ireq_we_1
    (others=>'0'),                      -- dp_dres
    '0','0','0',                        -- dp_dsrc_we,dp_ddst_we,dp_dres_val
    (others=>'0'),                      -- vm_addr
    (others=>'0'),                      -- vm_din
    (others=>'0'),                      -- vm_dout
    '0','0','0','0','0','0',            -- vm_req,..,vm_dspace
    (others=>'0'),                      -- vm_addr_1
    (others=>'0'),                      -- vm_dout_1
    '0','0','0','0','0',                -- vm_wacc_1,..,vm_dspace_1
    '0','0',                            -- vm_ack,vm_err
    '0','0','0','0','0',                -- vm_err_*
    '0','0',                            -- vm_trap_*
    '0',                                -- vm_pend
    '0','0','0',                        -- se_idle,se_istart(_1)
    '0','0',                            -- se_idone,se_vstart
    (others=>'0'),                      -- se_snum
    '0'                                 -- mwdrop
  );

  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal BRAM_EN : slbit := '0';
  signal BRAM_WE : slbit := '0';
  signal BRAM_ADDRA : slv(AWIDTH downto 0) := (others=>'0');
  signal BRAM_ADDRB : slv(AWIDTH downto 0) := (others=>'0');
  signal BRAM_DI : slv(143 downto 0) := (others=>'0');
  signal BRAM_DO : slv(143 downto 0) := (others=>'0');

  signal MAL_WE : slbit := '0';
  signal MAL_DI : slv16 := (others=>'0');
  signal MAL_DO : slv16 := (others=>'0');

  begin

  assert AWIDTH>=8 and AWIDTH<=11 
    report "assert(AWIDTH>=8 and AWIDTH<=11): unsupported AWIDTH"
    severity failure;

  BRAM0 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH =>  AWIDTH+1,
      DWIDTH => 36)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => BRAM_EN,
      ENB   => BRAM_EN,
      WEA   => BRAM_WE,
      WEB   => BRAM_WE,
      ADDRA => BRAM_ADDRA,
      ADDRB => BRAM_ADDRB,
      DIA   => BRAM_DI(bram_mf_port00),
      DIB   => BRAM_DI(bram_mf_port01),
      DOA   => BRAM_DO(bram_mf_port00),
      DOB   => BRAM_DO(bram_mf_port01)
    );
    
  BRAM1 : ram_2swsr_rfirst_gen
    generic map (
      AWIDTH =>  AWIDTH+1,
      DWIDTH => 36)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => BRAM_EN,
      ENB   => BRAM_EN,
      WEA   => BRAM_WE,
      WEB   => BRAM_WE,
      ADDRA => BRAM_ADDRA,
      ADDRB => BRAM_ADDRB,
      DIA   => BRAM_DI(bram_mf_port10),
      DIB   => BRAM_DI(bram_mf_port11),
      DOA   => BRAM_DO(bram_mf_port10),
      DOB   => BRAM_DO(bram_mf_port11)
    );

  MAL : ram_1swar_1ar_gen
    generic map (
      AWIDTH =>  4,
      DWIDTH => 16)
    port map (
      CLK   => CLK,
      WE    => MAL_WE,
      ADDRA => R_REGS.mal_waddr,
      ADDRB => R_REGS.mal_raddr,
      DI    => MAL_DI,
      DOA   => open,
      DOB   => MAL_DO);

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

  proc_next: process (R_REGS, RB_MREQ, DM_STAT_SE,
                      DM_STAT_DP, DM_STAT_DP.psw,    -- xst needs sub-records
                      DM_STAT_VM, DM_STAT_VM.vmcntl, DM_STAT_VM.vmstat,
                      DM_STAT_CO, BRAM_DO, MAL_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable irb_ack  : slbit := '0';
    variable irb_err  : slbit := '0';   -- FIXME: needed ??
    variable irb_busy : slbit := '0';   -- FIXME: needed ??
    variable irb_dout : slv16 := (others=>'0');
    variable irbena  : slbit := '0';
    variable ibramen : slbit := '0';    -- BRAM enable
    variable ibramwe : slbit := '0';    -- BRAN we
    variable igoeff  : slbit := '0';
    variable iactive : slbit := '0';
    variable itake   : slbit := '0';
    variable laddr_inc : slbit := '0';
    variable idat    : slv(143 downto 0) := (others=>'0');
    variable idat8   : slv16 := (others=>'0');
    variable idat7   : slv16 := (others=>'0');
    variable idat5   : slv16 := (others=>'0');
    variable ivmerr  : slv3 := (others=>'0');

    variable imal_we : slbit := '0';
    variable imal_re : slbit := '0';
    variable imal_di : slv16 := (others=>'0');
    variable imal_waddr_clr : slbit := '0';
    variable imal_raddr_clr : slbit := '0';
    
  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_err  := '0';
    irb_busy := '0';
    irb_dout := (others=>'0');
    irbena  := RB_MREQ.re or RB_MREQ.we;
        
    ibramen := '0';
    ibramwe := '0';

    igoeff  := '0';
    iactive := '0';
    itake   := '0';
    
    laddr_inc := '0';

    imal_we := '0';
    imal_re := '0';
    imal_di := r.vm_addr;
    imal_waddr_clr := '0';
    imal_raddr_clr := '0';

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(12 downto 3)=RB_ADDR(12 downto 3) then
      n.rbsel := '1';
      ibramen := '1';                   -- ensure bram read before rbus read
    end if;

    -- rbus transactions
    if r.rbsel = '1' then
      irb_ack := irbena;                -- ack all accesses
      case RB_MREQ.addr(2 downto 0) is
        when rbaddr_cntl =>               -- cntl ------------------
         if RB_MREQ.we = '1' then 
           case RB_MREQ.din(cntl_rbf_func) is
             when func_sto =>               -- func: stop ------------
               n.go    := '0';
               n.susp  := '0';
             when func_sta =>               -- func: start -----------
               n.mwsup := RB_MREQ.din(cntl_rbf_mwsup);
               n.imode := RB_MREQ.din(cntl_rbf_imode);
               n.wstop := RB_MREQ.din(cntl_rbf_wstop);
               n.go    := '1';
               n.susp  := '0';
               n.wrap  := '0';
               n.laddr := laddrzero;
               n.waddr := "0000";
             when func_sus =>               -- func: susp ------------
               if r.go = '1' then             -- noop unless running
                 n.go     := '0';
                 n.susp   := r.go;
               end if;
             when func_res =>               -- func: resu ------------
               n.go     := r.susp;
               n.susp   := '0';
             when others => null;           -- <> --------------------
           end case;             
         end if;

        when rbaddr_stat =>                 -- stat ------------------
          irb_err  := RB_MREQ.we;

        when rbaddr_addr =>                 -- addr ------------------
          if RB_MREQ.we = '1' then
            if r.go = '0' then                -- if not active OK
              n.laddr := RB_MREQ.din(addr_rbf_laddr);
              n.waddr := RB_MREQ.din(addr_rbf_waddr);
            else
              irb_err := '1';                 -- otherwise error
            end if;
          end if;

        when rbaddr_data =>                 -- data ------------------
          -- write to data is an error
          if RB_MREQ.we='1' then
            irb_err := '1';                   -- error
          end if;
          -- read to data always allowed, addr only incremented when not active
          if RB_MREQ.re = '1' and r.go = '0' then
            if r.waddr(3) = '1' then          -- equivalent waddr>=1000
              n.waddr := (others=>'0');
              laddr_inc := '1';
            else
              n.waddr := slv(unsigned(r.waddr) + 1);
            end if;
          end if;

        when rbaddr_iaddr =>                -- iaddr -----------------
          irb_err  := RB_MREQ.we;
          
        when rbaddr_ipc   =>                -- ipc -------------------
          irb_err  := RB_MREQ.we;

        when rbaddr_ireg  =>                -- ireg ------------------
          irb_err  := RB_MREQ.we;

        when rbaddr_imal  =>                -- imal ------------------
          irb_err  := RB_MREQ.we;
          imal_re  := RB_MREQ.re;
          
        when others => null;                -- <> --------------------          
      end case;
    end if;

    -- rbus output driver
    if r.rbsel = '1' then
      case RB_MREQ.addr(2 downto 0) is

        when rbaddr_cntl =>                 -- cntl ------------------
          irb_dout(cntl_rbf_mwsup)  := r.mwsup;
          irb_dout(cntl_rbf_imode)  := r.imode;
          irb_dout(cntl_rbf_wstop)  := r.wstop;

        when rbaddr_stat =>                 -- stat ------------------
          irb_dout(stat_rbf_bsize)  := slv(to_unsigned(AWIDTH-8,3));
          irb_dout(stat_rbf_malcnt) := r.mal_waddr;
          if SNUM then
            irb_dout(stat_rbf_snum)   := '1';
          end if;
          irb_dout(stat_rbf_wrap)   := r.wrap;
          irb_dout(stat_rbf_susp)   := r.susp;         -- started and suspended
          irb_dout(stat_rbf_run)    := r.go or r.susp; -- started

        when rbaddr_addr =>                 -- addr ------------------
          irb_dout(addr_rbf_laddr)  := r.laddr;
          irb_dout(addr_rbf_waddr)  := r.waddr;

        when rbaddr_data =>                 -- data ------------------
          case r.waddr is
            when "1000" => irb_dout := BRAM_DO(bram_df_word8);
            when "0111" => irb_dout := BRAM_DO(bram_df_word7);
            when "0110" => irb_dout := BRAM_DO(bram_df_word6);
            when "0101" => irb_dout := BRAM_DO(bram_df_word5);
            when "0100" => irb_dout := BRAM_DO(bram_df_word4);
            when "0011" => irb_dout := BRAM_DO(bram_df_word3);
            when "0010" => irb_dout := BRAM_DO(bram_df_word2);
            when "0001" => irb_dout := BRAM_DO(bram_df_word1);
            when "0000" => irb_dout := BRAM_DO(bram_df_word0);
            when others => irb_dout := (others=>'0');
          end case;

        when rbaddr_iaddr =>                -- iaddr -----------------
          null;                             -- FIXME_code: implement
          
        when rbaddr_ipc =>                  -- ipc -------------------
          irb_dout(r.dp_pc_dec'range) := r.dp_pc_dec;
          n.mal_raddr := (others=>'0');
            
        when rbaddr_ireg =>                 -- ireg ------------------
          irb_dout := r.dp_ireg;
          
        when rbaddr_imal =>                 -- imal ------------------
          irb_dout := MAL_DO;

        when others => null;
      end case;
    end if;

    -- cpu monitor 

    -- capture CPU state signals which are combinatorial logic
    if DM_STAT_SE.istart = '1' then
      n.dp_pc_fet := DM_STAT_DP.pc(15 downto 1);
    end if;
    n.dp_ireg      := DM_STAT_DP.ireg;
    n.dp_ireg_we   := DM_STAT_DP.ireg_we;
    n.dp_ireg_we_1 := r.dp_ireg_we;
    if r.dp_ireg_we = '1' then          -- dp_pc_dec update when dp_ireg changes
      n.dp_pc_dec := r.dp_pc_fet;
    end if;

    n.dp_dsrc_we  := DM_STAT_DP.dsrc_we;
    n.dp_ddst_we  := DM_STAT_DP.ddst_we;
    n.dp_dres_val := '0';
    if ((DM_STAT_DP.gr_we  or DM_STAT_DP.psr_we     or -- capture dres only when
         DM_STAT_DP.dsrc_we or DM_STAT_DP.ddst_we   or -- actually used
         DM_STAT_DP.dtmp_we or DM_STAT_DP.cpdout_we or
         DM_STAT_VM.vmcntl.req) = '1') then
      n.dp_dres := DM_STAT_DP.dres;
      n.dp_dres_val := '1';
    end if;

    n.vm_req    := DM_STAT_VM.vmcntl.req;
    -- capture vm request data when vm_req asserted, need them in later cycles
    -- don't update vmaddr for write part of rmw sequence
    -- no valid address vmaddr given, address is kept in vmbox
    if DM_STAT_VM.vmcntl.req = '1' then
      n.vm_wacc_1   := r.vm_wacc;
      n.vm_macc_1   := r.vm_macc;
      n.vm_cacc_1   := r.vm_cacc;
      n.vm_bytop_1  := r.vm_bytop;
      n.vm_dspace_1 := r.vm_dspace;
      n.vm_wacc     := DM_STAT_VM.vmcntl.wacc;
      n.vm_macc     := DM_STAT_VM.vmcntl.macc;
      n.vm_cacc     := DM_STAT_VM.vmcntl.cacc;
      n.vm_bytop    := DM_STAT_VM.vmcntl.bytop;
      n.vm_dspace   := DM_STAT_VM.vmcntl.dspace;
      if (DM_STAT_VM.vmcntl.macc and DM_STAT_VM.vmcntl.wacc) = '0' then
        n.vm_addr_1 := r.vm_addr;
        n.vm_addr   := DM_STAT_VM.vmaddr;
      end if;
      n.vm_din    := DM_STAT_VM.vmdin;
    end if;
    n.vm_ack    := DM_STAT_VM.vmstat.ack;
    n.vm_err    := DM_STAT_VM.vmstat.err;
    if DM_STAT_VM.vmstat.ack = '1' then
      n.vm_dout_1    := r.vm_dout;
      n.vm_dout      := DM_STAT_VM.vmdout;
      n.vm_trap_ysv  := DM_STAT_VM.vmstat.trap_ysv;
      n.vm_trap_mmu  := DM_STAT_VM.vmstat.trap_mmu;
    end if;
    if DM_STAT_VM.vmstat.err = '1' then
      n.vm_err_odd   := DM_STAT_VM.vmstat.err_odd;
      n.vm_err_mmu   := DM_STAT_VM.vmstat.err_mmu;
      n.vm_err_nxm   := DM_STAT_VM.vmstat.err_nxm;
      n.vm_err_iobto := DM_STAT_VM.vmstat.err_iobto;
      n.vm_err_rsv   := DM_STAT_VM.vmstat.err_rsv;
    end if;
      
    n.se_istart_1 := r.se_istart;
    n.se_idle     := DM_STAT_SE.idle;
    n.se_istart   := DM_STAT_SE.istart;
    n.se_idone    := DM_STAT_SE.idone;
    n.se_vstart   := DM_STAT_SE.vstart;
    n.se_snum     := DM_STAT_SE.snum;

    -- active state logic
    igoeff := '0';
    if r.go = '1' then
      if DM_STAT_CO.cpugo='1' and DM_STAT_CO.cpususp='0' then
        igoeff := '1';
      end if;
      if DM_STAT_CO.cpustep = '1' then
        igoeff := '1';
      end if;
    end if;

    iactive := r.active;
    if r.se_idle = '1' then             -- in idle state
      if igoeff = '0' then                -- if goeff=0 stop running
        n.active := '0';
      end if;
    else                                -- in non-idle state
      if igoeff = '1' then                -- if goerr=1 start running
        iactive  := '1';
        n.active := '1';
      end if;
    end if;

    if r.vm_req = '1' then
      n.mwdrop  := '0';
      n.vm_pend := '1';
    elsif (r.vm_ack or r.vm_err) = '1' then
      n.vm_pend := '0';      
    end if;
    
    itake := '0';
    if r.imode = '0' then               -- imode=0
      itake := '1';                       -- take all
      if r.mwsup = '1' then                 -- if mem wait suppress
        if (r.vm_pend and not (r.vm_ack or r.vm_err)) = '1' then
          itake    := '0';
          n.mwdrop := '1';
        end if;
      end if;
    else                                -- imode=1
      itake := r.se_idone or r.se_vstart or r.vm_err;
    end if;
    
    if iactive='1' and itake='1' then  -- active and enabled
      ibramen := '1';
      ibramwe := '1';
      laddr_inc := '1';
    end if;
    
    if laddr_inc = '1' then
      n.laddr := slv(unsigned(r.laddr) + 1);
      if r.go='1' and r.laddr=laddrlast then
        n.wrap := '1';
        if r.wstop = '1' then
          n.go   := '0';
        end if;
      end if;
    end if;

    -- last but not least: the clock cycle counter
    n.cnum := slv(unsigned(r.cnum) + 1);

    -- now build memory data word
    idat := (others=>'0');

    -- encode vm errors
    ivmerr := (others=>'0');
    if    r.vm_err_odd   = '1' then
      ivmerr := vmerr_odd;
    elsif r.vm_err_mmu   = '1' then
      ivmerr := vmerr_mmu;
    elsif r.vm_err_nxm   = '1' then
      ivmerr := vmerr_nxm;
    elsif r.vm_err_iobto = '1' then
      ivmerr := vmerr_iobto;
    elsif r.vm_err_rsv   = '1' then
      ivmerr := vmerr_rsv;
    end if;
    
    -- Note for imode=1
    --   Write vm request data unless there is an error.
    --   If in current or last cycle a ifetch (istart=1) was done use
    --   attributes of previous request. If last cycle was an ifetch
    --   and vm_ack set use also previous data. That ensures that the
    --   values of current instruction are shown, and not of pre-fetch

    -- build word8
    idat8 := (others=>'0');
    if r.vm_req = '1' or (r.imode='1' and r.vm_err='0') then
      idat8(dat8_rbf_req)    := '1';
      if r.imode = '1' and (r.se_istart='1' or r.se_istart_1='1') then
        idat8(dat8_rbf_wacc)   := R_REGS.vm_wacc_1;
        idat8(dat8_rbf_macc)   := R_REGS.vm_macc_1;
        idat8(dat8_rbf_cacc)   := R_REGS.vm_cacc_1;
        idat8(dat8_rbf_bytop)  := R_REGS.vm_bytop_1;
        idat8(dat8_rbf_dspace) := R_REGS.vm_dspace_1;
      else
        idat8(dat8_rbf_wacc)   := R_REGS.vm_wacc;
        idat8(dat8_rbf_macc)   := R_REGS.vm_macc;
        idat8(dat8_rbf_cacc)   := R_REGS.vm_cacc;
        idat8(dat8_rbf_bytop)  := R_REGS.vm_bytop;
        idat8(dat8_rbf_dspace) := R_REGS.vm_dspace;
      end if;
    else
      idat8(dat8_rbf_ack)    := R_REGS.vm_ack;
      idat8(dat8_rbf_err)    := R_REGS.vm_err;
      if r.vm_ack = '1' then
        idat8(dat8_rbf_trap_ysv) := R_REGS.vm_trap_ysv;
        idat8(dat8_rbf_trap_mmu) := R_REGS.vm_trap_mmu;
        idat8(dat8_rbf_mwdrop)   := R_REGS.mwdrop;
      elsif r.vm_err = '1' then
        idat8(dat8_rbf_vmerr)    := ivmerr;
      end if;
    end if;
    idat8(dat8_rbf_istart)  := R_REGS.se_istart;
    idat8(dat8_rbf_idone)   := R_REGS.se_idone;

    if r.imode = '0' then
      idat8(dat8_rbf_snum)   := R_REGS.se_snum;
    else
      idat8(dat8_rbf_cnum)   := R_REGS.cnum;
    end if;
    idat(bram_df_word8) := idat8;

    -- build word7
    idat7 := (others=>'0');
    idat7(dat7_rbf_pc)     := R_REGS.dp_pc_dec;
    idat7(dat7_rbf_idecode):= R_REGS.dp_ireg_we_1;
    idat(bram_df_word7)    := idat7;

    -- build word6
    idat(bram_df_word6)    := R_REGS.dp_ireg;

    -- build word5
    idat5 := (others=>'0');
    idat5(dat5_rbf_cmode)    := DM_STAT_DP.psw.cmode;
    idat5(dat5_rbf_pmode)    := DM_STAT_DP.psw.pmode;
    idat5(dat5_rbf_rset)     := DM_STAT_DP.psw.rset;
    if r.imode = '0' then
      idat5(dat5_rbf_dres_val) := R_REGS.dp_dres_val;
      idat5(dat5_rbf_ddst_we)  := R_REGS.dp_ddst_we;
      idat5(dat5_rbf_dsrc_we)  := R_REGS.dp_dsrc_we;
    else
      idat5(dat5_rbf_vstart)   := R_REGS.se_vstart;
    end if;
    idat5(dat5_rbf_pri)      := DM_STAT_DP.psw.pri;
    idat5(dat5_rbf_tflag)    := DM_STAT_DP.psw.tflag;
    idat5(dat5_rbf_cc)       := DM_STAT_DP.psw.cc;
    idat(bram_df_word5)      := idat5;
    
    -- build word4 to word2
    idat(bram_df_word4)    := DM_STAT_DP.dsrc;
    idat(bram_df_word3)    := DM_STAT_DP.ddst;
    idat(bram_df_word2)    := R_REGS.dp_dres;
    
    -- build word1
    if r.imode = '1' and (r.se_istart='1' or r.se_istart_1='1') then
      idat(bram_df_word1)    := R_REGS.vm_addr_1;
    else
      idat(bram_df_word1)    := R_REGS.vm_addr;
    end if;
    
    -- build word0
    if r.vm_wacc = '1' then
      idat(bram_df_word0) := R_REGS.vm_din;
    else
      if r.imode = '1' and r.se_istart_1 = '1' and r.vm_ack = '1' then
        idat(bram_df_word0) := R_REGS.vm_dout_1;
      else
        idat(bram_df_word0) := R_REGS.vm_dout;
      end if;
    end if;

    -- finally memory access log buffer logic
    if r.vm_cacc = '0' then
      if r.vm_req = '1' then
        imal_we := '1';
        imal_di := r.vm_addr;
      elsif r.vm_ack='1' then
        imal_we := '1';
        if r.vm_wacc='1' then
          imal_di := r.vm_din;
        else
          imal_di := r.vm_dout;
        end if;
        if r.vm_bytop = '1' then        -- for byte read/write data
          imal_di(15 downto 8) := (others=>'0'); -- zero msb (is undefined)
        end if;
      end if;
    end if;

    imal_waddr_clr := r.dp_ireg_we;      -- FIXME: very preliminary !!!
    
    if imal_waddr_clr = '1' then
      n.mal_waddr := (others=>'0');
    elsif imal_we = '1' then
      n.mal_waddr := slv(unsigned(r.mal_waddr) + 1);
    end if;
    
    if imal_raddr_clr = '1' then
      n.mal_raddr := (others=>'0');
    elsif imal_re = '1' then
      n.mal_raddr := slv(unsigned(r.mal_raddr) + 1);
    end if;
    
    N_REGS <= n;

    BRAM_EN <= ibramen;
    BRAM_WE <= ibramwe;
    BRAM_ADDRA <= '0' & R_REGS.laddr;
    BRAM_ADDRB <= '1' & R_REGS.laddr;
    BRAM_DI <= idat;

    MAL_WE <= imal_we;
    MAL_DI <= imal_di;
    
    RB_SRES.ack  <= irb_ack;
    RB_SRES.err  <= irb_err;
    RB_SRES.busy <= irb_busy;
    RB_SRES.dout <= irb_dout;

  end process proc_next;

end syn;
