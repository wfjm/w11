-- $Id: tst_sram.vhd 1181 2019-07-08 17:00:50Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2007-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
--
------------------------------------------------------------------------------
-- Module Name:    tst_sram - syn
-- Description:    test of sram (s3,c7) and cram (n2,n3,n4) and its controller
--
-- Dependencies:   vlib/memlib/ram_1swsr_wfirst_gen
--                 vlib/memlib/ram_2swsr_wfirst_gen
--
-- Test bench:     arty/tb/tb_tst_sram_arty       (with ddr3 via mig)
--                 nexys4d/tb/tb_tst_mig_n4d      (with ddr2 via mig)
--                 cmoda7/tb/tb_tst_sram_c7       (with sram)
--                 nexys4/tb/tb_tst_sram_n4       (with cram)
--                 nexys3/tb/tb_tst_sram_n3       (with cram)
--                 nexys2/tb/tb_tst_sram_n2       (with cram)
--                 s3board/tb/tb_tst_sram_s3      (with sram)
--
-- Target Devices: generic
-- Tool versions:  xst 8.2-14.7; viv 2014.4-2018.3; ghdl 0.18-0.35
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-03-02  1116   1.6.1  define init_rbf_*
-- 2017-06-25   917   1.6    allow AWIDTH=17; sstat_rbf_awidth instead of _wide
-- 2016-07-10   785   1.5.1  std SWI layout: now (7:4) disp select, SWI(1)->XON
-- 2016-07-09   784   1.5    AWIDTH generic, add 22bit support for cram
-- 2016-05-22   767   1.4.1  don't init N_REGS (vivado fix for fsm inference)
-- 2014-09-05   591   1.4    use new rlink v4 iface and 4 bit STAT
-- 2014-08-15   583   1.3    rb_mreq addr now 16 bit
-- 2011-11-21   432   1.2.0  now numeric_std clean
-- 2010-12-31   352   1.2    port to rbv3
-- 2010-10-23   335   1.1.3  rename RRI_LAM->RB_LAM;
-- 2010-06-18   306   1.1.2  rename rbus data fields to _rbf_
-- 2010-06-03   299   1.1.1  correct rbus init logic (use we, RB_ADDR)
-- 2010-05-24   294   1.1    Correct _al->_dl logic, remove BUSY=0 condition
-- 2010-05-21   292   1.0.1  move memory controller to top level entity
-- 2010-05-16   291   1.0    Initial version (extracted from sys_tst_sram)
--                           now RB_SRES only driven when selected
------------------------------------------------------------------------------
--
-- rbus registers:
--
-- Address   Bits Name        r/w/f  Function
-- bbb00000 15:00 mdih        r/w/-  Memory data input register, high word
-- bbb00001 15:00 mdil        r/w/-  Memory data input register,  low word
-- bbb00010 15:00 mdoh        r/-/-  Memory data output register, high word
-- bbb00011 15:00 mdol        r/-/-  Memory data output register,  low word
-- bbb00100 01:00 maddrh      r/w/-  Memory address register, high word
-- bbb00101 15:00 maddrl      r/w/-  Memory address register,  low word
--
-- bbb00110       mcmd        -/-/f  Immediate memory command register
--             14   ld        -/-/f    if 1 load addrh field to maddr high word
--             13   inc       -/-/f    if 1 post-increment maddr
--             12   we        -/-/f    if 1 do write cycle, otherwise read
--          11:08   be        -/-/f    byte enables (used for writes)
--           *:00   addrh     -/-/f    maddr high word (loaded of ld=1)
--
-- bbb00111 15:00 mblk        r/w/-  Memory block read/write
--                                     pairs of r/w to access memory directly
--                                     read access logic:
--                                       than mdo is read from mem(maddr)
--                                       1st read gives mdoh, 2nd loads mdol
--                                       maddr is post-incrememted
--                                     write access logic:
--                                       1st write loads mdih, 2nd loads mdil
--                                       than mdi is written to mem(maddr)
--                                       maddr is post-incrememted
--
-- bbb01000 10:00 slim        r/w/-  Sequencer range register
-- bbb01001 10:00 saddr       r/w/-  Sequencer address register
-- bbb01010 15:00 sblk        r/w/-  Sequencer memory block read/write
--                                     groups of 4 r/w to access sequencer mem
--                                     access order: 11,10,01,00
-- bbb01011 15:00 sblkc       r/w/-  Like sblk, access to command part
--                                     groups of 2 r/w to access sequencer mem
--                                     access order: 11,10
-- bbb01100 15:00 sblkd       r/w/-  Like sblk, access to data part
--                                     groups of 2 r/w to access sequencer mem
--                                     access order: 01,00
-- bbb01101       sstat       r/w/-  Sequencer status register
--             15   wide      r/-/-    1 if AWIDTH=22
--             09   wswap     r/w/-    enable swap of upper 4 addr bits
--             08   wloop     r/w/-    enable wide (22bit) loop (default 18bit)
--             07   loop      r/w/-    loop till maddr=<all-ones>
--             06   xord      r/w/-    xor memory address with maddr
--             05   xora      r/w/-    xor memory data with mdi
--             04   veri      r/w/-    verify memory reads
--             01   fail      r/-/-    1 if sequencer stopped after failure
--             00   run       r/-/-    1 if sequencer running
-- bbb01110       sstart      -/-/f  Start sequencer (sstat.run=1, .fail=0)
-- bbb01111       sstop       -/-/f  Stop sequencer  (sstat.run=0)
-- bbb10000 10:00 seaddr      r/-/-  Current sequencer address
-- bbb10001 15:00 sedath      r/-/-  Current sequencer data (high word)
-- bbb10010 15:00 sedatl      r/-/-  Current sequencer data ( low word)
--
-- Sequencer memory format
--   64 bit wide, upper 32 bits sequencer command, lower 32 bits data
--   Item    Bits Name        Function
--   scmd   31:28   wait      number of wait cycles
--             24   we        write enable
--          23:20   be        byte enables
--          17:00   addr      address
--
------------------------------------------------------------------------------
--
-- Usage of S3BOARD Switches, Buttons, LEDs:
--
--    BTN(3:0): unused
--
--    SWI(7:4): determine data displayed
--          SWI 3210
--              0000  mdil
--              0001  mdih
--              0010  mem_do.l
--              0011  mem_do.h
--              0100  maddr.l
--              0101  maddr.h
--              0110  slim
--              0111  saddr
--              1000  sstat
--              1001  seaddr
--              1010  sedatl
--              1011  sedath
--              1100  smem_b0  data.l
--              1101  smem_b1  data.h
--              1110  smem_b2  cmd.l
--              1111  smem_b3  cmd.h
--    SWI(3:2): unused
--    SWI(1):   1 enable XON
--    SWI(0):   RS232 port select (on some boards)
--
--    LED(7):   or of all unused BTNs and SWI
--    LED(6):   R_REGS.sloop
--    LED(5):   R_REGS.sveri
--    LED(4):   R_REGS.sfail
--    LED(3):   R_REGS.srun
--    LED(2):   MEM_ACT_W
--    LED(1):   MEM_ACT_R
--    LED(0):   MEM_BUSY
--
--    DSP:      data as selected by SWI(7..4)
--
--    DP(3):    not SER_MONI.txok       (shows tx back pressure)
--    DP(2):    SER_MONI.txact          (shows tx activity)
--    DP(1):    not SER_MONI.rxok       (shows rx back pressure)
--    DP(0):    SER_MONI.rxact          (shows rx activity)
--

-- ----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.rutil.all;
use work.memlib.all;
use work.rblib.all;

-- ----------------------------------------------------------------------------

entity tst_sram is                      -- tester for sram memctl
  generic (
    RB_ADDR : slv16 := slv(to_unsigned(2#0000000000000000#,16));
    AWIDTH : natural := 18);
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    RB_MREQ : in rb_mreq_type;          -- rbus: request
    RB_SRES : out rb_sres_type;         -- rbus: response
    RB_STAT : out slv4;                 -- rbus: status flags
    RB_LAM : out slbit;                 -- remote attention
    SWI : in slv8;                      -- hio switches
    BTN : in slv4;                      -- hio buttons
    LED : out slv8;                     -- hio leds
    DSP_DAT : out slv16;                -- hio display data
    MEM_RESET : out slbit;              -- mem: reset
    MEM_REQ   : out slbit;              -- mem: request
    MEM_WE    : out slbit;              -- mem: write enable
    MEM_BUSY : in slbit;                -- mem: controller busy
    MEM_ACK_R : in slbit;               -- mem: acknowledge read
    MEM_ACK_W : in slbit;               -- mem: acknowledge write
    MEM_ACT_R : in slbit;               -- mem: signal active read
    MEM_ACT_W : in slbit;               -- mem: signal active write
    MEM_ADDR : out slv(AWIDTH-1 downto 0); -- mem: address
    MEM_BE : out slv4;                  -- mem: byte enable
    MEM_DI : out slv32;                 -- mem: data in  (memory view)
    MEM_DO : in slv32                   -- mem: data out (memory view)
  );
end tst_sram;

architecture syn of tst_sram is

  constant IWIDTH : natural := imin(18, AWIDTH);
  
  signal SEQ_RESET : slbit := '0';
  
  signal SMEM_CEA : slbit := '0';
  signal SMEM_B3_WE : slbit := '0';
  signal SMEM_B2_WE : slbit := '0';
  signal SMEM_B1_WE : slbit := '0';
  signal SMEM_B0_WE : slbit := '0';
  signal SMEM_WEB  : slbit := '0';
  signal SMEM_CMD  : slv32 := (others=>'0');
  signal SMEM_DATA : slv32 := (others=>'0');

  type state_type is (
    s_idle,                             -- s_idle: wait for input
    s_mcmd,                             -- s_mcmd: immediate memory r/w
    s_mcmd_read,                        -- s_mcmd_read: wait for read completion
    s_mblk_wr1,                         -- s_mblk_wr1: mem blk write, get datal
    s_mblk_wr2,                         -- s_mblk_wr2: mem blk write, do write
    s_mblk_rd1,                         -- s_mblk_rd1: mem blk read, wait, datah
    s_mblk_rd2,                         -- s_mblk_rd2: mem blk read, datal
    s_sblk_rd,                          -- s_sblk_rd: read smem for sblk
    s_sblk,                             -- s_sblk: process sblk transfers
    s_sstart,                           -- s_sstart: sequencer startup 
    s_sload,                            -- s_sload: sequencer load data
    s_srun,                             -- s_srun: run sequencer commands
    s_sloop                             -- s_sloop: stop or loop
  );

  type regs_type is record
    state  : state_type;                -- state
    rbsel  : slbit;                     -- rbus select
    maddr  : slv(AWIDTH-1 downto 0);    -- memory address
    mdi    : slv32;                     -- memory data input
    saddr  : slv11;                     -- sequencer address
    slim   : slv11;                     -- sequencer range
    sbank  : slv2;                      -- current sblk bank
    srun   : slbit;                     -- seq: run flag
    slast  : slbit;                     -- seq: last cmd flag
    sfail  : slbit;                     -- seq: fail flag
    swcnt  : slv4;                      -- seq: wait counter
    scaddr : slv11;                     -- seq: current address
    sveri  : slbit;                     -- seq: verify mode (check data)
    sxora  : slbit;                     -- seq: xor maddr into address
    sxord  : slbit;                     -- seq: xor mdi   into data
    sloop  : slbit;                     -- seq: loop over maddr
    swloop : slbit;                     -- seq: enable wide loop (22bit)
    swswap : slbit;                     -- seq: enable top 4 bit addr swap
    mrp_val_al : slbit;                 -- mrp: valid flag,   addr latch stage
    mrp_adr_al : slv11;                 -- mrp: seq address,  addr latch stage
    mrp_dat_al : slv32;                 -- mrp: exp mem data, addr latch stage
    mrp_val_dl : slbit;                 -- mrp: valid flag,   data latch stage
    mrp_adr_dl : slv11;                 -- mrp: seq address,  data latch stage
    mrp_dat_dl : slv32;                 -- mrp: exp mem data, data latch stage
    se_addr : slv11;                    -- seq err: seq address
    se_data : slv32;                    -- seq err: memory data
    dispval : slv16;                    -- data for display
  end record regs_type;

  constant maddrzero : slv(AWIDTH-1 downto 0) := (others=>'0');
  
  constant regs_init : regs_type := (
    s_idle,                             -- state
    '0',                                -- rbsel
    maddrzero,                          -- maddr
    (others=>'0'),                      -- mdi
    (others=>'0'),                      -- saddr
    (others=>'0'),                      -- slim
    (others=>'0'),                      -- sbank
    '0','0','0',                        -- srun, slast, sfail
    (others=>'0'),                      -- swcnt
    (others=>'0'),                      -- scaddr
    '0','0','0',                        -- sveri,sxora,sxord
    '0','0','0',                        -- sloop,swloop,swswap
    '0',                                -- mrp_val_al
    (others=>'0'),                      -- mrp_adr_al
    (others=>'0'),                      -- mrp_dat_al
    '0',                                -- mrp_val_dl
    (others=>'0'),                      -- mrp_adr_dl
    (others=>'0'),                      -- mrp_dat_dl
    (others=>'0'),                      -- se_addr
    (others=>'0'),                      -- se_data
    (others=>'0')                       -- dispval
  );

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)

  subtype  maddr_f_wh      is integer range  AWIDTH-1 downto 16;
  subtype  maddr_f_wl      is integer range  15 downto  0;

  subtype  maddr_f_scmd    is integer range  IWIDTH-1 downto  0;
  subtype  maddr_f_top4    is integer range  AWIDTH-1   downto AWIDTH-1-3;
  subtype  maddr_f_mid4    is integer range  AWIDTH-1-4 downto AWIDTH-1-7;
  subtype  maddr_f_bot     is integer range  AWIDTH-1-8 downto          0;

  subtype  df_word0        is integer range  15 downto  0;
  subtype  df_word1        is integer range  31 downto 16;

  constant init_rbf_seq:    integer :=  0;
  constant init_rbf_mem:    integer :=  1;
  
  subtype  maddrh_rbf_h    is integer range  AWIDTH-1-16 downto 0;

  constant mcmd_rbf_ld:    integer :=  14;
  constant mcmd_rbf_inc:   integer :=  13;
  constant mcmd_rbf_we:    integer :=  12;
  subtype  mcmd_rbf_be     is integer range 11 downto  8;
  subtype  mcmd_rbf_addrh  is integer range AWIDTH-1-16 downto  0;
  
  subtype  sstat_rbf_awidth is integer range 15 downto  13;
  constant sstat_rbf_wswap: integer :=   9;
  constant sstat_rbf_wloop: integer :=   8;
  constant sstat_rbf_loop:  integer :=   7;
  constant sstat_rbf_xord:  integer :=   6;
  constant sstat_rbf_xora:  integer :=   5;
  constant sstat_rbf_veri:  integer :=   4;
  constant sstat_rbf_fail:  integer :=   1;
  constant sstat_rbf_run:   integer :=   0;

  subtype  scmd_rbf_wait   is integer range 31 downto 28;
  constant scmd_rbf_we:    integer :=  24;
  subtype  scmd_rbf_be     is integer range 23 downto 20;
  subtype  scmd_rbf_addr   is integer range IWIDTH-1 downto  0;

  constant rbaddr_mdih:   slv5 := "00000";  --  0    -/r/w
  constant rbaddr_mdil:   slv5 := "00001";  --  1    -/r/w
  constant rbaddr_mdoh:   slv5 := "00010";  --  2    -/r/-
  constant rbaddr_mdol:   slv5 := "00011";  --  3    -/r/-
  constant rbaddr_maddrh: slv5 := "00100";  --  4    -/r/w
  constant rbaddr_maddrl: slv5 := "00101";  --  5    -/r/w
  constant rbaddr_mcmd:   slv5 := "00110";  --  6    -/-/w
  constant rbaddr_mblk:   slv5 := "00111";  --  7    -/r/w
  constant rbaddr_slim:   slv5 := "01000";  --  8    -/r/w
  constant rbaddr_saddr:  slv5 := "01001";  --  9    -/r/w
  constant rbaddr_sblk:   slv5 := "01010";  -- 10    -/r/w
  constant rbaddr_sblkc:  slv5 := "01011";  -- 11    -/r/w
  constant rbaddr_sblkd:  slv5 := "01100";  -- 12    -/r/w
  constant rbaddr_sstat:  slv5 := "01101";  -- 13    -/r/w
  constant rbaddr_sstart: slv5 := "01110";  -- 14    f/-/-
  constant rbaddr_sstop:  slv5 := "01111";  -- 15    f/-/-
  constant rbaddr_seaddr: slv5 := "10000";  -- 16    -/r/-
  constant rbaddr_sedath: slv5 := "10001";  -- 17    -/r/-
  constant rbaddr_sedatl: slv5 := "10010";  -- 18    -/r/-

  constant omux_mdil:    slv4 := "0000";
  constant omux_mdih:    slv4 := "0001";
  constant omux_memdol:  slv4 := "0010";
  constant omux_memdoh:  slv4 := "0011";
  constant omux_maddrl:  slv4 := "0100";
  constant omux_maddrh:  slv4 := "0101";
  constant omux_slim:    slv4 := "0110";
  constant omux_saddr:   slv4 := "0111";
  constant omux_sstat:   slv4 := "1000";
  constant omux_seaddr:  slv4 := "1001";
  constant omux_sedatl:  slv4 := "1010";
  constant omux_sedath:  slv4 := "1011";
  constant omux_smemb0:  slv4 := "1100";
  constant omux_smemb1:  slv4 := "1101";
  constant omux_smemb2:  slv4 := "1110";
  constant omux_smemb3:  slv4 := "1111";

begin

  assert AWIDTH=17 or AWIDTH=18 or AWIDTH=22 
    report "assert(AWIDTH=17 or AWIDTH=18 or AWIDTH=22): unsupported AWIDTH"
    severity failure;

  SMEM_B3 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH => 16)
    port map (
      CLK  => CLK,
      EN   => SMEM_CEA,
      WE   => SMEM_B3_WE,
      ADDR => R_REGS.saddr,
      DI   => RB_MREQ.din,
      DO   => SMEM_CMD(df_word1)
    );

  SMEM_B2 : ram_1swsr_wfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH => 16)
    port map (
      CLK  => CLK,
      EN   => SMEM_CEA,
      WE   => SMEM_B2_WE,
      ADDR => R_REGS.saddr,
      DI   => RB_MREQ.din,
      DO   => SMEM_CMD(df_word0)
    );

  SMEM_B1 : ram_2swsr_wfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH => 16)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => SMEM_CEA,
      ENB   => SMEM_WEB,
      WEA   => SMEM_B1_WE,
      WEB   => SMEM_WEB,
      ADDRA => R_REGS.saddr,
      ADDRB => R_REGS.mrp_adr_dl,
      DIA   => RB_MREQ.din,
      DIB   => MEM_DO(df_word1),
      DOA   => SMEM_DATA(df_word1),
      DOB   => open
    );

  SMEM_B0 : ram_2swsr_wfirst_gen
    generic map (
      AWIDTH => 11,
      DWIDTH => 16)
    port map (
      CLKA  => CLK,
      CLKB  => CLK,
      ENA   => SMEM_CEA,
      ENB   => SMEM_WEB,
      WEA   => SMEM_B0_WE,
      WEB   => SMEM_WEB,
      ADDRA => R_REGS.saddr,
      ADDRB => R_REGS.mrp_adr_dl,
      DIA   => RB_MREQ.din,
      DIB   => MEM_DO(df_word0),
      DOA   => SMEM_DATA(df_word0),
      DOB   => open
    );

  -- look for init's against the rbus base address
  -- generate subsystem resets depending in data bits
  proc_reset: process (RESET, RB_MREQ)
  begin

    SEQ_RESET <= RESET;
    MEM_RESET <= RESET;

    if RB_MREQ.init='1' and RB_MREQ.addr=RB_ADDR then
      SEQ_RESET <= RB_MREQ.din(init_rbf_seq);
      MEM_RESET <= RB_MREQ.din(init_rbf_mem);
    end if;
    
  end process proc_reset;

  proc_regs: process (CLK)
  begin

    if rising_edge(CLK) then
      if SEQ_RESET = '1' then
        R_REGS <= regs_init;
      else
        R_REGS <= N_REGS;
      end if;
    end if;

  end process proc_regs;

  proc_next: process (R_REGS, RB_MREQ,
                      MEM_BUSY, MEM_ACT_R, MEM_ACK_R, MEM_DO,
                      SMEM_CMD, SMEM_DATA,
                      SWI)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable irb_ack  : slbit := '0';
    variable irb_busy : slbit := '0';
    variable irb_err  : slbit := '0';
    variable irb_dout : slv16 := (others=>'0');
    variable irbena : slbit := '0';     -- re or we           -> rbus request
    variable irbact : slbit := '0';     -- sel and (re or we) -> device active

    variable imem_reqr : slbit := '0';
    variable imem_reqw : slbit := '0';
    variable imem_be :   slv4  := (others=>'0');
    variable imem_addr : slv(AWIDTH-1 downto 0) := (others=>'0');
    variable imem_di :   slv32 := (others=>'0');

    variable ixor_addr : slv(AWIDTH-1 downto 0) := (others=>'0');
    variable ixor_data : slv32 := (others=>'0');
    variable imaddr_chk: slv(AWIDTH-1 downto 0) := (others=>'0');

    variable isblk_ok  : slbit := '0';
    variable isbank    : slv2  := "11";

    variable maddr_inc : slbit := '0';
    variable saddr_inc : slbit := '0';
    variable saddr_next : slbit := '0';
    variable saddr_last : slbit := '0';
    variable swcnt_inc : slbit := '0';
    
    variable ilam : slbit := '0';

    variable omux_sel : slv4  := "0000";
    variable omux_dat : slv16 := (others=>'0');

    constant c_maddr_ones : slv(AWIDTH-1 downto 0) := (others=>'1');

  begin

    r := R_REGS;
    n := R_REGS;

    irb_ack  := '0';
    irb_busy := '0';
    irb_err  := '0';
    irb_dout := (others=>'0');

    irbena  := RB_MREQ.re or RB_MREQ.we;
    irbact  := '0';

    imem_reqr := '0';
    imem_reqw := '0';
    imem_be   := (others=>'1');
    imem_addr := r.maddr;
    imem_di   := r.mdi;

    ixor_addr := (others=>'0');
    ixor_data := (others=>'0');

    isblk_ok := '0';
    isbank   := "11";
    
    maddr_inc := '0';
    saddr_inc := '0';
    saddr_next := '0';
    saddr_last := '0';
    swcnt_inc := '0';

    ilam := '0';

    omux_sel := omux_mdil;
    omux_dat := (others=>'0');
    
    SMEM_CEA   <= '0';
    SMEM_B3_WE <= '0';
    SMEM_B2_WE <= '0';
    SMEM_B1_WE <= '0';
    SMEM_B0_WE <= '0';
    SMEM_WEB   <= '0';

    if r.saddr = r.slim then
      saddr_last := '1';
    end if;

    if r.mrp_val_dl='1' and MEM_ACK_R='1' then
      n.mrp_val_dl := '0';
      if r.sveri = '1' then
        if r.mrp_dat_dl /= MEM_DO and                  -- mismatch
           r.sfail='0' then                              -- and no fail set yet
          ilam := '1';
          n.sfail := '1';
          n.srun  := '0';
          n.se_addr := r.mrp_adr_dl;
          n.se_data := MEM_DO;
        end if;
      else
        SMEM_WEB <= '1';
      end if;
    end if;
    if r.mrp_val_al='1' and MEM_ACT_R='1' then
      n.mrp_val_al := '0';
      n.mrp_val_dl := r.mrp_val_al;
      n.mrp_adr_dl := r.mrp_adr_al;
      n.mrp_dat_dl := r.mrp_dat_al;
    end if;

    -- rbus address decoder
    n.rbsel := '0';
    if RB_MREQ.aval='1' and RB_MREQ.addr(15 downto 5)=RB_ADDR(15 downto 5) then
      n.rbsel := '1';
    end if;
    
    if r.rbsel='1' and irbena='1' then
      irb_ack := '1';                     -- ack all (maybe rejected later)
      irbact := '1';                      -- signal device active
    end if;

    case r.state is

      when s_idle =>                    -- s_idle: wait for rbus requests ----

        if r.rbsel = '1' then             -- rbus select
          
          case RB_MREQ.addr(4 downto 0) is  -- rbus address decoder

            when rbaddr_mdih => 
              omux_sel := omux_mdih;
              if RB_MREQ.we = '1' then
                n.mdi(df_word1) := RB_MREQ.din;
              end if;

            when rbaddr_mdil => 
              omux_sel := omux_mdil;
              if RB_MREQ.we = '1' then
                n.mdi(df_word0) := RB_MREQ.din;
              end if;

            when rbaddr_mdoh => 
              omux_sel := omux_memdoh;
              if RB_MREQ.we = '1' then
                irb_err := '1';             -- read-only reg
              end if;

            when rbaddr_mdol => 
              omux_sel := omux_memdol;
              if RB_MREQ.we = '1' then
                irb_err := '1';             -- read-only reg
              end if;

            when rbaddr_maddrh => 
              omux_sel := omux_maddrh;
              if RB_MREQ.we = '1' then
                n.maddr(maddr_f_wh) := RB_MREQ.din(maddrh_rbf_h);
              end if;

            when rbaddr_maddrl => 
              omux_sel := omux_maddrl;
              if RB_MREQ.we = '1' then
                n.maddr(maddr_f_wl) := RB_MREQ.din;
              end if;

            when rbaddr_mcmd =>
              if RB_MREQ.we = '1' then
                if RB_MREQ.din(mcmd_rbf_ld) = '1' then
                  n.maddr(maddr_f_wh) := RB_MREQ.din(mcmd_rbf_addrh);
                end if;
                irb_busy := '1';
                n.state := s_mcmd;
              end if;
              if RB_MREQ.re = '1' then
                irb_err := '1';         -- write-only reg
              end if;
            
            when rbaddr_mblk =>
              imem_addr := r.maddr;

              if RB_MREQ.we = '1' then
                n.mdi(df_word1) := RB_MREQ.din;
                n.state := s_mblk_wr1;
              end if;
              if RB_MREQ.re = '1' then
                irb_busy := '1';
                imem_reqr := '1';
                if MEM_BUSY = '0' then
                  maddr_inc := '1';
                  n.state := s_mblk_rd1;
                end if;
              end if;
            
            when rbaddr_slim => 
              omux_sel := omux_slim;
              if RB_MREQ.we = '1' then
                n.slim := RB_MREQ.din(r.slim'range);
              end if;

            when rbaddr_saddr => 
              omux_sel := omux_saddr;
              if RB_MREQ.we = '1' then
                n.saddr := RB_MREQ.din(r.saddr'range);
              end if;

            when rbaddr_sblk|rbaddr_sblkc|rbaddr_sblkd =>
              if RB_MREQ.we = '1' then
                n.sbank := "11";
                irb_busy := '1';
                n.state := s_sblk;
              end if;
              if RB_MREQ.re = '1' then                
                n.sbank := "11";
                irb_busy := '1';
                n.state := s_sblk_rd;
              end if;

            when rbaddr_sstat =>
              omux_sel := omux_sstat;
              if RB_MREQ.we = '1' then
                n.swswap := RB_MREQ.din(sstat_rbf_wswap);
                n.swloop := RB_MREQ.din(sstat_rbf_wloop);
                n.sloop  := RB_MREQ.din(sstat_rbf_loop);
                n.sxord  := RB_MREQ.din(sstat_rbf_xord);
                n.sxora  := RB_MREQ.din(sstat_rbf_xora);
                n.sveri  := RB_MREQ.din(sstat_rbf_veri);
              end if;
            
            when rbaddr_sstart => 
              if RB_MREQ.we = '1' then
                n.sfail := '0';
                n.state := s_sstart;
              end if;
              if RB_MREQ.re = '1' then
                irb_err := '1';         -- write-only reg
              end if;

            when rbaddr_sstop => 
              if RB_MREQ.we = '1' then
                n.srun  := '0';
              end if;
              if RB_MREQ.re = '1' then
                irb_err := '1';         -- write-only reg
              end if;

            when rbaddr_seaddr => 
              omux_sel := omux_seaddr;
              if RB_MREQ.we = '1' then
                irb_err := '1';         -- read-only reg
              end if;

            when rbaddr_sedath =>
              omux_sel := omux_sedath;
              if RB_MREQ.we = '1' then
                irb_err := '1';         -- read-only reg
              end if;

            when rbaddr_sedatl => 
              omux_sel := omux_sedatl;
              if RB_MREQ.we = '1' then
                irb_err := '1';         -- read-only reg
              end if;

            when others =>
              irb_ack := '0';           -- refuse ack in case of bad addr
          end case;

        else                            -- no rbus request (rb_mreq.ack='0')
          
          if r.srun = '1' then
            n.state := s_srun;
          end if;

        end if;
        
      when s_mcmd=>                     -- s_mcmd: immediate memory r/w ------
        if RB_MREQ.din(mcmd_rbf_we) = '1' then  -- write command 
          imem_reqw := '1';
        else                              -- read command
          imem_reqr := '1';          
        end if;
        imem_be   := RB_MREQ.din(mcmd_rbf_be);
        imem_addr := r.maddr;
        imem_di   := r.mdi;
        
        if irbact = '0' then              -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if MEM_BUSY = '0' then         -- command accepted ?
            if RB_MREQ.din(mcmd_rbf_inc) = '1' then -- maddr inc requested
              maddr_inc := '1';
            end if;
            if RB_MREQ.din(mcmd_rbf_we) = '1' then  -- write command 
              n.state := s_idle;
            else                              -- read command
              irb_busy := '1';
              n.state := s_mcmd_read;
            end if;
          else                                -- otherwise
            irb_busy := '1';                    -- hold and wait
          end if;
        end if;

      when s_mcmd_read =>              -- s_mcmd_read: wait for read completion

        if irbact = '0' then              -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if MEM_ACK_R = '1' then           -- read acknowledge seen
            n.state := s_idle;
          else                              -- otherwise
            irb_busy := '1';                  -- hold and wait
          end if;
        end if;
        
      when s_mblk_wr1 =>                -- s_mblk_wr1: mem blk write, get datal
        if irbact = '1' then              -- wait for rbus request
          if RB_MREQ.we = '1' and           -- write access and cmd ok ?
             RB_MREQ.addr(4 downto 0)=rbaddr_mblk then 
            n.mdi(df_word0) := RB_MREQ.din;   -- latch datal
            irb_busy := '1';
            n.state := s_mblk_wr2;            -- next: issue mem write
          else
            irb_err := '1';                   -- signal error
            n.state := s_idle;                -- return to dispatch            
          end if;
        end if;

      when s_mblk_wr2 =>                -- s_mblk_wr2: mem blk write, do write
        n.state := s_mblk_wr2;             -- needed to prevent vivado iSTATE
        imem_reqw := '1';
        imem_be   := (others=>'1');
        imem_addr := r.maddr;
        imem_di   := r.mdi;

        if irbact = '0' then              -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if MEM_BUSY = '0' then            -- command accepted ?
            maddr_inc := '1';
            n.state := s_idle;
          else                              -- otherwise
            irb_busy := '1';                  -- hold and wait
          end if;
        end if;
          
      when s_mblk_rd1 =>                -- s_mblk_rd1: mem blk read, wait, datah
        omux_sel := omux_memdoh;          -- return mem datah
        if irbact = '0' then              -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          if MEM_ACK_R = '1' then           -- read acknowledge seen
            n.state := s_mblk_rd2;
          else                              -- otherwise
            irb_busy := '1';                  -- hold and wait
          end if;
        end if;
          
      when s_mblk_rd2 =>                -- s_mblk_rd2: mem blk read, datal ---
        omux_sel := omux_memdol;          -- return mem datal
        if irbact = '1' then              -- wait for rbus request
          if RB_MREQ.re = '1' and           -- read access and cmd ok ?
             RB_MREQ.addr(4 downto 0)=rbaddr_mblk then 
            n.state := s_idle;
          else                              -- write if unexpected cmd addr
            irb_err := '1';                   -- signal error
            n.state := s_idle;                -- return to dispatch
          end if;
        end if;

      when s_sblk_rd =>                 -- s_sblk_rd: read smem for sblk -----
        if irbact = '0' then              -- rbus cycle abort
          n.state := s_idle;                -- quit
        else
          irb_busy := '1';
          SMEM_CEA <= '1';
          n.state := s_sblk;
        end if;
          
      when s_sblk =>                    -- s_sblk: process sblk transfers ----

        isblk_ok := irbact;

        case RB_MREQ.addr(4 downto 0) is 
          when rbaddr_sblk =>
            isbank := r.sbank;
            if r.sbank = "00" then
              saddr_next := irbact;
            end if;
          when rbaddr_sblkc => 
            isbank := '1' & r.sbank(0);
            if r.sbank(0) = '0' then
              saddr_next := irbact;
            end if;
          when rbaddr_sblkd => 
            isbank := '0' & r.sbank(0);
            if r.sbank(0) = '0' then
              saddr_next := irbact;
            end if;
          when others =>
            isblk_ok := '0';
        end case;

        if isblk_ok='1' and RB_MREQ.we='1' then
          SMEM_CEA <= '1';
          case isbank is
            when "11" => SMEM_B3_WE <= '1';
            when "10" => SMEM_B2_WE <= '1';
            when "01" => SMEM_B1_WE <= '1';
            when "00" => SMEM_B0_WE <= '1';
            when others => null;
          end case;
        end if;

        case isbank is
          when "11" => omux_sel := omux_smemb3;
          when "10" => omux_sel := omux_smemb2;
          when "01" => omux_sel := omux_smemb1;
          when "00" => omux_sel := omux_smemb0;
          when others => null;
        end case;

        if isblk_ok = '1' then            -- in active sblk cycle ?
          n.sbank := slv(unsigned(r.sbank) - 1);
          if saddr_next = '1' then
            saddr_inc := '1';
            if RB_MREQ.re = '1' then
              n.state := s_sblk_rd;
            end if;
          end if;
        else                              -- not in active sblk cycle
          if irbact = '1' then              -- if request than other address
            irb_busy := '1';                  -- hold interface and
            n.state := s_idle;                -- back to dispatcher to handle
          end if;
        end if;        

      when s_sstart =>                  -- s_sstart: sequencer startup -------
        irb_busy := irbact;
        n.slast := '0';
        n.srun  := '1';
        n.saddr := (others=>'0');
        n.se_addr := (others=>'0');
        n.se_data := (others=>'0');
        n.state := s_sload;
        
      when s_sload =>                   -- s_sload: sequencer load data ------
        irb_busy := irbact;
        SMEM_CEA <= '1';
        n.scaddr := r.saddr;
        saddr_inc := '1';
        if saddr_last = '1' then
          n.slast := '1';
        end if;
        n.state := s_srun;
        
      when s_srun =>                    -- s_srun: run sequencer commands ----
        irb_busy := irbact;
        ixor_addr := r.maddr;
        if r.sxora = '0' then
          ixor_addr(maddr_f_scmd) := SMEM_CMD(scmd_rbf_addr);
        else
          ixor_addr(maddr_f_scmd) := SMEM_CMD(scmd_rbf_addr) xor
                                       r.maddr(maddr_f_scmd);
        end if;

        if r.swswap = '1' then
          ixor_addr := ixor_addr(maddr_f_mid4) & ixor_addr(maddr_f_top4) &
                         ixor_addr(maddr_f_bot);
        end if;
        
        if r.sxord = '0' then
          ixor_data := SMEM_DATA;
        else
          ixor_data := SMEM_DATA xor r.mdi;
        end if;
        imem_addr := ixor_addr;
        imem_be   := SMEM_CMD(scmd_rbf_be);
        imem_di   := ixor_data;

        if SMEM_CMD(scmd_rbf_wait) /= r.swcnt then
          swcnt_inc := '1';
        else
          if SMEM_CMD(scmd_rbf_we) = '1' then
            imem_reqw := '1';
          else
            imem_reqr := '1';
          end if;
          if MEM_BUSY = '0' then
            if imem_reqr = '1' then
              n.mrp_val_al := '1';
              n.mrp_adr_al := r.scaddr;
              n.mrp_dat_al := ixor_data;
            end if;
            if r.srun = '0' then
              n.state := s_idle;
            elsif r.slast = '1' then
              n.state := s_sloop;
            else
              SMEM_CEA <= '1';
              n.scaddr := r.saddr;
              saddr_inc := '1';
              if saddr_last = '1' then
                n.slast := '1';
              end if;
              if irbact = '1' then        -- pending rbus request ?
                n.state := s_idle;          -- than goto dispatcher
              end if;
            end if;
          end if;
        end if;
        
      when s_sloop =>                   -- s_sloop: stop or loop -------------
        irb_busy := irbact;
        imaddr_chk := r.maddr;
        if AWIDTH = 22 and r.swloop = '0' then
          imaddr_chk(maddr_f_top4) := (others=>'1');
        end if;
        if MEM_ACT_R='0' and MEM_ACK_R='0' then  -- wait here till mem read done
          if r.sfail='0' and r.sloop='1' and     -- no fail and loop requested ?
            imaddr_chk/=c_maddr_ones then        -- and not wrapping
              maddr_inc := '1';             -- increment maddr 
              n.state := s_sstart;          -- and restart
          else                            -- otherwise
            ilam   := not r.sfail;          -- signal attention unless fail set
            n.srun := '0';                  -- stop sequencer
            n.state := s_idle;              -- goto dispatcher
          end if;
        end if;

      when others => null;
    end case;

    if maddr_inc = '1' then
      n.maddr := slv(unsigned(r.maddr) + 1);
    end if;
    
    if saddr_inc = '1' then
      n.saddr := slv(unsigned(r.saddr) + 1);
    end if;

    if swcnt_inc = '1' then
      n.swcnt := slv(unsigned(r.swcnt) + 1);
    else
      n.swcnt := (others=>'0');      
    end if;

    if irbact = '0' then                -- if no rbus request, use SWI for mux
      omux_sel := SWI(7 downto 4);
    end if;

    case omux_sel is
      when omux_mdil   =>
        omux_dat := r.mdi(df_word0);
      when omux_mdih   =>
        omux_dat := r.mdi(df_word1);
      when omux_memdoh =>
        omux_dat := MEM_DO(df_word1);
      when omux_memdol =>
        omux_dat := MEM_DO(df_word0);
      when omux_maddrh =>
        omux_dat := (others=>'0');
        omux_dat(maddrh_rbf_h) := r.maddr(maddr_f_wh);
      when omux_maddrl =>
        omux_dat := r.maddr(maddr_f_wl);
      when omux_slim =>
        omux_dat := (others=>'0');
        omux_dat(r.slim'range) := r.slim;
      when omux_saddr =>
        omux_dat := (others=>'0');
        omux_dat(r.saddr'range) := r.saddr;
      when omux_sstat =>
        omux_dat := (others=>'0');
        omux_dat(sstat_rbf_awidth):= slv(to_unsigned(AWIDTH-16,3));
        omux_dat(sstat_rbf_wswap) := r.swswap;
        omux_dat(sstat_rbf_wloop) := r.swloop;
        omux_dat(sstat_rbf_loop)  := r.sloop;
        omux_dat(sstat_rbf_xord)  := r.sxord;
        omux_dat(sstat_rbf_xora)  := r.sxora;
        omux_dat(sstat_rbf_veri)  := r.sveri;
        omux_dat(sstat_rbf_fail)  := r.sfail;
        omux_dat(sstat_rbf_run)   := r.srun;
      when omux_seaddr =>
        omux_dat := (others=>'0');
        omux_dat(r.se_addr'range) := r.se_addr;
      when omux_sedath =>
        omux_dat := r.se_data(df_word1);
      when omux_sedatl =>
        omux_dat := r.se_data(df_word0);
      when omux_smemb0 =>
        omux_dat := SMEM_DATA(df_word0);
      when omux_smemb1 =>
        omux_dat := SMEM_DATA(df_word1);
      when omux_smemb2 =>
        omux_dat := SMEM_CMD(df_word0);
      when omux_smemb3 =>
        omux_dat := SMEM_CMD(df_word1);
        
      when others => null;
    end case;
    
    if irbact = '1' then
      irb_dout  := omux_dat;            -- if rbus request, drive dout
    else
      n.dispval := omux_dat;            -- if no rbus request, display mux value
    end if;

    N_REGS       <= n;

    RB_SRES      <= rb_sres_init;
    RB_SRES.ack  <= irb_ack;
    RB_SRES.busy <= irb_busy;
    RB_SRES.err  <= irb_err;
    RB_SRES.dout <= irb_dout;

    MEM_REQ  <= imem_reqr or imem_reqw;
    MEM_WE   <= imem_reqw;
    MEM_BE   <= imem_be;  
    MEM_ADDR <= imem_addr;
    MEM_DI   <= imem_di;

    RB_LAM   <= ilam;
    
  end process proc_next;

  RB_STAT(3) <= '0';
  RB_STAT(2) <= '0';
  RB_STAT(1) <= R_REGS.sfail;
  RB_STAT(0) <= R_REGS.srun;
    
  DSP_DAT   <= R_REGS.dispval;
  
  LED(0) <= MEM_BUSY;
  LED(1) <= MEM_ACT_R;
  LED(2) <= MEM_ACT_W;
  LED(3) <= R_REGS.srun;
  LED(4) <= R_REGS.sfail;
  LED(5) <= R_REGS.sveri;
  LED(6) <= R_REGS.sloop;
  LED(7) <= SWI(3) or SWI(2) or SWI(1) or SWI(0) or
            BTN(0) or BTN(1) or BTN(2) or BTN(3);
  
end syn;
