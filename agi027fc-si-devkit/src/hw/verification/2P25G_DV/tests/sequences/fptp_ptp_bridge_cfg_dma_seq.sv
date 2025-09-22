//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Basic DMA seq for configuring TCAM Rules (TCAM0 and TCAM1) for packets being sent.
//########################################################################
class fptp_ptp_bridge_cfg_dma_seq extends fptp_base_seq;
    
  rand int no_of_transactions ;
  rand int unsigned cfg_dma_sequence_length = 10;

  `uvm_object_utils(fptp_ptp_bridge_cfg_dma_seq);

  function new (string name = "fptp_ptp_bridge_cfg_dma_seq");
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
    bit                                   ptp_cfg_dma_done;

    rand bit                              dma_pri;

    rand bit [3:0]                        arb0_ch0_pri;
    rand bit [3:0]                        arb0_ch1_pri;
    rand bit [3:0]                        arb0_ch2_pri;

    rand bit [3:0]                        arb1_ch0_pri;
    rand bit [3:0]                        arb1_ch1_pri;
    rand bit [3:0]                        arb1_ch2_pri;


    rand bit [31:0]                       ch0_dma_key0;
    rand bit [31:0]                       ch0_dma_key1;
    rand bit [31:0]                       ch0_dma_key2;
    rand bit [31:0]                       ch1_dma_key0;
    rand bit [31:0]                       ch1_dma_key1;
    rand bit [31:0]                       ch1_dma_key2;
    rand bit [31:0]                       ch2_dma_key0;
    rand bit [31:0]                       ch2_dma_key1;
    rand bit [31:0]                       ch2_dma_key2;
    rand bit [31:0]                       ch3_dma_key0;
    rand bit [31:0]                       ch3_dma_key1;
    rand bit [31:0]                       ch3_dma_key2;
    rand bit [31:0]                       ch4_dma_key0;
    rand bit [31:0]                       ch4_dma_key1;
    rand bit [31:0]                       ch4_dma_key2;
    rand bit [31:0]                       ch5_dma_key0;
    rand bit [31:0]                       ch5_dma_key1;
    rand bit [31:0]                       ch5_dma_key2;
    rand bit [5:0]                        ch0_key_index;
    rand bit [5:0]                        ch1_key_index;
    rand bit [5:0]                        ch2_key_index;
    rand bit [5:0]                        ch3_key_index;
    rand bit [5:0]                        ch4_key_index;
    rand bit [5:0]                        ch5_key_index;
    rand bit [5:0]                        ch0_key_result;
    rand bit [5:0]                        ch1_key_result;
    rand bit [5:0]                        ch2_key_result;
    rand bit [5:0]                        ch3_key_result;
    rand bit [5:0]                        ch4_key_result;
    rand bit [5:0]                        ch5_key_result;

  constraint pri_c {
       soft dma_pri == 0;
  }

  constraint key_const_c {

     soft ch0_dma_key0 == 'h11111111;
     soft ch0_dma_key1 == 'h22222222;
     soft ch0_dma_key2 == 'h33333333;

     soft ch1_dma_key0 == 'h44444444;
     soft ch1_dma_key1 == 'h55555555;
     soft ch1_dma_key2 == 'h66666666;

     soft ch2_dma_key0 == 'h77777777;
     soft ch2_dma_key1 == 'h88888888;
     soft ch2_dma_key2 == 'h99999999;

     soft ch3_dma_key0 == 'h10101010;
     soft ch3_dma_key1 == 'h20202020;
     soft ch3_dma_key2 == 'h30303030;

     soft ch4_dma_key0 == 'h40404040;
     soft ch4_dma_key1 == 'h50505050;
     soft ch4_dma_key2 == 'h60606060;

     soft ch5_dma_key0 == 'h70707070;
     soft ch5_dma_key1 == 'h80808080;
     soft ch5_dma_key2 == 'h90909090;

     soft ch0_key_index == 10;
     soft ch1_key_index == 11;
     soft ch2_key_index == 12;
     soft ch3_key_index == 13;
     soft ch4_key_index == 14;
     soft ch5_key_index == 15;

     soft ch0_key_result == 0;
     soft ch1_key_result == 1;
     soft ch2_key_result == 2;
     soft ch3_key_result == 0;
     soft ch4_key_result == 1;
     soft ch5_key_result == 2;

  }


  constraint arb0_dma_pri_c {
       soft arb0_ch0_pri == 0;
       soft arb0_ch1_pri == 2;
       soft arb0_ch2_pri == 3;
  }

  constraint arb1_dma_pri_c {
       soft arb1_ch0_pri == 0;
       soft arb1_ch1_pri == 2;
       soft arb1_ch2_pri == 3;
  }

  task body();
     super.body();

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];
    ptp_cfg_dma_done = 0;

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    csr_wdata = 'h0;

    `uvm_info(get_full_name(), "Body:CHECK PCS READY FOR HSSI PORTS...", UVM_DEBUG) 

    #100ns;
    while (!data[0][4])
      begin
      #30ns;
      axi_master_read(
              .address(PKTCLI0_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI0 PCS READY IS ASSERTED SUCCESSFULLY..", UVM_DEBUG)
    end

    #100ns;
    while (!data[0][4])
      begin
      #30ns;
      axi_master_read(
              .address(PKTCLI1_STAT_SYSTEM_MISC),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
    end
    if (data[0][4]) begin
       `uvm_info(get_full_name(), " HSSI1 PCS READY IS ASSERTED SUCCESSFULLY..", UVM_DEBUG)
    end

    `uvm_info(get_full_name(), "Body:PTP CFG START...", UVM_DEBUG) 

   // CFG PRIORITY DMA 
   if(dma_pri)  // Randomize the priority for ARB0 CHANNELS and ARB1 CHANNELS
   begin
      csr_wdata[3:0] = arb0_ch0_pri;
      csr_wdata[7:4] = arb0_ch1_pri;
      csr_wdata[11:8] = arb0_ch2_pri;
      data[0] = csr_wdata;
      axi_master_write(
              .address(ING_ARB0_CFG_PRI_DMA_REG),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );


      csr_wdata[3:0] = arb1_ch0_pri;
      csr_wdata[7:4] = arb1_ch1_pri;
      csr_wdata[11:8] = arb1_ch2_pri;
      data[0] = csr_wdata;
      axi_master_write(
              .address(ING_ARB1_CFG_PRI_DMA_REG),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .data(data),
              .burst_length(1),
              .wstrb(wstrb)
      );
   end

   ///////////////////////////////////////////////
   //  DMA START P0
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch0_key_index;
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
       csr_wdata = ch0_dma_key0;
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
        csr_wdata = ch0_dma_key1;
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
       csr_wdata = ch0_dma_key2;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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


   // TCAM RESULT ENTRY forward on DMA0
   csr_wdata = ch0_key_result;
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

    #100ns;
    while (!data[0][8])
      begin
      #30ns;
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
   //  DMA END 
   ///////////////////////////////////////////////


   ///////////////////////////////////////////////
   //  DMA START P1
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch1_key_index;
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
       csr_wdata = ch1_dma_key0;
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
        csr_wdata = ch1_dma_key1;
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
       csr_wdata = ch1_dma_key2;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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

   // TCAM RESULT ENTRY forward on DMA1
   csr_wdata = ch1_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM0_RESULT_BASE_ADDR+'h8),
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

    #100ns;
    while (!data[0][8])
      begin
      #30ns;
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
   //  DMA END 
   ///////////////////////////////////////////////

   ///////////////////////////////////////////////
   //  DMA START P2
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch2_key_index;
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
       csr_wdata = ch2_dma_key0;
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
        csr_wdata = ch2_dma_key1;
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
       csr_wdata = ch2_dma_key2;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM0_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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



   // TCAM RESULT ENTRY forward on DMA0
   csr_wdata = ch2_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM0_RESULT_BASE_ADDR+'h10),
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

    #100ns;

    //exp_data = 32'h000;
    while (!data[0][8])
      begin
      #30ns;
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
   //  DMA END 
   ///////////////////////////////////////////////

   /////////////////////////////////////////////////////
   ///////////////////////////////////////////////
   //  DMA START P3
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch3_key_index;
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
       csr_wdata = ch3_dma_key0;
       //csr_wdata = 'h33333333;
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
        //csr_wdata = 'h66663333;
        csr_wdata = ch3_dma_key1;
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
       csr_wdata = ch3_dma_key2;
       //csr_wdata = 'h66666666;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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



   // TCAM RESULT ENTRY forward on DMA3
   csr_wdata = ch3_key_result;
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

    #100ns;

    //exp_data = 32'h000;
    while (!data[0][8])
      begin
      #30ns;
      axi_master_read(
              .address(PTP_TCAM1_BASE_ADDR +'h20),
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
   //  DMA END 
   ///////////////////////////////////////////////


   ///////////////////////////////////////////////
   //  DMA START P1
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch4_key_index;
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

   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = ch4_dma_key0;
       //csr_wdata = 'h44444444;
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
        csr_wdata = ch4_dma_key1;
        //csr_wdata = 'h77774444;
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
       csr_wdata = ch4_dma_key2;
       //csr_wdata = 'h77777777;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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



   // TCAM RESULT ENTRY forward on DMA4
   csr_wdata = ch4_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM1_RESULT_BASE_ADDR+'h8),
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

    #100ns;

    while (!data[0][8])
      begin
      #30ns;
      axi_master_read(
              .address(PTP_TCAM1_BASE_ADDR +'h20),
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
   //  DMA END 
   ///////////////////////////////////////////////

   ///////////////////////////////////////////////
   //  DMA START P2
   ///////////////////////////////////////////////

   //////////////////////////////////////////////////////
   // TCAM Entry at 0030
   csr_wdata = ch5_key_index;
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

   for (int i=0; i <16; i++)
   begin
     if (i==0) begin
       csr_wdata = ch5_dma_key0;
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
        csr_wdata = ch5_dma_key1;
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
       csr_wdata = ch5_dma_key2;
       //csr_wdata = 'h88888888;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+i*4),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
      end
      if ( i >=3 && i <= 12) begin
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
       if (i==13) begin
       csr_wdata = 'h00000800;
       data[0] = csr_wdata;
       axi_master_write(
                .address(PTP_TCAM1_KEY_BASE_ADDR+'h34),
                .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
                .data(data),
                .burst_length(1),
                .wstrb(wstrb)
        );
        end
       if ( i >=14 && i < 16) begin
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



   // TCAM RESULT ENTRY forward on DMA5
   csr_wdata = ch5_key_result;
   data[0] = csr_wdata;
   axi_master_write(
            .address(PTP_TCAM1_RESULT_BASE_ADDR+'h10),
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

    #100ns;

    while (!data[0][8])
      begin
      #30ns;
      axi_master_read(
              .address(PTP_TCAM1_BASE_ADDR +'h20),
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
   //  DMA END 
   ///////////////////////////////////////////////

    `uvm_info(get_full_name(), "Body:PTP CFG ENDS...", UVM_DEBUG) 
   ptp_cfg_dma_done = 1;
  endtask: body
endclass : fptp_ptp_bridge_cfg_dma_seq
