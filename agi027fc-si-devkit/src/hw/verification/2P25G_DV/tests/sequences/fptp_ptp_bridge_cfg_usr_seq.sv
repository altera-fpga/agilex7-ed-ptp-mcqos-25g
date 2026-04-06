//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Description: PTP Bridge TCAM configuration sequence for user
//#              (packet-client) traffic. Programs TCAM0 and TCAM1
//#              entries for the two user packet clients, including
//#              optional ingress arbitration priority configuration
//#              and MAC-address-based key, mask, and result register
//#              writes.
//# Purpose    : To set up the PTP Bridge TCAM rules that route user-
//#              traffic packets from Packet Client 0 and Packet Client
//#              1 to the correct ingress user ports after HSSI loopback.
//########################################################################
class fptp_ptp_bridge_cfg_usr_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned cfg_usr_sequence_length = 10;

  `uvm_object_utils(fptp_ptp_bridge_cfg_usr_seq);

  function new (string name = "fptp_ptp_bridge_cfg_usr_seq");
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
    bit                                   ptp_cfg_usr_done;

    rand bit                              usr_pri;
    rand bit [3:0]                        arb0_usr_pri;
    rand bit [3:0]                        arb1_usr_pri;
    rand bit [5:0]                        usr0_key_index;
    rand bit [5:0]                        usr1_key_index;
    rand bit [31:0]                       usr0_eth_key0;
    rand bit [31:0]                       usr0_eth_key1;
    rand bit [31:0]                       usr0_eth_key2;
    rand bit [31:0]                       usr1_eth_key0;
    rand bit [31:0]                       usr1_eth_key1;
    rand bit [31:0]                       usr1_eth_key2;
    rand bit [5:0]                        usr0_key_result;
    rand bit [5:0]                        usr1_key_result;

  constraint pri_c {
       soft usr_pri == 0;
  }

  constraint key_const_c {

     usr0_key_index == 7;
     usr1_key_index == 8;

     usr0_key_result == 8;
     usr1_key_result == 8;
     
     soft arb0_usr_pri == 1;
     soft arb1_usr_pri == 1;

     soft usr0_eth_key0 == 'hEEEEEEEE;
     soft usr0_eth_key1 == 'hBBBBEEEE;
     soft usr0_eth_key2 == 'hBBBBBBBB;

     soft usr1_eth_key0 == 'h22222222;
     soft usr1_eth_key1 == 'h11112222;
     soft usr1_eth_key2 == 'h11111111;
  }
 
  task body();
    super.body();    

    data = new[1];
    wstrb = new[1];

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    csr_wdata = 'h0;
    `uvm_info(get_full_name(), "Body:USR CFG START...", UVM_DEBUG) 


   if(usr_pri)  // Randomize the priority for ARB0 CHANNELS and ARB1 CHANNELS
   begin
      csr_wdata[3:0] = arb0_usr_pri;
      data[0] = csr_wdata;
      axi_master_write(
              .address(ING_ARB0_CFG_PRI_USR_REG),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );

      csr_wdata[3:0] = arb1_usr_pri;
      data[0] = csr_wdata;
      axi_master_write(
              .address(ING_ARB1_CFG_PRI_USR_REG),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
   end

   ///////////////////////////////////////////////
   // USER0 START
   ///////////////////////////////////////////////

   // TCAM Entry at 0030
   csr_wdata = usr0_key_index;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM0_BASE_ADDR +'h30),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
   // Configure TCAM Registers for PKT Routing on Ingress path
   // TCAM KEY ENTRY0 as DA address  lower key

   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = usr0_eth_key0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
     if (i==1) begin
        csr_wdata = usr0_eth_key1;
        data[0] = csr_wdata;
        axi_master_write(
                 .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data),
                 .burst_length(1),
                 .wstrb(wstrb)
         );
     end

     if (i==2) begin
       csr_wdata = usr0_eth_key2;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i < 16) begin
       csr_wdata = 'h0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
       end
     end



   // TCAM RESULT ENTRY0 as forward on DMA0
   csr_wdata = usr0_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM0_RESULT_BASE_ADDR),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
   );


   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = 'hFFFFFFFF;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
     if (i==1) begin
        // TCAM KEY ENTRY1 as DA upper address  lower key
        csr_wdata = 'hFFFFFFFF;
        data[0] = csr_wdata;
        axi_master_write(
                 .address(PTP_TCAM0_MASK_BASE_ADDR+i*4),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data),
                 .burst_length(1),
                 .wstrb(wstrb)
         );
     end

     if (i==2) begin
       csr_wdata = 'hFFFFFFFF;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i < 16) begin
       csr_wdata = 'h0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
       end
     end

   csr_wdata = 'h1;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM0_BASE_ADDR +'h20),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );



   ///////////////////////////////////////////////
   //Before entering KEY for DMA (2nd key) check the BUSY BIT 0 in MGMT CTRL
   ///////////////////////////////////////////////

    while (!data[0][8])
      begin
      #20ns;
      axi_master_read(
              .address(PTP_TCAM0_BASE_ADDR +'h20),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][8]) begin
    `uvm_info(get_full_name(), "INSERT KEY IS  SUCCESSFULL..", UVM_DEBUG)
    end

   ///////////////////////////////////////////////
   // USER0 END
   ///////////////////////////////////////////////


   ///////////////////////////////////////////////
   // USER1 START
   ///////////////////////////////////////////////

   // TCAM Entry at 0030
   csr_wdata = usr1_key_index;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM1_BASE_ADDR +'h30),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
   // Configure TCAM Registers for PKT Routing on Ingress path
   // TCAM KEY ENTRY0 as DA address  lower key

  // mem set data 16 bitreg -> 0
   

   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = usr1_eth_key0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
     if (i==1) begin
        // TCAM KEY ENTRY1 as DA upper address  lower key
        csr_wdata = usr1_eth_key1;
        data[0] = csr_wdata;
        axi_master_write(
                 .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data),
                 .burst_length(1),
                 .wstrb(wstrb)
         );
     end

     if (i==2) begin
       csr_wdata = usr1_eth_key2;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i < 16) begin
       csr_wdata = 'h0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
       end
     end



   // TCAM RESULT ENTRY forward on USR1 
   csr_wdata = usr1_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM1_RESULT_BASE_ADDR),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
   );


   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = 'hFFFFFFFF;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
     if (i==1) begin
        // TCAM KEY ENTRY1 as DA upper address  lower key
        csr_wdata = 'hFFFFFFFF;
        data[0] = csr_wdata;
        axi_master_write(
                 .address(PTP_TCAM1_MASK_BASE_ADDR+i*4),
                 .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                 .data(data),
                 .burst_length(1),
                 .wstrb(wstrb)
         );
     end

     if (i==2) begin
       csr_wdata = 'hFFFFFFFF;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i < 16) begin
       csr_wdata = 'h0;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_MASK_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
       end
     end

   csr_wdata = 'h1;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM1_BASE_ADDR +'h20),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );



   ///////////////////////////////////////////////
   //Before entering KEY for DMA (2nd key) check the BUSY BIT 0 in MGMT CTRL
   ///////////////////////////////////////////////

    while (!data[0][8])
      begin
      #20ns;
      axi_master_read(
              .address(PTP_TCAM1_BASE_ADDR +'h20),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][8]) begin
    `uvm_info(get_full_name(), "TCAM1 INSERT KEY IS  SUCCESSFULL..", UVM_DEBUG)
    end

   ///////////////////////////////////////////////
   // USER1 END
   ///////////////////////////////////////////////


    `uvm_info(get_full_name(), "Body:PTP CFG ENDS...", UVM_DEBUG) 
   ptp_cfg_usr_done = 1;
  endtask: body
endclass : fptp_ptp_bridge_cfg_usr_seq
