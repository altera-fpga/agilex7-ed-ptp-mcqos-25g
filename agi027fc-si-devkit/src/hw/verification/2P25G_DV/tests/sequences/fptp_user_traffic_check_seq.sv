//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Checks the Pkt client registers status for data integrity.
//########################################################################
class fptp_user_traffic_check_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned check_sequence_length = 10;

  `uvm_object_utils(fptp_user_traffic_check_seq);

  function new (string name = "fptp_user_traffic_check_seq");
    super.new(name);
  endfunction : new

    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]        wstrb [];
    bit [31:0]                            exp_data,obs_data,addr;
    bit [7:0]                             idle_cycle;   
    bit [1:0]                             mode_len;   
    bit                                   pkt_gap;   
    bit                                   pkt_chk_en;   
    bit                                   dyn_mode;   
    bit                                   traff_en;   
    bit [31:0]                            csr_wdata;   
    bit                                   h2f_check_done; 
    bit                                   pktcli0_start_check=0;
    bit                                   pktcli1_start_check=0;
    rand bit [31:0]                       pkt_cnt;
    bit [31:0]                            exp_cnt;

  task body();
     super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];
    h2f_check_done = 0;
    exp_cnt = pkt_cnt;
   

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    csr_wdata = 'h0;
    `uvm_info(get_full_name(), "Body:USER TRAFFIC CHECK START...", UVM_DEBUG) 
    `uvm_info(get_full_name(), " CHECK PKTCLIENT0 is enabled..", UVM_DEBUG)

    while (!data[0][0])
      begin
      #20ns;
      axi_master_read(
              .address(PKTCLI0_CFG_PKT_CL_CTRL),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][0]) begin
    `uvm_info(get_full_name(), "PKT CLIENT0 TRAFFIC IS ENABLED..", UVM_DEBUG)
     pktcli0_start_check = 1;
    end


    data[0] = 0;
    while (!data[0][0])
      begin
      #20ns;
      axi_master_read(
              .address(PKTCLI1_CFG_PKT_CL_CTRL),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][0]) begin
    `uvm_info(get_full_name(), "PKT CLIENT1 TRAFFIC IS ENABLED..", UVM_DEBUG)
     pktcli1_start_check = 1;
    end

    if (pktcli0_start_check)
    begin
       axi_master_read(
               .address(PKTCLI0_STAT_CHECKER_MISC),
               .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
               .burst_length(1),
               .wdata(exp_data),
               .data(data)
       );
       if (!data[0][0]) begin
       `uvm_info(get_full_name(), "PKT CLIENT0 CHECKER NO DATA MISMATCH SEEN ..", UVM_DEBUG)
       end
       else 
       begin
         `uvm_error("PKTCLIENT0", $sformatf(" PKT CLIENT0 CHECKER HAS DATA MISMATCH, DATA = `h%h ", data[0][0]));
       end 
    end

    if (pktcli1_start_check)
    begin
       axi_master_read(
               .address(PKTCLI1_STAT_CHECKER_MISC),
               .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
               .burst_length(1),
               .wdata(exp_data),
               .data(data)
       );
       if (!data[0][0]) begin
       `uvm_info(get_full_name(), "PKT CLIENT1 CHECKER NO DATA MISMATCH SEEN..", UVM_DEBUG)
       end
       else 
       begin
         `uvm_error("PKTCLIENT1", $sformatf(" PKT CLIENT1 CHECKER HAS DATA MISMATCH, DATA = `h%h ", data[0][0]));
       end 
    end
    `uvm_info(get_full_name(), "Body:ENDS...", UVM_DEBUG) 
  endtask: body
endclass : fptp_user_traffic_check_seq
