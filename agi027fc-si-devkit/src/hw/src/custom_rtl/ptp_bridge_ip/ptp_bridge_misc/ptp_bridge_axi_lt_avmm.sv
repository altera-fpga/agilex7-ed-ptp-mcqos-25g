//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


//////////////////////////////////////////////////////////////////////////////////////////////
// Description:
// AXI-Lite to AVMM converter using 2 clk domains
// 
// Tables below shows the Region that each module or reserved space is mapped to:
//
// No debug counter enabled (default):
//
// Region   Instance                                 Start   End
// -------------------------------------=============-------------
// tx_0		Ingress Arbiter 0	                     0x0	 0x8
// tx_1		Ingress Arbiter 1	                     0xC	 0x14
// rx_0		Reserved	                             0x18	 0x5C
// rx_0		Egress RX Demux 0	                     0x60	 0x70
// rx_0		Reserved	                             0x74	 0x84
// rx_1		Egress RX Demux 1	                     0x88	 0x98
// rx_1		Reserved 	                             0x9C	 0x19C
// rx_0		Ingress RX Width Adapter 0	             0x1A0	 0x1A8
// rx_1		Ingress RX Width Adapter 1	             0x1AC	 0x1B4
// rx_1		Reserved	                             0x1B8	 0x1FC
// rx_0		TCAM_0 (16KB)	                         0x200	 0x41FC
// rx_1		TCAM_1 (16KB)	                         0x4200	 0x81FC
// rx_0		Egress RX Width Adapter 0 (User port)    0x8200  0x8208      
// rx_1		Egress RX Width Adapter 1 (User port)    0x820C  0x8214               
// rx_1		Reserved	                             0x8218	 0xFFFF
//
// Debug counter enabled:
//
// Region   Instance                                 Start   End
// -------------------------------------=============-------------
// tx_0		Ingress Arbiter 0	                     0x0	 0x8
// tx_1		Ingress Arbiter 1	                     0xC	 0x14
// rx_0		Reserved	                             0x18	 0x5C
// rx_0		Egress RX Demux 0	                     0x60	 0x70
// rx_0		Reserved	                             0x74	 0x84
// rx_1		Egress RX Demux 1	                     0x88	 0x98
// rx_1		Reserved 	                             0x9C	 0x19C
// rx_0		Ingress RX Width Adapter 0	             0x1A0	 0x1A8
// rx_1		Ingress RX Width Adapter 1	             0x1AC	 0x1B4
// rx_1		Reserved	                             0x1B8	 0x1FC
// rx_0		TCAM_0 (16KB)	                         0x200	 0x41FC
// rx_1		TCAM_1 (16KB)	                         0x4200	 0x81FC
// rx_0		Egress RX Width Adapter 0 (User port)    0x8200  0x8208      
// rx_1		Egress RX Width Adapter 1 (User port)    0x820C  0x8214   
// Debug counters:
// tx_0   tx_dbg_cntrs 0                         0x8218  0x8234
// tx_1   tx_dbg_cntrs 1                         0x8238  0x8254
// rx_0   rx_dbg_cntrs 0                         0x8258  0x8294
// rx_1   rx_dbg_cntrs 1                         0x8298  0x82D4
// rx_1		Reserved	                             0x82D8  0xFFFF
//
//////////////////////////////////////////////////////////////////////////////////////////////

module ptp_bridge_axi_lt_avmm
   #( parameter DEVICE_FAMILY    = "Agilex 7"
     ,parameter ADDR_WIDTH       = 8
     ,parameter DATA_WIDTH       = 32
     ,parameter AVMM_MAX_LATENCY = 5 // cycles of when avmm_write updates targeted register
     ,parameter HSSI_PORT        = 2 
     ,parameter DBG_CNTR_EN      = 0
     ,parameter INST_ID          = 0
     ,parameter TCAM_START_ADDR  = 'h200
     ,parameter TCAM_END_ADDR    = 'h41FC
   ) 

  (
    //---------------------------------------------------------------------------------------
    // Clocks
    input var logic                        axi_lite_clk
   ,input var logic                        tx_clk
   ,input var logic                        rx_clk
    //---------------------------------------------------------------------------------------

    //---------------------------------------------------------------------------------------
    // Resets 
    ,input var logic                       axi_lt_rst
    ,input var logic                       tx_rst
    ,input var logic                       rx_rst
    //---------------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------------
    // AXI-Lite interface

    // Write Address Channel
    ,input var logic [ADDR_WIDTH-1:0]      awaddr                        
    ,input var logic                       awvalid                       
    ,output var logic                      awready                       
										   
    // Write Data Channel                  
    ,input var logic [DATA_WIDTH-1:0]      wdata                         
    ,input var logic                       wvalid
    ,input var logic [(DATA_WIDTH/8)-1:0]  wstrb	
    ,output var logic                      wready                        

    // Write Response Channel
    ,output var logic [1:0]                bresp                         
    ,output var logic                      bvalid                        
    ,input var logic                       bready 

    // Read Address Channel
    ,input var logic [ADDR_WIDTH-1:0]      araddr
    ,input var logic                       arvalid
    ,output var logic                      arready

    // Read Data Channel
    ,output var logic [1:0]                rresp
    ,output var logic [DATA_WIDTH-1:0]     rdata
    ,output var logic                      rvalid
    ,input var logic                       rready

    //-----------------------------------------------------------------------------------------
    // TCAM csr interface: 

    //-----WRITE ADDRESS CHANNEL-------
    ,output var logic [ADDR_WIDTH - 1:0]     axi_lite_tcam_awaddr_o 
    ,output var logic                        axi_lite_tcam_awvalid_o
															  
    ,input var logic                         axi_lite_tcam_awready_i
											
     //-----WRITE DATA CHANNEL----------                           
    ,output var logic  [DATA_WIDTH - 1:0]     axi_lite_tcam_wdata_o 
    ,output var logic                         axi_lite_tcam_wvalid_o
    ,output var logic  [(DATA_WIDTH/8) - 1:0] axi_lite_tcam_wstrb_o
							     			                 
    ,input var logic                          axi_lite_tcam_wready_i
								     		                
     //-----WRITE RESPONSE CHANNEL------                           
    ,input var logic [1:0]                    axi_lite_tcam_bresp_i 
    ,input var logic                          axi_lite_tcam_bvalid_i
									     		
    ,output var logic                         axi_lite_tcam_bready_o 
									     		      
     //-----READ ADDRESS CHANNEL-------                            
    ,output var logic  [ADDR_WIDTH - 1:0]    axi_lite_tcam_araddr_o 
    ,output var logic                        axi_lite_tcam_arvalid_o
									      		    
    ,input var logic                         axi_lite_tcam_arready_i 
									      	
     //-----READ DATA CHANNEL----------                        
    ,input var logic [1:0]                   axi_lite_tcam_rresp_i
     
    ,input var logic  [DATA_WIDTH - 1:0]     axi_lite_tcam_rdata_i
    ,input var logic                         axi_lite_tcam_rvalid_i   
											
    ,output var logic                        axi_lite_tcam_rready_o  
    //-----------------------------------------------------------------------------------------
    // AVMM interface

    ,output var logic [ADDR_WIDTH-1:0]     tx_avmm_address
    ,output var logic                      tx_avmm_read
    ,input  var logic [DATA_WIDTH-1:0]     tx_avmm_readdata 
    ,output var logic                      tx_avmm_write
    ,output var logic [DATA_WIDTH-1:0]     tx_avmm_writedata
    ,output var logic [(DATA_WIDTH/8)-1:0] tx_avmm_byteenable
    ,input  var logic                      tx_avmm_readdata_valid
									       
    ,output var logic [ADDR_WIDTH-1:0]     rx_avmm_address
    ,output var logic                      rx_avmm_read
    ,input  var logic [DATA_WIDTH-1:0]     rx_avmm_readdata 
    ,output var logic                      rx_avmm_write
    ,output var logic [DATA_WIDTH-1:0]     rx_avmm_writedata
    ,output var logic [(DATA_WIDTH/8)-1:0] rx_avmm_byteenable
    ,input  var logic                      rx_avmm_readdata_valid

   );

   import ptp_bridge_pkg::*;

   logic [1:0][DATA_WIDTH-1:0] avmm_readdata_bp;

   logic [1:0] avmm_write_waitreq, avmm_access_rsvd_posedge,
     avmm_write_dly, avmm_access_rsvd, avmm_access_rsvd_c1;

   logic awaddr_fifo_wr, awaddr_fifo_rd, awaddr_fifo_empty,
     awaddr_fifo_overflow, awaddr_fifo_underflow, 
     wdata_fifo_wr, wdata_fifo_rd, wdata_fifo_empty,
     wdata_fifo_overflow, wdata_fifo_underflow;

   logic [1:0] awaddr_fifo_occ, wdata_fifo_occ;
   
   logic [ADDR_WIDTH-1:0]      tx_awaddr, rx_awaddr;                   
   logic                       tx_awvalid, rx_awvalid;                              
            
   logic [DATA_WIDTH-1:0]      tx_wdata, rx_wdata, tx_rdata,
                               rx_rdata, wdata_dout;                    
   logic                       tx_wvalid, rx_wvalid, tx_rvalid,
                               rx_rvalid;
   logic [(DATA_WIDTH/8)-1:0]  tx_wstrb, rx_wstrb, wstrb_dout;       

   logic [ADDR_WIDTH-1:0]      tx_araddr, rx_araddr;
   logic                       tx_arvalid, rx_arvalid;
 
   logic [1:0]                 tx_rresp, rx_rresp;

   logic [1:0]                 tx_bresp, rx_bresp;
   
   logic [DATA_WIDTH-1:0]      rx_avmm_readdata_bp;

   logic [ADDR_WIDTH-1:0]      awaddr_dout;
                         
   logic tx_bvalid, rx_bvalid, tx_arready,
     rx_arready, tx_awready, rx_awready,
     tx_wready, rx_wready, tx_pending,
     rx_pending, tx_avmm_write_waitreq, tx_avmm_write_dly,
     rx_avmm_access_rsvd, rx_avmm_access_rsvd_c1, rx_avmm_write_waitreq,
     rx_avmm_write_dly, rx_avmm_access_rsvd_posedge, rx_avmm_read_c1,
     rx_avmm_write_c1, tcam_wr_rsp_state;

   logic tcam_wr_rsp_pending, tcam_rd_rsp_pending, tcam_rd_rsp_state;

    // -------------------------------------------------------------------
    // write request fifos used in case data comes before address

    always_ff @ (posedge axi_lite_clk) begin
      awready <= awaddr_fifo_occ <= 'd2;
      wready <= wdata_fifo_occ <= 'd2;
    end

    always_comb begin
      awaddr_fifo_wr = awvalid & awready;
      wdata_fifo_wr = wvalid & wready;

      arready = tx_arready & rx_arready & axi_lite_tcam_arready_i;
    end

    ptp_bridge_ipbb_sdc_fifo_inff 
      #( .DWD (ADDR_WIDTH)
        ,.NUM_WORDS (4) ) awaddr_fifo
      (//---------------------------------------------------------------
       // clk/rst
       .clk1 (axi_lite_clk)
       ,.clk2 (axi_lite_clk)
       ,.rst (axi_lt_rst)
    
       // inputs
       ,.din (awaddr)
       ,.wrreq (awaddr_fifo_wr)
       ,.rdreq (awaddr_fifo_rd)
    
       // outputs
       ,.dout (awaddr_dout) 
       ,.rdempty (awaddr_fifo_empty)
       ,.rdempty_lkahd () 
       ,.wrfull ()
       ,.wrusedw (awaddr_fifo_occ)
       ,.overflow (awaddr_fifo_overflow)
       ,.underflow (awaddr_fifo_underflow)
       );

    ptp_bridge_ipbb_sdc_fifo_inff 
      #( .DWD ((DATA_WIDTH/8)
               +DATA_WIDTH)
        ,.NUM_WORDS (4) ) wdata_fifo
      (//---------------------------------------------------------------
       // clk/rst
       .clk1 (axi_lite_clk)
       ,.clk2 (axi_lite_clk)
       ,.rst (axi_lt_rst)
    
       // inputs
       ,.din ({ wstrb
               ,wdata})
       ,.wrreq (wdata_fifo_wr)
       ,.rdreq (wdata_fifo_rd)
    
       // outputs
       ,.dout ({ wstrb_dout
                ,wdata_dout}) 
       ,.rdempty (wdata_fifo_empty)
       ,.rdempty_lkahd () 
       ,.wrfull ()
       ,.wrusedw (wdata_fifo_occ)
       ,.overflow (wdata_fifo_overflow)
       ,.underflow (wdata_fifo_underflow)
       );

    // -------------------------------------------------------------------
    // determine which region is the register access targeting
  
    generate
      if (DBG_CNTR_EN) begin
        if (INST_ID == 0) begin
        // -------------------------------------------------------
        // debug counter enabled for INST_ID == 0

          // tx pipeline (excluding TCAM)
          always_ff @ (posedge axi_lite_clk) begin
            // write request
            if (!awaddr_fifo_empty 
                & !wdata_fifo_empty 
                & tx_awready
                & tx_wready 
                & (awaddr_dout <= 'h8 // igr_arb_region
                   || (awaddr_dout >= 'h8218 && awaddr_dout <= 'h8234)
                  ) // tx_dbg_region
                & !tx_pending) begin
              tx_awvalid <= '1;
              tx_pending <= '1;
            end else if (awaddr_fifo_empty 
                        & wdata_fifo_empty) begin
              tx_awvalid <= '0;
              tx_pending <= '0;
            // end else if (tx_pending) begin
              // tx_awvalid <= '0;
            end
		  
            // read request
            if (arvalid 
                & tx_arready 
                & (araddr <= 'h8 // igr_arb_region
                   || (araddr >= 'h8218 && araddr <= 'h8234)
                  ) // tx_dbg_region
                ) begin
              tx_arvalid <= arvalid;
              tx_araddr <= araddr;
            end else begin
              tx_arvalid <= '0;
            end
		  
            if (axi_lt_rst) begin
              tx_awvalid <= '0;
              tx_arvalid <= '0;
              tx_pending <= '0;
              tx_araddr <= '0;
            end    
		  
          end // always_ff
   
        // rx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & rx_awready
              & rx_wready
              & ((awaddr_dout > 'h14 && awaddr_dout < 'h88) // rsvd_rx_dmux_rsvd_region
                 || (awaddr_dout >= 'h1A0 && awaddr_dout <= 'h1A8) // rx_igr_wadj_region
                 || (awaddr_dout >= 'h8200 && awaddr_dout <= 'h8208) // rx_egr_wadj_region
                 || (awaddr_dout >= 'h8258 && awaddr_dout <= 'h8294) // rx_dbg_region
                 )
              & !rx_pending) begin
            rx_awvalid <= '1;
            rx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            rx_awvalid <= '0;
            rx_pending <= '0;
          // end else if (rx_pending) begin
            // rx_awvalid <= '0;
          end      
        
          // read request
          if (arvalid 
              & rx_arready 
              & ((araddr > 'h14 && araddr < 'h88) // rsvd_rx_dmux_rsvd_region
                 || (araddr >= 'h1A0 && araddr <= 'h1A8) // rx_igr_wadj_region
                 || (araddr >= 'h8200 && araddr <= 'h8208) // rx_egr_wadj_region
                 || (araddr >= 'h8258 && araddr <= 'h8294) // rx_dbg_region
                 )
              ) begin
            rx_arvalid <= arvalid;
            rx_araddr <= araddr;
          end else begin
            rx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            rx_awvalid <= '0;
            rx_arvalid <= '0;
            rx_pending <= '0;
            rx_araddr <= '0;
          end 
        
        end // always_ff
        end else begin
        // -------------------------------------------------------
        // debug counter enabled for INST_ID == 1

          // tx pipeline (excluding TCAM)
          always_ff @ (posedge axi_lite_clk) begin
            // write request
            if (!awaddr_fifo_empty 
                & !wdata_fifo_empty 
                & tx_awready
                & tx_wready
                & ((awaddr_dout >= 'hC && awaddr_dout <= 'h14) // igr_arb_region
                   || (awaddr_dout >= 'h8238 && awaddr_dout <= 'h8254) // tx_dbg_region
                   )
                & !tx_pending) begin
              tx_awvalid <= '1;
              tx_pending <= '1;
            end else if (awaddr_fifo_empty 
                        & wdata_fifo_empty) begin
              tx_awvalid <= '0;
              tx_pending <= '0;
            // end else if (tx_pending) begin
              // tx_awvalid <= '0;
            end
		  
            // read request
            if (arvalid 
                & tx_arready 
                & ((araddr >= 'hC && araddr <= 'h14) // igr_arb_region
                   || (araddr >= 'h8238 && araddr <= 'h8254) // tx_dbg_region
                    )
                ) begin
              tx_arvalid <= arvalid;
              tx_araddr <= araddr;
            end else begin
              tx_arvalid <= '0;
            end
		  
            if (axi_lt_rst) begin
              tx_awvalid <= '0;
              tx_arvalid <= '0;
              tx_pending <= '0;
              tx_araddr <= '0;
            end    
		  
          end // always_ff

        // rx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & rx_awready
              & rx_wready
              & ((awaddr_dout > 'h84 && awaddr_dout < 'h1A0) // rx_dmux_rsvd_region
                 || (awaddr_dout >= 'h1AC && awaddr_dout <= 'h1FC) // rx_igr_wadj_rsvd_region
                 || (awaddr_dout >= 'h820C && awaddr_dout <= 'h8214) // rx_egr_wadj_region
                 || (awaddr_dout >= 'h8298 && awaddr_dout <= 'h82D4) // rx_dbg_region
                 || (awaddr_dout >= 'h82D8) // rx_dbg_rsvd_region
                 )
              & !rx_pending) begin
            rx_awvalid <= '1;
            rx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            rx_awvalid <= '0;
            rx_pending <= '0;
          // end else if (rx_pending) begin
            // rx_awvalid <= '0;
          end      
        
          // read request
          if (arvalid 
              & rx_arready 
              & ((araddr > 'h84 && araddr < 'h1A0) // rx_dmux_rsvd_region
                 || (araddr >= 'h1AC && araddr <= 'h1FC) // rx_igr_wadj_rsvd_region
                 || (araddr >= 'h820C && araddr <= 'h8214) // rx_egr_wadj_region
                 || (araddr >= 'h8298 && araddr <= 'h82D4) // rx_dbg_region
                 || (araddr >= 'h82D8) // rx_dbg_rsvd_region
                 )) begin
            rx_arvalid <= arvalid;
            rx_araddr <= araddr;
          end else begin
            rx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            rx_awvalid <= '0;
            rx_arvalid <= '0;
            rx_pending <= '0;
            rx_araddr <= '0;
          end 
        
        end // always_ff

        end // if (INST_ID == 0)
      end // if (DBG_CNTR_EN)
      else begin
        if (INST_ID == 0) begin
        // -------------------------------------------------------
        // debug counter disabled for INST_ID == 0

        // tx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & tx_awready
              & tx_wready
              & awaddr_dout <= 'h8 // igr_arb_region
              & !tx_pending) begin
            tx_awvalid <= '1;
            tx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            tx_awvalid <= '0;
            tx_pending <= '0;
          // end else if (tx_pending) begin
            // tx_awvalid <= '0;
          end

          // read request
          if (arvalid & tx_arready 
              & araddr <= 'h8 // igr_arb_region
               ) begin
            tx_arvalid <= arvalid;
            tx_araddr <= araddr;
          end else begin
            tx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            tx_awvalid <= '0;
            tx_arvalid <= '0;
            tx_pending <= '0;
            tx_araddr <= '0;
          end    

        end //always_ff

        // rx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & rx_awready
              & rx_wready
              & ((awaddr_dout > 'h14 && awaddr_dout < 'h88) // rsvd_rx_dmux_rsvd_region
                 || (awaddr_dout >= 'h1A0  && awaddr_dout <= 'h1A8) // rx_igr_wadj_region
                 || (awaddr_dout >= 'h8200 && awaddr_dout <= 'h8208) // rx_egr_wadj_region
                  ) 
              & !rx_pending) begin
            rx_awvalid <= '1;
            rx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            rx_awvalid <= '0;
            rx_pending <= '0;
          // end else if (rx_pending) begin
            // rx_awvalid <= '0;
          end      
        
          // read request
          if (arvalid 
              & rx_arready 
              & ((araddr > 'h14 && araddr < 'h88) // rsvd_rx_dmux_rsvd_region
                 || (araddr >= 'h1A0  && araddr <= 'h1A8) // rx_igr_wadj_region
                 || (araddr >= 'h8200 && araddr <= 'h8208) // rx_egr_wadj_region
                   )
               ) begin 
            rx_arvalid <= arvalid;
            rx_araddr <= araddr;
          end else begin
            rx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            rx_awvalid <= '0;
            rx_arvalid <= '0;
            rx_pending <= '0;
            rx_araddr <= '0;
          end 
        
        end // always_ff

       end else begin
        // -------------------------------------------------------
        // debug counter disabled for INST_ID == 1

        // tx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & tx_awready
              & tx_wready
              & (awaddr_dout >= 'hC && awaddr_dout <= 'h14) // igr_arb_region
              & !tx_pending) begin
            tx_awvalid <= '1;
            tx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            tx_awvalid <= '0;
            tx_pending <= '0;
          // end else if (tx_pending) begin
            // tx_awvalid <= '0;
          end

          // read request
          if (arvalid & tx_arready 
              & (araddr >= 'hC && araddr <= 'h14) // igr_arb_region
               ) begin
            tx_arvalid <= arvalid;
            tx_araddr <= araddr;
          end else begin
            tx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            tx_awvalid <= '0;
            tx_arvalid <= '0;
            tx_pending <= '0;
            tx_araddr <= '0;
          end    

        end //always_ff

        // rx pipeline (excluding TCAM)
        always_ff @ (posedge axi_lite_clk) begin
          // write request
          if (!awaddr_fifo_empty 
              & !wdata_fifo_empty 
              & rx_awready
              & rx_wready
              & ((awaddr_dout > 'h84 && awaddr_dout < 'h1A0) // rx_dmux_rsvd_region
                 || (awaddr_dout >= 'h1AC  && awaddr_dout <= 'h1FC) // rx_igr_wadj_rsvd_region
                 || (awaddr_dout >= 'h820C && awaddr_dout <= 'h8214) // rx_egr_wadj_rsvd_region
                 || (awaddr_dout >= 'h8218) // rsvd_region
                  )
              & !rx_pending) begin
            rx_awvalid <= '1;
            rx_pending <= '1;
          end else if (awaddr_fifo_empty 
                      & wdata_fifo_empty) begin
            rx_awvalid <= '0;
            rx_pending <= '0;
          // end else if (rx_pending) begin
            // rx_awvalid <= '0;
          end      
        
          // read request
          if (arvalid 
              & rx_arready 
              & ((araddr > 'h84 && araddr < 'h1A0) // rx_dmux_rsvd_region
                 || (araddr >= 'h1AC  && araddr <= 'h1FC) // rx_igr_wadj_rsvd_region
                 || (araddr >= 'h820C && araddr <= 'h8214) // rx_egr_wadj_rsvd_region
                 || (araddr >= 'h8218) // rsvd_region
                  )
               ) begin 
            rx_arvalid <= arvalid;
            rx_araddr <= araddr;
          end else begin
            rx_arvalid <= '0;
          end

          if (axi_lt_rst) begin
            rx_awvalid <= '0;
            rx_arvalid <= '0;
            rx_pending <= '0;
            rx_araddr <= '0;
          end 
        
        end // always_ff
       end // if (INST_ID == 1)
      end
    endgenerate

    // TCAM
    always_comb begin
      // write request
      if (!awaddr_fifo_empty 
          & !wdata_fifo_empty 
          & (awaddr_dout >= TCAM_START_ADDR && awaddr_dout < TCAM_END_ADDR) ) begin
        axi_lite_tcam_awvalid_o = '1;
        axi_lite_tcam_awaddr_o  = awaddr_dout - TCAM_START_ADDR[ADDR_WIDTH-1:0];
   
        axi_lite_tcam_wdata_o  = wdata_dout;
        axi_lite_tcam_wvalid_o = '1;
        axi_lite_tcam_wstrb_o  = wstrb_dout;
        
      end else begin
        axi_lite_tcam_awvalid_o = '0;
        axi_lite_tcam_awaddr_o = '0;

        axi_lite_tcam_wdata_o = '0;
        axi_lite_tcam_wvalid_o = '0;
        axi_lite_tcam_wstrb_o = '0;
      end

      // read request
      if (arvalid & (araddr >= TCAM_START_ADDR & araddr < TCAM_END_ADDR)) begin
        axi_lite_tcam_araddr_o  = araddr - TCAM_START_ADDR[ADDR_WIDTH-1:0];
        axi_lite_tcam_arvalid_o = arvalid;
      end else begin
        axi_lite_tcam_araddr_o  = '0;
        axi_lite_tcam_arvalid_o = '0;
      end

    end

    // tcam_wr_rsp_pending, tcam_rd_rsp_pending : assert pending wr or rd response
    always_ff @(posedge axi_lite_clk) begin
      if (!awaddr_fifo_empty & !wdata_fifo_empty 
          & (awaddr_dout >= TCAM_START_ADDR && awaddr_dout < TCAM_END_ADDR) )
        tcam_wr_rsp_pending <= '1;
      else
        tcam_wr_rsp_pending <= '0;

      if (arvalid & ((araddr >= TCAM_START_ADDR & araddr < TCAM_END_ADDR)) )
        tcam_rd_rsp_pending <= '1;
      else
        tcam_rd_rsp_pending <= '0;

    end

    // tcam_wr_rsp_state: state to hold until received bvalid
    always_ff @(posedge axi_lite_clk) begin
      if (tcam_wr_rsp_pending & !tcam_wr_rsp_state)
        tcam_wr_rsp_state <= '1;
      else if (tcam_wr_rsp_state & axi_lite_tcam_bvalid_i & axi_lite_tcam_bready_o)
        tcam_wr_rsp_state <= '0;
	  	  
      if (axi_lt_rst)
        tcam_wr_rsp_state <= '0;
    end   


    // tcam_rd_rsp_state: state to hold until received rvalid
    always_ff @(posedge axi_lite_clk) begin
      if (tcam_rd_rsp_pending & !tcam_rd_rsp_state)
        tcam_rd_rsp_state <= '1;
      else if (tcam_rd_rsp_state & axi_lite_tcam_rvalid_i & axi_lite_tcam_rready_o)
        tcam_rd_rsp_state <= '0;
	  
      if (axi_lt_rst)
        tcam_rd_rsp_state <= '0;
    end    

    always_comb begin
      // read from awaddr_fifo and wdata_fifo
      if (!awaddr_fifo_empty & !wdata_fifo_empty) begin
        if (awaddr_dout >= TCAM_START_ADDR  && awaddr_dout < TCAM_END_ADDR) 
          awaddr_fifo_rd = axi_lite_tcam_awready_i & axi_lite_tcam_wready_i;
        else
          awaddr_fifo_rd = '1;
      end else begin
        awaddr_fifo_rd = '0;
      end

      wdata_fifo_rd = awaddr_fifo_rd;
    end   

    always_ff @ (posedge tx_clk) begin
      // waitreq
      tx_avmm_write_waitreq <= !tx_avmm_write_dly;
    end

    ptp_bridge_pipe_dly #( 
             .W(1),
             .N(AVMM_MAX_LATENCY)) tx_avmm_pipe
         (.clk (tx_clk)
         ,.dIn (tx_avmm_write)
         ,.dOut (tx_avmm_write_dly) );

    // -------------------------------------------------------------------
    // detect reserve access (part of rx pipeline region)
    generate
    if (INST_ID == 0) begin

    always_ff @ (posedge rx_clk) begin
      // reserved accesses
      if ( (rx_avmm_read | rx_avmm_write) & 
	     ( ((rx_avmm_address >= 'h18)   // rsvd_0
          & (rx_avmm_address <= 'h5C))  // rsvd_0

         | ((rx_avmm_address >= 'h74)   // rsvd_1
          & (rx_avmm_address <= 'h84))  // rsvd_1
            )
          ) begin
        rx_avmm_access_rsvd <= '1;
        rx_avmm_readdata_bp <= '0;
      end else begin
        rx_avmm_access_rsvd <= '0;
        rx_avmm_readdata_bp <= rx_avmm_readdata;
      end
      
      // cycle delay
      rx_avmm_access_rsvd_c1 <= rx_avmm_access_rsvd;
      rx_avmm_read_c1        <= rx_avmm_read;
      rx_avmm_write_c1       <= rx_avmm_write;
      
      // waitreq
      rx_avmm_write_waitreq <= !(rx_avmm_write_dly & rx_avmm_access_rsvd == '0);
    end // always_ff

    end // if (INST_ID == 0)
    else begin
    // ---------------------------------------------------
    // INST_ID == 1

    always_ff @ (posedge rx_clk) begin
      // reserved accesses
      if ( (rx_avmm_read | rx_avmm_write) & 
	     ( ((rx_avmm_address >= 'h9C)   // rsvd_2
          & (rx_avmm_address <= 'h19C)) // rsvd_2
         
         | ((rx_avmm_address >= 'h1B8)  // rsvd_3
          & (rx_avmm_address <= 'h1FC)) // rsvd_3

         | (rx_avmm_address >= (DBG_CNTR_EN ? 'h82D8 : 'h8218)) // rsvd_4
          ) ) begin
        rx_avmm_access_rsvd <= '1;
        rx_avmm_readdata_bp <= '0;
      end else begin
        rx_avmm_access_rsvd <= '0;
        rx_avmm_readdata_bp <= rx_avmm_readdata;
      end
      
      // cycle delay
      rx_avmm_access_rsvd_c1 <= rx_avmm_access_rsvd;
      rx_avmm_read_c1        <= rx_avmm_read;
      rx_avmm_write_c1       <= rx_avmm_write;
      
      // waitreq
      rx_avmm_write_waitreq <= !(rx_avmm_write_dly & rx_avmm_access_rsvd == '0);
    end

    end // if (INST_ID == 1)
    endgenerate

    always_comb begin
      rx_avmm_access_rsvd_posedge = !rx_avmm_access_rsvd_c1 & rx_avmm_access_rsvd
                                    & (rx_avmm_read_c1 | rx_avmm_write_c1);
    end

    ptp_bridge_pipe_dly #( 
             .W(1),
             .N(AVMM_MAX_LATENCY)) rx_avmm_pipe
         (.clk (rx_clk)
         ,.dIn (rx_avmm_write)
         ,.dOut (rx_avmm_write_dly) );

    // -------------------------------------------------------------------
    // combine tx, rx, TCAM output signals

    always_comb begin
        axi_lite_tcam_bready_o = bready;
        axi_lite_tcam_rready_o = rready;

      if (axi_lt_rst) begin
        bvalid = '0;
        rvalid = '0;
        bresp = '0;
        rresp = '0;
        rdata = '0;
      end else begin

         // mask off stale tcam signals if no pending TCAM transaction
        if (tcam_wr_rsp_state) begin
          bvalid = axi_lite_tcam_bvalid_i;
          bresp = axi_lite_tcam_bresp_i;
        end else begin
          bvalid = tx_bvalid | rx_bvalid ;
          bresp = tx_bresp   | rx_bresp;
        end

        // mask off stale tcam signals if no pending TCAM transaction
        if (tcam_rd_rsp_state) begin
          rvalid = axi_lite_tcam_rvalid_i;
          rresp = axi_lite_tcam_rresp_i;
          rdata = axi_lite_tcam_rdata_i;
        end else begin
          rvalid = tx_rvalid | rx_rvalid;
          rresp = tx_rresp   | rx_rresp;
          rdata = tx_rvalid ? tx_rdata : 
                  rx_rvalid ? rx_rdata : '0;
        end

      end

    end

    // -------------------------------------------------------------------

   // tx pipeline
   ipbb_axi_lite_to_avmm_range_check_cdc #(
       .DEVICE_FAMILY   (DEVICE_FAMILY)
      ,.AWADDR_WIDTH    (ADDR_WIDTH)
      ,.WDATA_WIDTH     (DATA_WIDTH)
      ,.ARADDR_WIDTH    (ADDR_WIDTH)
      ,.RDATA_WIDTH     (DATA_WIDTH)
      ,.AVMMADDR_WIDTH  (ADDR_WIDTH)
      ,.AVMMWDATA_WIDTH (DATA_WIDTH)
      ,.AVMMRDATA_WIDTH (DATA_WIDTH) ) axi_lt_to_avmm_tx (
    
     // inputs
      .axi_lite_clk   (axi_lite_clk)                     
     ,.axi_lite_rst_n (!axi_lt_rst)
     ,.avmm_clk       (tx_clk)              
     ,.avmm_rst_n     (!tx_rst)
   
     // Write Address Channel
     // inputs
     ,.awaddr  (awaddr_dout)              
     ,.awvalid (tx_awvalid)    
     // output          
     ,.awready (tx_awready)
   
     // Write Data Channel
     // inputs
     ,.wdata  (wdata_dout)              
     ,.wvalid (tx_awvalid)
     ,.wstrb  (wstrb_dout)
     // output 
     ,.wready (tx_wready)
   
     // Write Response Channel
     // outputs 
     ,.bresp  (tx_bresp)              
     ,.bvalid (tx_bvalid)           
     // input   
     ,.bready (bready)
   
     // Read Address Channel
     // inputs   
     ,.araddr  (tx_araddr)
     ,.arvalid (tx_arvalid)
     // output
     ,.arready (tx_arready)
   
     // Read Data Channel
     // outputs 
     ,.rresp  (tx_rresp)
     ,.rdata  (tx_rdata)
     ,.rvalid (tx_rvalid)
     // input
     ,.rready (rready)
   
     // AVMM initiator interface
     // outputs
     ,.avmm_address              (tx_avmm_address)
     ,.avmm_read                 (tx_avmm_read)
     ,.avmm_write                (tx_avmm_write)
     ,.avmm_writedata            (tx_avmm_writedata)
     ,.avmm_byteenable           (tx_avmm_byteenable)
     // inputs
     ,.avmm_readdata             (tx_avmm_readdata)
     ,.avmm_waitrequest          (!tx_avmm_readdata_valid & tx_avmm_write_waitreq) 
                                  // | !tx_avmm_access_rsvd_posedge)

     ,.avmm_address_out_of_range ('0) // access beyond addr map
    );
   
   // rx pipeline
   ipbb_axi_lite_to_avmm_range_check_cdc #(
       .DEVICE_FAMILY   (DEVICE_FAMILY)
      ,.AWADDR_WIDTH    (ADDR_WIDTH)
      ,.WDATA_WIDTH     (DATA_WIDTH)
      ,.ARADDR_WIDTH    (ADDR_WIDTH)
      ,.RDATA_WIDTH     (DATA_WIDTH)
      ,.AVMMADDR_WIDTH  (ADDR_WIDTH)
      ,.AVMMWDATA_WIDTH (DATA_WIDTH)
      ,.AVMMRDATA_WIDTH (DATA_WIDTH) ) axi_lt_to_avmm_rx (
    
     // inputs
      .axi_lite_clk   (axi_lite_clk)                     
     ,.axi_lite_rst_n (!axi_lt_rst)
     ,.avmm_clk       (rx_clk)              
     ,.avmm_rst_n     (!rx_rst)
   
     // Write Address Channel
     // inputs
     ,.awaddr  (awaddr_dout)              
     ,.awvalid (rx_awvalid)    
     // output          
     ,.awready (rx_awready)
   
     // Write Data Channel
     // inputs
     ,.wdata  (wdata_dout)              
     ,.wvalid (rx_awvalid)
     ,.wstrb  (wstrb_dout)
     // output 
     ,.wready (rx_wready)
   
     // Write Response Channel
     // outputs 
     ,.bresp  (rx_bresp)              
     ,.bvalid (rx_bvalid)           
     // input   
     ,.bready (bready)
   
     // Read Address Channel
     // inputs   
     ,.araddr  (rx_araddr)
     ,.arvalid (rx_arvalid)
     // output
     ,.arready (rx_arready)
   
     // Read Data Channel
     // outputs 
     ,.rresp  (rx_rresp)
     ,.rdata  (rx_rdata)
     ,.rvalid (rx_rvalid)
     // input
     ,.rready (rready)
   
     // AVMM initiator interface
     // outputs
     ,.avmm_address              (rx_avmm_address)
     ,.avmm_read                 (rx_avmm_read)
     ,.avmm_write                (rx_avmm_write)
     ,.avmm_writedata            (rx_avmm_writedata)
     ,.avmm_byteenable           (rx_avmm_byteenable)
     // inputs
     ,.avmm_readdata             (rx_avmm_readdata_bp)
     ,.avmm_waitrequest          ((!rx_avmm_readdata_valid & rx_avmm_write_waitreq) 
                                  & !rx_avmm_access_rsvd_posedge)
     ,.avmm_address_out_of_range ('0) // access beyond addr map
    );


endmodule
