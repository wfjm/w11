// $Id: rlink_cext_iface_dpi.sv 778 2016-06-25 15:18:01Z mueller $
//
// Copyright 2016- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
//
// This program is free software; you may redistribute and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 2, or at your option any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
// for complete details.
// 
//----------------------------------------------------------------------------
// Module Name:    rlink_cext_iface - sim
// Description:    Interface to external C code for tbcore_rlink - DPI version
//
// Dependencies:   -
//
// To test:        -
//
// Target Devices: generic
// Tool versions:  viv 2015.4-2016.3
// Revision History: 
// Date         Rev Version  Comment
// 2016-06-25   778   1.0.1  add timescale
// 2016-04-17   762   1.0    Initial version
// 2016-02-07   729   0.1    First draft
//----------------------------------------------------------------------------

`default_nettype none
`timescale 1 ps / 1 ps
  
package rlink_cext_dpi;
   import "DPI-C" function int rlink_cext_getbyte_dpi(input int clk);
   import "DPI-C" function int rlink_cext_putbyte_dpi(input int dat);
endpackage   // rlink_cext_dpi

module rlink_cext_iface(input  wire        clk,
                        input  wire [31:0] clk_cycle,
                        output reg  [31:0] rx_data,
                        output reg         rx_val,
                        input  wire        rx_hold,
                        input  wire [7:0]  tx_data,
                        input  wire        tx_ena
                        );
   
   int itxdata  = 0;
   int itxrc    = 0;
   int icycle   = 0;
   int irxdata  = 0;

   initial rx_data = 8'b00000000;
   initial rx_val  = 1'b0;

   always @ (posedge clk) begin
      //$display("+++tx1: ena: %b; data: %b", tx_ena, tx_data);
      if (tx_ena) begin
         itxdata = tx_data;
         itxrc   = rlink_cext_dpi::rlink_cext_putbyte_dpi(itxdata);
         if (itxrc != 0) begin
            $display("rlink_cext_putbyte error: %d", itxrc);
            $finish;            
         end
      end 
   end

   always @ (posedge clk) begin
      icycle   = clk_cycle;
      //$display("+++rx1: cyc: %4d; hold: %b; val: %b", icycle, rx_hold, rx_val);
      if (~rx_hold | ~rx_val ) begin
         irxdata  = rlink_cext_dpi::rlink_cext_getbyte_dpi(icycle);
         rx_data <= irxdata;
         rx_val  <= irxdata >= 0;
      end
   end

 
endmodule    // rlink_cext_iface

`default_nettype wire
