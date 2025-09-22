//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#This is base sequence used to configure PKT CLIENTS,
//#TXDMA and RX DMA for basic data flow.
//########################################################################
class fptp_data_traffic_cfg_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned cfg_sequence_length = 10;

  `uvm_object_utils(fptp_data_traffic_cfg_seq);

  function new (string name = "fptp_data_traffic_cfg_seq");
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
    bit                                   h2f_cfg_done; 
    rand bit [5:0]                        ch_en;
    rand bit [1:0]                        usr_en;
    rand bit [31:0]                       usr_pkt;  

  constraint ch_en_c {
     soft ch_en == 0;
  }

  constraint usr_en_c {
     soft usr_en == 0;
  }

  constraint usr_pkt_c {
     soft usr_pkt == 'h3E8;
  }

  task body();
     super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];
    h2f_cfg_done = 0;

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    csr_wdata = 'h0;
    `uvm_info(get_full_name(), "Body:DESC CFG START...", UVM_DEBUG) 


    `uvm_info(get_full_name(), "Body: CFG PKT CLIENT0 STARTS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "PKTCLI0_CFG_DYN_PKT_NUM...", UVM_DEBUG)
    csr_wdata = 'hEEEEEEEE;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'hEEEE;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'hBBBBBBBB;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'hBBBB;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = usr_pkt; 
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    `uvm_info(get_full_name(), "PKTCLI0_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    csr_wdata[31:16] = 'd1500;
    csr_wdata[15:0] = 'd64;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI0_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "PKTCLI0_CFG_PKT_CL_CTRL...", UVM_DEBUG)
    csr_wdata[0] = 'h1;
    csr_wdata[3:1] = 'h0;
    csr_wdata[4] = 'h1;
    csr_wdata[5] = 'h1;
    csr_wdata[8:6] = 'h0;
    csr_wdata[9] = 'h1;
    csr_wdata[11:10] = 'h1;
    csr_wdata[19:12] = 'h8;
    data[0] = csr_wdata;
    if(usr_en[0]) begin
       data[0] = 32'h0000_8A31;
    end
    else begin
       data[0] = 32'h0000_8610;
    end
    axi_master_write(
            .address(PKTCLI0_CFG_PKT_CL_CTRL),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    `uvm_info(get_full_name(), "Body: CFG PKT CLIENT0 ENDS...", UVM_DEBUG)


    `uvm_info(get_full_name(), "Body: CFG PKT CLIENT1 STARTS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "PKTCLI1_CFG_DYN_PKT_NUM...", UVM_DEBUG)
    csr_wdata = 'h22222222;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_DMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'h2222;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_DMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'h11111111;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_SMAC_ADDR_L),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = 'h1111;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_SMAC_ADDR_U),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    csr_wdata = usr_pkt; 
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_PKT_NUM),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    `uvm_info(get_full_name(), "PKTCLI1_CFG_DYN_PKT_SIZE_CFG...", UVM_DEBUG)
    csr_wdata[31:16] = 'd1500;
    csr_wdata[15:0] = 'd64;
    data[0] = csr_wdata;
    axi_master_write(
            .address(PKTCLI1_DYN_PKT_SIZE_CFG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "PKTCLI1_CFG_PKT_CL_CTRL...", UVM_DEBUG)
    csr_wdata[0] = 'h1;
    csr_wdata[3:1] = 'h0;
    csr_wdata[4] = 'h1;
    csr_wdata[5] = 'h1;
    csr_wdata[8:6] = 'h0;
    csr_wdata[9] = 'h1;
    csr_wdata[11:10] = 'h1;
    csr_wdata[19:12] = 'h8;
    data[0] = csr_wdata;
    if(usr_en[1]) begin
       data[0] = 32'h0000_8631;
    end
    else begin
       data[0] = 32'h0000_8610;
    end
    axi_master_write(
            .address(PKTCLI1_CFG_PKT_CL_CTRL),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );

    `uvm_info(get_full_name(), "Body: CFG PKT CLIENT1 ENDS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG STARTS...", UVM_DEBUG)
    
   for (int i=0; i <6; i++)
   begin
     case (i)
     0 : begin
          csr_wdata = 'h14000000;
          addr = DMA_PORT0_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     1 : begin
          csr_wdata = 'h14800000;
          addr = DMA_PORT1_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     2 : begin
          csr_wdata = 'h15000000;
          addr = DMA_PORT2_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     3 : begin
          csr_wdata = 'h15800000;
          addr = DMA_PORT3_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     4 : begin
          csr_wdata = 'h16000000;
          addr = DMA_PORT4_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     5 : begin
          csr_wdata = 'h16800000;
          addr = DMA_PORT5_BASE_TXDMA_PREF_ADDR+'h4;
         end  
     endcase
     `uvm_info(get_full_name(), "PORT0 TX DMA CONFIG...", UVM_DEBUG)
     data[0] = csr_wdata;
     axi_master_write(
             .address(addr),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data),
             .burst_length(1),
             .wstrb(wstrb)
     );
   end
 
   for (int i=0; i <6; i++)
   begin
     case (i)
     0 : begin
          addr = DMA_PORT0_BASE_TXDMA_PREF_ADDR;
          if (ch_en[0]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     1 : begin
          addr = DMA_PORT1_BASE_TXDMA_PREF_ADDR;
          if (ch_en[1]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     2 : begin
          addr = DMA_PORT2_BASE_TXDMA_PREF_ADDR;
          if (ch_en[2]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     3 : begin
          addr = DMA_PORT3_BASE_TXDMA_PREF_ADDR;
          if (ch_en[3]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     4 : begin
          addr = DMA_PORT4_BASE_TXDMA_PREF_ADDR;
          if (ch_en[4]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     5 : begin
          addr = DMA_PORT5_BASE_TXDMA_PREF_ADDR;
          if (ch_en[5]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     endcase
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
   end

    `uvm_info(get_full_name(), "Body: TX DMA CHANNELS CFG ENDS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG STARTS...", UVM_DEBUG)

   for (int i=0; i <6; i++)
   begin
     case (i)
     0 : begin
          csr_wdata = 'h10000000;
          addr = DMA_PORT0_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     1 : begin
          csr_wdata = 'h10800000;
          addr = DMA_PORT1_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     2 : begin
          csr_wdata = 'h11000000;
          addr = DMA_PORT2_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     3 : begin
          csr_wdata = 'h11800000;
          addr = DMA_PORT3_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     4 : begin
          csr_wdata = 'h12000000;
          addr = DMA_PORT4_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     5 : begin
          csr_wdata = 'h12800000;
          addr = DMA_PORT5_BASE_RXDMA_PREF_ADDR+'h4;
         end  
     endcase
     `uvm_info(get_full_name(), "PORT0 RX DMA CONFIG...", UVM_DEBUG)
     data[0] = csr_wdata;
     axi_master_write(
             .address(addr),
             .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
             .data(data),
             .burst_length(1),
             .wstrb(wstrb)
     );
   end
 
   for (int i=0; i <6; i++)
   begin
      $display ("CHANNEL EN = %h", ch_en);
     case (i)
     0 : begin
          addr = DMA_PORT0_BASE_RXDMA_PREF_ADDR;
          if (ch_en[0]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     1 : begin
          addr = DMA_PORT1_BASE_RXDMA_PREF_ADDR;
          if (ch_en[1]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     2 : begin
          addr = DMA_PORT2_BASE_RXDMA_PREF_ADDR;
          if (ch_en[2]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     3 : begin
          addr = DMA_PORT3_BASE_RXDMA_PREF_ADDR;
          if (ch_en[3]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     4 : begin
          addr = DMA_PORT4_BASE_RXDMA_PREF_ADDR;
          if (ch_en[4]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     5 : begin
          addr = DMA_PORT5_BASE_RXDMA_PREF_ADDR;
          if (ch_en[5]==1) 
             csr_wdata = 'h1;
          else
             csr_wdata = 'h0;
         end  
     endcase
      data[0] = csr_wdata;
      axi_master_write(
              .address(addr),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
   end


    `uvm_info(get_full_name(), "Body: RX DMA CHANNELS CFG ENDS...", UVM_DEBUG)
    h2f_cfg_done = 1;
    `uvm_info(get_full_name(), "Body:TCAM, PKT CLI and DMA CHANNLELS  CFG DONE...", UVM_DEBUG) 
    `uvm_info(get_full_name(), "Body:ENDS...", UVM_DEBUG) 
  endtask: body
endclass : fptp_data_traffic_cfg_seq
