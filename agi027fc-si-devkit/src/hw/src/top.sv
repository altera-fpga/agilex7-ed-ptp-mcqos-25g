//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

// This is a generated system top level RTL file. 

import ofs_fim_eth_if_pkg::*;
import macsec_srd_pkg::*;
import ptp_bridge_pkg::*;
import ptp_bridge_hdr_pkg::*;
`include "custom_rtl/hssi/ofs_fim_axi_lite_if.sv"

module top #(
  parameter FP_WIDTH                        = 20
 ,parameter NUM_PORTS                       = 2
 ,parameter ETHERNET_RATE                   = 25   // supports 10/25/50/100/200/400   
 ,parameter DMA_TDATA_WIDTH                 = 64   // supports only 64b
 ,parameter HSSI_TDATA_WIDTH                = 64   // supports 64/128/256/512/1024
 ,parameter HSSI_NUM_OF_SEG                 = 1    // supports 1/2/4/8/16
 ,parameter DMA_NUM_OF_SEG                  = 1    // supports only 1
 ,parameter DMA_NUM_OF_SOP                  = 1    // supports only 1 	
 ,parameter HSSI_NUM_OF_SOP                 = 1    // supports only 1
 ,parameter TXEGR_TS_DW                     = 128
 ,parameter RXIGR_TS_DW                     = 96
 ,parameter PTP_WIDTH                       = 94
 ,parameter PTP_EXT_WIDTH                   = 328
 ,parameter PKT_CYL                         = 1
 ,parameter CLIENT_IF_TYPE                  = 1   // 0:Segmented; 1:AvST;
 ,parameter READY_LATENCY                   = 0
 ,parameter DATA_WIDTH                      = 64 
 ,parameter WORDS                           = 1 //8 NOTE: WORDS = 1, DATA WIDTH = WORDS*64 = 64
 ,parameter EMPTY_WIDTH                     = 4 //6 NOTE: EMPTY_WIDTH = $clog2(DATA_WIDTH/8)+1;
 ,parameter DMA_CHS                         = 6
 ,parameter TS_REQ_FP_WIDTH                 = 20
)
(

// Clock and Reset
input    wire                   fpga_clk_100,
input    wire                   ftile_clk_ref,
input    wire                   ftile_master_todclk_ref,
output   wire [NUM_PORTS-1:0]   ftile_tx_serial, 
output   wire [NUM_PORTS-1:0]   ftile_tx_serial_n,
input    wire [NUM_PORTS-1:0]   ftile_rx_serial,
input    wire [NUM_PORTS-1:0]   ftile_rx_serial_n,
output   wire                   master_tod_top_0_pulse_per_second,
input    wire                   ref_pps_in,
output   wire                   hssi_cdr_clk_out, 

//QSFP Sideband
input    wire                   qsfpdd_modprsn,
output   wire                   qsfpdd_resetn,
output   wire                   qsfpdd_modseln,
input    wire                   qsfpdd_intn,
output   wire                   qsfpdd_initmode, // initmode  == lpmode
inout    wire                   qsfpdd_i2c_scl,
inout    wire                   qsfpdd_i2c_sda,
inout    wire                   zl_i2c_scl,
inout    wire                   zl_i2c_sda,

input    wire                   uart1_RX,
output   wire                   uart1_TX,

////HPS
output   wire [0:0]             emif_hps_mem_mem_ck,
output   wire [0:0]             emif_hps_mem_mem_ck_n,
output   wire [16:0]            emif_hps_mem_mem_a,
output   wire [0:0]             emif_hps_mem_mem_act_n,
output   wire [1:0]             emif_hps_mem_mem_ba,
output   wire [1-1:0]           emif_hps_mem_mem_bg,
output   wire [0:0]             emif_hps_mem_mem_cke,
output   wire [0:0]             emif_hps_mem_mem_cs_n,
output   wire [0:0]             emif_hps_mem_mem_odt,
output   wire [0:0]             emif_hps_mem_mem_reset_n,
output   wire [0:0]             emif_hps_mem_mem_par,
input    wire [0:0]             emif_hps_mem_mem_alert_n,
input    wire                   emif_hps_oct_oct_rzqin,
input    wire                   emif_hps_pll_ref_clk,
inout    wire [8-1:0]           emif_hps_mem_mem_dbi_n,
inout    wire [64-1:0]          emif_hps_mem_mem_dq,
inout    wire [8-1:0]           emif_hps_mem_mem_dqs,
inout    wire [8-1:0]           emif_hps_mem_mem_dqs_n,
input    wire                   hps_jtag_tck,
input    wire                   hps_jtag_tms,
output   wire                   hps_jtag_tdo,
input    wire                   hps_jtag_tdi,
output   wire                   hps_sdmmc_CCLK, 
inout    wire                   hps_sdmmc_CMD,          
inout    wire                   hps_sdmmc_D0,          
inout    wire                   hps_sdmmc_D1,          
inout    wire                   hps_sdmmc_D2,        
inout    wire                   hps_sdmmc_D3,        
inout    wire                   hps_usb0_DATA0,         
inout    wire                   hps_usb0_DATA1,      
inout    wire                   hps_usb0_DATA2,        
inout    wire                   hps_usb0_DATA3,       
inout    wire                   hps_usb0_DATA4,        
inout    wire                   hps_usb0_DATA5,      
inout    wire                   hps_usb0_DATA6,      
inout    wire                   hps_usb0_DATA7,         
input    wire                   hps_usb0_CLK,         
output   wire                   hps_usb0_STP,       
input    wire                   hps_usb0_DIR,        
input    wire                   hps_usb0_NXT, 
output   wire                   hps_emac0_TX_CLK,      
input    wire                   hps_emac0_RX_CLK,      
output   wire                   hps_emac0_TX_CTL,
input    wire                   hps_emac0_RX_CTL,      
output   wire                   hps_emac0_TXD0,       
output   wire                   hps_emac0_TXD1,
input    wire                   hps_emac0_RXD0,     
input    wire                   hps_emac0_RXD1,                
output   wire                   hps_emac0_TXD2,        
output   wire                   hps_emac0_TXD3,
input    wire                   hps_emac0_RXD2,        
input    wire                   hps_emac0_RXD3, 
inout    wire                   hps_emac0_MDIO,         
output   wire                   hps_emac0_MDC,
input    wire                   hps_uart0_RX,       
output   wire                   hps_uart0_TX, 
inout    wire                   hps_gpio1_io0,
inout    wire                   hps_gpio1_io1,
inout    wire                   hps_gpio1_io4,
inout    wire                   hps_gpio1_io5,
inout    wire                   hps_gpio1_io6,
inout    wire                   hps_gpio1_io7,
inout    wire                   hps_gpio1_io19,
inout    wire                   hps_gpio1_io20,
inout    wire                   hps_gpio1_io21,
input    wire                   hps_ref_clk
);

// PTP Bridge IP instatiation (L2 SW)
localparam USER_DATA_WIDTH = HSSI_TDATA_WIDTH;
localparam USER_NUM_OF_SEG = HSSI_NUM_OF_SEG;
localparam STS_WIDTH = 5;
localparam STS_EXT_WIDTH = 32;
localparam TX_CLIENT_WIDTH = 2;
localparam RX_CLIENT_WIDTH = 7;
localparam PTP_BRDG_AWADDR_WIDTH = 16;
localparam PTP_BRDG_WDATA_WIDTH = 32;
localparam PTP_BRDG_HSSI_IGR_FIFO_DEPTH = 2048;
localparam PTP_BRDG_USER_IGR_FIFO_DEPTH = 512;
localparam PTP_BRDG_DMA_IGR_FIFO_DEPTH  = 512;
localparam TCAM_KEY_WIDTH = 492;
localparam TCAM_RESULT_WIDTH = 32;
localparam TCAM_ENTRIES = 32;
localparam TCAM_USERMETADATA_WIDTH = 1;
localparam IGR_DMA_BYTE_ROTATE = 0;
localparam IGR_USER_BYTE_ROTATE = 0;
localparam IGR_HSSI_BYTE_ROTATE = 1;
localparam EGR_DMA_BYTE_ROTATE = 1;
localparam EGR_USER_BYTE_ROTATE = 1;
localparam EGR_HSSI_BYTE_ROTATE = 0;
localparam DBG_CNTR_EN = 0;

logic [NUM_PORTS-1:0] tx_init_done, rx_init_done;
localparam AWADDR_WIDTH = 32;
localparam WDATA_WIDTH = 32;

logic [NUM_PORTS-1:0][AWADDR_WIDTH - 1:0]     axi_lite_tcam_awaddr_o; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_awvalid_o;
logic [NUM_PORTS-1:0]                         axi_lite_tcam_awready_i;
logic [NUM_PORTS-1:0] [WDATA_WIDTH - 1:0]     axi_lite_tcam_wdata_o; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_wvalid_o;
logic [NUM_PORTS-1:0] [(WDATA_WIDTH/8) - 1:0] axi_lite_tcam_wstrb_o; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_wready_i; 
logic [NUM_PORTS-1:0][1:0]                    axi_lite_tcam_bresp_i; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_bvalid_i; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_bready_o; 
logic [NUM_PORTS-1:0] [AWADDR_WIDTH - 1:0]    axi_lite_tcam_araddr_o; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_arvalid_o; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_arready_i; 
logic [NUM_PORTS-1:0][1:0]                    axi_lite_tcam_rresp_i;
logic [NUM_PORTS-1:0] [WDATA_WIDTH - 1:0]     axi_lite_tcam_rdata_i;
logic [NUM_PORTS-1:0]                         axi_lite_tcam_rvalid_i; 
logic [NUM_PORTS-1:0]                         axi_lite_tcam_rready_o;

logic [NUM_PORTS-1:0]                         user_axi_st_tx_tvalid_i;
logic [NUM_PORTS-1:0][USER_DATA_WIDTH-1:0]    user_axi_st_tx_tdata_i;
logic [NUM_PORTS-1:0][USER_DATA_WIDTH/8-1:0]  user_axi_st_tx_tkeep_i;
logic [NUM_PORTS-1:0]                         user_axi_st_tx_tlast_i;
logic [NUM_PORTS-1:0][PTP_WIDTH-1:0]          user_axi_st_tx_tuser_ptp_i;
logic [NUM_PORTS-1:0][PTP_EXT_WIDTH-1:0]      user_axi_st_tx_tuser_ptp_extended_i;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0] 
                                      [TX_CLIENT_WIDTH-1:0]  user_axi_st_tx_tuser_client_i;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_tx_tuser_pkt_seg_parity_i;
logic [NUM_PORTS-1:0]                         user_axi_st_rx_tvalid_o;
logic [NUM_PORTS-1:0] [USER_DATA_WIDTH-1:0]   user_axi_st_rx_tdata_o;
logic [NUM_PORTS-1:0] [USER_DATA_WIDTH/8-1:0] user_axi_st_rx_tkeep_o;
logic [NUM_PORTS-1:0]                         user_axi_st_rx_tlast_o;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]
                                       [RX_CLIENT_WIDTH-1:0] user_axi_st_rx_tuser_client_o;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0] 
									    [STS_WIDTH-1:0] user_axi_st_rx_tuser_sts_o;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]
                                        [STS_EXT_WIDTH-1:0] user_axi_st_rx_tuser_sts_extended_o;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_rx_tuser_pkt_seg_parity_o;
logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0]    user_axi_st_rx_tuser_last_segment_o;
logic  [NUM_PORTS-1:0]                        user_axi_st_rx_tready_i;

logic [NUM_PORTS-1:0]                         user_axi_st_txegrts0_tvalid_o;
logic [NUM_PORTS-1:0][TXEGR_TS_DW-1:0]        user_axi_st_txegrts0_tdata_o;
logic [NUM_PORTS-1:0]                         user_axi_st_txegrts1_tvalid_o;
logic [NUM_PORTS-1:0][TXEGR_TS_DW-1:0]        user_axi_st_txegrts1_tdata_o;

logic [NUM_PORTS-1:0]                         user_axi_st_rxigrts0_tvalid_o;
logic [NUM_PORTS-1:0][RXIGR_TS_DW-1:0]        user_axi_st_rxigrts0_tdata_o;
logic [NUM_PORTS-1:0]                         user_axi_st_rxigrts1_tvalid_o;
logic [NUM_PORTS-1:0][RXIGR_TS_DW-1:0]        user_axi_st_rxigrts1_tdata_o;
	
logic [DMA_CHS-1:0]                                    axi_st_tx_tvalid_i                ;
logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH-1:0]             axi_st_tx_tdata_i                 ;
logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH/8-1:0]           axi_st_tx_tkeep_i                 ;
logic [DMA_CHS-1:0]                                    axi_st_tx_tlast_i                 ;
logic [DMA_CHS-1:0]  [PTP_WIDTH -1:0]                  axi_st_tx_tuser_ptp_i             ;
logic [DMA_CHS-1:0]  [PTP_EXT_WIDTH -1:0]              axi_st_tx_tuser_ptp_extended_i    ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [1:0]        axi_st_tx_tuser_client_i          ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_pkt_seg_parity_i  ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_tx_tuser_last_segment_i    ;
logic [DMA_CHS-1:0]                                    axi_st_tx_tready_o                ;

logic [DMA_CHS-1:0]                                    axi_st_rx_tvalid_o                ;
logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH-1:0]             axi_st_rx_tdata_o                 ;
logic [DMA_CHS-1:0]  [DMA_TDATA_WIDTH/8-1:0]           axi_st_rx_tkeep_o                 ;
logic [DMA_CHS-1:0]                                    axi_st_rx_tlast_o                 ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [6:0]        axi_st_rx_tuser_client_o          ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [4:0]        axi_st_rx_tuser_sts_o             ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0] [31:0]       axi_st_rx_tuser_sts_extended_o    ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_rx_tuser_pkt_seg_parity_o  ;
logic [DMA_CHS-1:0]  [DMA_NUM_OF_SEG-1:0]              axi_st_rx_tuser_last_segment_o    ;
logic [DMA_CHS-1:0]                                    axi_st_rx_tready_i                ;

logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tvalid             ; 
logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tready             ; 
logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH-1:0]    hssi_ss_st_tx_tdata              ; 
logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH/8-1:0]  hssi_ss_st_tx_tkeep              ; 
logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tlast              ; 
logic [NUM_PORTS-1:0] [1:0]                     hssi_ss_st_tx_tuser_client       ; 
logic [NUM_PORTS-1:0] [PTP_WIDTH -1:0]          hssi_ss_st_tx_tuser_ptp          ; 
logic [NUM_PORTS-1:0] [PTP_EXT_WIDTH -1:0]      hssi_ss_st_tx_tuser_ptp_extended ; 
logic [NUM_PORTS-1:0]                           hssi_ss_st_tx_tuser_last_segment ; 

logic [NUM_PORTS-1:0]                           hssi_ss_st_rx_tvalid               ;
logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH-1:0]    hssi_ss_st_rx_tdata                ;
logic [NUM_PORTS-1:0] [HSSI_TDATA_WIDTH/8-1:0]  hssi_ss_st_rx_tkeep                ;
logic [NUM_PORTS-1:0]                           hssi_ss_st_rx_tlast                ;
logic [NUM_PORTS-1:0] [6:0]                     hssi_ss_st_rx_tuser_client         ;
logic [NUM_PORTS-1:0] [4:0]                     hssi_ss_st_rx_tuser_sts            ;
logic [NUM_PORTS-1:0][PTP_EXT_WIDTH -1:0]       hssi_ss_st_rx_tuser_sts_extended   ;
logic [NUM_PORTS-1:0][HSSI_NUM_OF_SEG-1:0]      hssi_ss_st_rx_tuser_pkt_seg_parity ;
logic [NUM_PORTS-1:0]                           hssi_ss_st_rx_tuser_last_segment   ;

logic [NUM_PORTS-1:0] hssi_ss_st_rx_tready, hssi_ss_st_rx_pause;
logic [NUM_PORTS-1:0] o_clk_pll;
logic [DMA_CHS-1:0]                        tx_ts_valid ;
logic [DMA_CHS-1:0] [TS_REQ_FP_WIDTH-1:0]  tx_ts_fp ;
logic [DMA_CHS-1:0] [RXIGR_TS_DW-1:0]      tx_ts_data ;

wire        port0_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port0_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        port1_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port1_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        port2_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port2_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        port3_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port3_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        port4_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port4_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        port5_tx_dma_fifo_0_out_ts_req_valid;       
wire [19:0] port5_tx_dma_fifo_0_out_ts_req_fingerprint; 
wire        dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire        dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire        dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire        dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire        dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire        dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid;
wire [95:0] dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata;  
wire [NUM_PORTS-1:0] hssi_ptp_tx_tod_tvalid;        
wire [NUM_PORTS-1:0] [95:0] hssi_ptp_tx_tod_tdata;  
wire [NUM_PORTS-1:0] hssi_ptp_rx_tod_tvalid;        
wire [NUM_PORTS-1:0] [95:0] hssi_ptp_rx_tod_tdata;  

wire        ninit_done;
wire        system_reset_n;
wire [19:0] ftile_debug_status;
reg  [6:0]  ftile_debug_status_0_reg;
reg  [6:0]  ftile_debug_status_1_reg;
wire [6:0]  status_vector_0_sync;
wire [6:0]  status_vector_1_sync;
wire        hssi_cold_boot_rstackn_sync;
wire  [(NUM_PORTS*10)-1:0]  status_vector;// {10 status bits for each port}
reg         hssi_cold_boot_reg;
wire        axi4lite_clk_clk;
wire        axi4lite_rst_reset_n;
wire        clk_ptp_sample_clk;

wire [NUM_PORTS-1:0]                   hssi_ptp_tx_egrts_tvalid ;    
wire [NUM_PORTS-1:0] [TXEGR_TS_DW-1:0] hssi_ptp_tx_egrts_tdata;      
wire [DMA_CHS-1:0]                     dma_axi_st_txegrts0_tvalid_o; 
wire [DMA_CHS-1:0]   [TXEGR_TS_DW-1:0] dma_axi_st_txegrts0_tdata_o;  
wire [NUM_PORTS-1:0]                   hssi_ptp_rx_ingrts_tvalid ;   
wire [NUM_PORTS-1:0] [RXIGR_TS_DW-1:0] hssi_ptp_rx_ingrts_tdata;     
wire [DMA_CHS-1:0]                     dma_axi_st_rxigrts0_tvalid;
wire [DMA_CHS-1:0]   [RXIGR_TS_DW-1:0] dma_axi_st_rxigrts0_tdata;

wire [NUM_PORTS-1:0] hssi_pll_rst;

logic [NUM_PORTS-1:0][USER_NUM_OF_SEG-1:0] user_axi_st_tx_tuser_last_segment_i;
logic [NUM_PORTS-1:0]                      user_axi_st_tx_tready_o;

wire [31:0]    f2h_irq1_irq;
wire qsfpdd_i2c_scl_oe;
wire qsfpdd_i2c_sda_oe;
wire zl_i2c_scl_oe;
wire zl_i2c_sda_oe;
wire [1:0]  qsfpdd_status_pio;
wire [5:0]  qsfpdd_spi_ctrl_pio;
wire [1:0]  glitch_free_cmux_sel;

// Traffic generator module instantiation

  wire  [NUM_PORTS-1:0]                         avst_tx_ready_int;
  wire  [NUM_PORTS-1:0]                         avst_tx_valid_int;
  wire  [NUM_PORTS-1:0]                         avst_tx_sop_int;
  wire  [NUM_PORTS-1:0]                         avst_tx_eop_int;
  wire  [NUM_PORTS-1:0] [EMPTY_WIDTH-1:0]       avst_tx_empty_int;
  wire  [NUM_PORTS-1:0] [WORDS*DATA_WIDTH-1:0]  avst_tx_data_int;
  wire  [NUM_PORTS-1:0]                         avst_tx_error_int;
  wire  [NUM_PORTS-1:0]                         avst_tx_skip_crc_int;
  logic [NUM_PORTS-1:0]                         avst_rx_valid_int;
  wire  [NUM_PORTS-1:0] [WORDS*DATA_WIDTH-1:0]  avst_rx_tdata_int;
  wire  [NUM_PORTS-1:0] [EMPTY_WIDTH*WORDS-1:0] avst_rx_empty_int;
  logic [NUM_PORTS-1:0]                         avst_rx_sop_int;
  logic [NUM_PORTS-1:0]                         avst_rx_eop_int;
  logic [NUM_PORTS-1:0] [3:0]                   trafficgen_system_status;

wire [NUM_PORTS-1:0] ss_app_cold_rst_ack_n, ss_app_warm_rst_ack_n, ss_app_cold_rst_ack_n_sync, ss_app_warm_rst_ack_n_sync;
reg  [NUM_PORTS-1:0] tcam_cold_rst_n, tcam_warm_rst_n;
wire [NUM_PORTS-1:0] ss_app_rst_rdy, app_ss_rst_req, app_ss_st_areset_n;


ofs_fim_hssi_ptp_tx_egrts_if      hssi_ptp_tx_egrts  [NUM_PORTS-1:0]();
ofs_fim_hssi_ptp_rx_ingrts_if     hssi_ptp_rx_ingrts [NUM_PORTS-1:0]();
ofs_fim_hssi_ptp_tx_tod_if        hssi_ptp_tx_tod    [NUM_PORTS-1:0]();
ofs_fim_hssi_ptp_rx_tod_if        hssi_ptp_rx_tod    [NUM_PORTS-1:0]();

ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32)) axi4lite_ptpb();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(26), .WDATA_WIDTH(32), .ARADDR_WIDTH(26), .RDATA_WIDTH(32)) axi4lite_hssi();
axi4lite_if #(.AWADDR_WIDTH(16), .WDATA_WIDTH(32), .ARADDR_WIDTH(16), .RDATA_WIDTH(32))  axi4lite_pktcli [NUM_PORTS-1:0]();



`ifdef SIM_MODE
   //defparam rd1.CNTR_BITS = 14;//TODO check 16bits
   assign system_reset_n = ~ninit_done;
`else
   defparam rd1.CNTR_BITS = 28;//TODO check 16bits
   alt_reset_delay rd1 ( .clk    (fpga_clk_100), .ready_in(~ninit_done),  .ready_out(system_reset_n) );
`endif

// cold boot reset logic
    eth_f_altera_std_synchronizer_nocut cold_boot_rstackn_sync_inst (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[0]),          
        .dout       (hssi_cold_boot_rstackn_sync)
    );

always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n)
    hssi_cold_boot_reg <= 1'b0;
  else if(~hssi_cold_boot_rstackn_sync)
    hssi_cold_boot_reg <= 1'b1;

for (genvar nump=0; nump < NUM_PORTS; nump++) begin : GenClkRst
   
   fim_resync #(
    .SYNC_CHAIN_LENGTH  (2),
    .WIDTH              (1),
    .INIT_VALUE         (1),
    .NO_CUT             (0)
   ) st_tx_rst_sync(
    .clk                (o_clk_pll[nump]),
    .reset              (~system_reset_n),
    .d                  (1'b0),
    .q                  (hssi_pll_rst[nump])
);
end

// cold boot reset logic
  eth_f_altera_std_synchronizer_nocut cold_boot_rstack_tcam_inst_1 (
    .clk        (axi4lite_clk_clk),
    .reset_n    (1'b1),
    .din        (ss_app_cold_rst_ack_n[0]),          // cold boot reset ackn
    .dout       (ss_app_cold_rst_ack_n_sync[0])
  );

// cold boot reset logic
  eth_f_altera_std_synchronizer_nocut cold_boot_rstack_tcam_inst_2 (
    .clk        (axi4lite_clk_clk),
    .reset_n    (1'b1),
    .din        (ss_app_cold_rst_ack_n[1]),          // cold boot reset ackn
    .dout       (ss_app_cold_rst_ack_n_sync[1])
  );

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n) 
  if(~axi4lite_rst_reset_n)
    tcam_cold_rst_n[0] <= 1'b0;
  else if(~ss_app_cold_rst_ack_n_sync[0])
    tcam_cold_rst_n[0] <= 1'b1;

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n) 
  if(~axi4lite_rst_reset_n)
    tcam_cold_rst_n[1] <= 1'b0;
  else if(~ss_app_cold_rst_ack_n_sync[1])
    tcam_cold_rst_n[1] <= 1'b1;

// warm boot reset logic
  eth_f_altera_std_synchronizer_nocut warm_boot_rstack_tcam_inst_1 (
    .clk        (axi4lite_clk_clk),	
    .reset_n    (1'b1),
    .din        (ss_app_warm_rst_ack_n[0]),          
    .dout       (ss_app_warm_rst_ack_n_sync[0])
  );

// warm boot reset logic
  eth_f_altera_std_synchronizer_nocut warm_boot_rstack_tcam_inst_2 (
    .clk        (axi4lite_clk_clk),	
    .reset_n    (1'b1),
    .din        (ss_app_warm_rst_ack_n[1]),          
    .dout       (ss_app_warm_rst_ack_n_sync[1])
  );

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n)
  if(~axi4lite_rst_reset_n)
    tcam_warm_rst_n[0] <= 1'b0;
  else if(~ss_app_warm_rst_ack_n_sync[0])
    tcam_warm_rst_n[0] <= 1'b1;

always @(posedge axi4lite_clk_clk or negedge axi4lite_rst_reset_n)
  if(~axi4lite_rst_reset_n)
    tcam_warm_rst_n[1] <= 1'b0;
  else if(~ss_app_warm_rst_ack_n_sync[1])
    tcam_warm_rst_n[1] <= 1'b1;
	
// ispp status vector
//status_vector[0] = cold_boot_rstackn;
//status_vector[1] = rx_rstackn;
//status_vector[2] = tx_rstackn;
//status_vector[3] = tx_lanes_stable;
//status_vector[4] = tx_pll_locked;
//status_vector[5] = rx_pcs_ready;
//status_vector[6] = tx_ptp_ready;
//status_vector[7] = rx_ptp_ready;
//status_vector[8] = rx_ptp_offset_data_valid;
//status_vector[9] = tx_ptp_offset_data_valid;
//assign  ftile_debug_status[6:0]   = status_vector[9:3];      // port 8 status
//assign  ftile_debug_status[16:10] = status_vector[19:13];    // port 12 status

for (genvar i=0; i < 7; i++) begin : sts_gen_3_9
// Ftile debug status logic
    eth_f_altera_std_synchronizer_nocut ftile_debug_status_3_9 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[3+i]),          // cold boot reset ackn
        .dout       (status_vector_0_sync[i])
    );
end

for (genvar j=0; j < 7; j++) begin : sts_gen_10_16
// Ftile debug status logic
    eth_f_altera_std_synchronizer_nocut ftile_debug_status_13_19 (
        .clk        (fpga_clk_100),
        .reset_n    (1'b1),
        .din        (status_vector[13+j]),          // cold boot reset ackn
        .dout       (status_vector_1_sync[j])
    );
end

always @(posedge fpga_clk_100 or negedge system_reset_n)
  if(~system_reset_n)
    begin
      ftile_debug_status_0_reg <= 7'b0;
      ftile_debug_status_1_reg <= 7'b0;
	end
  else 
    begin
      ftile_debug_status_0_reg <= status_vector_0_sync;
      ftile_debug_status_1_reg <= status_vector_1_sync;
	end


for(genvar i = 0; i < DMA_CHS; i++) begin : tx_ts_assign
    always_comb begin
       tx_ts_valid[i] = dma_axi_st_txegrts0_tvalid_o[i];
       tx_ts_fp[i]    = dma_axi_st_txegrts0_tdata_o[i][115:96];
       tx_ts_data[i]  = dma_axi_st_txegrts0_tdata_o[i][95:0];
    end
end

for(genvar i = 0; i < DMA_CHS; i++) begin : last_segment_assign
  assign axi_st_tx_tuser_last_segment_i[i][0]      = axi_st_tx_tlast_i[i];
  assign axi_st_tx_tuser_pkt_seg_parity_i[i]       = 1'b0;
end

for(genvar i = 0; i < NUM_PORTS; i++) begin : user_last_segment_assign
  assign user_axi_st_tx_tuser_last_segment_i[i][0] = user_axi_st_tx_tlast_i[i] ;
  assign user_axi_st_tx_tuser_pkt_seg_parity_i[i]  = 1'b0;
end


assign ftile_debug_status[6:0]   = ftile_debug_status_0_reg;      // port 8 status
assign ftile_debug_status[16:10] = ftile_debug_status_1_reg;    // port 12 status

assign qsfpdd_resetn            = qsfpdd_spi_ctrl_pio[0]; //1'b1;
assign qsfpdd_initmode          = qsfpdd_spi_ctrl_pio[1]; //1'b1;	//known as LPMode in QSFPDD
assign qsfpdd_modseln           = qsfpdd_spi_ctrl_pio[2]; //1'b0;
assign glitch_free_cmux_sel     = qsfpdd_spi_ctrl_pio[5:4];// 2'b01

assign qsfpdd_i2c_scl = (qsfpdd_i2c_scl_oe == 1'b1) ? 1'b0 : 1'bz;
assign qsfpdd_i2c_sda = (qsfpdd_i2c_sda_oe == 1'b1) ? 1'b0 : 1'bz;

assign zl_i2c_scl = (zl_i2c_scl_oe == 1'b1) ? 1'b0 : 1'bz;
assign zl_i2c_sda = (zl_i2c_sda_oe == 1'b1) ? 1'b0 : 1'bz;

assign qsfpdd_status_pio = {qsfpdd_intn, qsfpdd_modprsn};
assign f2h_irq1_irq    = {32'b0};

assign dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[5];
assign dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[4];
assign dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[3];
assign dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[2];
assign dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[1];
assign dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid = dma_axi_st_rxigrts0_tvalid[0];
 
assign dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[5][95:0];
assign dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[4][95:0];
assign dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[3][95:0];
assign dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[2][95:0];
assign dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[1][95:0];
assign dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata = dma_axi_st_rxigrts0_tdata[0][95:0];

assign trafficgen_system_status[0] = {status_vector_0_sync[2], status_vector_0_sync[1], status_vector_0_sync[0], system_reset_n};
assign trafficgen_system_status[1] = {status_vector_1_sync[2], status_vector_1_sync[1], status_vector_1_sync[0], system_reset_n};

//--------------------------------------------------
//the todclk_ref is used as a core refclk signal for several IOPLLs.  This results in a
// critical warning from Quartus: "Signal ftile_master_todclk_ref has been promoted to use the global 
// clock network, but is placed on a non-dedicated clock pin location. To minimize clock uncertainty, 
//Intel recommends placing all pin clocks on dedicated clock pin locations". In order to be explicit that
//the user intent is to have the signal come from core logic and prevent the warning, the lcell below is inserted
    lcell lcell_i
    (
      .in         (ftile_master_todclk_ref),
      .out        (ftile_master_todclk_ref_lcell)
    );

  qsys_top #(
      .FP_WIDTH  (FP_WIDTH)
    ) inst_qsys_top (
      .axi4lite_clk_clk            (axi4lite_clk_clk             ),            
      .axi4lite_hssi_awaddr        (axi4lite_hssi.awaddr         ),            
      .axi4lite_hssi_awprot        (axi4lite_hssi.awprot         ),            
      .axi4lite_hssi_awvalid       (axi4lite_hssi.awvalid        ),            
      .axi4lite_hssi_awready       (axi4lite_hssi.awready        ),            
      .axi4lite_hssi_wdata         (axi4lite_hssi.wdata          ),            
      .axi4lite_hssi_wstrb         (axi4lite_hssi.wstrb          ),            
      .axi4lite_hssi_wvalid        (axi4lite_hssi.wvalid         ),            
      .axi4lite_hssi_wready        (axi4lite_hssi.wready         ),            
      .axi4lite_hssi_bresp         (axi4lite_hssi.bresp          ),            
      .axi4lite_hssi_bvalid        (axi4lite_hssi.bvalid         ),            
      .axi4lite_hssi_bready        (axi4lite_hssi.bready         ),            
      .axi4lite_hssi_araddr        (axi4lite_hssi.araddr         ),            
      .axi4lite_hssi_arprot        (axi4lite_hssi.arprot         ),            
      .axi4lite_hssi_arvalid       (axi4lite_hssi.arvalid        ),            
      .axi4lite_hssi_arready       (axi4lite_hssi.arready        ),            
      .axi4lite_hssi_rdata         (axi4lite_hssi.rdata          ),            
      .axi4lite_hssi_rresp         (axi4lite_hssi.rresp          ),            
      .axi4lite_hssi_rvalid        (axi4lite_hssi.rvalid         ),            
      .axi4lite_hssi_rready        (axi4lite_hssi.rready         ),            
      .axi4lite_pktcli_0_awaddr    (axi4lite_pktcli[0].awaddr    ) ,           
      .axi4lite_pktcli_0_awprot    (axi4lite_pktcli[0].awprot    ) ,           
      .axi4lite_pktcli_0_awvalid   (axi4lite_pktcli[0].awvalid   ) ,           
      .axi4lite_pktcli_0_awready   (axi4lite_pktcli[0].awready   ) ,           
      .axi4lite_pktcli_0_wdata     (axi4lite_pktcli[0].wdata     ) ,           
      .axi4lite_pktcli_0_wstrb     (axi4lite_pktcli[0].wstrb     ) ,           
      .axi4lite_pktcli_0_wvalid    (axi4lite_pktcli[0].wvalid    ) ,           
      .axi4lite_pktcli_0_wready    (axi4lite_pktcli[0].wready    ) ,           
      .axi4lite_pktcli_0_bresp     (axi4lite_pktcli[0].bresp     ) ,           
      .axi4lite_pktcli_0_bvalid    (axi4lite_pktcli[0].bvalid    ) ,           
      .axi4lite_pktcli_0_bready    (axi4lite_pktcli[0].bready    ) ,           
      .axi4lite_pktcli_0_araddr    (axi4lite_pktcli[0].araddr    ) ,           
      .axi4lite_pktcli_0_arprot    (axi4lite_pktcli[0].arprot    ) ,           
      .axi4lite_pktcli_0_arvalid   (axi4lite_pktcli[0].arvalid   ) ,           
      .axi4lite_pktcli_0_arready   (axi4lite_pktcli[0].arready   ) ,           
      .axi4lite_pktcli_0_rdata     (axi4lite_pktcli[0].rdata     ) ,           
      .axi4lite_pktcli_0_rresp     (axi4lite_pktcli[0].rresp     ) ,           
      .axi4lite_pktcli_0_rvalid    (axi4lite_pktcli[0].rvalid    ) ,           
      .axi4lite_pktcli_0_rready    (axi4lite_pktcli[0].rready    ) ,           
      .axi4lite_pktcli_1_awaddr    (axi4lite_pktcli[1].awaddr    ) ,           
      .axi4lite_pktcli_1_awprot    (axi4lite_pktcli[1].awprot    ) ,           
      .axi4lite_pktcli_1_awvalid   (axi4lite_pktcli[1].awvalid   ) ,           
      .axi4lite_pktcli_1_awready   (axi4lite_pktcli[1].awready   ) ,           
      .axi4lite_pktcli_1_wdata     (axi4lite_pktcli[1].wdata     ) ,           
      .axi4lite_pktcli_1_wstrb     (axi4lite_pktcli[1].wstrb     ) ,           
      .axi4lite_pktcli_1_wvalid    (axi4lite_pktcli[1].wvalid    ) ,           
      .axi4lite_pktcli_1_wready    (axi4lite_pktcli[1].wready    ) ,           
      .axi4lite_pktcli_1_bresp     (axi4lite_pktcli[1].bresp     ) ,           
      .axi4lite_pktcli_1_bvalid    (axi4lite_pktcli[1].bvalid    ) ,           
      .axi4lite_pktcli_1_bready    (axi4lite_pktcli[1].bready    ) ,           
      .axi4lite_pktcli_1_araddr    (axi4lite_pktcli[1].araddr    ) ,           
      .axi4lite_pktcli_1_arprot    (axi4lite_pktcli[1].arprot    ) ,           
      .axi4lite_pktcli_1_arvalid   (axi4lite_pktcli[1].arvalid   ) ,           
      .axi4lite_pktcli_1_arready   (axi4lite_pktcli[1].arready   ) ,           
      .axi4lite_pktcli_1_rdata     (axi4lite_pktcli[1].rdata     ) ,           
      .axi4lite_pktcli_1_rresp     (axi4lite_pktcli[1].rresp     ) ,           
      .axi4lite_pktcli_1_rvalid    (axi4lite_pktcli[1].rvalid    ) ,           
      .axi4lite_pktcli_1_rready    (axi4lite_pktcli[1].rready    ) ,           
      .axi4lite_ptpb_awaddr        (axi4lite_ptpb.awaddr         ),            
      .axi4lite_ptpb_awprot        (axi4lite_ptpb.awprot         ),            
      .axi4lite_ptpb_awvalid       (axi4lite_ptpb.awvalid        ),            
      .axi4lite_ptpb_awready       (axi4lite_ptpb.awready        ),            
      .axi4lite_ptpb_wdata         (axi4lite_ptpb.wdata          ),            
      .axi4lite_ptpb_wstrb         (axi4lite_ptpb.wstrb          ),            
      .axi4lite_ptpb_wvalid        (axi4lite_ptpb.wvalid         ),            
      .axi4lite_ptpb_wready        (axi4lite_ptpb.wready         ),            
      .axi4lite_ptpb_bresp         (axi4lite_ptpb.bresp          ),            
      .axi4lite_ptpb_bvalid        (axi4lite_ptpb.bvalid         ),            
      .axi4lite_ptpb_bready        (axi4lite_ptpb.bready         ),            
      .axi4lite_ptpb_araddr        (axi4lite_ptpb.araddr         ),            
      .axi4lite_ptpb_arprot        (axi4lite_ptpb.arprot         ),            
      .axi4lite_ptpb_arvalid       (axi4lite_ptpb.arvalid        ),            
      .axi4lite_ptpb_arready       (axi4lite_ptpb.arready        ),            
      .axi4lite_ptpb_rdata         (axi4lite_ptpb.rdata          ),            
      .axi4lite_ptpb_rresp         (axi4lite_ptpb.rresp          ),            
      .axi4lite_ptpb_rvalid        (axi4lite_ptpb.rvalid         ),            
      .axi4lite_ptpb_rready        (axi4lite_ptpb.rready         ),            
      .axi4lite_rst_reset_n        (axi4lite_rst_reset_n         ),            
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_valid                      (port0_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port0_tx_dma_fifo_0_out_ts_req_fingerprint),  
      
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[0]),            
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[0]),              
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[0]),              
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[0]),             
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[0][0]),   
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[0]),            
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[0]),             
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[0]),             
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[0]),             
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[0]),      
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[0]),         
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[0]),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port0_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port0_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[0]),               
      .dma_subsys_dma_subsys_port0_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[0],tx_ts_data[0]}),  
      .dma_subsys_dma_subsys_port0_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),          
      .dma_subsys_dma_subsys_port0_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),       
      .dma_subsys_dma_subsys_port0_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port0_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port0_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port0_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_valid                      (port1_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port1_tx_dma_fifo_0_out_ts_req_fingerprint),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[1]),             
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[1]),             
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[1][0]),    
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[1]),             
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[1]),              
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[1]),       
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[1]),          
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[1]),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port1_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port1_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[1]),               
      .dma_subsys_dma_subsys_port1_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[1],tx_ts_data[1]}),  
      .dma_subsys_dma_subsys_port1_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),          
      .dma_subsys_dma_subsys_port1_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),       
      .dma_subsys_dma_subsys_port1_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port1_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port1_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port1_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_valid                      (port2_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port2_tx_dma_fifo_0_out_ts_req_fingerprint),              
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[2]),            
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[2]),             
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[2]),              
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[2]),              
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[2]),             
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[2][0]),   
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[2]),            
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[2]),             
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[2]),             
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[2]),             
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[2]),      
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[2]),         
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[2]),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port2_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port2_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[2]),               
      .dma_subsys_dma_subsys_port2_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[2],tx_ts_data[2]}),  
      .dma_subsys_dma_subsys_port2_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[0]),           
      .dma_subsys_dma_subsys_port2_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[0]),        
      .dma_subsys_dma_subsys_port2_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port2_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port2_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port2_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_valid                      (port3_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port3_tx_dma_fifo_0_out_ts_req_fingerprint),  
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[3]),            
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[3]),            
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[3][0]),   
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[3]),            
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[3]),             
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[3]),      
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[3]),         
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[3]),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port3_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port3_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[3]),              
      .dma_subsys_dma_subsys_port3_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[3],tx_ts_data[3]}), 
      .dma_subsys_dma_subsys_port3_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),                
      .dma_subsys_dma_subsys_port3_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),             
      .dma_subsys_dma_subsys_port3_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port3_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port3_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port3_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_valid                      (port4_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port4_tx_dma_fifo_0_out_ts_req_fingerprint),     
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[4]),            
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[4]),              
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[4]),              
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[4]),              
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[4]),             
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[4][0]),   
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[4]),            
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[4]),             
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[4]),             
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[4]),             
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[4]),      
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[4]),         
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[4]),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port4_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port4_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[4]),                
      .dma_subsys_dma_subsys_port4_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[4],tx_ts_data[4]}),   
      .dma_subsys_dma_subsys_port4_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),                  
      .dma_subsys_dma_subsys_port4_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),               
      .dma_subsys_dma_subsys_port4_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port4_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port4_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port4_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym        ('d0  ), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_p2p_idx('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_asym_sign   ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_cf_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_csum_offset (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_eb_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_cf      ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ins_ets     ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_p2p         ('b0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_format   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_offset   (16'd0), 
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_ts_valid    ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_tx_its      ('d0  ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_update_eb   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_ptp_zero_csum   (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_i_av_st_tx_skip_crc        (1'b0 ),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_valid                      (port5_tx_dma_fifo_0_out_ts_req_valid),              
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_avst_tx_ptp_fingerprint                (port5_tx_dma_fifo_0_out_ts_req_fingerprint),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tready                      (axi_st_tx_tready_o[5]),            
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tvalid                      (axi_st_tx_tvalid_i[5]),             
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tdata                       (axi_st_tx_tdata_i[5]),              
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tlast                       (axi_st_tx_tlast_i[5]),              
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tkeep                       (axi_st_tx_tkeep_i[5]),             
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axit_tx_if_tuser                       (axi_st_tx_tuser_client_i[5][0]),   
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tvalid                     (axi_st_rx_tvalid_o[5]),            
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tdata                      (axi_st_rx_tdata_o[5]),             
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tlast                      (axi_st_rx_tlast_o[5]),             
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tkeep                      (axi_st_rx_tkeep_o[5]),             
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_axist_rx_if_tuser                      (axi_st_rx_tuser_client_o[5]),      
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_tuser_sts_tuser_1                (axi_st_rx_tuser_sts_o[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_tx_tuser_ptp_tuser_1                (axi_st_tx_tuser_ptp_i[5]),         
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_tx_tuser_ptp_extended_tuser_2       (axi_st_tx_tuser_ptp_extended_i[5]),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid         (dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tvalid),
      .dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata          (dma_subsys_dma_subsys_port5_avst_axist_bridge_0_p0_rx_ingrts0_interface_tdata),
      .dma_subsys_dma_subsys_port5_hssi_ets_ts_adapter_0_egrs_ts_hssi_tvalid                  (tx_ts_valid[5]),               
      .dma_subsys_dma_subsys_port5_hssi_ets_ts_adapter_0_egrs_ts_hssi_tdata                   ({tx_ts_fp[5],tx_ts_data[5]}),  
      .dma_subsys_dma_subsys_port5_ts_chs_compl_0_clk_bus_in_clk_bus                          (o_clk_pll[1]),           
      .dma_subsys_dma_subsys_port5_ts_chs_compl_0_rst_bus_in_rst_bus                          (hssi_pll_rst[1]),         
      .dma_subsys_dma_subsys_port5_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_valid      (port5_tx_dma_fifo_0_out_ts_req_valid), 
      .dma_subsys_dma_subsys_port5_ftile_tx_dma_ch1_tx_dma_fifo_0_out_ts_req_fingerprint(port5_tx_dma_fifo_0_out_ts_req_fingerprint),
      
      .hps_sub_sys_agilex_hps_uart1_cts_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dcd_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dsr_n                                                     (1'b0),
      .hps_sub_sys_agilex_hps_uart1_dtr_n                                                     (),
      .hps_sub_sys_agilex_hps_uart1_out1_n                                                    (),
      .hps_sub_sys_agilex_hps_uart1_out2_n                                                    (),
      .hps_sub_sys_agilex_hps_uart1_ri_n                                                      (1'b1),
      .hps_sub_sys_agilex_hps_uart1_rts_n                                                     (),
      .hps_sub_sys_agilex_hps_uart1_rx                                                        (uart1_RX),
      .hps_sub_sys_agilex_hps_uart1_tx                                                        (uart1_TX),
      
      .qsfpdd_i2c_scl_in_clk                                                                  (qsfpdd_i2c_scl),
      .qsfpdd_i2c_clk_clk                                                                     (qsfpdd_i2c_scl_oe),
      .qsfpdd_i2c_sda_i                                                                       (qsfpdd_i2c_sda),
      .qsfpdd_i2c_sda_oe                                                                      (qsfpdd_i2c_sda_oe),
      .hps_sub_sys_agilex_hps_i2c1_scl_in_clk                                                 (zl_i2c_scl),
      .hps_sub_sys_agilex_hps_i2c1_clk_clk                                                    (zl_i2c_scl_oe),
      .hps_sub_sys_agilex_hps_i2c1_sda_i                                                      (zl_i2c_sda),
      .hps_sub_sys_agilex_hps_i2c1_sda_oe                                                     (zl_i2c_sda_oe),
      .hps_io_EMAC0_TX_CLK                                                                    (hps_emac0_TX_CLK),     
      .hps_io_EMAC0_RX_CLK                                                                    (hps_emac0_RX_CLK),     
      .hps_io_EMAC0_TX_CTL                                                                    (hps_emac0_TX_CTL),    
      .hps_io_EMAC0_RX_CTL                                                                    (hps_emac0_RX_CTL),    
      .hps_io_EMAC0_TXD0                                                                      (hps_emac0_TXD0),     
      .hps_io_EMAC0_TXD1                                                                      (hps_emac0_TXD1),
      .hps_io_EMAC0_RXD0                                                                      (hps_emac0_RXD0),       
      .hps_io_EMAC0_RXD1                                                                      (hps_emac0_RXD1),        
      .hps_io_EMAC0_TXD2                                                                      (hps_emac0_TXD2),      
      .hps_io_EMAC0_TXD3                                                                      (hps_emac0_TXD3),   
      .hps_io_EMAC0_RXD2                                                                      (hps_emac0_RXD2),        
      .hps_io_EMAC0_RXD3                                                                      (hps_emac0_RXD3),
      .hps_io_EMAC0_MDIO                                                                      (hps_emac0_MDIO),       
      .hps_io_EMAC0_MDC                                                                       (hps_emac0_MDC), 
      .hps_io_SDMMC_CCLK                                                                      (hps_sdmmc_CCLK),   
      .hps_io_SDMMC_CMD                                                                       (hps_sdmmc_CMD), 
      .hps_io_SDMMC_D0                                                                        (hps_sdmmc_D0),          
      .hps_io_SDMMC_D1                                                                        (hps_sdmmc_D1),          
      .hps_io_SDMMC_D2                                                                        (hps_sdmmc_D2),         
      .hps_io_SDMMC_D3                                                                        (hps_sdmmc_D3),        
      .hps_io_USB0_CLK                                                                        (hps_usb0_CLK), 
      .hps_io_USB0_STP                                                                        (hps_usb0_STP), 
      .hps_io_USB0_DIR                                                                        (hps_usb0_DIR),
      .hps_io_USB0_NXT                                                                        (hps_usb0_NXT),
      .hps_io_USB0_DATA0                                                                      (hps_usb0_DATA0),
      .hps_io_USB0_DATA1                                                                      (hps_usb0_DATA1), 
      .hps_io_USB0_DATA2                                                                      (hps_usb0_DATA2), 
      .hps_io_USB0_DATA3                                                                      (hps_usb0_DATA3), 
      .hps_io_USB0_DATA4                                                                      (hps_usb0_DATA4), 
      .hps_io_USB0_DATA5                                                                      (hps_usb0_DATA5),
      .hps_io_USB0_DATA6                                                                      (hps_usb0_DATA6), 
      .hps_io_USB0_DATA7                                                                      (hps_usb0_DATA7),
      
      .hps_io_UART0_RX                                                                        (hps_uart0_RX),          
      .hps_io_UART0_TX                                                                        (hps_uart0_TX), 
      .hps_io_jtag_tck                                                                        (hps_jtag_tck),                
      .hps_io_jtag_tms                                                                        (hps_jtag_tms),                
      .hps_io_jtag_tdo                                                                        (hps_jtag_tdo),                 
      .hps_io_jtag_tdi                                                                        (hps_jtag_tdi),    
      .hps_io_gpio1_io0                                                                       (hps_gpio1_io0),
      .hps_io_gpio1_io1                                                                       (hps_gpio1_io1),
      .hps_io_gpio1_io4                                                                       (hps_gpio1_io4),
      .hps_io_gpio1_io5                                                                       (hps_gpio1_io5),
      .hps_io_gpio1_io6                                                                       (hps_gpio1_io6),
      .hps_io_gpio1_io7                                                                       (hps_gpio1_io7),
      .hps_io_gpio1_io19                                                                      (hps_gpio1_io19),
      .hps_io_gpio1_io20                                                                      (hps_gpio1_io20),
      .hps_io_gpio1_io21                                                                      (hps_gpio1_io21),
      
      .emif_hps_mem_mem_ck                                                                    (emif_hps_mem_mem_ck),   
      .emif_hps_mem_mem_ck_n                                                                  (emif_hps_mem_mem_ck_n),  
      .emif_hps_mem_mem_a                                                                     (emif_hps_mem_mem_a),       
      .emif_hps_mem_mem_act_n                                                                 (emif_hps_mem_mem_act_n),   
      .emif_hps_mem_mem_ba                                                                    (emif_hps_mem_mem_ba),      
      .emif_hps_mem_mem_bg                                                                    (emif_hps_mem_mem_bg),      
      .emif_hps_mem_mem_cke                                                                   (emif_hps_mem_mem_cke),    
      .emif_hps_mem_mem_cs_n                                                                  (emif_hps_mem_mem_cs_n),    
      .emif_hps_mem_mem_odt                                                                   (emif_hps_mem_mem_odt),     
      .emif_hps_mem_mem_reset_n                                                               (emif_hps_mem_mem_reset_n),
      .emif_hps_mem_mem_par                                                                   (emif_hps_mem_mem_par),          
      .emif_hps_mem_mem_alert_n                                                               (emif_hps_mem_mem_alert_n),    
      .emif_hps_mem_mem_dqs                                                                   (emif_hps_mem_mem_dqs),       
      .emif_hps_mem_mem_dqs_n                                                                 (emif_hps_mem_mem_dqs_n),     
      .emif_hps_mem_mem_dq                                                                    (emif_hps_mem_mem_dq), 
      .emif_hps_mem_mem_dbi_n                                                                 (emif_hps_mem_mem_dbi_n), 
      .emif_hps_oct_oct_rzqin                                                                 (emif_hps_oct_oct_rzqin), 
      
      .clk_ptp_sample_clk                                                                     (clk_ptp_sample_clk), 
      .o_p0_clk_tx_div_clk                                                                    (o_p8_clk_tx_div_clk),
      .o_p0_clk_rec_div_clk                                                                   (o_p8_clk_rec_div_clk),
      .o_p1_clk_tx_div_clk                                                                    (o_p9_clk_tx_div_clk),
      .o_p1_clk_rec_div_clk                                                                   (o_p9_clk_rec_div_clk),
      .o_p0_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p1_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p2_clk_pll_clk                                                                       (o_clk_pll[0]),
      .o_p3_clk_pll_clk                                                                       (o_clk_pll[1]),
      .o_p4_clk_pll_clk                                                                       (o_clk_pll[1]),
      .o_p5_clk_pll_clk                                                                       (o_clk_pll[1]),
      .qsfpdd_status_pio_external_connection_export                                           (qsfpdd_status_pio),
      .qsfpdd_ctrl_pio_0_econ_export                                                          (qsfpdd_spi_ctrl_pio),
      .clk_100_clk                                                                            (fpga_clk_100),
      .dma_subsys_port0_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port1_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port2_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port3_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port4_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .dma_subsys_port5_rx_dma_resetn_reset_n                                                 (system_reset_n),
      .ninit_done_ninit_done                                                                  (ninit_done),
      .f2h_irq1_irq                                                                           (f2h_irq1_irq),
      .hps_io_hps_osc_clk                                                                     (hps_ref_clk),
      .agilex_hps_h2f_reset_reset                                                             (           ),
      .reset_reset_n                                                                          (system_reset_n),
      .emif_hps_pll_ref_clk_clk                                                               (emif_hps_pll_ref_clk),   
      .mtod_subsys_master_tod_top_0_i_upstr_pll_lock                                          ('b1),                            
      .qsys_top_master_todclk_0_in_clk_clk                                                    (ftile_master_todclk_ref_lcell),
      .master_tod_top_0_pulse_per_second_pps                                                  (master_tod_top_0_pulse_per_second),
      .mtod_subsys_pps_in_pulse_per_second                                                    (ref_pps_in),
      
      .tod_slave_subsys_port_0_tod_stack_tx_pll_locked_lock                                   (status_vector[4]), 
      .tod_slave_subsys_port_0_tod_stack_tx_tod_interface_tvalid                              (hssi_ptp_tx_tod_tvalid[0]),
      .tod_slave_subsys_port_0_tod_stack_tx_tod_interface_tdata                               (hssi_ptp_tx_tod_tdata[0]),
      .tod_slave_subsys_port_0_tod_stack_rx_tod_interface_tvalid                              (hssi_ptp_rx_tod_tvalid[0]),
      .tod_slave_subsys_port_0_tod_stack_rx_tod_interface_tdata                               (hssi_ptp_rx_tod_tdata[0]),   
      `ifdef FTILE_PTP_HSSI_10G                                                              
      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (1'b1),
      `else                                                                                  
      .tod_slave_subsys_port_0_tod_stack_todsync_sel_todsync_sel                              (1'b0),
      `endif
      
      .tod_slave_subsys_port_1_tod_stack_tx_pll_locked_lock                                   (status_vector[14]), 
      .tod_slave_subsys_port_1_tod_stack_tx_tod_interface_tvalid                              (hssi_ptp_tx_tod_tvalid[1]),
      .tod_slave_subsys_port_1_tod_stack_tx_tod_interface_tdata                               (hssi_ptp_tx_tod_tdata[1]),
      .tod_slave_subsys_port_1_tod_stack_rx_tod_interface_tvalid                              (hssi_ptp_rx_tod_tvalid[1]),
      .tod_slave_subsys_port_1_tod_stack_rx_tod_interface_tdata                               (hssi_ptp_rx_tod_tdata[1]), 
      `ifdef FTILE_PTP_HSSI_10G 
      .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (1'b1),
      `else                                                                                   
      .tod_slave_subsys_port_1_tod_stack_todsync_sel_todsync_sel                              (1'b0),
      `endif
      
      .ftile_debug_status_econ_export                                                         (ftile_debug_status),
      .dma_subsys_ninit_done_reset                                                            (ninit_done),
      .wd_reset_reset_n                                                                       ()
);

ptp_bridge_subsys
   #(  .HSSI_PORT  (NUM_PORTS )   
      ,.USER_PORT  (NUM_PORTS )   
      ,.DMA_CHNL   (DMA_CHS  )   
	 
      ,.DMA_DATA_WIDTH           (DMA_TDATA_WIDTH         )       
      ,.USER_DATA_WIDTH          (USER_DATA_WIDTH        )     
      ,.HSSI_DATA_WIDTH          (HSSI_TDATA_WIDTH        )     
	 
      ,.DMA_NUM_OF_SEG           (DMA_NUM_OF_SEG         )      
      ,.HSSI_NUM_OF_SEG          (HSSI_NUM_OF_SEG        )      
      ,.USER_NUM_OF_SEG          (USER_NUM_OF_SEG        )   
     
      ,.HSSI_IGR_FIFO_DEPTH      (PTP_BRDG_HSSI_IGR_FIFO_DEPTH)
      ,.USER_IGR_FIFO_DEPTH      (PTP_BRDG_USER_IGR_FIFO_DEPTH)
      ,.DMA_IGR_FIFO_DEPTH       (PTP_BRDG_DMA_IGR_FIFO_DEPTH )   
      ,.TX_CLIENT_WIDTH          (TX_CLIENT_WIDTH        )
      ,.RX_CLIENT_WIDTH          (RX_CLIENT_WIDTH        )
      ,.TXEGR_TS_DW              (TXEGR_TS_DW            )      
      ,.RXIGR_TS_DW              (RXIGR_TS_DW            )      
      ,.SYS_FINGERPRINT_WIDTH    (TS_REQ_FP_WIDTH        )
      ,.PTP_WIDTH                (PTP_WIDTH              )      
      ,.PTP_EXT_WIDTH            (PTP_EXT_WIDTH          )      
      ,.STS_WIDTH                (STS_WIDTH              )      
      ,.STS_EXT_WIDTH            (STS_EXT_WIDTH          )      
      ,.AWADDR_WIDTH             (PTP_BRDG_AWADDR_WIDTH)      
      ,.WDATA_WIDTH              (PTP_BRDG_WDATA_WIDTH )      
      ,.TCAM_KEY_WIDTH           (TCAM_KEY_WIDTH         )      
      ,.TCAM_RESULT_WIDTH        (TCAM_RESULT_WIDTH      )      
      ,.TCAM_ENTRIES             (TCAM_ENTRIES           )      
      ,.TCAM_USERMETADATA_WIDTH  (TCAM_USERMETADATA_WIDTH)      
      // default: IGR HSSI, msgDMA, and User are all little endian
      ,.IGR_DMA_BYTE_ROTATE      (IGR_DMA_BYTE_ROTATE  )    
      ,.IGR_USER_BYTE_ROTATE     (IGR_USER_BYTE_ROTATE )    
      ,.IGR_HSSI_BYTE_ROTATE     (IGR_HSSI_BYTE_ROTATE )    
      // default: EGR HSSI, msgDMA, and User are all little endian
      ,.EGR_DMA_BYTE_ROTATE      (EGR_DMA_BYTE_ROTATE )      
      ,.EGR_USER_BYTE_ROTATE     (EGR_USER_BYTE_ROTATE)      
      ,.EGR_HSSI_BYTE_ROTATE     (EGR_HSSI_BYTE_ROTATE) 
      ,.DBG_CNTR_EN              (DBG_CNTR_EN            )
   ) ptp_bridge_subsys
  (
      //AXI Streaming Interface     
      // Tx streaming clock
       .tx_clk_i      (o_clk_pll)
      ,.tx_areset_n_i	({!hssi_pll_rst[1], !hssi_pll_rst[0]}) 
    
       // Rx streaming clock & reset                 
      ,.rx_clk_i      (o_clk_pll)
      ,.rx_areset_n_i ({!hssi_pll_rst[1], !hssi_pll_rst[0]}) 
    
      // axi_lite csr clock & reset                  
      ,.axi_lite_clk_i   (axi4lite_clk_clk  )	  
      ,.axi_lite_rst_n_i (axi4lite_rst_reset_n)
    
      // init_done status
      ,.tx_init_done_o	(tx_init_done)
      ,.rx_init_done_o	(rx_init_done)
    
      //TCAM Reset Interface // ID check the connection    
      ,.app_ss_cold_rst_n     (tcam_cold_rst_n)       
      ,.app_ss_warm_rst_n     (tcam_warm_rst_n)         
      ,.app_ss_rst_req        ('0)          
      ,.ss_app_rst_rdy        ()
      ,.ss_app_cold_rst_ack_n (ss_app_cold_rst_ack_n)
      ,.ss_app_warm_rst_ack_n (ss_app_warm_rst_ack_n)
      ,.axi_lite_awaddr_i  (axi4lite_ptpb.awaddr )
      ,.axi_lite_awvalid_i (axi4lite_ptpb.awvalid)
      ,.axi_lite_awready_o (axi4lite_ptpb.awready)
      ,.axi_lite_wdata_i  (axi4lite_ptpb.wdata )
      ,.axi_lite_wvalid_i (axi4lite_ptpb.wvalid)
      ,.axi_lite_wready_o (axi4lite_ptpb.wready)
      ,.axi_lite_wstrb_i  (axi4lite_ptpb.wstrb )
      ,.axi_lite_bresp_o  (axi4lite_ptpb.bresp  )
      ,.axi_lite_bvalid_o (axi4lite_ptpb.bvalid )
      ,.axi_lite_bready_i (axi4lite_ptpb.bready )
      ,.axi_lite_araddr_i (axi4lite_ptpb.araddr )
      ,.axi_lite_arvalid_i(axi4lite_ptpb.arvalid)
      ,.axi_lite_arready_o (axi4lite_ptpb.arready)
      ,.axi_lite_rresp_o  (axi4lite_ptpb.rresp )
      ,.axi_lite_rdata_o  (axi4lite_ptpb.rdata )
      ,.axi_lite_rvalid_o (axi4lite_ptpb.rvalid)
      ,.axi_lite_rready_i (axi4lite_ptpb.rready)
    
      // TX Interface:  
      //----------------------------------------------------------------------------
      // tx ingress interface - Input from DMA
      // inputs
    
      ,.dma_axi_st_tx_tvalid_i                (axi_st_tx_tvalid_i                   )
      ,.dma_axi_st_tx_tdata_i                 (axi_st_tx_tdata_i                    )
      ,.dma_axi_st_tx_tkeep_i                 (axi_st_tx_tkeep_i                    )
      ,.dma_axi_st_tx_tlast_i                 (axi_st_tx_tlast_i                    )
      ,.dma_axi_st_tx_tuser_ptp_i             (axi_st_tx_tuser_ptp_i                )
      ,.dma_axi_st_tx_tuser_ptp_extended_i    (axi_st_tx_tuser_ptp_extended_i       )
      ,.dma_axi_st_tx_tuser_client_i          (axi_st_tx_tuser_client_i             )
      ,.dma_axi_st_tx_tuser_pkt_seg_parity_i  (axi_st_tx_tuser_pkt_seg_parity_i     )  
      ,.dma_axi_st_tx_tuser_last_segment_i    (axi_st_tx_tuser_last_segment_i       )  
    
      // output
      ,.dma_axi_st_tx_tready_o                (axi_st_tx_tready_o                   )
      //----------------------------------------------------------------------------
      // tx ingress interface - Input from USER
      ,.user_axi_st_tx_tvalid_i               (user_axi_st_tx_tvalid_i              )  
      ,.user_axi_st_tx_tdata_i                (user_axi_st_tx_tdata_i               )  
      ,.user_axi_st_tx_tkeep_i                (user_axi_st_tx_tkeep_i               )  
      ,.user_axi_st_tx_tlast_i                (user_axi_st_tx_tlast_i               )  
      ,.user_axi_st_tx_tuser_ptp_i            (user_axi_st_tx_tuser_ptp_i           )  
      ,.user_axi_st_tx_tuser_ptp_extended_i   (user_axi_st_tx_tuser_ptp_extended_i  ) 
      ,.user_axi_st_tx_tuser_client_i         (user_axi_st_tx_tuser_client_i        ) 
      ,.user_axi_st_tx_tuser_pkt_seg_parity_i (user_axi_st_tx_tuser_pkt_seg_parity_i)  
      ,.user_axi_st_tx_tuser_last_segment_i   (user_axi_st_tx_tuser_last_segment_i  )  

      ,.user_axi_st_tx_tready_o               (user_axi_st_tx_tready_o              )
   
      //----------------------------------------------------------------------------
      // tx egress interface - Outputs to HSSI
      // outputs
      ,.hssi_axi_st_tx_tvalid_o               (hssi_ss_st_tx_tvalid                 )
      ,.hssi_axi_st_tx_tdata_o                (hssi_ss_st_tx_tdata                  )
      ,.hssi_axi_st_tx_tkeep_o                (hssi_ss_st_tx_tkeep                  )
      ,.hssi_axi_st_tx_tlast_o                (hssi_ss_st_tx_tlast                  )
      ,.hssi_axi_st_tx_tuser_ptp_o            (hssi_ss_st_tx_tuser_ptp              )
      ,.hssi_axi_st_tx_tuser_ptp_extended_o   (hssi_ss_st_tx_tuser_ptp_extended     )
      ,.hssi_axi_st_tx_tuser_client_o         (hssi_ss_st_tx_tuser_client           )
      ,.hssi_axi_st_tx_tuser_pkt_seg_parity_o (                                     ) 
      ,.hssi_axi_st_tx_tuser_last_segment_o   (hssi_ss_st_tx_tuser_last_segment     )
   
      // input                                                                      
      ,.hssi_axi_st_tx_tready_i               (hssi_ss_st_tx_tready                 )
   
      // RX Interface
      //----------------------------------------------------------------------------
      // rx ingress interface -  Inputs from HSSI
      // inputs
      ,.hssi_axi_st_rx_tvalid_i               (hssi_ss_st_rx_tvalid                 )
      ,.hssi_axi_st_rx_tdata_i                (hssi_ss_st_rx_tdata                  )
      ,.hssi_axi_st_rx_tkeep_i                (hssi_ss_st_rx_tkeep                  )
      ,.hssi_axi_st_rx_tlast_i                (hssi_ss_st_rx_tlast                  )
      //Rx Packet Error Status                                                      
      ,.hssi_axi_st_rx_tuser_client_i         (hssi_ss_st_rx_tuser_client           )
      //Rx Packet Status                                                            
      ,.hssi_axi_st_rx_tuser_sts_i            (hssi_ss_st_rx_tuser_sts              )
      ,.hssi_axi_st_rx_tuser_sts_extended_i   (hssi_ss_st_rx_tuser_sts_extended     ) 
      ,.hssi_axi_st_rx_tuser_pkt_seg_parity_i (hssi_ss_st_rx_tuser_pkt_seg_parity   ) 
      ,.hssi_axi_st_rx_tuser_last_segment_i   (hssi_ss_st_rx_tuser_last_segment     )
   
      // outputs                                                                    
      ,.hssi_axi_st_rx_tready_o               (                                     )  
      ,.hssi_axi_st_rx_pause_o                (hssi_ss_st_rx_pause                  )
   
      //----------------------------------------------------------------------------
      // rx egress interface - Output to DMA
      // outputs
   
      ,.dma_axi_st_rx_tvalid_o                (axi_st_rx_tvalid_o                  )
      ,.dma_axi_st_rx_tdata_o                 (axi_st_rx_tdata_o                   )
      ,.dma_axi_st_rx_tkeep_o                 (axi_st_rx_tkeep_o                   )
      ,.dma_axi_st_rx_tlast_o                 (axi_st_rx_tlast_o                   )
      //Rx Packet Error Status                                                    
      ,.dma_axi_st_rx_tuser_client_o          (axi_st_rx_tuser_client_o            )
      //Rx Packet Status                                                          
      ,.dma_axi_st_rx_tuser_sts_o             (axi_st_rx_tuser_sts_o               )
      ,.dma_axi_st_rx_tuser_sts_extended_o    (                                    )
      ,.dma_axi_st_rx_tuser_pkt_seg_parity_o  (                                    )
      ,.dma_axi_st_rx_tuser_last_segment_o    (                                    )
   
      // input
      ,.dma_axi_st_rx_tready_i                (6'h3F                               ) 
   
      // rx egress interface - Output to USER
      ,.user_axi_st_rx_tvalid_o               (user_axi_st_rx_tvalid_o             )   
      ,.user_axi_st_rx_tdata_o                (user_axi_st_rx_tdata_o              )  
      ,.user_axi_st_rx_tkeep_o                (user_axi_st_rx_tkeep_o              )   
      ,.user_axi_st_rx_tlast_o                (user_axi_st_rx_tlast_o              )   
      //Rx Packet Error Status                                                     
      ,.user_axi_st_rx_tuser_client_o         (user_axi_st_rx_tuser_client_o       )  
      //Rx Packet Status                                                           
      ,.user_axi_st_rx_tuser_sts_o            (                                    ) 
      ,.user_axi_st_rx_tuser_sts_extended_o   (                                    ) 
      ,.user_axi_st_rx_tuser_pkt_seg_parity_o (                                    ) 
      ,.user_axi_st_rx_tuser_last_segment_o   (                                    ) 
   
      ,.user_axi_st_rx_tready_i               (user_axi_st_rx_tready_i             )  
   
      
      // Time Stamp Interface:
      //---------------------------------------------------------------------------
      // tx egress timestamp from HSSI
      //inputs
      ,.hssi_axi_st_txegrts0_tvalid_i         (hssi_ptp_tx_egrts_tvalid            )
      ,.hssi_axi_st_txegrts0_tdata_i          (hssi_ptp_tx_egrts_tdata             )
      ,.hssi_axi_st_txegrts1_tvalid_i         ('0)
      ,.hssi_axi_st_txegrts1_tdata_i          ('0)
      
      // tx egress timestamp to DMA                                        
      ,.dma_axi_st_txegrts0_tvalid_o          (dma_axi_st_txegrts0_tvalid_o        )
      ,.dma_axi_st_txegrts0_tdata_o           (dma_axi_st_txegrts0_tdata_o         )
      ,.dma_axi_st_txegrts1_tvalid_o          (                                    )
      ,.dma_axi_st_txegrts1_tdata_o           (                                    )
      
      // tx egress timestamp to USER                               
      ,.user_axi_st_txegrts0_tvalid_o         (                                    )
      ,.user_axi_st_txegrts0_tdata_o          (                                    )
      ,.user_axi_st_txegrts1_tvalid_o         (                                    )
      ,.user_axi_st_txegrts1_tdata_o          (                                    )
      
      // rx ingress timestamp from HSSI
      // inputs
      ,.hssi_axi_st_rxigrts0_tvalid_i        (hssi_ptp_rx_ingrts_tvalid            )
      ,.hssi_axi_st_rxigrts0_tdata_i         (hssi_ptp_rx_ingrts_tdata             )
      ,.hssi_axi_st_rxigrts1_tvalid_i        ('0)
      ,.hssi_axi_st_rxigrts1_tdata_i         ('0)
      
      // rx ingress timestamp to DMA  
      // outputs                              
      ,.dma_axi_st_rxigrts0_tvalid_o         (dma_axi_st_rxigrts0_tvalid           )
      ,.dma_axi_st_rxigrts0_tdata_o          (dma_axi_st_rxigrts0_tdata            )
      ,.dma_axi_st_rxigrts1_tvalid_o         (                                     )
      ,.dma_axi_st_rxigrts1_tdata_o          (                                     )
      
      // rx ingress timestamp to USER                               
      ,.user_axi_st_rxigrts0_tvalid_o        (                                     )
      ,.user_axi_st_rxigrts0_tdata_o         (                                     )
      ,.user_axi_st_rxigrts1_tvalid_o        (                                     )
      ,.user_axi_st_rxigrts1_tdata_o         (                                     )
   );

generate for(genvar i=0;i<NUM_PORTS;i++) begin : gen_mulit_inst

  eth_f_packet_client_top_axi_adaptor #(
      .WIDTH                                 (DATA_WIDTH),
      .WORDS                                 (WORDS),
      .EMPTY_WIDTH                           (EMPTY_WIDTH)
  ) packet_client_axi_adaptor_top_0(
      .i_arst                                (!hssi_pll_rst[i]), // active low reset
      .i_clk_tx                              (o_clk_pll[i] ),
      .i_clk_rx                              (o_clk_pll[i] ),
	  
      //from packet client tx
      .o_avst_tx_ready                       (avst_tx_ready_int            [i]),
      .i_avst_tx_valid                       (avst_tx_valid_int            [i]),
      .i_avst_tx_sop                         (avst_tx_sop_int              [i]),
      .i_avst_tx_eop                         (avst_tx_eop_int              [i]),
      .i_avst_tx_empty                       (avst_tx_empty_int            [i]),
      .i_avst_tx_data                        (avst_tx_data_int             [i]),
      .i_avst_tx_error                       (avst_tx_error_int            [i]),
      .i_avst_tx_skip_crc                    (avst_tx_skip_crc_int         [i]),
	  
      // to ptp_bridge                                                         
      .i_axis_tx_ready                       (user_axi_st_tx_tready_o      [i]),
      .o_axis_tx_valid                       (user_axi_st_tx_tvalid_i      [i]),
      .o_axis_tx_tdata                       (user_axi_st_tx_tdata_i       [i]),
      .o_axis_tx_tkeep                       (user_axi_st_tx_tkeep_i       [i]),
      .o_axis_tx_tlast                       (user_axi_st_tx_tlast_i       [i]),
      .o_axis_tx_tuser                       (user_axi_st_tx_tuser_ptp_i   [i]),
	  
      // from ptp_bridge
      .o_axis_rx_ready                       (user_axi_st_rx_tready_i      [i]),
      .i_axis_rx_valid                       (user_axi_st_rx_tvalid_o      [i]),
      .i_axis_rx_tdata                       (user_axi_st_rx_tdata_o       [i]),
      .i_axis_rx_tlast                       (user_axi_st_rx_tlast_o       [i]),
      .i_axis_rx_tkeep                       (user_axi_st_rx_tkeep_o       [i]),
      .i_axis_rx_tuser                       (user_axi_st_rx_tuser_client_o[i]),
	  
      // to packet client rx
      .i_avst_rx_ready                       (1'b1),
      .o_avst_rx_valid                       (avst_rx_valid_int            [i]),
      .o_avst_rx_tdata                       (avst_rx_tdata_int            [i]),
      .o_avst_rx_empty                       (avst_rx_empty_int            [i]),
      .o_avst_rx_sop                         (avst_rx_sop_int              [i]),
      .o_avst_rx_eop                         (avst_rx_eop_int              [i]),
      .o_tx_st_eop_sync_with_macsec_tuser_error ()
  );
  
 eth_f_packet_client_top #(
       .PKT_CYL          (PKT_CYL          ) 
      ,.CLIENT_IF_TYPE   (CLIENT_IF_TYPE   ) 
      ,.READY_LATENCY    (READY_LATENCY    ) 
      ,.DATA_WIDTH       (DATA_WIDTH       ) 
      ,.WORDS            (WORDS            ) 
      ,.EMPTY_WIDTH      (EMPTY_WIDTH      ) 
       //   parameter PKT_ROM_INIT_FILE      = "eth_f_hw_pkt_gen_rom_init.hex"
    ) i_eth_f_packet_client_top (
      .i_arst                                (hssi_pll_rst[i]) , //active high reset
      .i_clk_tx                              (o_clk_pll   [i] ),
      .i_clk_rx                              (o_clk_pll   [i] ),
      .i_clk_status                          (axi4lite_clk_clk),
      .i_clk_status_rst                      (!axi4lite_rst_reset_n),
     
       //AVST TX IF -done
      .i_tx_ready                            (avst_tx_ready_int     [i]),
      .o_tx_valid                            (avst_tx_valid_int     [i]),
      .o_tx_sop                              (avst_tx_sop_int       [i]),
      .o_tx_eop                              (avst_tx_eop_int       [i]),
      .o_tx_empty                            (avst_tx_empty_int     [i]),
      .o_tx_data                             (avst_tx_data_int      [i]),
      .o_tx_error                            (avst_tx_error_int     [i]),
      .o_tx_skip_crc                         (avst_tx_skip_crc_int  [i]),
      .i_rx_valid                            (avst_rx_valid_int     [i]),
      .i_rx_sop                              (avst_rx_sop_int       [i]),
      .i_rx_eop                              (avst_rx_eop_int       [i]),
      .i_rx_empty                            (avst_rx_empty_int     [i]),
      .i_rx_data                             (avst_rx_tdata_int     [i]),
      .i_rx_error                            (7'b0),    
      .i_rxstatus_valid                      (1'b0),
      .i_rxstatus_data                       (40'd0),
      .i_rx_preamble                         (64'b0),
      .o_tx_preamble                         (),
     
      .pktcli_csr_if_slv                     (axi4lite_pktcli       [i]),
      .o_cold_rst_csr                        (),  
      .i_sadb_config_done                    (0),
      .i_system_status                       (trafficgen_system_status[i])
);
end endgenerate

`ifdef FTILE_PTP_HSSI_25G 
  hssi_ss_25G #( 
      `ifdef SIM_MODE
      .SIM_MODE                      (1'b1),
      `else
      .SIM_MODE                      (1'b0),
      `endif
      .SET_AXI_LITE_RESPONSE_TO_ZERO (1'b1)
  ) inst_hssi_25G (

      .app_ss_lite_clk                    (axi4lite_clk_clk),                 
      .app_ss_lite_areset_n               (axi4lite_rst_reset_n),             
      .app_ss_lite_awaddr                 (axi4lite_hssi.awaddr),             
      .app_ss_lite_awprot                 (axi4lite_hssi.awprot),             
      .app_ss_lite_awvalid                (axi4lite_hssi.awvalid),            
      .ss_app_lite_awready                (axi4lite_hssi.awready),            
      .app_ss_lite_wdata                  (axi4lite_hssi.wdata),              
      .app_ss_lite_wstrb                  (axi4lite_hssi.wstrb),              
      .app_ss_lite_wvalid                 (axi4lite_hssi.wvalid),             
      .ss_app_lite_wready                 (axi4lite_hssi.wready),             
      .ss_app_lite_bresp                  (axi4lite_hssi.bresp),              
      .ss_app_lite_bvalid                 (axi4lite_hssi.bvalid),             
      .app_ss_lite_bready                 (axi4lite_hssi.bready),             
      .app_ss_lite_araddr                 (axi4lite_hssi.araddr),             
      .app_ss_lite_arprot                 (axi4lite_hssi.arprot),             
      .app_ss_lite_arvalid                (axi4lite_hssi.arvalid),            
      .ss_app_lite_arready                (axi4lite_hssi.arready),            
      .ss_app_lite_rdata                  (axi4lite_hssi.rdata),              
      .ss_app_lite_rvalid                 (axi4lite_hssi.rvalid),             
      .app_ss_lite_rready                 (axi4lite_hssi.rready),             
      .ss_app_lite_rresp                  (axi4lite_hssi.rresp),              
      .p8_app_ss_st_tx_clk                (o_clk_pll[0]),                     
      .p8_app_ss_st_tx_areset_n           (system_reset_n),                    
      .p8_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[0] ),         
      .p8_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[0] ),         
      .p8_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[0] ),          
      .p8_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[0] ),          
      .p8_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[0] ),          
      .p8_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[0]),    
      .p8_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[0]),       
      .p8_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[0]), 
      .p8_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[0]), 
      .p9_app_ss_st_tx_clk                (o_clk_pll[1]),                       
      .p9_app_ss_st_tx_areset_n           (system_reset_n),                      
      .p9_app_ss_st_tx_tvalid             (hssi_ss_st_tx_tvalid[1]),            
      .p9_ss_app_st_tx_tready             (hssi_ss_st_tx_tready[1]),            
      .p9_app_ss_st_tx_tdata              (hssi_ss_st_tx_tdata[1] ),            
      .p9_app_ss_st_tx_tkeep              (hssi_ss_st_tx_tkeep[1]),             
      .p9_app_ss_st_tx_tlast              (hssi_ss_st_tx_tlast[1] ),            
      .p9_app_ss_st_tx_tuser_client       (hssi_ss_st_tx_tuser_client[1]),      
      .p9_app_ss_st_tx_tuser_ptp          (hssi_ss_st_tx_tuser_ptp[1]),         
      .p9_app_ss_st_tx_tuser_ptp_extended (hssi_ss_st_tx_tuser_ptp_extended[1]),
      .p9_app_ss_st_tx_tuser_last_segment (hssi_ss_st_tx_tuser_last_segment[1]),
      .p8_app_ss_st_rx_clk                (o_clk_pll[0]),                       
      .p8_app_ss_st_rx_areset_n           (system_reset_n),                      
      .p8_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[0]),            
      .p8_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[0]),             
      .p8_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[0]),             
      .p8_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[0]),             
      .p8_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[0]),      
      .p8_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[0]),
      .p8_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[0]),         
      .p9_app_ss_st_rx_clk                (o_clk_pll[1]),                       
      .p9_app_ss_st_rx_areset_n           (system_reset_n),                      
      .p9_ss_app_st_rx_tvalid             (hssi_ss_st_rx_tvalid[1]),            
      .p9_ss_app_st_rx_tdata              (hssi_ss_st_rx_tdata[1]),             
      .p9_ss_app_st_rx_tkeep              (hssi_ss_st_rx_tkeep[1]),             
      .p9_ss_app_st_rx_tlast              (hssi_ss_st_rx_tlast[1]),             
      .p9_ss_app_st_rx_tuser_client       (hssi_ss_st_rx_tuser_client[1]),      
      .p9_ss_app_st_rx_tuser_last_segment (hssi_ss_st_rx_tuser_last_segment[1]),
      .p9_ss_app_st_rx_tuser_sts          (hssi_ss_st_rx_tuser_sts[1]),         
      .p8_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[0]),          
      .p8_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[0]),           
      .p9_app_ss_st_txtod_tvalid          (hssi_ptp_tx_tod_tvalid[1]),          
      .p9_app_ss_st_txtod_tdata           (hssi_ptp_tx_tod_tdata[1]),           
      .p8_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[0]),          
      .p8_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[0]),           
      .p9_app_ss_st_rxtod_tvalid          (hssi_ptp_rx_tod_tvalid[1]),          
      .p9_app_ss_st_rxtod_tdata           (hssi_ptp_rx_tod_tdata[1]),           
      .p8_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[0]),      
      .p8_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[0]),       
      .p9_ss_app_st_txegrts0_tvalid       (hssi_ptp_tx_egrts_tvalid[1]),      
      .p9_ss_app_st_txegrts0_tdata        (hssi_ptp_tx_egrts_tdata[1]),       
      .p8_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[0]),     
      .p8_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[0]),      
      .p9_ss_app_st_rxingrts0_tvalid      (hssi_ptp_rx_ingrts_tvalid[1]),     
      .p9_ss_app_st_rxingrts0_tdata       (hssi_ptp_rx_ingrts_tdata[1]),      
      .i_p8_tx_pause                      (),                     
      .i_p8_tx_pfc                        (8'd0),                 
      .o_p8_rx_pause                      (),                     
      .o_p8_rx_pfc                        (),                     
      .i_p9_tx_pause                      (),                     
      .i_p9_tx_pfc                        (8'd0),                 
      .o_p9_rx_pause                      (),                     
      .o_p9_rx_pfc                        (),                     
      .p8_tx_serial                       (ftile_tx_serial[0]),   
      .p8_tx_serial_n                     (ftile_tx_serial_n[0]), 
      .p8_rx_serial                       (ftile_rx_serial[0]),   
      .p8_rx_serial_n                     (ftile_rx_serial_n[0]), 
      .p9_tx_serial                       (ftile_tx_serial[1]),   
      .p9_tx_serial_n                     (ftile_tx_serial_n[1]), 
      .p9_rx_serial                       (ftile_rx_serial[1]),   
      .p9_rx_serial_n                     (ftile_rx_serial_n[1]), 
      .port0_led_speed                    (),                 
      .port0_led_status                   (),                 
      .port1_led_speed                    (),                 
      .port1_led_status                   (),                 
      .port2_led_speed                    (),                 
      .port2_led_status                   (),                 
      .port3_led_speed                    (),                 
      .port3_led_status                   (),                 
      .port4_led_speed                    (),                 
      .port4_led_status                   (),                 
      .port5_led_speed                    (),                 
      .port5_led_status                   (),                 
      .port6_led_speed                    (),                 
      .port6_led_status                   (),                 
      .port7_led_speed                    (),                 
      .port7_led_status                   (),                 
      .port8_led_speed                    (),                 
      .port8_led_status                   (),                 
      .port9_led_speed                    (),                 
      .port9_led_status                   (),                 
      .port10_led_speed                   (),                 
      .port10_led_status                  (),                 
      .port11_led_speed                   (),                 
      .port11_led_status                  (),                 
      .port12_led_speed                   (),                 
      .port12_led_status                  (),                 
      .port13_led_speed                   (),                 
      .port13_led_status                  (),                 
      .port14_led_speed                   (),                 
      .port14_led_status                  (),                 
      .port15_led_speed                   (),                 
      .port15_led_status                  (),                 
      .port16_led_speed                   (),                 
      .port16_led_status                  (),                 
      .port17_led_speed                   (),                 
      .port17_led_status                  (),                 
      .port18_led_speed                   (),                 
      .port18_led_status                  (),                 
      .port19_led_speed                   (),                 
      .port19_led_status                  (),                 
      .p8_tx_lanes_stable                 (status_vector[3]), 
      .p8_rx_pcs_ready                    (status_vector[5]), 
      .o_p8_tx_pll_locked                 (status_vector[4]), 
      .o_p8_rx_pcs_fully_aligned          (),                 
      .o_p8_tx_ptp_ready                  (status_vector[6]), 
      .o_p8_rx_ptp_ready                  (status_vector[7]), 
      .o_p8_rx_ptp_offset_data_valid      (status_vector[8]), 
      .o_p8_tx_ptp_offset_data_valid      (status_vector[9]), 
      .p9_tx_lanes_stable                 (status_vector[13]),
      .p9_rx_pcs_ready                    (status_vector[15]),
      .o_p9_tx_pll_locked                 (status_vector[14]),
      .o_p9_rx_pcs_fully_aligned          (),                 
      .o_p9_tx_ptp_ready                  (status_vector[16]),
      .o_p9_rx_ptp_ready                  (status_vector[17]),     
      .o_p9_rx_ptp_offset_data_valid      (status_vector[19]),     
      .o_p9_tx_ptp_offset_data_valid      (status_vector[18]),     
      .subsystem_cold_rst_n               (hssi_cold_boot_reg),    
      .subsystem_cold_rst_ack_n           (status_vector[0]),      
      .i_p8_tx_rst_n                      (system_reset_n),         
      .i_p8_rx_rst_n                      (system_reset_n),         
      .o_p8_rx_rst_ack_n                  (status_vector[1]),      
      .o_p8_tx_rst_ack_n                  (status_vector[2]),      
      .o_p8_ereset_n                      (),                      
      .i_p9_tx_rst_n                      (system_reset_n),         
      .i_p9_rx_rst_n                      (system_reset_n),         
      .o_p9_rx_rst_ack_n                  (status_vector[11]),     
      .o_p9_tx_rst_ack_n                  (status_vector[12]),     
      .o_p9_ereset_n                      (),                      
      .i_clk_ref                          (ftile_clk_ref),         
      .i_p8_clk_tx_tod                    (o_p8_clk_tx_div_clk),   
      .i_p8_clk_rx_tod                    (o_p8_clk_rec_div_clk),  
      .o_p8_clk_pll                       (o_clk_pll[0]),          
      .o_p8_clk_tx_div                    (o_p8_clk_tx_div_clk),   
      .o_p8_clk_rec_div64                 (),                      
      .o_p8_clk_rec_div                   (o_p8_clk_rec_div_clk),  
      .i_p8_clk_ptp_sample                (clk_ptp_sample_clk),    
      .i_p9_clk_tx_tod                    (o_p9_clk_tx_div_clk),   
      .i_p9_clk_rx_tod                    (o_p9_clk_rec_div_clk),  
      .o_p9_clk_pll                       (o_clk_pll[1]),          
      .o_p9_clk_tx_div                    (o_p9_clk_tx_div_clk),   
      .o_p9_clk_rec_div64                 (),                      
      .o_p9_clk_rec_div                   (o_p9_clk_rec_div_clk),  
      .i_p9_clk_ptp_sample                (clk_ptp_sample_clk),    
      .o_p8_cdr_divclk                    (hssi_cdr_clk_out)       
     );


`endif

endmodule
