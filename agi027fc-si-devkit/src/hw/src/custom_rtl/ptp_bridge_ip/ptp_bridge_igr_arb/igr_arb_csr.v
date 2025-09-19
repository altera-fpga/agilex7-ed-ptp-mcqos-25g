//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

module igr_arb_csr (
// register offset : 0x0, field offset : 0, access : RW, scratch_reg.scratch
// register offset : 0x4, field offset : 0, access : RW, cfg_priority_dma.ch_0
output  reg[3:0] cfg_priority_dma_ch_0,
// register offset : 0x4, field offset : 4, access : RW, cfg_priority_dma.ch_1
output  reg[3:0] cfg_priority_dma_ch_1,
// register offset : 0x4, field offset : 8, access : RW, cfg_priority_dma.ch_2
output  reg[3:0] cfg_priority_dma_ch_2,
// register offset : 0x4, field offset : 12, access : RO, cfg_priority_dma.reserved
// register offset : 0x8, field offset : 0, access : RW, cfg_priority_user.port_0
output  reg[3:0] cfg_priority_user_port_0,
// register offset : 0x8, field offset : 4, access : RO, cfg_priority_user.reserved
//Bus Interface
input clk,
input reset,
input [31:0] writedata,
input read,
input write,
input [3:0] byteenable,
output reg [31:0] readdata,
output reg readdatavalid,
input [3:0] address

);


wire reset_n = !reset;	
// Protocol management
// combinatorial read data signal declaration
reg [31:0] rdata_comb;

// synchronous process for the read
always @(posedge clk)  
   if (!reset_n) readdata[31:0] <= 32'h0; else readdata[31:0] <= rdata_comb[31:0];

// read data is always returned on the next cycle
always @( posedge clk)
   if (!reset_n) readdatavalid <= 1'b0; else readdatavalid <= read;
//
//  Protocol specific assignment to inside signals
//
wire  we = write;
wire  re = read;
wire [3:0] addr = address[3:0];
wire [31:0] din  = writedata [31:0];
// A write byte enable for each register
// register scratch_reg with  writeType: write
wire	[3:0]  we_scratch_reg		=	we  & (addr[3:0]  == 4'h0)	?	byteenable[3:0]	:	{4{1'b0}};
// register cfg_priority_dma with  writeType: write
wire	[1:0]  we_cfg_priority_dma		=	we  & (addr[3:0]  == 4'h4)	?	byteenable[1:0]	:	{2{1'b0}};
// register cfg_priority_user with  writeType: write
wire	  we_cfg_priority_user		=	we  & (addr[3:0]  == 4'h8)	?	byteenable[0]	:	1'b0;

// A read byte enable for each register

/* Definitions of REGISTER "scratch_reg" */

// scratch_reg_scratch
// bitfield description: Scratch Register.
// customType:  RW
// hwAccess: NA 
// reset value : 0x00000000 

reg [31:0] scratch_reg_scratch; // 

always @( posedge clk)
   if (!reset_n)  begin
      scratch_reg_scratch <= 32'h00000000;
   end
   else begin
   if (we_scratch_reg[0]) begin 
      scratch_reg_scratch[7:0]   <=  din[7:0];  //
   end
   if (we_scratch_reg[1]) begin 
      scratch_reg_scratch[15:8]   <=  din[15:8];  //
   end
   if (we_scratch_reg[2]) begin 
      scratch_reg_scratch[23:16]   <=  din[23:16];  //
   end
   if (we_scratch_reg[3]) begin 
      scratch_reg_scratch[31:24]   <=  din[31:24];  //
   end
end
/* Definitions of REGISTER "cfg_priority_dma" */

// cfg_priority_dma_ch_0
// bitfield description: Configured priority level for DMA channel 0.
// 0: highest priority, 3: lowest priority, d4-d15: reserved.This register along with cfg_priority_user register (0x8) configures the ingress arbiter priority levels.
// Values across both registers must have unique priority values.
// customType:  RW
// hwAccess: RO 
// reset value : 0x0 


always @( posedge clk)
   if (!reset_n)  begin
      cfg_priority_dma_ch_0 <= 4'h0;
   end
   else begin
   if (we_cfg_priority_dma[0]) begin 
      cfg_priority_dma_ch_0[3:0]   <=  din[3:0];  //
   end
end

// cfg_priority_dma_ch_1
// bitfield description: Configured priority level for DMA channel 1.
// 0: highest priority, 3: lowest priority, d4-d15: reserved.This register along with cfg_priority_user register (0x8) configures the ingress arbiter priority levels.
// Values across both registers must have unique priority values.
// customType:  RW
// hwAccess: RO 
// reset value : 0x2 


always @( posedge clk)
   if (!reset_n)  begin
      cfg_priority_dma_ch_1 <= 4'h2;
   end
   else begin
   if (we_cfg_priority_dma[0]) begin 
      cfg_priority_dma_ch_1[3:0]   <=  din[7:4];  //
   end
end

// cfg_priority_dma_ch_2
// bitfield description: Configured priority level for DMA channel 2.
// 0: highest priority, 3: lowest priority, d4-d15: reserved.This register along with cfg_priority_user register (0x8) configures the ingress arbiter priority levels.
// Values across both registers must have unique priority values.
// customType:  RW
// hwAccess: RO 
// reset value : 0x3 


always @( posedge clk)
   if (!reset_n)  begin
      cfg_priority_dma_ch_2 <= 4'h3;
   end
   else begin
   if (we_cfg_priority_dma[1]) begin 
      cfg_priority_dma_ch_2[3:0]   <=  din[11:8];  //
   end
end

// cfg_priority_dma_reserved
// bitfield description: Reserved.
// customType:  RO
// hwAccess: NA 
// reset value : 0x00000 
// NO register generated


/* Definitions of REGISTER "cfg_priority_user" */

// cfg_priority_user_port_0
// bitfield description: Configured priority level for User_0 port.
// 0: highest priority, 3: lowest priority, d4-d15: reserved.This register along with cfg_priority_dma register (0x4) configures the ingress arbiter priority levels.
// Values across both registers must have unique priority values.
// customType:  RW
// hwAccess: RO 
// reset value : 0x1 


always @( posedge clk)
   if (!reset_n)  begin
      cfg_priority_user_port_0 <= 4'h1;
   end
   else begin
   if (we_cfg_priority_user) begin 
      cfg_priority_user_port_0[3:0]   <=  din[3:0];  //
   end
end

// cfg_priority_user_reserved
// bitfield description: Reserved.
// customType:  RO
// hwAccess: NA 
// reset value : 0x0000000 
// NO register generated




// read process
always @ (*)
begin
rdata_comb = 32'h00000000;
   if(re) begin
      case (addr)  
	4'h0 : begin
		rdata_comb [31:0]	= scratch_reg_scratch [31:0] ;		// readType = read   writeType =write
	end
	4'h4 : begin
		rdata_comb [3:0]	= cfg_priority_dma_ch_0 [3:0] ;		// readType = read   writeType =write
		rdata_comb [7:4]	= cfg_priority_dma_ch_1 [3:0] ;		// readType = read   writeType =write
		rdata_comb [11:8]	= cfg_priority_dma_ch_2 [3:0] ;		// readType = read   writeType =write
		rdata_comb [31:12]	= 20'h00000 ;  // cfg_priority_dma_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	4'h8 : begin
		rdata_comb [3:0]	= cfg_priority_user_port_0 [3:0] ;		// readType = read   writeType =write
		rdata_comb [31:4]	= 28'h0000000 ;  // cfg_priority_user_reserved 	is reserved or a constant value, a read access gives the reset value
	end
	default : begin
		rdata_comb = 32'h00000000;
	end
      endcase
   end
end

endmodule
