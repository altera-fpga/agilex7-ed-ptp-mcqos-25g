//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#AXI Slave response sequence
//#This class extends from the "svt_axi_slave_base_sequence" used to provide slave response 
//#to the Slave[0] present in the System agent.
//#This class acts as Host that will return descriptor/data to prefetcher/agent through AXI4 READ channel 
//#based on the AXI4 packet received 
//########################################################################
`ifndef FPTP_AXI_SLAVE_HOST_REPSONSE_SEQ__SV
`define FPTP_AXI_SLAVE_HOST_REPSONSE_SEQ__SV

/**
==========================================================================================
IMPORTS
==========================================================================================
*/
import axi_base_sequence_pkg::*;

parameter WAIT_FOR_SOC_NEXT_TRANSACTION_TIMEOUT_NS = 5000000; // 5ms default;
/**
==========================================================================================
CLASS
==========================================================================================
*/

class fptp_axi_slave_host_response_seq extends svt_axi_slave_base_sequence;

  svt_axi_slave_transaction req_resp;
  
  /** UVM Object Utility macro */
  `uvm_object_utils(fptp_axi_slave_host_response_seq)
  // TBD
  `uvm_declare_p_sequencer(svt_axi_slave_sequencer)
  
  // ---------------
  // Instantiations
  // ---------------
  // struct packed from "axi_base_sequence_pkg.sv"
  e_address_type  address_type;
  e_agent_type    agent_type;
  e_agent_port    agent_port;
  int desc_size = 3; 

  // Typedef struct packed from "axi_base_sequence_pkg".
  t_h2d_st_descriptor	h2d_st_data_desc_1;
  eth_pkt               eth_pkt_1;
  // ----------
  // Variables
  // ----------
  int burst_length = 0; 
  int up_burst_length = 0; 
  int up_burst_mod = 0; 
  int length = 0;
  int rec_bytes[6];
  int hdr_sent[6];
  int z;
  

  rand bit[15:0] ch0_max_desc;
  rand bit[15:0] ch1_max_desc;
  rand bit[15:0] ch2_max_desc;
  rand bit[15:0] ch3_max_desc;
  rand bit[15:0] ch4_max_desc;
  rand bit[15:0] ch5_max_desc;
  rand bit[15:0] ch_desc_length[6];
  rand bit[31:0] resp_time_in_ns;
  
  rand bit [47:0] ch0_da; 
  rand bit [47:0] ch0_sa; 
  rand bit [15:0] ch0_eth;
  rand bit [47:0] ch1_da; 
  rand bit [47:0] ch1_sa; 
  rand bit [15:0] ch1_eth;
  rand bit [47:0] ch2_da; 
  rand bit [47:0] ch2_sa; 
  rand bit [15:0] ch2_eth;
  rand bit [47:0] ch3_da; 
  rand bit [47:0] ch3_sa; 
  rand bit [15:0] ch3_eth;
  rand bit [47:0] ch4_da; 
  rand bit [47:0] ch4_sa; 
  rand bit [15:0] ch4_eth;
  rand bit [47:0] ch5_da; 
  rand bit [47:0] ch5_sa; 
  rand bit [15:0] ch5_eth;
  
  // Stores the number of descriptors requested through AR Channel.
  int num_of_desc_requested_per_arlen = 0;
  int num_of_desc_requested_per_awlen = 0;
  
  // Counter for the number of descriptors fetched------------
  int desc_offset_per_memrd_pkt_request = 0;
  int desc_offset_per_memwr_pkt_request = 0;
  
  // Queue to store router_tdata & router_tkeep_queue
  bit [511:0] rdesc_queue[6][$];

  bit [511:0] wdesc_queue[6][$];

  bit [511:0] data_queue[6][$];
  bit [511:0] pend_data_queue[6][$];

  bit [31:0] ch_rd_addr[6];
  
  bit [511:0] rdata_out[];
  bit [511:0] rdesc_pop;
  bit [511:0] wdesc_pop;
  bit [511:0] data_pop[5:0];
  
  int soc_timer_counter_ns 	= 0; 
  int host_read_pkt_received = 0; 
  int host_write_pkt_received = 0; 
  int last_desc;
  logic  [31:0] ctrl;
  logic  [31:0] next_descptr;
  logic  [31:0] rd_addr,wr_addr;
  logic  [47:0] da,sa;
  logic  [15:0] len;
  int  seq_num; 
  int  start;
  reg [31:0] s_ctrl;
  reg [31:0] e_ctrl;
  reg [31:0] tx_addr;
  reg [31:0] rx_addr;
  reg [31:0] next_descr;


  // ==========================================================================================
  // CONSTRUCTOR
  // ==========================================================================================
  function new(string name="fptp_axi_slave_host_response_seq");
    super.new(name);
  endfunction


  constraint desc_c {
     soft ch0_max_desc inside {[5:25]};
     soft ch1_max_desc inside {[5:25]};
     soft ch2_max_desc inside {[5:25]};
     soft ch3_max_desc inside {[5:25]};
     soft ch4_max_desc inside {[5:25]};
     soft ch5_max_desc inside {[5:25]};
  }

  constraint desc_len_c {
     soft ch_desc_length[0] inside {[64:1500]};
     soft ch_desc_length[1] inside {[64:1500]};
     soft ch_desc_length[2] inside {[64:1500]};
     soft ch_desc_length[3] inside {[64:1500]};
     soft ch_desc_length[4] inside {[64:1500]};
     soft ch_desc_length[5] inside {[64:1500]};

  }
  // ==========================================================================================
  // TEST SEQUENCE
  // ==========================================================================================
  virtual task body();
    integer status;
    svt_configuration get_cfg;
    
    super.body();
    `uvm_info("body", "Entered ...", UVM_NONE)
    $display("HOST SEQ ENTERED1");
    
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `uvm_fatal("body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
    end
    $display("HOST SEQ ENTERED2");
    
    // consumes responses sent by driver
    soc_timer_counter_ns = 0;
			

    //////////////////////////////////////////////////////////////////////////////////
    `uvm_info("body", "Entered 112233...", UVM_NONE)

    fork 
      begin
        //while (soc_timer_counter_ns < WAIT_FOR_SOC_NEXT_TRANSACTION_TIMEOUT_NS) begin
        while (soc_timer_counter_ns < resp_time_in_ns ) begin
          #1ns;   
          if ((host_read_pkt_received == 1) || (host_write_pkt_received == 1))begin
            soc_timer_counter_ns = 0;
            $display("reset soc_timer_counter_ns");
          end else begin
            soc_timer_counter_ns += 1;
          end
        end
        `uvm_warning(get_type_name(), "Timer stops waiting for subsequent memory read request packets.")
        // end
      end 


     ////////////////////////////////////////////////////////////
		
      begin
        forever begin
          //Get the response request from the slave sequencer. The response request is
          //provided to the slave sequencer by the slave port monitor, through
          //TLM port.

          `uvm_info(get_full_name( ), "peek in the sequencer port for request packet", UVM_NONE)
          p_sequencer.response_request_port.peek(req_resp);
          $cast(req,req_resp);
          `uvm_info("transaction to slave", $sformatf("xact_IN:\n%s", req_resp.sprint()), UVM_NONE)
          `uvm_info("body", "response_request_port_2 done ... ", UVM_NONE)

          //----------------------------------------------------------------------------------
          // Host write respond 
          //----------------------------------------------------------------------------------
          if((req_resp.xact_type ==(svt_axi_transaction::COHERENT)) && (req_resp.transmitted_channel == (svt_axi_transaction::WRITE)))begin
            bit [511:0] wr_data[];
            host_write_pkt_received = 1;
            $cast(address_type,req_resp.addr[30:28]); 
             $display("HOST SEQ ENTERED8");
            `uvm_info(get_full_name(), "Received WRITE packet", UVM_NONE)
            if (address_type == DMA_DATA) begin
                $cast(agent_type,req_resp.addr[27:26]);
                $cast(agent_port,req_resp.addr[25:23]);
                $cast(burst_length,req_resp.burst_length);
                $display("Address type received for WR DMA DATA");
                $display("agent_type for last : %0d",agent_type);
                $display("agent_port for last : %0d",agent_port);
                $display("burst_length : %0d",burst_length);
            end
            else if (address_type == DESCR) begin   
                $cast(agent_type,req_resp.addr[27:26]);
                $cast(agent_port,req_resp.addr[25:23]);
                $cast(burst_length,req_resp.burst_length);
                $display("Address type received for DESC WR BACK");
                $display("agent_type for last : %0d",agent_type);
                $display("agent_port for last : %0d",agent_port);
                $display("burst_length : %0d",burst_length);
            end
            num_of_desc_requested_per_awlen = burst_length;
            while (desc_offset_per_memwr_pkt_request < num_of_desc_requested_per_awlen) begin

               wr_data = new[req_resp.data.size()];
               foreach (req_resp.data[i]) begin
                 wr_data[i] = req_resp.data[i];
               end
               desc_offset_per_memwr_pkt_request++;
            end
            $display("sending BRESP to slave sequencer");
            `uvm_rand_send_with(req, {	
              bresp == svt_axi_slave_transaction::OKAY;
              `ifdef WATCHDOG_TIMER_EN	
              addr_ready_delay == 16;
              `endif//WATCHDOG_TIMER_EN
            })
            host_write_pkt_received = 0;
            $display (" WRITE TXN ENDS");
          end

          //----------------------------------------------------------------------------------
          // Host read respond 
          //---------------------------------------------------------------------------------- 
          if((req_resp.xact_type ==(svt_axi_transaction::COHERENT)) && (req_resp.transmitted_channel == (svt_axi_transaction::READ)))begin
             $display("CHECK THE REQ IS FOR READ for H2D/D2H ENTERED4");
             $display("CHECK THE REQ IS FOR DESC READ/DMA READ ENTERED4");
            `uvm_info(get_full_name(), "Received READ packet", UVM_NONE)
            host_read_pkt_received = 1;
            
            //----------------------------------------------------------------------------------------
            // STEP 1::Checks format type and assign values to address_type, agent_type and agent_port
            //----------------------------------------------------------------------------------------
            $cast(address_type,req_resp.addr[30:28]); 
            if (address_type == CSR) begin
              $cast(agent_type,req_resp.addr[21:20]);
              $cast(agent_port,req_resp.addr[16:13]);
              $cast(burst_length,req_resp.burst_length);
              $display("burst_length : %0d",burst_length);
              $display("Address type received CSR");
            end  
            else if (address_type == DESCR) begin
                $cast(agent_type,req_resp.addr[27:26]);  
                $cast(agent_port,req_resp.addr[25:23]);
                $cast(burst_length,req_resp.burst_length);
                if (req_resp.addr[31]) begin
                   last_desc = 1;
                   $display("Received DESC Addr = %h",req_resp.addr);  
                   $display("burst_length : %0d",burst_length);
                   $display("agent_type   : %0d",agent_type);
                   $display("agent_port   : %0d",agent_port);
                end
                else begin
                   last_desc = 0;
                   $display("Received DESC Addr = %h",req_resp.addr);  
                   $display("burst_length for other than last %0d",burst_length);
                   $display("Address type received non CSR");
                   $display("agent_type for last : %0d",agent_type);
                   $display("agent_port for last : %0d",agent_port);
                end
            end
            else if (address_type == DMA_DATA) begin
                $display("Received DATA Addr = %h",req_resp.addr);  
                $cast(agent_type,req_resp.addr[27:26]);
                $cast(agent_port,req_resp.addr[25:23]);
                $cast(burst_length,req_resp.burst_length);
                $display("Address type received for DMA DATA");
                $display("agent_type for last : %0d",agent_type);
                $display("agent_port for last : %0d",agent_port);
                $display("burst_length for DMA DATA: %0d",burst_length);
                if (burst_length > 1) begin
                    $display("In case burst_length for DMA DATA: %0d",burst_length);
                    if (burst_length==8 ) begin
                        up_burst_length = 1;
                    end
                    else if (burst_length >8 && burst_length <=16) begin
                        up_burst_length = 2;
                        end     
                    else if (burst_length >16 && burst_length <=24) begin
                        up_burst_length = 3;
                    end
                    else if (burst_length >24 && burst_length <=32) begin
                        up_burst_length = 4;
                    end
                end
                else begin
                     up_burst_mod    = ch_desc_length[agent_port]%8;
                end
                $display("UP_burst_length : %0d",up_burst_length);
                $display("UP_burst_mod : %0d",up_burst_mod);
                case(req_resp.addr[25:23])
                 0 : begin
                       ch_rd_addr[0] = req_resp.addr;
                       $display("PORT0 DMA addr = %h",ch_rd_addr[0]);
                     end
                 1 : begin
                       ch_rd_addr[1] = req_resp.addr;
                     end
                 2 : begin
                       ch_rd_addr[2] = req_resp.addr;
                     end
                 3 : begin
                       ch_rd_addr[3] = req_resp.addr;
                     end
                 4 : begin
                       ch_rd_addr[4] = req_resp.addr;
                     end
                 5 : begin
                       ch_rd_addr[5] = req_resp.addr;
                     end
                endcase
            end
			
            `uvm_info(get_full_name(),
                      $sformatf(" Received address type is %s, for agent %0s @ port %0d",
                                 address_type.name(), agent_type.name(), agent_port),
                      UVM_NONE)

             

            //----------------------------------------------------------------------------------------
            // STEP 2::Address type == DESCR, construct rdata to prefetcher, to return descriptors
            //----------------------------------------------------------------------------------------
            if (address_type == DESCR) begin
              $display("=================================================================================");
              $display("Memory read request for descriptor request: 256'h%0h", req_resp.addr);
              $display("=================================================================================");
              $display("HOST SEQ ENTERED5");
              
              num_of_desc_requested_per_arlen = burst_length;
              `uvm_info(get_full_name(),
                        $sformatf("num_of_desc_requested_per_arlen : %0d",num_of_desc_requested_per_arlen),
                        UVM_NONE)
              // Initialize before processing the request of an memory read packet.
              desc_offset_per_memrd_pkt_request = 0;
              // [IF BLOCK]
              if (agent_type == H2D_ST_AGENT) // H2D -> 1 D2H -> 0
              begin 
                case(agent_port)
                  0 : h2d_write_descriptor(agent_port,ch0_max_desc);
                  1 : h2d_write_descriptor(agent_port,ch1_max_desc);
                  2 : h2d_write_descriptor(agent_port,ch2_max_desc);
                  3 : h2d_write_descriptor(agent_port,ch3_max_desc);
                  4 : h2d_write_descriptor(agent_port,ch4_max_desc);
                  5 : h2d_write_descriptor(agent_port,ch5_max_desc);
                endcase
              end
              else if (agent_type == D2H_ST_AGENT) // H2D -> 1 D2H -> 0
              begin
                case(agent_port)
                  0 : d2h_write_descriptor(agent_port,ch0_max_desc);
                  1 : d2h_write_descriptor(agent_port,ch1_max_desc);
                  2 : d2h_write_descriptor(agent_port,ch2_max_desc);
                  3 : d2h_write_descriptor(agent_port,ch3_max_desc);
                  4 : d2h_write_descriptor(agent_port,ch4_max_desc);
                  5 : d2h_write_descriptor(agent_port,ch5_max_desc);
                endcase
              end  
              

              // [WHILE LOOP::Prefetcher TLP Payload]
              $display("ENTER_WHILE_LOOP_PREFETCHER_PAYLOAD");
              while (desc_offset_per_memrd_pkt_request < num_of_desc_requested_per_arlen) begin
                desc_offset_per_memrd_pkt_request++;
                $display("desc_offset_per_memrd_pkt_request",desc_offset_per_memrd_pkt_request);
                $display("num_of_desc_requested_per_arlen",num_of_desc_requested_per_arlen);
                $display("START OF WHILE LOOP");
                if (desc_offset_per_memrd_pkt_request	== num_of_desc_requested_per_arlen) begin
                  $display("----Send MemRd Cpl TLP Packet----");
                  $display("HOST SEQ ENTERED6");
                  if (agent_type == H2D_ST_AGENT) begin
                     rdata_out = new[burst_length]; 
                     rdesc_pop = rdesc_queue[agent_port].pop_front();
                     for (int i=0; i<burst_length; i++) begin 
                        $display("%d, rdesc_pop = %h",i,rdesc_pop);
                        rdata_out[i] = rdesc_pop[64*i+:64];
                        $display("rdata_out[%0d]:%h",i,rdata_out[i]);
                        $display ("IN PORT[%d] RDESC POP",agent_port);
                     end
                  end   
                  else if (agent_type == D2H_ST_AGENT) begin
                     rdata_out = new[burst_length]; 
                     wdesc_pop = wdesc_queue[agent_port].pop_front();
                     for (int i=0; i<burst_length; i++) begin 
                       $display("%d, wdesc_pop = %h",i,wdesc_pop);
                       rdata_out[i] = wdesc_pop[64*i+:64];
                       $display("rdata_out[%0d]:%h",i,rdata_out[i]);
                       $display ("IN PORT[%d] WDESC POP",agent_port);
                     end
                   end
                end
                $display("END OF WHILE LOOP");
              end //end of WHILE LOOP

              // send req_resp to driver
              `uvm_info("body", "sending Descriptors to slave sequencer ", UVM_NONE)
              host_read_pkt_received = 0; 
              `uvm_rand_send_with(req, {	
                                        foreach (data[index])   {
                                          data[index] == rdata_out[index]; }
                                        foreach (rresp[index]) {
                                          rresp[index] == svt_axi_slave_transaction::OKAY; }
                                        `ifdef WATCHDOG_TIMER_EN	
                                        addr_ready_delay == 16;
                                        `endif//WATCHDOG_TIMER_EN
                                       })
              desc_offset_per_memrd_pkt_request = 0;
            end //end of DESCR
			
            //----------------------------------------------------------------------------------------
            // STEP 3::Address type == DMA, construct rdata to Agents, to return DMA data
            //----------------------------------------------------------------------------------------
            if (address_type == DMA_DATA) begin
              $display("=================================================================================");
              $display("Memory read request for DMA data request: 256'h%0h", req_resp.addr);
              $display("=================================================================================");
              $display("HOST SEQ ENTERED7");
              
              // send req_resp to driver
              `uvm_info("body", "sending DMA data to slave sequencer ", UVM_NONE)
              host_read_pkt_received = 0; 
              rdata_out = new[burst_length]; //burst_length changed to 0 temporarily. TBD
              case(agent_port)
                 0: load_data (agent_port,ch0_da,ch0_sa,ch0_eth);
                 1: load_data (agent_port,ch1_da,ch1_sa,ch1_eth);
                 2: load_data (agent_port,ch2_da,ch2_sa,ch2_eth);
                 3: load_data (agent_port,ch3_da,ch3_sa,ch3_eth);
                 4: load_data (agent_port,ch4_da,ch4_sa,ch4_eth);
                 5: load_data (agent_port,ch5_da,ch5_sa,ch5_eth);
              endcase  

               rdata_out = new[burst_length]; //burst_length changed to 0 temporarily. TBD
               if (burst_length > 1) begin 
                  for (int i=0; i<up_burst_length; i++) begin 
                    data_pop[0] = data_queue[agent_port].pop_front();
                    for (int j=0; j<8; j++) begin 
                         rdata_out[i*8+j] = data_pop[0][64*j+:64];
                         $display("rdata_out[%0d]:%h",i*8+j,rdata_out[i*8+j]);
                         $display ("IN PORT[%d] RDATA POP",agent_port);
                    end  
                  end
                  rec_bytes[0] = burst_length*8 + rec_bytes[agent_port]; 
                  $display(" Totallength = %d",rec_bytes[agent_port]);
                  if(ch_desc_length[agent_port] == rec_bytes[agent_port]) begin
                        hdr_sent[agent_port] = 0;
                        rec_bytes[agent_port] = 0;
                        $display(" HDR SENT[%d] = %h, Port = %d", agent_port, hdr_sent[agent_port], agent_port) ;
                  end
                  
               end
               if (burst_length == 1)
               begin
                 if (up_burst_mod!=0)
                 begin 
                     z = rdata_out.size(); 
                     z= z-1;  
                     $display(" DATA OUT SIZE= %d", rdata_out.size());  
                     data_pop[0] = pend_data_queue[agent_port].pop_front();
                     for (int j=0; j<up_burst_mod; j++) begin 
                         rdata_out[z+j] = data_pop[0][64*j+:64];
                         $display("rdata_out[%0d]:%h",z+j,rdata_out[z+j]);
                         $display ("IN PORT[%d] RDATA POP",agent_port);
                     end  
                 end
                 else 
                 begin 
                     z = rdata_out.size(); 
                     z= z-1;  
                     $display(" DATA OUT SIZE= %d", rdata_out.size());  
                     data_pop[0] = pend_data_queue[agent_port].pop_front();
                     for (int j=0; j<8; j++) begin 
                         rdata_out[z+j] = data_pop[0][64*j+:64];
                         $display("rdata_out[%0d]:%h",z+j,rdata_out[z+j]);
                         $display ("IN PORT[%d] RDATA POP",agent_port);
                     end  
                 end
               end
              `uvm_rand_send_with(req, {	
                                        foreach (data[index])   {
                                          data[index] == rdata_out[index]; }
                                         foreach (rresp[index]) {
                                          	rresp[index] == svt_axi_slave_transaction::OKAY; }
                                         `ifdef WATCHDOG_TIMER_EN	
                                         addr_ready_delay == 16;
                                         `endif//WATCHDOG_TIMER_EN
                                 })
            end //end of DMA_DATA
          end //end of READ transaction 
          $display ("TASK END BEFORE");
        end //forever
      end // fork end
    join_any
     $display ("TASK END");
    `uvm_info("Exiting_body", "fptp_axi_slave_host_response_seq...!! ", UVM_NONE)
  endtask: body 


   // Task for loading H2D descriptor
   task h2d_write_descriptor (int port, int desc);
      logic [31:0] sctrl;
      logic [31:0] ectrl;
      logic [31:0] descptr;
      logic [31:0] addr;
      $display("MAX_DESC in PORT[%d] = %d",port, desc);
      $display("DESC LENGTH n PORT[%d] = %d",port,ch_desc_length[port]);
       case (port)
            0 : begin
                  sctrl = PORT0_START_DESC_CTRL;
                  ectrl = PORT0_END_DESC_CTRL ;
                  descptr =  'h14010000;
                  addr = PORT0_TXDMA_ADDR;
                end
            1 : begin
                  sctrl = PORT1_START_DESC_CTRL;
                  ectrl = PORT1_END_DESC_CTRL ;
                  descptr =  'h14810000;
                  addr = PORT1_TXDMA_ADDR;
                end
            2 : begin
                  sctrl = PORT2_START_DESC_CTRL;
                  ectrl = PORT2_END_DESC_CTRL ;
                  descptr =  'h15010000;
                  addr = PORT2_TXDMA_ADDR;
                end
            3 : begin
                  sctrl = PORT3_START_DESC_CTRL;
                  ectrl = PORT3_END_DESC_CTRL ;
                  descptr =  'h15810000;
                  addr = PORT3_TXDMA_ADDR;
                end
            4 : begin
                  sctrl = PORT4_START_DESC_CTRL;
                  ectrl = PORT4_END_DESC_CTRL ;
                  descptr =  'h16010000;
                  addr = PORT4_TXDMA_ADDR;
                end
            5 : begin
                  sctrl = PORT5_START_DESC_CTRL;
                  ectrl = PORT5_END_DESC_CTRL ;
                  descptr =  'h16810000;
                  addr = PORT5_TXDMA_ADDR;
                end
       endcase   
       $display(" SCTRL = %h",sctrl);
       $display(" ECTRL = %h",ectrl);
       $display(" DESCR = %h",descptr);
       $display(" ADDR = %h",addr);
         for (int i = 0; i <desc;i++) begin // No.of desc
            if ( i ==0 )
            begin 
                 ctrl = sctrl;
                 seq_num = i;
                 next_descptr = descptr;; 
                 rd_addr = addr;
                 $display(" SCTRL = %h",sctrl);
                  
            end
            else if (i>=1 && i<desc-1)
            begin 
                 ctrl = sctrl;
                 seq_num = i;
                 next_descptr = next_descptr +'h100;
                 rd_addr =  rd_addr + 'h600;
                 $display(" SCTRL = %h",sctrl);
            end
            else if (i==desc-1)
            begin 
                 ctrl = ectrl; 
                 seq_num = i;
                 next_descptr = next_descptr +'h100;
                 rd_addr =  rd_addr + 'h600;
                 $display(" ECTRL = %h",ectrl);
            end
             h2d_st_data_desc_1.Control = ctrl;
             h2d_st_data_desc_1.Reserved = 'h0;
             h2d_st_data_desc_1.NextDescptrU = 'h0;
             h2d_st_data_desc_1.WriteAddressU = 'h0;
             h2d_st_data_desc_1.ReadAddressU = 'h0; 
             h2d_st_data_desc_1.Stride = 'h0;
             h2d_st_data_desc_1.BurstSeqnumber = seq_num;
             h2d_st_data_desc_1.Reserved1 = 'h0;
             h2d_st_data_desc_1.Status = 'h0;
             h2d_st_data_desc_1.ActualBytesTransfered = 'h0;
             h2d_st_data_desc_1.NextDescptrL = next_descptr;
             h2d_st_data_desc_1.Length = ch_desc_length[port];
             h2d_st_data_desc_1.WriteAddressL = 'h0;
             h2d_st_data_desc_1.ReadAddressL = rd_addr;
   
             $display("----link_desc----");
             rdesc_queue[port].push_back({
             h2d_st_data_desc_1.Control, // SOP and EOP set
             h2d_st_data_desc_1.Reserved,
             h2d_st_data_desc_1.NextDescptrU,
             h2d_st_data_desc_1.WriteAddressU,
             h2d_st_data_desc_1.ReadAddressU, 
             h2d_st_data_desc_1.Stride,
             h2d_st_data_desc_1.BurstSeqnumber,
             h2d_st_data_desc_1.Reserved1,
             h2d_st_data_desc_1.Status,
             h2d_st_data_desc_1.ActualBytesTransfered,
             h2d_st_data_desc_1.NextDescptrL,
             h2d_st_data_desc_1.Length, 
             h2d_st_data_desc_1.WriteAddressL,
             h2d_st_data_desc_1.ReadAddressL}); 
             $display("rdesc_queue[%d]:%h",port,rdesc_queue[port][i]);
             $display ("IN PORT[%d] RDESC QUEUE",port);
         end   
   endtask

   // Task for loading D2H descriptor
   task d2h_write_descriptor (int port, int desc);
      logic [31:0] sctrl;
      logic [31:0] ectrl;
      logic [31:0] descptr;
      logic [31:0] addr;
      $display("MAX_DESC in PORT[%d] = %d",port, desc);
      $display("DESC LENGTH n PORT[%d] = %d",port,ch_desc_length[port]);
       case (port)
            0 : begin
                  sctrl = PORT0_START_DESC_CTRL;
                  ectrl = PORT0_END_DESC_CTRL ;
                  descptr =  'h10010000;
                  addr = PORT0_RXDMA_ADDR;
                end
            1 : begin
                  sctrl = PORT1_START_DESC_CTRL;
                  ectrl = PORT1_END_DESC_CTRL ;
                  descptr =  'h10810000;
                  addr = PORT1_RXDMA_ADDR;
                end
            2 : begin
                  sctrl = PORT2_START_DESC_CTRL;
                  ectrl = PORT2_END_DESC_CTRL ;
                  descptr =  'h11010000;
                  addr = PORT2_RXDMA_ADDR;
                end
            3 : begin
                  sctrl = PORT3_START_DESC_CTRL;
                  ectrl = PORT3_END_DESC_CTRL ;
                  descptr =  'h11810000;
                  addr = PORT3_RXDMA_ADDR;
                end
            4 : begin
                  sctrl = PORT4_START_DESC_CTRL;
                  ectrl = PORT4_END_DESC_CTRL ;
                  descptr =  'h12010000;
                  addr = PORT4_RXDMA_ADDR;
                end
            5 : begin
                  sctrl = PORT5_START_DESC_CTRL;
                  ectrl = PORT5_END_DESC_CTRL ;
                  descptr =  'h12810000;
                  addr = PORT5_RXDMA_ADDR;
                end
       endcase   
       $display(" SCTRL = %h",sctrl);
       $display(" ECTRL = %h",ectrl);
       $display(" DESCR = %h",descptr);
       $display(" ADDR = %h",addr);
         for (int i = 0; i <desc;i++) begin // No.of desc
            if ( i ==0 )
            begin 
                 ctrl = sctrl;
                 seq_num = i;
                 next_descptr = descptr;; 
                 wr_addr = addr;
                 $display(" SCTRL = %h",sctrl);
                  
            end
            else if (i>=1 && i<desc-1)
            begin 
                 ctrl = sctrl;
                 seq_num = i;
                 next_descptr = next_descptr +'h100;
                 wr_addr =  wr_addr + 'h600;
                 $display(" SCTRL = %h",sctrl);
            end
            else if (i==desc-1)
            begin 
                 ctrl = ectrl; 
                 seq_num = i;
                 next_descptr = next_descptr +'h100;
                 wr_addr =  wr_addr + 'h600;
                 $display(" ECTRL = %h",ectrl);
            end
             h2d_st_data_desc_1.Control = ctrl;
             h2d_st_data_desc_1.Reserved = 'h0;
             h2d_st_data_desc_1.NextDescptrU = 'h0;
             h2d_st_data_desc_1.WriteAddressU = 'h0;
             h2d_st_data_desc_1.ReadAddressU = 'h0; 
             h2d_st_data_desc_1.Stride = 'h0;
             h2d_st_data_desc_1.BurstSeqnumber = seq_num;
             h2d_st_data_desc_1.Reserved1 = 'h0;
             h2d_st_data_desc_1.Status = 'h0;
             h2d_st_data_desc_1.ActualBytesTransfered = 'h0;
             h2d_st_data_desc_1.NextDescptrL = next_descptr;
             h2d_st_data_desc_1.Length = ch_desc_length[port];
             h2d_st_data_desc_1.WriteAddressL = wr_addr;
             h2d_st_data_desc_1.ReadAddressL = 'h0;
   
             $display("----link_desc----");
             wdesc_queue[port].push_back({
             h2d_st_data_desc_1.Control, // SOP and EOP set
             h2d_st_data_desc_1.Reserved,
             h2d_st_data_desc_1.NextDescptrU,
             h2d_st_data_desc_1.WriteAddressU,
             h2d_st_data_desc_1.ReadAddressU, 
             h2d_st_data_desc_1.Stride,
             h2d_st_data_desc_1.BurstSeqnumber,
             h2d_st_data_desc_1.Reserved1,
             h2d_st_data_desc_1.Status,
             h2d_st_data_desc_1.ActualBytesTransfered,
             h2d_st_data_desc_1.NextDescptrL,
             h2d_st_data_desc_1.Length, 
             h2d_st_data_desc_1.WriteAddressL,
             h2d_st_data_desc_1.ReadAddressL}); 
             $display("wdesc_queue[%d]:%h",port,wdesc_queue[port][i]);
             $display ("IN PORT[%d] WDESC QUEUE",port);
         end   
   endtask
   
   // Task for loading DMA DATA
   task load_data( int port,bit[47:0] DA, bit[47:0] SA, bit[15:0] ETH);
         if (burst_length > 1)
         begin
           for (int j=0; j<up_burst_length; j++) begin
               if (j==0)
               begin
                   $display(" ADDR0 = %h",ch_rd_addr[port]);   
                   $display (" IN LENGTH1 && J 0");
                   $display(" HDR SENT[%d] = %h, Port = %d", port, hdr_sent[port], port) ;
                   if (!hdr_sent[port]) begin
                      sa = SA;
                      da = DA;
                      len = ETH;
                      hdr_sent[port] = 1;
                      $display(" HDR SENT[%d] in first if = %h, Port = %d", port, hdr_sent[port], port) ;
                   end
                   else
                   begin
                      sa = $random;
                      da = $random;
                      len = $random;
                   end    
               end
               else
               begin
                 sa = $random; 
                 da = $random;
                 len = $random;
               end 
               eth_pkt_1.data3 = $random;
               eth_pkt_1.data2 = $random;
               eth_pkt_1.data1 = $random;
               eth_pkt_1.data0 = $random;
               eth_pkt_1.len = len;
               eth_pkt_1.sa = sa;
               eth_pkt_1.da = da;

               data_queue[port].push_back({
               eth_pkt_1.data3,
               eth_pkt_1.data2,
               eth_pkt_1.data1,
               eth_pkt_1.data0,
               eth_pkt_1.len,
               eth_pkt_1.sa,
               eth_pkt_1.da });
               $display("data_queue[%0d]:%h",port,j,data_queue[port][j]);
               $display("FIRST PKT PORT0 %d",  j);
           end
         end
         else  begin
           // Check for mod to be non_zero and its value between 1 to 7
             if (up_burst_mod!=0)
             begin
               $display(" ADDR0 = %h",ch_rd_addr[port]);   
               hdr_sent[port] = 0;
               $display(" HDR SENT[%d] in RESET0 = %h, Port = %d", port, hdr_sent[port], port) ;
               for (int j=0; j<up_burst_mod; j++) begin
                   eth_pkt_1.data3 = $random;
                   eth_pkt_1.data2 = $random;
                   eth_pkt_1.data1 = $random;
                   eth_pkt_1.data0 = $random;
                   eth_pkt_1.len = $random;
                   eth_pkt_1.sa = $random;
                   eth_pkt_1.da = $random;

                   pend_data_queue[port].push_back({
                   eth_pkt_1.data3,
                   eth_pkt_1.data2,
                   eth_pkt_1.data1,
                   eth_pkt_1.data0,
                   eth_pkt_1.len,
                   eth_pkt_1.sa,
                   eth_pkt_1.da });
                   $display("pend_data_queue[%0d]:%h",port,j,pend_data_queue[port][j]);
                   $display("SECONDPKT PORT0");
               end
             end    
             else if (!up_burst_mod) 
             begin
               $display(" ADDR0 = %h",ch_rd_addr[port]);   
               hdr_sent[port] = 0;
               $display(" HDR SENT[%d] in RESET1 = %h, Port = %d", port, hdr_sent[port], port) ;
               for (int j=0; j<8; j++) begin
                   eth_pkt_1.data3 = $random;
                   eth_pkt_1.data2 = $random;
                   eth_pkt_1.data1 = $random;
                   eth_pkt_1.data0 = $random;
                   eth_pkt_1.len = $random;
                   eth_pkt_1.sa = $random;
                   eth_pkt_1.da = $random;

                   pend_data_queue[port].push_back({
                   eth_pkt_1.data3,
                   eth_pkt_1.data2,
                   eth_pkt_1.data1,
                   eth_pkt_1.data0,
                   eth_pkt_1.len,
                   eth_pkt_1.sa,
                   eth_pkt_1.da });
                   $display("pend_data_queue[%0d]:%h",port,j,pend_data_queue[port][j]);
                   $display("SECONDPKT PORT0");
               end
             end     
         end
   endtask

endclass:fptp_axi_slave_host_response_seq

`endif // FPTP_AXI_SLAVE_HOST_REPSONSE_SEQ__SV

