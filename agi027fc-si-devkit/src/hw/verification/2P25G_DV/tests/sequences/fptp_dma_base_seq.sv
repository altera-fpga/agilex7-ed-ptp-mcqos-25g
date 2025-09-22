//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Basic DMA Test sequence to send DMA traffic with less descriptors from all channels to HSSI. The packets 
//# are reaches HSSI, gets looped back and routed back respective RX DMA channels
//# based on the configuration in PTP Bridge (TCAM)
//########################################################################
class fptp_dma_base_seq extends uvm_sequence;
  `uvm_declare_p_sequencer(svt_axi_system_sequencer)

    
  `uvm_object_utils(fptp_dma_base_seq);

  fptp_data_traffic_cfg_seq cfg_csr_seq;
  fptp_ptp_bridge_cfg_dma_seq ptp_cfg_seq;
  fptp_axi_slave_host_response_seq host_resp_seq;

  function new (string name = "fptp_dma_base_seq");
    super.new(name);
  endfunction : new


  bit [47:0] p0_da;
  bit [47:0] p0_sa;
  bit [15:0] p0_eth;

  bit [47:0] p1_da;
  bit [47:0] p1_sa;
  bit [15:0] p1_eth;

  bit [47:0] p2_da;
  bit [47:0] p2_sa;
  bit [15:0] p2_eth;

  bit [47:0] p3_da;
  bit [47:0] p3_sa;
  bit [15:0] p3_eth;

  bit [47:0] p4_da;
  bit [47:0] p4_sa;
  bit [15:0] p4_eth;

  bit [47:0] p5_da;
  bit [47:0] p5_sa;
  bit [15:0] p5_eth;

 
  task body();

    super.body();
   p0_da  = 'hdddddddddddd; 
   p0_sa  = 'haaaaaaaaaaaa; 
   p0_eth = 'h0800;
   p1_da  = 'hffffffffffff; 
   p1_sa  = 'hbbbbbbbbbbbb; 
   p1_eth = 'h8857;
   p2_da  = 'heeeeeeeeeeee; 
   p2_sa  = 'hcccccccccccc; 
   p2_eth = 'h0800;
   p3_da  = 'h333333333333; 
   p3_sa  = 'h666666666666; 
   p3_eth = 'h8857;
   p4_da  = 'h444444444444; 
   p4_sa  = 'h777777777777; 
   p4_eth = 'h0800;
   p5_da  = 'h555555555555; 
   p5_sa  = 'h888888888888; 
   p5_eth = 'h8857;

    `uvm_info(get_full_name(), "Body:STARTS in DATA PATH SEQ.", UVM_DEBUG) 
      `uvm_do_with (ptp_cfg_seq, {
                    ch0_dma_key0 ==  p0_da[31:0];
                    ch0_dma_key1 ==  {p0_sa[15:0],p0_da[47:32]};
                    ch0_dma_key2 ==  p0_sa[47:16];
                    ch1_dma_key0 ==  p1_da[31:0];
                    ch1_dma_key1 ==  {p1_sa[15:0],p1_da[47:32]};
                    ch1_dma_key2 ==  p1_sa[47:16];
                    ch2_dma_key0 ==  p2_da[31:0];
                    ch2_dma_key1 ==  {p2_sa[15:0],p2_da[47:32]};
                    ch2_dma_key2 ==  p2_sa[47:16];
                    ch3_dma_key0 ==  p3_da[31:0];
                    ch3_dma_key1 ==  {p3_sa[15:0],p3_da[47:32]};
                    ch3_dma_key2 ==  p3_sa[47:16];
                    ch4_dma_key0 ==  p4_da[31:0];
                    ch4_dma_key1 ==  {p4_sa[15:0],p4_da[47:32]};
                    ch4_dma_key2 ==  p4_sa[47:16];
                    ch5_dma_key0 ==  p5_da[31:0];
                    ch5_dma_key1 ==  {p5_sa[15:0],p5_da[47:32]};
                    ch5_dma_key2 ==  p5_sa[47:16];
                   }
                   )
      begin
        wait (ptp_cfg_seq.ptp_cfg_dma_done==1);
      end
      #100ns;      

    fork
      `uvm_do_with (cfg_csr_seq, {
                    ch_en == 6'h3F;
                   }
                   )
      begin
        wait (cfg_csr_seq.h2f_cfg_done==1);
      end
      `uvm_do_on_with (host_resp_seq, p_sequencer.slave_sequencer[0], {
                      ch0_max_desc == 3;
                      ch1_max_desc == 3;
                      ch2_max_desc == 3;
                      ch3_max_desc == 3;
                      ch4_max_desc == 3;
                      ch5_max_desc == 3;
                      ch_desc_length[0] == 512;
                      ch_desc_length[1] == 271;
                      ch_desc_length[2] == 1267;
                      ch_desc_length[3] == 967;
                      ch_desc_length[4] == 363;
                      ch_desc_length[5] == 123;
                      ch0_da == p0_da;
                      ch0_sa == p0_sa;
                      ch0_eth == p0_eth;     
                      ch1_da == p1_da;
                      ch1_sa == p1_sa;
                      ch1_eth == p1_eth;     
                      ch2_da == p2_da;
                      ch2_sa == p2_sa;
                      ch2_eth == p2_eth;     
                      ch3_da == p3_da;
                      ch3_sa == p3_sa;
                      ch3_eth == p3_eth;     
                      ch4_da == p4_da;
                      ch4_sa == p4_sa;
                      ch4_eth == p4_eth;     
                      ch5_da == p5_da;
                      ch5_sa == p5_sa;
                      ch5_eth == p5_eth;     
                      resp_time_in_ns == 100000;
                      }
                      )
     join

    `uvm_info(get_full_name(), "Body:ENDS in DATA PATH SEQ...", UVM_DEBUG) 

  endtask: body

endclass : fptp_dma_base_seq
