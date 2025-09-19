//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

// Description
//-----------------------------------------------------------------------------
// This is a pass-thru module to enable exporting the AXI4-lite interface
//-----------------------------------------------------------------------------

module axi4lite_shim #(
  parameter      AW =18,
  parameter      DW =64,
  parameter      ASYNC=0
)(
  // Global signals
  input                  s_clk,
  input                  s_rst_n,
  input                  m_clk,
  input                  m_rst_n,

  // Slave WR ADDR Channel
  input      [AW-1:0]    s_awaddr,
  input      [2:0]       s_awprot,
  input                  s_awvalid,
  output                 s_awready,
  // Slave WR DATA Channel
  input      [DW-1:0]    s_wdata,
  input      [DW/8-1:0]  s_wstrb,
  input                  s_wvalid,
  output                 s_wready,
  // Slave WR RESP Channel
  output       [1:0]     s_bresp,
  output logic           s_bvalid,
  input                  s_bready,
  // Slave RD ADDR Channel
  input      [AW-1:0]    s_araddr,
  input      [2:0]       s_arprot,
  input                  s_arvalid,
  output                 s_arready,
  // Slave RD DATA Channel
  output      [DW-1:0]   s_rdata,
  output      [1:0]      s_rresp,
  output logic           s_rvalid,
  input                  s_rready,

  // Master WR ADDR Channel
  output      [AW-1:0]   m_awaddr,
  output      [2:0]      m_awprot,
  output logic           m_awvalid,
  input                  m_awready,
  // Master WR DATA Channel
  output      [DW-1:0]   m_wdata,
  output      [DW/8-1:0] m_wstrb,
  output logic           m_wvalid,
  input                  m_wready,
  // Master WR RESP Channel
  input       [1:0]      m_bresp,
  input                  m_bvalid,
  output                 m_bready,
  // Master RD ADDR Channel
  output      [AW-1:0]   m_araddr,
  output      [2:0]      m_arprot,
  output logic           m_arvalid,
  input                  m_arready,
  // Master RD DATA Channel
  input       [DW-1:0]   m_rdata,
  input       [1:0]      m_rresp,
  input                  m_rvalid,
  output                 m_rready
);

  //-------------------------------------
  // Signals mapping : NO CDC
  //-------------------------------------
  
generate if (ASYNC==0) begin : no_cdc
  // Write address channel
  assign s_awready= m_awready ;
  assign m_awvalid= s_awvalid ;
  assign m_awaddr = s_awaddr  ;
  assign m_awprot = s_awprot  ;

  // Write data channel
  assign s_wready = m_wready  ;
  assign m_wvalid = s_wvalid  ;
  assign m_wdata  = s_wdata   ;
  assign m_wstrb  = s_wstrb   ;

  // Write response channel
  assign m_bready = s_bready  ;
  assign s_bvalid = m_bvalid  ;
  assign s_bresp  = m_bresp   ;

  // Read address channel
  assign s_arready= m_arready ;
  assign m_arvalid= s_arvalid ;
  assign m_araddr = s_araddr  ;
  assign m_arprot = s_arprot  ;

  // Read response channel
  assign m_rready = s_rready  ;
  assign s_rvalid = m_rvalid  ;
  assign s_rdata  = m_rdata   ;
  assign s_rresp  = m_rresp   ;
end else begin

  //-------------------------------------
  // AWadd Signals mapping : CDC
  //-------------------------------------

  logic awfull;
  logic awempty;

  assign s_awready= ~awfull ;

  fim_rdack_dcfifo #(
    .DATA_WIDTH            (AW+3),                // Width of address & prot
    .DEPTH_LOG2            (2),                   // Depth of 4
    .READ_ACLR_SYNC        ("ON")                 // add aclr synchronizer on read side
  ) aw_fifo (
    .wclk                  ( s_clk ),
    .rclk                  ( m_clk ),
    .aclr                  ( ~s_rst_n ),
    .wdata                 ( {s_awprot,s_awaddr} ),
    .wreq                  ( s_awvalid & ~awfull ),
    .rdack                 ( m_awvalid & m_awready ),
    .rdata                 ( {m_awprot,m_awaddr} ),
    .wfull                 ( awfull ),
    .almfull               (  ),
    .rvalid                ( m_awvalid )
  );

  //-------------------------------------
  // ARadd Signals mapping : CDC
  //-------------------------------------

  logic arfull;
  logic arempty;

  assign s_arready = ~arfull  ;

  fim_rdack_dcfifo #(
    .DATA_WIDTH            (AW+3),                // Width of address & prot
    .DEPTH_LOG2            (2),                   // Depth of 4
    .READ_ACLR_SYNC        ("ON")                 // add aclr synchronizer on read side
  ) ar_fifo (
    .wclk                  ( s_clk ),
    .rclk                  ( m_clk ),
    .aclr                  ( ~s_rst_n ),
    .wdata                 ( {s_arprot,s_araddr} ),
    .wreq                  ( s_arvalid & ~arfull ),
    .rdack                 ( m_arvalid & m_arready ),
    .rdata                 ( {m_arprot,m_araddr} ),
    .wfull                 ( arfull ),
    .almfull               (  ),
    .rvalid                ( m_arvalid )
  );

  //-------------------------------------
  // Wdata Signals mapping : CDC
  //-------------------------------------

  logic wdfull;
  logic wdempty;
  assign s_wready= ~wdfull ;

  fim_rdack_dcfifo #(
    .DATA_WIDTH            (DW+DW/8),             // Width of data & strobe
    .DEPTH_LOG2            (2),                   // Depth of 4
    .READ_ACLR_SYNC        ("ON")                 // add aclr synchronizer on read side
  ) wd_fifo (
    .wclk                  ( s_clk ),
    .rclk                  ( m_clk ),
    .aclr                  ( ~s_rst_n ),
    .wdata                 ( {s_wstrb,s_wdata} ),
    .wreq                  ( s_wvalid & ~wdfull ),
    .rdack                 ( m_wvalid & m_wready ),
    .rdata                 ( {m_wstrb,m_wdata} ),
    .wfull                 ( wdfull ),
    .almfull               (  ),
    .rvalid                ( m_wvalid )
  );

  //-------------------------------------
  // WResp Signals mapping : CDC
  //-------------------------------------
  
  logic wrfull;
  logic wrempty;
  assign m_bready = ~wrfull;

  fim_rdack_dcfifo #(
    .DATA_WIDTH            (2),                   // Width of bresp
    .DEPTH_LOG2            (2),                   // Depth of 4
    .WRITE_ACLR_SYNC       ("ON")                 // add aclr synchronizer on read side
  ) wr_fifo (
    .wclk                  ( m_clk ),
    .rclk                  ( s_clk ),
    .aclr                  ( ~s_rst_n ),
    .wdata                 ( m_bresp ),
    .wreq                  ( m_bvalid & ~wrfull ),
    .rdack                 ( s_bvalid & s_bready ),
    .rdata                 ( s_bresp ),
    .wfull                 ( wrfull ),
    .almfull               (  ),
    .rvalid                ( s_bvalid )
  );

  //-------------------------------------
  // RResp Signals mapping : CDC
  //-------------------------------------
  logic rrfull;
  logic rrempty;
  assign m_rready = ~rrfull;

  fim_rdack_dcfifo #(
    .DATA_WIDTH            (DW+2),                // Width of rdata & rresp
    .DEPTH_LOG2            (2),                   // Depth of 4
    .WRITE_ACLR_SYNC       ("ON")                 // add aclr synchronizer on read side
  ) rr_fifo (
    .wclk                  ( m_clk ),
    .rclk                  ( s_clk ),
    .aclr                  ( ~s_rst_n ),
    .wdata                 ( {m_rresp,m_rdata} ),
    .wreq                  ( m_rvalid & ~rrfull ),
    .rdack                 ( s_rvalid & s_rready ),
    .rdata                 ( {s_rresp,s_rdata} ),
    .wfull                 ( rrfull ),
    .almfull               (  ),
    .rvalid                ( s_rvalid )
  );


end endgenerate
endmodule
