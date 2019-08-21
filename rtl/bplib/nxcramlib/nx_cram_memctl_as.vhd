-- $Id: nx_cram_memctl_as.vhd 1203 2019-08-19 21:41:03Z mueller $
-- SPDX-License-Identifier: GPL-3.0-or-later
-- Copyright 2010-2019 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
-- 
------------------------------------------------------------------------------
-- Module Name:    nx_cram_memctl_as - syn
-- Description:    nexys2/3/4: CRAM controller - async and page mode
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
-- Test bench:     tb/tb_nx_cram_memctl_as
--                 sys_gen/tst_sram/nexys2/tb/tb_tst_sram_n2
--                 sys_gen/tst_sram/nexys3/tb/tb_tst_sram_n3
--                 sys_gen/tst_sram/nexys4/tb/tb_tst_sram_n4
-- Target Devices: generic
-- Tool versions:  ise 11.4-14.7; viv 2014.4-2019.1; ghdl 0.26-0.36
--
-- Synthesized (viv):
-- Date         Rev  viv    Target       flop  lutl  lutm  bram  slic    
-- 2016-07-03   783 2016.3  xc7a100t-1     91    87     0     0    43
-- 
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2016-07-03   767 14.7 131013  xc6slx16-2   100  134    0   60 s  4.2
-- 2010-06-03   299 11.4    L68  xc3s1200e-4   91  100    0   96 s  6.7
-- 2010-05-24   294 11.4    L68  xc3s1200e-4   91   99    0   95 s  6.7
-- 2010-05-23   293 11.4    L68  xc3s1200e-4   91  139    0   99 s  6.7
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2019-08-17  1203   2.1.1  fix for ghdl V0.36 -Whide warnings
-- 2016-07-16   788   2.1    change *DELAY generics, now absolute delay cycles
--                           add s_init1; drop "KEEP" for data (better for dbg)
-- 2016-07-10   786   2.0    add page mode support
-- 2016-05-22   767   1.2.2  don't init N_REGS (vivado fix for fsm inference)
-- 2015-12-26   718   1.2.1  BUGFIX: do_dispatch(): always define imem_oe
-- 2011-11-26   433   1.2    renamed from n2_cram_memctl_as
-- 2011-11-19   432   1.1    remove O_FLA_CE_N port
-- 2011-11-19   427   1.0.5  now numeric_std clean
-- 2010-11-22   339   1.0.4  cntdly now 3 bit; add assert for DELAY generics
-- 2010-06-03   299   1.0.3  add "KEEP" for data iob; MEM_OE='1' on first read
--                           cycle;
-- 2010-05-30   297   1.0.2  use READ(0|1)DELAY generic
-- 2010-05-24   294   1.0.1  more compact n.memdi logic; extra wait in s_rdwait1
-- 2010-05-23   293   1.0    Initial version 
--
-- Notes:
--  1. There is no 'bus-turn-around' cycle needed for a write->read change
--     FPGA_OE goes 1->0 and MEM_OE goes 0->1 on the s_wrput1->s_rdinit
--     transition simultaneously. The FPGA will go high-Z quickly, the memory
--     low-Z delay by the IOB and internal memory delays. No clash.
--  2. There is a hidden 'bus-turn-around' cycle for a read->write change.
--     MEM_OE goes 1->0 on s_rdget1->s_wrinit and the memory will go high-z with
--     some delay. FPGA_OE goes 0->1 in the next cycle at s_wrinit->s_wrwait0.
--     Again no clash due to the 1 cycle delay.
--
-- Nominal timings:
--     READ0   = (T_aa + ext_read_delay)  in cycles
--     READ1   = (T_pa + ext_read_delay)  in cycles
--     WRITE   = (T_aa + ext_write_delay) in cycles
--   with
--     ext_read_delay:  output_IOB + 2*PCB_delay + input_IOB + skew
--     ext_write_delay: skew
--
--
-- Timing of some signals:
--
-- single read request:
--
-- state      |_idle  |_rdinit|_rdwt0 |_rdwt0 |_rdget0|_rdwt1 |_rdget1|
--                      0      20      40      60      80      100     120
-- CLK      __|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|
-- 
-- REQ      _______|^^^^^|_____________________________________________
-- WE       ___________________________________________________________
-- 
-- IOB_CE   __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_OE    _________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- 
-- DO       oooooooooooooooooooooooooooooooooooooooooo|lllllll|lllllll|h
-- BUSY     __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|________________
-- ACK_R   ___________________________________________________________|^^^^^^^|_
-- 
-- single write request:
-- 
-- state       |_idle  |_wrinit|_wrwt0 |_wrwt0 |_wrwt0 |_wrput0|_idle  |
--                       0      20      40      60      80      100     120
-- CLK       __|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|^^^|___|
-- 
-- REQ       _______|^^^^^|______________________________________
-- WE        _______|^^^^^|______________________________________
-- 
-- IOB_CE    __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_BE    __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_
-- IOB_OE    ____________________________________________________
-- IOB_WE    ______________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_____
-- 
-- BUSY      __________|^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^|_________
-- ACK_W     __________________________________________|^^^^^^^|_
-- 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;

entity nx_cram_memctl_as is             -- CRAM controller (async+page mode)
  generic (
    READ0DELAY : positive := 4;         -- read word 0 delay in clock cycles
    READ1DELAY : positive := 2;         -- read word 1 delay in clock cycles
    WRITEDELAY : positive := 4);        -- write delay in clock cycles
  port (
    CLK : in slbit;                     -- clock
    RESET : in slbit;                   -- reset
    REQ   : in slbit;                   -- request
    WE    : in slbit;                   -- write enable
    BUSY : out slbit;                   -- controller busy
    ACK_R : out slbit;                  -- acknowledge read
    ACK_W : out slbit;                  -- acknowledge write
    ACT_R : out slbit;                  -- signal active read
    ACT_W : out slbit;                  -- signal active write
    ADDR : in slv22;                    -- address  (32 bit word address)
    BE : in slv4;                       -- byte enable
    DI : in slv32;                      -- data in  (memory view)
    DO : out slv32;                     -- data out (memory view)
    O_MEM_CE_N : out slbit;             -- cram: chip enable   (act.low)
    O_MEM_BE_N : out slv2;              -- cram: byte enables  (act.low)
    O_MEM_WE_N : out slbit;             -- cram: write enable  (act.low)
    O_MEM_OE_N : out slbit;             -- cram: output enable (act.low)
    O_MEM_ADV_N : out slbit;            -- cram: address valid (act.low)
    O_MEM_CLK : out slbit;              -- cram: clock
    O_MEM_CRE : out slbit;              -- cram: command register enable
    I_MEM_WAIT : in slbit;              -- cram: mem wait
    O_MEM_ADDR  : out slv23;            -- cram: address lines
    IO_MEM_DATA : inout slv16           -- cram: data lines
  );
end nx_cram_memctl_as;


architecture syn of nx_cram_memctl_as is

  type state_type is (
    s_init,                             -- s_init: startup state
    s_init1,                            -- s_init1: reset released
    s_wcinit,                           -- s_wcinit: write rcr init
    s_wcwait,                           -- s_wcwait: write rcr wait
    s_wcput,                            -- s_wcput: write rcr done
    s_rainit,                           -- s_rainit: read array init
    s_rawait,                           -- s_rawait: wait read array
    s_idle,                             -- s_idle: wait for req
    s_rdinit,                           -- s_rdinit:  read init cycle
    s_rdwait0,                          -- s_rdwait0: read wait low word
    s_rdget0,                           -- s_rdget0:  read get low word
    s_rdwait1,                          -- s_rdwait1: read wait high word
    s_rdget1,                           -- s_rdget1:  read get high word
    s_wrinit,                           -- s_wrinit:  write init cycle
    s_wrwait0,                          -- s_rdwait0: write wait 1st word
    s_wrput0,                           -- s_rdput0:  write put 1st word
    s_wrini1,                           -- s_wrini1:  write init 2nd word
    s_wrwait1,                          -- s_wrwait1: write wait 2nd word
    s_wrput1                            -- s_wrput1:  write put 2nd word
  );
  
  type regs_type is record
    state : state_type;                 -- state
    ackr : slbit;                       -- signal ack_r
    addr0 : slbit;                      -- current addr0
    be2nd : slv2;                       -- be's of 2nd write cycle
    cntdly : slv3;                      -- wait delay counter
    cntce : slv7;                       -- ce counter
    fidle : slbit;                      -- force idle flag
    memdo0 : slv16;                     -- mem data out, low word
    memdi : slv32;                      -- mem data in
  end record regs_type;

  constant regs_init : regs_type := (
    s_init,                             -- state
    '0',                                -- ackr
    '0',                                -- addr0
    "00",                               -- be2nd
    (others=>'0'),                      -- cntdly
    (others=>'0'),                      -- cntce
    '0',                                -- fidle
    (others=>'0'),                      -- memdo0
    (others=>'0')                       -- memdi
  );

  constant c_addrh_rcr_setup : slv22 :=
    "000" &             -- 22:20 reserved MBZ
    "00"  &             -- 19:18 reg sel 00=RCR
    "0000000000"  &     -- 17: 8 reserved MBZ
    '1' &               --     7 page mode enable (1=enable)
    "00" &              --  6: 5 reserved MBZ
    '1' &               --     4 dpd disaable (1=disable)
    "000";              --  3: 1 rest is reserved or PAR, which should be 0

  signal R_REGS : regs_type := regs_init;
  signal N_REGS : regs_type;            -- don't init (vivado fix for fsm infer)
  
  signal CLK_180  : slbit := '0';
  signal MEM_CE_N : slbit := '1';
  signal MEM_BE_N : slv2  := "11";
  signal MEM_WE_N : slbit := '1';
  signal MEM_OE_N : slbit := '1';
  signal MEM_CRE  : slbit := '0';
  signal BE_CE    : slbit := '0';
  signal ADDRH_CE : slbit := '0';
  signal ADDR0_CE : slbit := '0';
  signal ADDRH    : slv22 := (others=>'0');
  signal ADDR0    : slbit := '0';
  signal DATA_CEI : slbit := '0';
  signal DATA_CEO : slbit := '0';
  signal DATA_OE  : slbit := '0';
  signal MEM_DO   : slv16 := (others=>'0');
  signal MEM_DI   : slv16 := (others=>'0');

begin

  -- Notes:
  --   used READ0DELAY-2 and READ0DELAY-3
  --   used READ1DELAY-2
  --   used WRITEDELAY-2
  
  assert READ0DELAY-2 < 2**R_REGS.cntdly'length and
         READ1DELAY-2 < 2**R_REGS.cntdly'length and
         WRITEDELAY-2 < 2**R_REGS.cntdly'length
    report "assert( (READ0,READ1,WRITE)DELAY-2 < 2**cntdly'length)"
    severity failure;
  assert READ0DELAY >= 3 and
         READ1DELAY >= 2 and
         WRITEDELAY >= 2
    report "assert( (READ0,READ1,WRITE)DELAY-2 >= 2 or 3)"
    severity failure;

  CLK_180 <= not CLK;
  
  IOB_MEM_CE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_CE_N,
      PAD => O_MEM_CE_N
    );
  
  IOB_MEM_BE : iob_reg_o_gen
    generic map (
      DWIDTH => 2,
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => BE_CE,
      DO  => MEM_BE_N,
      PAD => O_MEM_BE_N
    );
  
  IOB_MEM_WE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK_180,
      CE  => '1',
      DO  => MEM_WE_N,
      PAD => O_MEM_WE_N
    );
  
  IOB_MEM_OE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_OE_N,
      PAD => O_MEM_OE_N
    );
  
  IOB_MEM_CRE : iob_reg_o
    generic map (
      INIT   => '0')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => MEM_CRE,
      PAD => O_MEM_CRE
    );
  
  IOB_MEM_ADDRH : iob_reg_o_gen
    generic map (
      DWIDTH => 22)
    port map (
      CLK => CLK,
      CE  => ADDRH_CE,
      DO  => ADDRH,
      PAD => O_MEM_ADDR(22 downto 1)
    );
  
  IOB_MEM_ADDR0 : iob_reg_o
    port map (
      CLK => CLK,
      CE  => ADDR0_CE,
      DO  => ADDR0,
      PAD => O_MEM_ADDR(0)
    );
  
  IOB_MEM_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 16,
      PULL   => "NONE")
    port map (
      CLK => CLK,
      CEI => DATA_CEI,
      CEO => DATA_CEO,
      OE  => DATA_OE,
      DI  => MEM_DO,
      DO  => MEM_DI,
      PAD => IO_MEM_DATA
    );

  O_MEM_ADV_N <= '0';
  O_MEM_CLK   <= '0';

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

  proc_next: process (R_REGS, REQ, WE, BE, DI, ADDR, MEM_DO)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;
    variable ibusy : slbit := '0';
    variable iackw : slbit := '0';
    variable iactr : slbit := '0';
    variable iactw : slbit := '0';
    variable imem_ce   : slbit := '0';
    variable imem_be   : slv2  := "00";
    variable imem_we   : slbit := '0';
    variable imem_oe   : slbit := '0';
    variable imem_cre  : slbit := '0';
    variable ibe_ce    : slbit := '0';
    variable iaddrh_ce : slbit := '0';
    variable iaddr0_ce : slbit := '0';
    variable iaddrh    : slv22 := (others=>'0');
    variable iaddr0    : slbit := '0';
    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';
    
    procedure do_dispatch(pnstate  : out state_type;
                          piaddrh_ce : out slbit;
                          piaddr0_ce : out slbit;
                          piaddr0  : out slbit;
                          pibe_ce  : out slbit;
                          pimem_be : out slv2;
                          pimem_ce : out slbit;
                          pimem_oe : out slbit;
                          pnbe2nd  : out slv2) is
    begin
      piaddrh_ce := '1';                -- latch address (high part)
      piaddr0_ce := '1';                -- latch address 0 bit
      pibe_ce    := '1';                -- latch be's
      pimem_ce   := '1';                -- ce CRAM next cycle
      pnbe2nd    := "00";               -- assume no 2nd write cycle
      if WE = '0' then                  -- if READ requested
        piaddr0  := '0';                  -- go first for low word
        pimem_be := "11";                 -- on read always on
        pimem_oe := '1';                  -- oe CRAM next cycle
        pnstate  := s_rdinit;             -- next: read init part
      else                              -- if WRITE requested
        if BE(1 downto 0) /= "00" then    -- low word write
          piaddr0  := '0';                  -- access word 0 
          pimem_be := BE(1 downto 0);       -- set be's for 1st cycle
          pnbe2nd  := BE(3 downto 2);       -- keep be's for 2nd cycle
        else                              -- high word write
          piaddr0  := '1';                  -- access word 1 
          pimem_be := BE(3 downto 2);       -- set be's for 1st cycle
        end if;
        pimem_oe := '0';                  -- oe=0
        pnstate := s_wrinit;              -- next: write init part
      end if;
    end procedure do_dispatch;

  begin

    r := R_REGS;
    n := R_REGS;
    n.ackr := '0';

    ibusy := '0';
    iackw := '0';
    iactr := '0';
    iactw := '0';

    imem_ce   := '0';
    imem_be   := "11";
    imem_we   := '0';
    imem_oe   := '0';
    imem_cre  := '0';
    ibe_ce    := '0';
    iaddrh_ce := '0';
    iaddr0_ce := '0';
    iaddrh    := ADDR;
    iaddr0    := '0';
    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';

    if unsigned(r.cntdly) /= 0 then
      n.cntdly := slv(unsigned(r.cntdly) - 1);
    end if;

    case r.state is
      when s_init =>                    -- s_init: startup state
        ibusy   := '1';                   -- signal busy, unable to handle req
        n.state := s_init1;

      when s_init1 =>                   -- s_init1: reset released
        ibusy   := '1';                   -- signal busy, unable to handle req
        iaddrh  := c_addrh_rcr_setup;
        iaddr0  := '0';
        iaddrh_ce := '1';
        iaddr0_ce := '1';
        imem_ce  := '1';                  -- ce  CRAM next cycle
        imem_cre := '1';                  -- cre CRAM next cycle
        n.state := s_wcinit;

      when s_wcinit =>                  -- s_wcinit: write rcr init
        ibusy    := '1';                  -- signal busy, unable to handle req
        imem_ce  := '1';                  -- ce  CRAM next cycle
        imem_cre := '1';                  -- cre CRAM next cycle
        imem_we  := '1';                  -- we  CRAM next cycle
        n.cntdly := slv(to_unsigned(WRITEDELAY-2, n.cntdly'length));
        n.state  := s_wcwait;

      when s_wcwait =>                  -- s_wcinit: write rcr wait
        ibusy    := '1';                  -- signal busy, unable to handle req
        imem_ce  := '1';                  -- ce  CRAM next cycle
        imem_we  := '1';                  -- we  CRAM next cycle
        imem_cre := '1';                  -- cre CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_wcput;             -- next: write rcr done
        end if;

      when s_wcput =>                   -- s_wcput: write rcr done
        ibusy    := '1';                  -- signal busy, unable to handle req
        n.state  := s_rainit;             -- next: read array init

      when s_rainit =>                  -- s_rainit: read array init
        ibusy   := '1';                   -- signal busy, unable to handle req
        imem_ce := '1';                   -- ce CRAM next cycle
        n.cntdly:= slv(to_unsigned(READ0DELAY-2, n.cntdly'length));
        n.state := s_rawait ;             -- next: wait read array

      when s_rawait =>                  -- s_rawait: wait read array
        ibusy   := '1';                   -- signal busy, unable to handle req
        imem_ce := '1';                   -- ce CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_idle;              -- next: wait for req
        end if;

      when s_idle =>                    -- s_idle: wait for req
        if REQ = '1' then                 -- if IO requested
          do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                               ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
        end if;
        
      when s_rdinit =>                  -- s_rdinit:  read init cycle
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        n.cntdly:= slv(to_unsigned(READ0DELAY-3, n.cntdly'length));
        n.state := s_rdwait0;             -- next: wait low word

      when s_rdwait0 =>                  -- s_rdwait0: read wait low word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_rdget0;              -- next: get low word
        end if;

      when s_rdget0 =>                  -- s_rdget0: read get low word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        idata_cei := '1';                 -- latch input data
        iaddr0_ce := '1';                 -- latch address 0 bit
        iaddr0    := '1';                 -- now go for high word
        n.cntdly:= slv(to_unsigned(READ1DELAY-2, n.cntdly'length));
        n.state := s_rdwait1;             -- next: wait high word

      when s_rdwait1 =>                 -- s_rdwait1: read wait high word
        ibusy   := '1';                   -- signal busy, unable to handle req
        iactr   := '1';                   -- signal mem read
        imem_ce := '1';                   -- ce CRAM next cycle
        imem_oe := '1';                   -- oe CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_rdget1;              -- next: get high word
        end if;                             --

      when s_rdget1 =>                  -- s_rdget1: read get high word
        iactr   := '1';                   -- signal mem read
        n.memdo0:= MEM_DO;                -- save low word data
        idata_cei := '1';                 -- latch input data
        n.ackr  := '1';                   -- ACK_R next cycle
        n.state := s_idle;                -- next: wait next request
        if r.fidle = '1' then             -- forced idle cycle
          ibusy   := '1';                   -- signal busy, unable to handle req
        else
          if REQ = '1' then                 -- if IO requested            
            do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                 ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
          end if;
        end if;

      when s_wrinit =>                  -- s_wrinit:  write init cycle
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        iackw := '1';                     -- signal write done (all latched)
        idata_ceo:= '1';                  -- latch output data
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM in half cycle
        n.cntdly:= slv(to_unsigned(WRITEDELAY-2, n.cntdly'length));
        n.state := s_wrwait0;             -- next: wait

      when s_wrwait0 =>                 -- s_rdput0:  write wait 1st word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_wrput0;            -- next: put 1st word
        end if;

      when s_wrput0 =>                  -- s_rdput0:  write put 1st word
        iactw := '1';                     -- signal mem write
        imem_we  := '0';                  -- deassert we CRAM in half cycle
        if r.be2nd /= "00" then
          ibusy := '1';                     -- signal busy, unable to handle req
          imem_ce  := '1';                  -- ce CRAM next cycle
          iaddr0_ce := '1';                 -- latch address 0 bit
          iaddr0    := '1';                 -- now go for high word
          ibe_ce    := '1';                 -- latch be's
          imem_be   := r.be2nd;             -- now be's of high word
          n.state := s_wrini1;              -- next: start 2nd write
        else
          n.state := s_idle;                -- next: wait next request
          if r.fidle = '1' then             -- forced idle cycle
            ibusy   := '1';                   -- signal busy
          else
            if REQ = '1' then                 -- if IO requested            
              do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                   ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
            end if;
          end if;
        end if;

      when s_wrini1 =>                  -- s_wrini1:  write init 2nd word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_ceo:= '1';                  -- latch output data
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM in half cycle
        n.cntdly:= slv(to_unsigned(WRITEDELAY-2, n.cntdly'length));
        n.state := s_wrwait1;             -- next: wait

      when s_wrwait1 =>                 -- s_wrwait1: write wait 2nd word
        ibusy := '1';                     -- signal busy, unable to handle req
        iactw := '1';                     -- signal mem write
        idata_oe := '1';                  -- oe FPGA next cycle
        imem_ce  := '1';                  -- ce CRAM next cycle
        imem_we  := '1';                  -- we CRAM next cycle
        if unsigned(r.cntdly) = 0 then    -- wait expired ?
          n.state := s_wrput1;            -- next: put 2nd word
        end if;

      when s_wrput1 =>                  -- s_wrput1:  write put 2nd word
        iactw := '1';                     -- signal mem write
        imem_we  := '0';                  -- deassert we CRAM in half cycle
        n.state := s_idle;                -- next: wait next request
        if r.fidle = '1' then             -- forced idle cycle
          ibusy   := '1';                   -- signal busy, unable to handle req
        else
          if REQ = '1' then                 -- if IO requested            
            do_dispatch(n.state, iaddrh_ce, iaddr0_ce, iaddr0,
                                 ibe_ce, imem_be, imem_ce, imem_oe, n.be2nd);
          end if;
        end if;
                
      when others => null;
    end case;

    if imem_ce = '0' then               -- if cmem not active
      n.cntce := (others=>'0');           -- clear counter 
      n.fidle := '0';                     -- clear force idle flag
    else                                -- if cmem active
      if unsigned(r.cntce) >= 127 then    -- if max ce count expired
        n.fidle := '1';                     -- set forced idle flag
      else                                -- if max ce count not yet reached
        n.cntce := slv(unsigned(r.cntce) + 1);   -- increment counter
      end if;
    end if;
    
    if iaddrh_ce = '1' then             -- if addresses are latched
      n.memdi := DI;                      -- latch data too...
    end if;
    
    if iaddr0_ce = '1' then             -- if address bit 0 changed
      n.addr0 := iaddr0;                  -- mirror it in state regs
    end if;
    
    N_REGS <= n;

    MEM_CE_N <= not imem_ce;
    MEM_WE_N <= not imem_we;
    MEM_BE_N <= not imem_be;
    MEM_OE_N <= not imem_oe;
    MEM_CRE  <=     imem_cre;

    if r.addr0 = '0' then
      MEM_DI <= r.memdi(15 downto 0);
    else
      MEM_DI <= r.memdi(31 downto 16);
    end if;

    BE_CE    <= ibe_ce;
    ADDRH_CE <= iaddrh_ce;
    ADDR0_CE <= iaddr0_ce;
    ADDRH    <= iaddrh;
    ADDR0    <= iaddr0;
    DATA_CEI <= idata_cei;
    DATA_CEO <= idata_ceo;
    DATA_OE  <= idata_oe;

    BUSY  <= ibusy;
    ACK_R <= r.ackr;
    ACK_W <= iackw;
    ACT_R <= iactr;
    ACT_W <= iactw;
    
    DO    <= MEM_DO & r.memdo0;
    
  end process proc_next;
  
end syn;
