-- $Id: fx2_2fifoctl_as.vhd 453 2012-01-15 17:51:18Z mueller $
--
-- Copyright 2011-2012 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    fx2_2fifoctl_as - syn
-- Description:    Cypress EZ-USB FX2 driver (2 fifo; async)
--
-- Dependencies:   vlib/xlib/iob_reg_o
--                 vlib/xlib/iob_reg_i_gen
--                 vlib/xlib/iob_reg_o_gen
--                 vlib/xlib/iob_reg_io_gen
--                 memlib/fifo_1c_dram
--
-- Test bench:     -
-- Target Devices: generic
-- Tool versions:  xst 12.1, 13.1, 13.3; ghdl 0.26-0.29
--
-- Synthesized (xst):
-- Date         Rev  ise         Target      flop lutl lutm slic t peri
-- 2012-01-14   453  13.3   O76x xc3s1200e-4   65  153   64  133 s  7.2
-- 2012-01-03   449  13.3   O76x xc3s1200e-4   67  149   64  133 s  7.2
-- 2011-12-25   445  13.3   O76x xc3s1200e-4   61  147   64  127 s  7.2
-- 2011-12-25   444  13.3   O76x xc3s1200e-4   54  140   64  123 s  7.2
-- 2011-07-07   389  12.1   M53d xc3s1200e-4   45  132   64  109 s  7.9
--
-- Revision History: 
-- Date         Rev Version  Comment
-- 2012-01-14   453   1.3    common DELAY for PE and WR; use aempty/afull logic
-- 2012-01-04   450   1.2.2  use new FLAG layout (EF,FF now fixed)
-- 2012-01-03   449   1.2.1  use new fx2ctl_moni layout; hardcode ep's
-- 2011-12-25   445   1.2    change pktend handling, now timer based
-- 2011-11-25   433   1.1.1  now numeric_std clean
-- 2011-07-30   400   1.1    capture rx data in 2nd last s_rdpwh cycle
-- 2011-07-24   389   1.0.2  use FX2_FLAG_N to signal that flags are act.low
-- 2011-07-17   394   1.0.1  (RX|TX)FIFOEP now generics; add MONI port
-- 2011-07-08   390   1.0    Initial version 
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.slvtypes.all;
use work.xlib.all;
use work.memlib.all;
use work.fx2lib.all;

entity fx2_2fifoctl_as is               -- EZ-USB FX2 driver (2 fifo; async)
  generic (
    RXFAWIDTH : positive :=  5;         -- receive  fifo address width
    TXFAWIDTH : positive :=  5;         -- transmit fifo address width
    PETOWIDTH : positive :=  7;         -- packet end time-out counter width
    CCWIDTH :   positive :=  5;         -- chunk counter width
    RXAEMPTY_THRES : natural := 1;      -- threshold for rx aempty flag
    TXAFULL_THRES  : natural := 1;      -- threshold for tx afull flag
    RDPWLDELAY : positive := 5;         -- slrd low  delay in clock cycles
    RDPWHDELAY : positive := 5;         -- slrd high delay in clock cycles
    WRPWLDELAY : positive := 5;         -- slwr low  delay in clock cycles
    WRPWHDELAY : positive := 7;         -- slwr high delay in clock cycles
    FLAGDELAY  : positive := 2);        -- flag delay in clock cycles
  port (
    CLK : in slbit;                     -- clock
    CE_USEC : in slbit;                 -- 1 usec clock enable
    RESET : in slbit := '0';            -- reset
    RXDATA : out slv8;                  -- receive data out
    RXVAL : out slbit;                  -- receive data valid
    RXHOLD : in slbit;                  -- receive data hold
    RXAEMPTY : out slbit;               -- receive almost empty flag
    TXDATA : in slv8;                   -- transmit data in
    TXENA : in slbit;                   -- transmit data enable
    TXBUSY : out slbit;                 -- transmit data busy
    TXAFULL : out slbit;                -- transmit almost full flag
    MONI : out fx2ctl_moni_type;        -- monitor port data
    I_FX2_IFCLK : in slbit;             -- fx2: interface clock
    O_FX2_FIFO : out slv2;              -- fx2: fifo address
    I_FX2_FLAG : in slv4;               -- fx2: fifo flags
    O_FX2_SLRD_N : out slbit;           -- fx2: read enable    (act.low)
    O_FX2_SLWR_N : out slbit;           -- fx2: write enable   (act.low)
    O_FX2_SLOE_N : out slbit;           -- fx2: output enable  (act.low)
    O_FX2_PKTEND_N : out slbit;         -- fx2: packet end     (act.low)
    IO_FX2_DATA : inout slv8            -- fx2: data lines
  );
end fx2_2fifoctl_as;


architecture syn of fx2_2fifoctl_as is

  constant c_rxfifo : slv2 := c_fifo_ep4;
  constant c_txfifo : slv2 := c_fifo_ep6;
  
  constant c_flag_prog   : integer := 0;
  constant c_flag_tx_ff  : integer := 1;
  constant c_flag_rx_ef  : integer := 2;
  constant c_flag_tx2_ff : integer := 3;

  type state_type is (
    s_init,                             -- s_init: init state
    s_rdprep,                           -- s_rdprep: prepare read
    s_rdwait,                           -- s_rdwait: wait for data
    s_rdpwl,                            -- s_rdpwl: read, strobe low
    s_rdpwh,                            -- s_rdpwh: read, strobe high
    s_wrprep,                           -- s_wrprep: prepare write
    s_wrpwl,                            -- s_wrpwl: write, strobe low
    s_wrpwh,                            -- s_wrpwh: write, strobe high
    s_peprep,                           -- s_peprep: prepare pktend
    s_pepwl,                            -- s_pepwl: pktend, strobe low
    s_pepwh                             -- s_pepwh: pktend, strobe high
  );
  
  type regs_type is record
    state : state_type;                 -- state
    petocnt : slv(PETOWIDTH-1 downto 0);  -- pktend time out counter
    pepend : slbit;                     -- pktend pending
    dlycnt : slv4;                      -- wait delay counter
    moni_ep4_sel : slbit;               -- ep4 (rx) select
    moni_ep6_sel : slbit;               -- ep6 (tx) select
    moni_ep4_pf : slbit;                -- ep4 (rx) prog flag
    moni_ep6_pf : slbit;                -- ep6 (rx) prog flag
  end record regs_type;

  constant petocnt_init : slv(PETOWIDTH-1 downto 0) := (others=>'0');

  constant regs_init : regs_type := (
    s_init,                             -- state
    petocnt_init,                       -- petocnt
    '0',                                -- pepend
    (others=>'0'),                      -- cntdly
    '0','0',                            -- moni_ep(4|6)_sel
    '0','0'                             -- moni_ep(4|6)_pf
  );
    
  signal R_REGS : regs_type := regs_init;  -- state registers
  signal N_REGS : regs_type := regs_init;  -- next value state regs

  signal FX2_FIFO     : slv2 := (others=>'0');
  signal FX2_FIFO_CE  : slbit := '0';
  signal FX2_FLAG_N   : slv4 := (others=>'0');
  signal FX2_SLRD_N   : slbit := '1';
  signal FX2_SLWR_N   : slbit := '1';
  signal FX2_SLOE_N   : slbit := '1';
  signal FX2_PKTEND_N : slbit := '1';
  signal FX2_DATA_CEI : slbit := '0';
  signal FX2_DATA_CEO : slbit := '0';
  signal FX2_DATA_OE  : slbit := '0';

  signal RXFIFO_DI  : slv8 := (others=>'0');
  signal RXFIFO_ENA  : slbit := '0';
  signal RXFIFO_BUSY : slbit := '0';
  signal RXSIZE  : slv(RXFAWIDTH downto 0) := (others=>'0');
  signal TXFIFO_DO   : slv8 := (others=>'0');
  signal TXFIFO_VAL  : slbit := '0';
  signal TXFIFO_HOLD : slbit := '0';
  signal TXSIZE  : slv(TXFAWIDTH downto 0) := (others=>'0');

  signal TXBUSY_L : slbit := '0';
  
begin

  assert RDPWLDELAY<=2**R_REGS.dlycnt'length and
         RDPWHDELAY<=2**R_REGS.dlycnt'length and RDPWHDELAY>=2 and
         WRPWLDELAY<=2**R_REGS.dlycnt'length and
         WRPWHDELAY<=2**R_REGS.dlycnt'length and
         FLAGDELAY<=2**R_REGS.dlycnt'length
    report "assert(*DELAY <= 2**dlycnt'length and RDPWHDELAY >=2)"
    severity failure;

  assert RXAEMPTY_THRES<=2**RXFAWIDTH and
         TXAFULL_THRES<=2**TXFAWIDTH
    report "assert((RXAEMPTY|TXAFULL)_THRES <= 2**(RX|TX)FAWIDTH)"
    severity failure;

  IOB_FX2_FIFO : iob_reg_o_gen
    generic map (
      DWIDTH => 2,
      INIT   => '0')
    port map (
      CLK => CLK,
      CE  => FX2_FIFO_CE,
      DO  => FX2_FIFO,
      PAD => O_FX2_FIFO
    );
  
  IOB_FX2_FLAG : iob_reg_i_gen
    generic map (
      DWIDTH => 4,
      INIT   => '0')
    port map (
      CLK => CLK,
      CE  => '1',
      DI  => FX2_FLAG_N,
      PAD => I_FX2_FLAG
    );
  
  IOB_FX2_SLRD : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => FX2_SLRD_N,
      PAD => O_FX2_SLRD_N
    );
  
  IOB_FX2_SLWR : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => FX2_SLWR_N,
      PAD => O_FX2_SLWR_N
    );
  
  IOB_FX2_SLOE : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => FX2_SLOE_N,
      PAD => O_FX2_SLOE_N
    );
    
  IOB_FX2_PKTEND : iob_reg_o
    generic map (
      INIT   => '1')
    port map (
      CLK => CLK,
      CE  => '1',
      DO  => FX2_PKTEND_N,
      PAD => O_FX2_PKTEND_N
    );

  IOB_FX2_DATA : iob_reg_io_gen
    generic map (
      DWIDTH => 8,
      PULL   => "KEEP")
    port map (
      CLK => CLK,
      CEI => FX2_DATA_CEI,
      CEO => FX2_DATA_CEO,
      OE  => FX2_DATA_OE,
      DI  => RXFIFO_DI,                 -- input data   (read from pad)
      DO  => TXFIFO_DO,                 -- output data  (write  to pad)
      PAD => IO_FX2_DATA
    );

  RXFIFO : fifo_1c_dram                -- input fifo, 1 clock, dram based
    generic map (
      AWIDTH => RXFAWIDTH,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => RXFIFO_DI,
      ENA   => RXFIFO_ENA,
      BUSY  => RXFIFO_BUSY,
      DO    => RXDATA,
      VAL   => RXVAL,
      HOLD  => RXHOLD,
      SIZE  => RXSIZE
    );

  TXFIFO : fifo_1c_dram                -- output fifo, 1 clock, dram based
    generic map (
      AWIDTH => TXFAWIDTH,
      DWIDTH => 8)
    port map (
      CLK   => CLK,
      RESET => RESET,
      DI    => TXDATA,
      ENA   => TXENA,
      BUSY  => TXBUSY_L,
      DO    => TXFIFO_DO,
      VAL   => TXFIFO_VAL,
      HOLD  => TXFIFO_HOLD,
      SIZE  => TXSIZE
    );
 
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

  proc_next: process (R_REGS, CE_USEC,
                      FX2_FLAG_N, TXFIFO_VAL, RXFIFO_BUSY, TXBUSY_L)

    variable r : regs_type := regs_init;
    variable n : regs_type := regs_init;

    variable idly_ld   : slbit := '0';
    variable idly_val  : slv(r.dlycnt'range) := (others=>'0');
    variable idly_end  : slbit := '0';
    variable idly_end1 : slbit := '0';

    variable iflag_rdok : slbit := '0';
    variable iflag_wrok : slbit := '0';

    variable ififo_ce : slbit := '0';
    variable ififo    : slv2 := "00";

    variable irxfifo_ena  : slbit := '0';
    variable itxfifo_hold : slbit := '0';

    variable islrd   : slbit := '0';
    variable islwr   : slbit := '0';
    variable isloe   : slbit := '0';
    variable ipktend : slbit := '0';

    variable idata_cei : slbit := '0';
    variable idata_ceo : slbit := '0';
    variable idata_oe  : slbit := '0';

    variable imoni  : fx2ctl_moni_type := fx2ctl_moni_init;
    
    procedure go_rdprep(nstate   : out state_type;
                        idly_ld  : out slbit;
                        idly_val : out slv4;
                        ififo_ce : out slbit;
                        ififo    : out slv2) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(FLAGDELAY-1, idly_val'length));
      ififo_ce := '1';
      ififo    := c_rxfifo;
      nstate   := s_rdprep;
    end procedure go_rdprep;

    procedure go_wrprep(nstate   : out state_type;
                        idly_ld  : out slbit;
                        idly_val : out slv4;
                        ififo_ce : out slbit;
                        ififo    : out slv2) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(FLAGDELAY-1, idly_val'length));
      ififo_ce := '1';
      ififo    := c_txfifo;
      nstate   := s_wrprep;
    end procedure go_wrprep;

    procedure go_peprep(nstate   : out state_type;
                        idly_ld  : out slbit;
                        idly_val : out slv4;
                        ififo_ce : out slbit;
                        ififo    : out slv2) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(FLAGDELAY-1, idly_val'length));
      ififo_ce := '1';
      ififo    := c_txfifo;
      nstate   := s_peprep;
    end procedure go_peprep;

    procedure go_rdpwl(nstate   : out state_type;
                       idly_ld  : out slbit;
                       idly_val : out slv4;
                       islrd    : out slbit) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(RDPWLDELAY-1, n.dlycnt'length));
      islrd    := '1';
      nstate   := s_rdpwl;
    end procedure go_rdpwl;

    procedure go_wrpwl(nstate   : out state_type;
                       idly_ld  : out slbit;
                       idly_val : out slv4;
                       islwr    : out slbit) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(WRPWLDELAY-1, n.dlycnt'length));
      islwr    := '1';
      nstate   := s_wrpwl;
    end procedure go_wrpwl;

    procedure go_pepwl(nstate   : out state_type;
                       idly_ld  : out slbit;
                       idly_val : out slv4;
                       ipktend  : out slbit) is
    begin
      idly_ld  := '1';
      idly_val := slv(to_unsigned(WRPWLDELAY-1, n.dlycnt'length));
      ipktend  := '1';
      nstate   := s_pepwl;
    end procedure go_pepwl;
    
  begin

    r := R_REGS;
    n := R_REGS;

    ififo_ce := '0';
    ififo    := "00";

    irxfifo_ena  := '0';
    itxfifo_hold := '1';
  
    islrd   := '0';
    islwr   := '0';
    isloe   := '0';
    ipktend := '0';

    idata_cei := '0';
    idata_ceo := '0';
    idata_oe  := '0';

    imoni := fx2ctl_moni_init;
    
    iflag_rdok := FX2_FLAG_N(c_flag_rx_ef);      -- empty flag is act.low!
    iflag_wrok := FX2_FLAG_N(c_flag_tx_ff);      --  full flag is act.low!
      
    idly_ld   := '0';
    idly_val  := (others=>'0');
    idly_end  := '1';    
    idly_end1 := '0';    
    if unsigned(r.dlycnt) /= 0 then
      idly_end := '0';
    end if;     
    if unsigned(r.dlycnt) = 1 then
      idly_end1 := '1';
    end if;     

    case r.state is
      when s_init =>                    -- s_init:
        go_rdprep(n.state, idly_ld, idly_val, ififo_ce, ififo);

      when s_rdprep =>                  -- s_rdprep: prepare read
        if idly_end = '1' then
          n.state := s_rdwait;
        end if;

      when s_rdwait =>                  -- s_rdwait: wait for data
        if r.pepend='1' and TXFIFO_VAL='0' then
          go_peprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
          
        elsif iflag_rdok='1' and
             (RXFIFO_BUSY='0' and TXBUSY_L='0') then
          go_rdpwl(n.state, idly_ld, idly_val, islrd);

        elsif TXFIFO_VAL = '1' then
          go_wrprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
        end if;
        
      when s_rdpwl =>                   -- s_rdpwl: read, strobe low
        idata_cei := '1';
        isloe     := '1';
        if idly_end = '1' then
          idly_ld  := '1';
          idly_val := slv(to_unsigned(RDPWHDELAY-1, n.dlycnt'length));
          n.state  := s_rdpwh;
        else
          islrd    := '1';
          n.state  := s_rdpwl;
        end if;

      -- Note: data is sampled and written into rxfifo in 2nd last cycle in the
      --       last cycle the rxfifo busy reflects therefore last written byte
      --       and safely indicates whether another byte will fit.
      when s_rdpwh =>                   -- s_rdpwh: read, strobe high
        idata_cei := '1';
        isloe     := '1';
        if idly_end1 = '1' then           -- 2nd last cycle
          irxfifo_ena := '1';             -- capture rxdata
        end if;
        if idly_end = '1' then            -- last cycle 
          if iflag_rdok='1' and
            (RXFIFO_BUSY='0' and TXBUSY_L='0') then
            go_rdpwl(n.state, idly_ld, idly_val, islrd);

          elsif TXFIFO_VAL = '1' then
            go_wrprep(n.state, idly_ld, idly_val, ififo_ce, ififo);

          else
            n.state := s_rdwait;
          end if;
        end if;

      when s_wrprep =>                  -- s_wrprep: prepare write
        if idly_end = '1' then
          if iflag_wrok = '1' then
            go_wrpwl(n.state, idly_ld, idly_val, islwr);
          else
            go_rdprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
          end if;
        end if;
        
      when s_wrpwl =>                   -- s_wrpwl: write, strobe low
        idata_ceo := '1';
        idata_oe  := '1';
        if idly_end = '1' then
          idata_ceo    := '0';
          itxfifo_hold := '0';
          idly_ld  := '1';
          idly_val := slv(to_unsigned(WRPWHDELAY-1, n.dlycnt'length));
          n.state := s_wrpwh;
        else
          islwr    := '1';
          n.state := s_wrpwl;
        end if;

      when s_wrpwh =>                   -- s_wrpwh: write, strobe high
        idata_oe  := '1';
        if idly_end = '1' then
          if iflag_wrok='1' and TXFIFO_VAL='1' then
            go_wrpwl(n.state, idly_ld, idly_val, islwr);
          elsif iflag_wrok='1' and r.pepend='1' and TXFIFO_VAL='0' then
            go_pepwl(n.state, idly_ld, idly_val, ipktend);
          else
            go_rdprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
          end if;
        end if;

      when s_peprep =>                  -- s_peprep: prepare pktend
        if idly_end = '1' then
          if iflag_wrok = '1' then
            go_pepwl(n.state, idly_ld, idly_val, ipktend);
          else
            go_rdprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
          end if;
        end if;
        
      when s_pepwl =>                   -- s_pepwl: pktend, strobe low
        if idly_end = '1' then
          idly_ld  := '1';
          idly_val := slv(to_unsigned(WRPWHDELAY-1, n.dlycnt'length));
          n.state := s_pepwh;
        else
          ipktend := '1';
          n.state := s_pepwl;
        end if;
        
      when s_pepwh =>                   -- s_pepwh: pktend, strobe high
        if idly_end = '1' then
          n.pepend := '0';
          go_rdprep(n.state, idly_ld, idly_val, ififo_ce, ififo);
        end if;

      when others => null;
    end case;

    if idly_ld = '1' then
      n.dlycnt := idly_val;
    elsif idly_end = '0' then
      n.dlycnt := slv(unsigned(r.dlycnt) - 1);
    end if;     

    -- pktend time-out handling:
    --   if tx fifo is non-empty, set counter to max
    --   if tx fifo is empty, count down every usec
    --   on 1->0 transition queue pktend request
    if TXFIFO_VAL = '1' then
      n.petocnt := (others=>'1');
    else
      if CE_USEC = '1' and unsigned(r.petocnt) /= 0 then
        n.petocnt := slv(unsigned(r.petocnt) - 1);
        if unsigned(r.petocnt) = 1 then
          n.pepend := '1';
        end if;
      end if;
    end if;

    n.moni_ep4_sel := '0';
    n.moni_ep6_sel := '0';
    if r.state = s_wrprep or r.state = s_wrpwl or r.state = s_wrpwh or
       r.state = s_peprep or r.state = s_pepwl or r.state = s_pepwh then
      n.moni_ep6_sel := '1';
      n.moni_ep6_pf  := not FX2_FLAG_N(c_flag_prog);
    else
      n.moni_ep4_sel := '1';
      n.moni_ep4_pf  := not FX2_FLAG_N(c_flag_prog);
    end if;
    
    imoni.fifo_ep4        := r.moni_ep4_sel;
    imoni.fifo_ep6        := r.moni_ep6_sel;
    imoni.flag_ep4_empty  := not FX2_FLAG_N(c_flag_rx_ef);
    imoni.flag_ep4_almost := r.moni_ep4_pf;
    imoni.flag_ep6_full   := not FX2_FLAG_N(c_flag_tx_ff);
    imoni.flag_ep6_almost := r.moni_ep6_pf;
    imoni.slrd            := islrd;
    imoni.slwr            := islwr;
    imoni.pktend          := ipktend;    
    
    N_REGS <= n;

    FX2_FIFO_CE  <= ififo_ce;
    FX2_FIFO     <= ififo;

    FX2_SLRD_N   <= not islrd;
    FX2_SLWR_N   <= not islwr;
    FX2_SLOE_N   <= not isloe;
    FX2_PKTEND_N <= not ipktend;

    FX2_DATA_CEI <= idata_cei;
    FX2_DATA_CEO <= idata_ceo;
    FX2_DATA_OE  <= idata_oe;

    RXFIFO_ENA   <= irxfifo_ena;
    TXFIFO_HOLD  <= itxfifo_hold;

    MONI         <= imoni;
    
  end process proc_next;

  proc_almost: process (RXSIZE, TXSIZE)
  begin

    -- (rx|tx)size is the number of bytes in fifo
    --   --> rxsize is number of bytes which can be read
    --   --> 2**txfawidth-txsize is is number of bytes which can be written
    
    if unsigned(RXSIZE) <= RXAEMPTY_THRES then
      RXAEMPTY <= '1';
    else
      RXAEMPTY <= '0';
    end if;

    if unsigned(TXSIZE) >= 2**TXFAWIDTH-TXAFULL_THRES then
      TXAFULL <= '1';
    else
      TXAFULL <= '0';
    end if;

  end process proc_almost;

  TXBUSY <= TXBUSY_L;
  
end syn;
