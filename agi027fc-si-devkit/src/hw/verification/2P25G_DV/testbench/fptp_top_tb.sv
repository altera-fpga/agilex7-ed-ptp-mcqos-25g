//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# FPTP Tb TOP which instanties DUT.Generates clock/reset
//########################################################################

`timescale 1ps/1ps

module fptp_top_tb;

   

   // Define the top level DUT parameters
    reg  clk_ref = 0;
    reg  csr_clk = 0;
    reg  i_refclk2pll = 0;
    reg  assign_100Ghz_clk = 0;


  logic          refclk_bti;
  logic [1-1:0]  fpga_clk_100;
  logic [4-1:0]  fpga_led_pio;
  logic [4-1:0]  fpga_dipsw_pio;
  logic [4-1:0]  fpga_button_pio;
  logic           ftile_clk_ref;
  logic           ftile_master_todclk_ref;
  logic [`NUM_INST-1:0]   ftile_tx_serial;
  logic [`NUM_INST-1:0]   ftile_tx_serial_n;
  logic [`NUM_INST-1:0]   ftile_rx_serial;
  logic [`NUM_INST-1:0]   ftile_rx_serial_n;
  logic           master_tod_top_0_pulse_per_second;
  logic           qsfpdd_modprsn;
  logic           qsfpdd_resetn;
  logic           qsfpdd_modseln;
  logic           qsfpdd_intn;
  logic           qsfpdd_initmode;
  logic           ref_pps_in;
  wire            qsfpdd_i2c_scl;
  wire            qsfpdd_i2c_sda;
  logic           uart1_RX ;
  logic [0:0]    emif_hps_mem_mem_ck;
  logic [0:0]    emif_hps_mem_mem_ck_n;
  logic [16:0]   emif_hps_mem_mem_a;
  logic [0:0]    emif_hps_mem_mem_act_n;
  logic [1:0]    emif_hps_mem_mem_ba;
  logic [1-1:0]  emif_hps_mem_mem_bg;
  logic [0:0]    emif_hps_mem_mem_cke;
  logic [0:0]    emif_hps_mem_mem_cs_n;
  logic [0:0]    emif_hps_mem_mem_odt;
  logic [0:0]    emif_hps_mem_mem_reset_n;
  logic [0:0]    emif_hps_mem_mem_par;
  logic [0:0]    emif_hps_mem_mem_alert_n;
  logic          emif_hps_oct_oct_rzqin;
  logic          emif_hps_pll_ref_clk;
  wire  [8-1:0]  emif_hps_mem_mem_dbi_n;
  wire  [64-1:0] emif_hps_mem_mem_dq;
  wire  [8-1:0]  emif_hps_mem_mem_dqs;
  wire  [8-1:0]  emif_hps_mem_mem_dqs_n;
  logic          hps_jtag_tck;
  logic          hps_jtag_tms;
  logic          hps_jtag_tdo;
  logic          hps_jtag_tdi;
  logic          hps_sdmmc_CCLK; 
  wire           hps_sdmmc_CMD;          
  wire           hps_sdmmc_D0;          
  wire           hps_sdmmc_D1;          
  wire           hps_sdmmc_D2;        
  wire           hps_sdmmc_D3;        
  wire           hps_usb0_DATA0;         
  wire           hps_usb0_DATA1;      
  wire           hps_usb0_DATA2;        
  wire           hps_usb0_DATA3;       
  wire           hps_usb0_DATA4;        
  wire           hps_usb0_DATA5;      
  wire           hps_usb0_DATA6;      
  wire           hps_usb0_DATA7;        
  logic          hps_usb0_CLK;         
  logic          hps_usb0_STP;       
  logic          hps_usb0_DIR;        
  logic          hps_usb0_NXT; 
  logic          hps_emac0_TX_CLK;       
  logic          hps_emac0_RX_CLK;      
  logic          hps_emac0_TX_CTL;
  logic          hps_emac0_RX_CTL;      
  logic          hps_emac0_TXD0;       
  logic          hps_emac0_TXD1;
  logic          hps_emac0_RXD0;     
  logic          hps_emac0_RXD1;                
  logic          hps_emac0_TXD2;        
  logic          hps_emac0_TXD3;
  logic          hps_emac0_RXD2;        
  logic          hps_emac0_RXD3; 
  wire           hps_emac0_MDIO;         
  logic          hps_emac0_MDC;
  logic          hps_uart0_RX;       
  logic          hps_uart0_TX; 
  wire        hps_gpio1_io0;
  wire        hps_gpio1_io1;
  wire        hps_gpio1_io4;
  wire        hps_gpio1_io5;
  wire        hps_gpio1_io6;
  wire        hps_gpio1_io7;
  wire        hps_gpio1_io19;
  wire        hps_gpio1_io20;
  wire        hps_gpio1_io21;
  logic        hps_ref_clk;
  logic [1-1:0]   fpga_reset_n ;      
  logic tb_reset;

  wire                   agilex_hps_spim1_mosi_o ;                                
  wire                   agilex_hps_spim1_miso_i ;                               
  wire                   agilex_hps_spim1_mosi_oe;                               
  wire                   agilex_hps_spim1_ss0_n_o;                               
  wire                   agilex_hps_spim1_ss1_n_o;                               
  wire                   agilex_hps_spim1_ss2_n_o;                               
  wire                   agilex_hps_spim1_ss3_n_o;                               
  wire                   agilex_hps_spim1_sclk_out_clk;                          
                      
                        
  wire clk_tx_ip0,clk_tx_ip1 ;
  wire clk_rx_ip0, clk_rx_ip1;
  wire clk_pll_ip0,clk_pll_ip1 ;           

  logic dma_valid, dma_ready, dma_ready_1;
  reg clk_tx;
  bit run_lpbk;

top_auto_tiles top_auto_tiles ();
//------------------------------------------------------------------------------
// Interface instantiation
//------------------------------------------------------------------------------

svt_axi_if axi_if();    // Master IF
fptp_axi_reset_if       fptp_axi_reset_if();


//------------------------------------------------------------------------------
// VIP Master Interface 
//------------------------------------------------------------------------------

//assign axi_if.common_aclk = csr_clk; 
assign axi_if.master_if[0].aclk = csr_clk;
assign axi_if.master_if[0].aresetn = tb_reset;
assign axi_if.slave_if[0].aclk = `TOP.dma_subsys_dma_clk_out_bridge_0_out_clk_clk;
assign fptp_axi_reset_if.clk = csr_clk; 


assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awvalid  =  axi_if.master_if[0].awvalid;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awaddr   =  axi_if.master_if[0].awaddr;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awprot   =  axi_if.master_if[0].awprot;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awid     =  axi_if.master_if[0].awid;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awlen    =  axi_if.master_if[0].awlen;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awsize   =  axi_if.master_if[0].awsize;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awburst  =  axi_if.master_if[0].awburst;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awlock   =  axi_if.master_if[0].awlock;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awcache  =  axi_if.master_if[0].awcache;
assign  axi_if.master_if[0].awready                 =  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_awready;

assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_wvalid   =  axi_if.master_if[0].wvalid;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_wdata    =  axi_if.master_if[0].wdata; 
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_wstrb    =  axi_if.master_if[0].wstrb; 
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_wlast    =  axi_if.master_if[0].wlast; 
assign  axi_if.master_if[0].wready                  = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_wready;

assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_bready   =  axi_if.master_if[0].bready;
assign  axi_if.master_if[0].bresp               = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_bresp;
assign  axi_if.master_if[0].bvalid              = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_bvalid;
assign  axi_if.master_if[0].bid                 = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_bid;

assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arvalid  =  axi_if.master_if[0].arvalid;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_araddr   =  axi_if.master_if[0].araddr;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arprot   =  axi_if.master_if[0].arprot;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arid     =  axi_if.master_if[0].arid;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arlen    =  axi_if.master_if[0].arlen;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arsize   =  axi_if.master_if[0].arsize;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arburst  =  axi_if.master_if[0].arburst;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arlock   =  axi_if.master_if[0].arlock;
assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arcache  =  axi_if.master_if[0].arcache;
assign  axi_if.master_if[0].arready                 =  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_arready;

assign  `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rready   =  axi_if.master_if[0].rready;
assign  axi_if.master_if[0].rvalid              = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rvalid;
assign  axi_if.master_if[0].rdata               = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rdata;
assign  axi_if.master_if[0].rresp               = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rresp;
assign  axi_if.master_if[0].rid                 = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rid;
assign  axi_if.master_if[0].rlast               = `TOP.hps_sub_sys_agilex_hps_h2f_axi_master_rlast;


//------------------------------------------------------------------------------
// VIP slave Interface 
//------------------------------------------------------------------------------

assign axi_if.slave_if[0].aresetn = tb_reset; 

assign  axi_if.slave_if[0].awvalid          =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awvalid ; 
assign  axi_if.slave_if[0].awaddr           =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awaddr  ; 
assign  axi_if.slave_if[0].awprot           =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awprot  ;
assign  axi_if.slave_if[0].awid             =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awid    ; 
assign  axi_if.slave_if[0].awlen            =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awlen   ; 
assign  axi_if.slave_if[0].awsize           =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awsize  ; 
assign  axi_if.slave_if[0].awburst          =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awburst ;
assign  axi_if.slave_if[0].awlock           =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awlock  ; 
assign  axi_if.slave_if[0].awcache          =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awcache ; 
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_awready   =    axi_if.slave_if[0].awready  ;

assign  axi_if.slave_if[0].wvalid           =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_wvalid ;  
assign  axi_if.slave_if[0].wdata            =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_wdata  ; 
assign  axi_if.slave_if[0].wstrb            =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_wstrb  ;
assign  axi_if.slave_if[0].wlast            =   `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_wlast  ;
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_wready    =    axi_if.slave_if[0].wready  ; 

assign  axi_if.slave_if[0].bready           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_bready ;
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_bresp     =    axi_if.slave_if[0].bresp       ;  
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_bvalid    =    axi_if.slave_if[0].bvalid      ; 
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_bid       =    axi_if.slave_if[0].bid         ;

assign  axi_if.slave_if[0].arvalid          =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arvalid ; 
assign  axi_if.slave_if[0].araddr           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_araddr  ; 
assign  axi_if.slave_if[0].arprot           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arprot  ; 
assign  axi_if.slave_if[0].arid             =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arid    ;
assign  axi_if.slave_if[0].arlen            =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arlen   ; 
assign  axi_if.slave_if[0].arsize           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arsize  ; 
assign  axi_if.slave_if[0].arburst          =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arburst ; 
assign  axi_if.slave_if[0].arlock           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arlock  ; 
assign  axi_if.slave_if[0].arcache          =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arcache ; 
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_arready   =     axi_if.slave_if[0].arready  ;

assign  axi_if.slave_if[0].rready           =    `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rready ;
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rvalid    =     axi_if.slave_if[0].rvalid ; 
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rdata     =     axi_if.slave_if[0].rdata  ; 
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rresp     =     axi_if.slave_if[0].rresp  ;
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rid       =     axi_if.slave_if[0].rid    ;
assign  `TOP.mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_rlast     =     axi_if.slave_if[0].rlast  ; 

///////////////////////////////
    assign  axi_if.slave_if[0].awqos      ='h0;
    assign  axi_if.slave_if[0].arqos      ='h0;
    assign  axi_if.slave_if[0].arsnoop    ='h0;
    assign  axi_if.slave_if[0].arbar      ='h0;
    assign  axi_if.slave_if[0].awbar      ='h0;
    assign  axi_if.slave_if[0].awsnoop    ='h0;
    assign  axi_if.slave_if[0].awuser     ='h0;
    assign  axi_if.slave_if[0].aruser     ='h0;
    assign  axi_if.slave_if[0].ardomain   ='h3;
    assign  axi_if.slave_if[0].awdomain   ='h3;



////////////////////////////////



assign agilex_hps_spim1_miso_i = 0;
assign fptp_axi_reset_if.reset = tb_reset;

initial begin
  fpga_reset_n =  1;
  tb_reset     = 0;
  ref_pps_in = 0;
  qsfpdd_modprsn = 0;
  qsfpdd_intn = 0;
  uart1_RX = 0;
  emif_hps_mem_mem_alert_n = 0; 
  emif_hps_oct_oct_rzqin = 0;
  emif_hps_pll_ref_clk = 0;
  hps_jtag_tck = 0;
  hps_jtag_tms = 0;
  hps_jtag_tdi = 0;
  #1000ns;             
  fpga_reset_n =  0;
  #1000ns;             
  fpga_reset_n =  1;
  #2500ns; 
  wait(fptp_top_tb.u_dut.inst_qsys_top.dma_subsys.dma_subsys_port0.rx_dma_resetn==1);

   if (uvm_config_db#(bit)::get(null,"uvm_test_top.env", "run_lpbk",run_lpbk))
          `uvm_info("body", $sformatf("TB TOP: run_lpbk %d ", run_lpbk), UVM_LOW);

  `ifdef HSSI_2P25G
      wait(fptp_top_tb.u_dut.inst_hssi_25G.hssi_ss_1.p8_rx_pcs_ready==1);
      wait(fptp_top_tb.u_dut.inst_hssi_25G.hssi_ss_1.p9_rx_pcs_ready==1);
   `else 
      wait(fptp_top_tb.u_dut.inst_hssi_25G.hssi_ss_1.p8_rx_pcs_ready==1);
   `endif
      
  tb_reset     = 1;
end 

always begin
       #5ns csr_clk = ~csr_clk;
end

always begin
       #4ns clk_ref = ~clk_ref;
end   

always begin
         #3200ps i_refclk2pll = ~i_refclk2pll;
end 

always begin
       #50ps assign_100Ghz_clk = ~assign_100Ghz_clk;
end



initial begin
   force fptp_top_tb.u_dut.ninit_done = 1;
   force fptp_top_tb.u_dut.user_axi_st_tx_tuser_ptp_i = 0;
   force fptp_top_tb.u_dut.user_axi_st_tx_tuser_ptp_extended_i = 0;
   force fptp_top_tb.u_dut.user_axi_st_tx_tuser_client_i = 0;
 

   force fptp_top_tb.u_dut.system_reset_n= 1;
   #8000ns;
   force fptp_top_tb.u_dut.ninit_done = 0;
   #2000ns;
   force fptp_top_tb.u_dut.system_reset_n= 0;
   #13000ns;
   force fptp_top_tb.u_dut.system_reset_n = 1;

end

//------------------------------------------------------------------------------
// DUT Wrapper Instantiation
//------------------------------------------------------------------------------
top u_dut (
/*//////////////////////////////////////////*/
/* TODO: List down all the IP signals here. */
/*//////////////////////////////////////////*/
 .fpga_clk_100                           ( csr_clk                      ),
 .ftile_clk_ref                         (  {2{i_refclk2pll}}                 ),
 .ftile_master_todclk_ref               (  i_refclk2pll          ),
 .ftile_tx_serial                        ( ftile_tx_serial                   ),
 .ftile_tx_serial_n                      ( ftile_tx_serial_n                 ),
 .ftile_rx_serial                       (  ftile_rx_serial                  ),
 .ftile_rx_serial_n                     (  ftile_rx_serial_n                ),
 .master_tod_top_0_pulse_per_second      ( master_tod_top_0_pulse_per_second ),
 .ref_pps_in                            (  ref_pps_in                        ), // input
 .hssi_cdr_clk_out                      (  hssi_cdr_clk_out                  ), // out
 .qsfpdd_modprsn                        (  qsfpdd_modprsn                   ),
 .qsfpdd_resetn                          ( qsfpdd_resetn                     ),
 .qsfpdd_modseln                         ( qsfpdd_modseln                    ),
 .qsfpdd_intn                          (   qsfpdd_intn                     ),
 .qsfpdd_initmode                        ( qsfpdd_initmode                   ),
 .qsfpdd_i2c_scl                        (  qsfpdd_i2c_scl                   ),
 .qsfpdd_i2c_sda                        (  qsfpdd_i2c_sda                   ),
 .zl_i2c_scl                             ( zl_i2c_scl                       ),
 .zl_i2c_sda                             ( zl_i2c_sda                       ),
 .uart1_RX                               ( uart1_RX                         ),
 .uart1_TX                               ( uart1_TX                         ),
 .emif_hps_mem_mem_ck                    ( emif_hps_mem_mem_ck               ),
 .emif_hps_mem_mem_ck_n                  ( emif_hps_mem_mem_ck_n             ),
 .emif_hps_mem_mem_a                     ( emif_hps_mem_mem_a                ),
 .emif_hps_mem_mem_act_n                 ( emif_hps_mem_mem_act_n            ),
 .emif_hps_mem_mem_ba                    ( emif_hps_mem_mem_ba               ),
 .emif_hps_mem_mem_bg                  (   emif_hps_mem_mem_bg             ),
 .emif_hps_mem_mem_cke                   ( emif_hps_mem_mem_cke              ),
 .emif_hps_mem_mem_cs_n                  ( emif_hps_mem_mem_cs_n             ),
 .emif_hps_mem_mem_odt                   ( emif_hps_mem_mem_odt              ),
 .emif_hps_mem_mem_reset_n               ( emif_hps_mem_mem_reset_n          ),
 .emif_hps_mem_mem_par                   ( emif_hps_mem_mem_par              ),
 .emif_hps_mem_mem_alert_n               ( emif_hps_mem_mem_alert_n          ),
 .emif_hps_oct_oct_rzqin                 ( emif_hps_oct_oct_rzqin            ),
 .emif_hps_pll_ref_clk                   ( emif_hps_pll_ref_clk              ),
 .emif_hps_mem_mem_dbi_n                 ( emif_hps_mem_mem_dbi_n            ),
 .emif_hps_mem_mem_dq                   (  emif_hps_mem_mem_dq              ),
 .emif_hps_mem_mem_dqs                   ( emif_hps_mem_mem_dqs              ),
 .emif_hps_mem_mem_dqs_n                 ( emif_hps_mem_mem_dqs_n            ),
 .hps_jtag_tck                         (   hps_jtag_tck                    ),
 .hps_jtag_tms                         (   hps_jtag_tms                    ),
 .hps_jtag_tdo                           ( hps_jtag_tdo                      ),
 .hps_jtag_tdi                         (   hps_jtag_tdi                    ),
 .hps_sdmmc_CCLK                         ( hps_sdmmc_CCLK                    ),
 .hps_sdmmc_CMD                          ( hps_sdmmc_CMD                     ),
 .hps_sdmmc_D0                           ( hps_sdmmc_D0                      ),
 .hps_sdmmc_D1                           ( hps_sdmmc_D1                      ),
 .hps_sdmmc_D2                           ( hps_sdmmc_D2                      ),
 .hps_sdmmc_D3                           ( hps_sdmmc_D3                      ),
 .hps_usb0_DATA0                         ( hps_usb0_DATA0                    ),
 .hps_usb0_DATA1                         ( hps_usb0_DATA1                    ),
 .hps_usb0_DATA2                         ( hps_usb0_DATA2                    ),
 .hps_usb0_DATA3                         ( hps_usb0_DATA3                    ),
 .hps_usb0_DATA4                         ( hps_usb0_DATA4                    ),
 .hps_usb0_DATA5                         ( hps_usb0_DATA5                    ),
 .hps_usb0_DATA6                         ( hps_usb0_DATA6                    ),
 .hps_usb0_DATA7                         ( hps_usb0_DATA7                    ),
 .hps_usb0_CLK                           ( 'b0                      ),
 .hps_usb0_STP                           ( hps_usb0_STP                      ),
 .hps_usb0_DIR                         (   'b0),
 .hps_usb0_NXT                         (   'b0                    ),
 .hps_emac0_TX_CLK                       ( hps_emac0_TX_CLK                  ),
 .hps_emac0_RX_CLK                     (   'b0),
 .hps_emac0_TX_CTL                       ( hps_emac0_TX_CTL                  ),
 .hps_emac0_RX_CTL                     (   'b0),
 .hps_emac0_TXD0                         ( hps_emac0_TXD0                    ),
 .hps_emac0_TXD1                         ( hps_emac0_TXD1                    ),
 .hps_emac0_RXD0                       (   'b0),
 .hps_emac0_RXD1                       (   'b0),
 .hps_emac0_TXD2                         ( hps_emac0_TXD2                    ),
 .hps_emac0_TXD3                         ( hps_emac0_TXD3                    ),
 .hps_emac0_RXD2                       (   'b0),
 .hps_emac0_RXD3                       (   'b0),
 .hps_emac0_MDIO                        (  hps_emac0_MDIO                   ),
 .hps_emac0_MDC                          ( hps_emac0_MDC                     ),
 .hps_uart0_RX                         (   'b0),
 .hps_uart0_TX                           ( hps_uart0_TX                      ),
 .hps_gpio1_io0                         (  hps_gpio1_io0                    ),
 .hps_gpio1_io1                         (  hps_gpio1_io1                    ),
 .hps_gpio1_io4                         (  hps_gpio1_io4                    ),
 .hps_gpio1_io5                         (  hps_gpio1_io5                    ),
 .hps_gpio1_io6                         (  hps_gpio1_io6                    ),
 .hps_gpio1_io7                         (  hps_gpio1_io7                    ),
 .hps_gpio1_io19                        (  hps_gpio1_io19                   ),
 .hps_gpio1_io20                        (  hps_gpio1_io20                   ),
 .hps_gpio1_io21                        (  hps_gpio1_io21                   ),
 .hps_ref_clk                          (   'b0                              ));


    assign interrupt = 1'b0;
    assign ftile_rx_serial[0] = run_lpbk ? ftile_tx_serial[1]:ftile_tx_serial[0]; 
    assign ftile_rx_serial_n[0] = run_lpbk ? ftile_tx_serial_n[1]:ftile_tx_serial_n[0]; 
    assign ftile_rx_serial[1] = run_lpbk ? ftile_tx_serial[0]:ftile_tx_serial[1]; 
    assign ftile_rx_serial_n[1] = run_lpbk ? ftile_tx_serial_n[0]:ftile_tx_serial_n[1]; 


  initial 
  begin
    uvm_config_db#(virtual fptp_axi_reset_if.axi_reset_modport)::set(uvm_root::get(), "uvm_test_top.env.rst_sequencer", "reset_mp", fptp_axi_reset_if.axi_reset_modport);
    uvm_config_db#(svt_axi_vif)::set(uvm_root::get(), "uvm_test_top.env.axi_system_env", "vif", axi_if);
    run_test();
  end 

initial begin
  `ifdef VCS_DUMP
    $vcdplusfile("dump.vpd");
    $vcdpluson(0,fptp_top_tb);
  `endif
end


endmodule 
