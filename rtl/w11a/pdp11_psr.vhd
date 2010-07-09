-- $Id: pdp11_psr.vhd 314 2010-07-09 17:38:41Z mueller $
--
-- Copyright 2006-2009 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
-- Module Name:    pdp11_psr - syn
-- Description:    pdp11: processor status word register
--
-- Dependencies:   -
-- Test bench:     tb/tb_pdp11_core (implicit)
-- Target Devices: generic
-- Tool versions:  xst 8.1, 8.2, 9.1, 9.2; ghdl 0.18-0.25
-- Revision History: 
-- Date         Rev Version  Comment
-- 2009-05-30   220   1.1.4  final removal of snoopers (were already commented)
-- 2008-08-22   161   1.1.3  rename ubf_ -> ibf_; use iblib
-- 2008-03-02   121   1.1.2  remove snoopers
-- 2008-01-05   110   1.1.1  rename IB_MREQ(ena->req) SRES(sel->ack, hold->busy)
-- 2007-12-30   107   1.1    use IB_MREQ/IB_SRES interface now
-- 2007-06-14    56   1.0.1  Use slvtypes.all
-- 2007-05-12    26   1.0    Initial version 
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

use work.slvtypes.all;
use work.iblib.all;
use work.pdp11.all;

-- ----------------------------------------------------------------------------

entity pdp11_psr is                     -- processor status word register
  port (
    CLK : in slbit;                     -- clock
    CRESET : in slbit;                  -- console reset
    DIN : in slv16;                     -- input data
    CCIN : in slv4;                     -- cc input
    CCWE : in slbit;                    -- enable update cc
    WE : in slbit;                      -- write enable (from DIN)
    FUNC : in slv3;                     -- write function (from DIN)
    PSW : out psw_type;                 -- current psw
    IB_MREQ : in ib_mreq_type;          -- ibus request
    IB_SRES : out ib_sres_type          -- ibus response
  );
end pdp11_psr;

architecture syn of pdp11_psr is

  constant ibaddr_psr : slv16 := conv_std_logic_vector(8#177776#,16);

  signal IBSEL_PSR : slbit := '0';
  signal R_PSW : psw_type := psw_init;  -- ps register

begin
  
  proc_ibsel: process (IB_MREQ)
    variable ipsr : slbit := '0';
  begin
    ipsr := '0';
    if IB_MREQ.req='1' and IB_MREQ.addr=ibaddr_psr(12 downto 1) then
      ipsr := '1';
    end if;
    IBSEL_PSR    <= ipsr;
    IB_SRES.ack  <= ipsr;
    IB_SRES.busy <= '0';
  end process proc_ibsel;
    
  proc_ibdout: process (IBSEL_PSR, R_PSW)
    variable pswout : slv16 := (others=>'0');
  begin
    pswout := (others=>'0');
    if IBSEL_PSR = '1' then
      pswout(psw_ibf_cmode) := R_PSW.cmode;
      pswout(psw_ibf_pmode) := R_PSW.pmode;
      pswout(psw_ibf_rset)  := R_PSW.rset;
      pswout(psw_ibf_pri)   := R_PSW.pri;
      pswout(psw_ibf_tflag) := R_PSW.tflag;
      pswout(psw_ibf_cc)    := R_PSW.cc;      
    end if;
    IB_SRES.dout <= pswout;
  end process proc_ibdout;
  
  proc_psw : process (CLK)
  begin
      
    if CLK'event and CLK='1' then

      if CRESET = '1' then
        R_PSW <= psw_init;

      else
        
        if CCWE = '1' then
          R_PSW.cc <= CCIN;
        end if;

        if WE = '1' then
          case FUNC is
            when c_psr_func_wspl =>       -- wspl
              R_PSW.pri <= DIN(2 downto 0);
            
            when c_psr_func_wcc =>        -- wcc
              if DIN(4) = '1' then        --   set cc opcodes
                R_PSW.cc <= R_PSW.cc or DIN(3 downto 0);
              else                        --   clear cc opcodes
                R_PSW.cc <= R_PSW.cc and not DIN(3 downto 0);
              end if;
            
            when c_psr_func_wint =>       -- wint (interupt handling)
              R_PSW.cmode <= DIN(psw_ibf_cmode);
              R_PSW.pmode <= R_PSW.cmode; --   save current mode
              R_PSW.rset <= DIN(psw_ibf_rset);
              R_PSW.pri <= DIN(psw_ibf_pri);
              R_PSW.tflag <= DIN(psw_ibf_tflag);
              R_PSW.cc <= DIN(psw_ibf_cc);
            
            when c_psr_func_wrti =>       -- wrti (rti/rtt in non-kernel mode)
              R_PSW.cmode <= R_PSW.cmode or DIN(psw_ibf_cmode);
              R_PSW.pmode <= R_PSW.pmode or DIN(psw_ibf_pmode) or
                             R_PSW.cmode or DIN(psw_ibf_cmode); 
              R_PSW.rset <= R_PSW.rset or DIN(psw_ibf_rset);
              R_PSW.tflag <= DIN(psw_ibf_tflag);
              R_PSW.cc <= DIN(psw_ibf_cc);

            when c_psr_func_wall =>       -- wall (rti/rtt kernel mode)
              R_PSW.cmode <= DIN(psw_ibf_cmode);
              R_PSW.pmode <= DIN(psw_ibf_pmode);
              R_PSW.rset <= DIN(psw_ibf_rset);
              R_PSW.pri <= DIN(psw_ibf_pri);
              R_PSW.tflag <= DIN(psw_ibf_tflag);
              R_PSW.cc <= DIN(psw_ibf_cc);
                           
            when others => null;
          end case;
        end if;
      end if;

      if IBSEL_PSR='1' and IB_MREQ.we='1' then
        if IB_MREQ.be1 = '1' then
          R_PSW.cmode <= IB_MREQ.din(psw_ibf_cmode);
          R_PSW.pmode <= IB_MREQ.din(psw_ibf_pmode);
          R_PSW.rset <= IB_MREQ.din(psw_ibf_rset);
        end if;
        if IB_MREQ.be0 = '1' then
          R_PSW.pri <= IB_MREQ.din(psw_ibf_pri);
          R_PSW.cc <= IB_MREQ.din(psw_ibf_cc);
        end if;
      end if;
      
    end if;
    
  end process proc_psw;

  PSW <= R_PSW;
  
end syn;
