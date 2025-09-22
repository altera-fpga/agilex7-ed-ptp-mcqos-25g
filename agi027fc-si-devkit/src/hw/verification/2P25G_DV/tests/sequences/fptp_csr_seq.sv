//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# CSR sequences to check default values on MSGDMA, PTP Bridge, TCAM,
//# PKT CLI0, PKT CLI1 and HSSI Registers.
//# Also does Write/Read on R/w Registers
//########################################################################
class fptp_csr_seq extends fptp_base_seq;
    

  `uvm_object_utils(fptp_csr_seq);

  /** Declare a typed sequencer object that the sequence can access */
  //`uvm_declare_p_sequencer(fptp_vir_seqr)

  function new (string name = "fptp_csr_seq");
    super.new(name);
  endfunction : new

  virtual task body();
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]     data [];
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]            wstrb [];
    bit [31:0]                            exp_data;

    `uvm_info(get_full_name(), "Body: Entered...", UVM_DEBUG)

    data = new[1];
    wstrb = new[1];

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    wstrb[0] = 'hf;
    

    ////////////////// PORT0 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT0...", UVM_DEBUG)
    
    for (int j=0;j<8;j++)
    begin 
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT0_BASE_ADDR+j*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT0",DMA_PORT0_BASE_ADDR+j*4);
    end
    `uvm_info(get_full_name(), "Body: DMA PORT0 ENDS...", UVM_DEBUG)
    ////////////////// PORT0 ENDS /////////////////////////////////
    ////////////////// PORT1 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT1...", UVM_DEBUG)

    for (int l=0; l<8;l++)
    begin 
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT1_BASE_ADDR+l*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT1",DMA_PORT1_BASE_ADDR+l*4);
    end
    `uvm_info(get_full_name(), "Body: DMA PORT1 ENDS...", UVM_DEBUG)
    ////////////////// PORT1 ENDS /////////////////////////////////

    ////////////////// PORT2 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT2...", UVM_DEBUG)
    for (int m=0; m<8;m++)
    begin
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT2_BASE_ADDR+m*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT2",DMA_PORT2_BASE_ADDR+m*4);
    end 
    `uvm_info(get_full_name(), "Body: DMA PORT2 ENDS...", UVM_DEBUG)
    ////////////////// PORT2 ENDS /////////////////////////////////
    ////////////////// PORT3 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT3...", UVM_DEBUG)
    for (int n=0; n<8;n++)
    begin
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT3_BASE_ADDR+n*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT3",DMA_PORT3_BASE_ADDR+n*4);
    end
    `uvm_info(get_full_name(), "Body: DMA PORT3 ENDS...", UVM_DEBUG)
    ////////////////// PORT3 ENDS /////////////////////////////////
    ////////////////// PORT4 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT4...", UVM_DEBUG)
    for (int o=0; o<8;o++)
    begin
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT4_BASE_ADDR+o*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT4",DMA_PORT4_BASE_ADDR+o*4);
    end
    `uvm_info(get_full_name(), "Body: DMA PORT4 ENDS...", UVM_DEBUG)
    ////////////////// PORT4 ENDS /////////////////////////////////
    ////////////////// PORT5 STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: DMA PORT5...", UVM_DEBUG)
    for (int p=0; p<8;p++)
    begin
      exp_data = 32'h0;
      axi_master_read(
              .address(DMA_PORT5_BASE_ADDR+p*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"DMA PORT5",DMA_PORT5_BASE_ADDR+p*4);
    end
    `uvm_info(get_full_name(), "Body: DMA PORT5 ENDS...", UVM_DEBUG)
    ////////////////// PORT5 ENDS /////////////////////////////////
    ////////////////// PTP BRIDGE STARTS /////////////////////////////////
    `uvm_info(get_full_name(), "Body: PTP BRIDGE...", UVM_DEBUG)
     `uvm_info(get_name(), "ING_ARB0_SCRATCH__REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_ARB0_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_SCRATCH__REG);
    `uvm_info(get_name(), "ING_ARB0_CFG_PRI_DMA_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h320;
    axi_master_read(
            .address(ING_ARB0_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_CFG_PRI_DMA_REG);
    `uvm_info(get_name(), "ING_ARB0_CFG_PRI_USR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1;
    axi_master_read(
            .address(ING_ARB0_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_CFG_PRI_USR_REG);
     `uvm_info(get_name(), "ING_ARB1_SCRATCH__REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_ARB1_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_SCRATCH__REG);
    `uvm_info(get_name(), "ING_ARB1_CFG_PRI_DMA_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h320;
    axi_master_read(
            .address(ING_ARB1_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_CFG_PRI_DMA_REG);
    `uvm_info(get_name(), "ING_ARB1_CFG_PRI_USR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1;
    axi_master_read(
            .address(ING_ARB1_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_CFG_PRI_USR_REG);

    `uvm_info(get_name(), "ING_ARB1_RSVD0 at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_ARB1_RSVD0),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD0);
    `uvm_info(get_name(), "ING_ARB1_RSVD1 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD1),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD1);
    `uvm_info(get_name(), "ING_ARB1_RSVD2 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD2),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD2);
    `uvm_info(get_name(), "ING_ARB1_RSVD3 at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_ARB1_RSVD3),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD3);
    `uvm_info(get_name(), "ING_ARB1_RSVD4 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD4),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD4);
    `uvm_info(get_name(), "ING_ARB1_RSVD5 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD5),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD5);
    `uvm_info(get_name(), "ING_ARB1_RSVD6 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD6),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD6);
    `uvm_info(get_name(), "ING_ARB1_RSVD7 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD7),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD7);
    `uvm_info(get_name(), "ING_ARB1_RSVD8 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD8),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD8);
    `uvm_info(get_name(), "ING_ARB1_RSVD9 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD9),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD9);

    `uvm_info(get_name(), "ING_ARB1_RSVD10 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD10),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD10);
    `uvm_info(get_name(), "ING_ARB1_RSVD11 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD11),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD11);
    `uvm_info(get_name(), "ING_ARB1_RSVD12 at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_ARB1_RSVD12),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD12);
    `uvm_info(get_name(), "ING_ARB1_RSVD13 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD13),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD13);
    `uvm_info(get_name(), "ING_ARB1_RSVD14 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD14),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD14);
    `uvm_info(get_name(), "ING_ARB1_RSVD15 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD15),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD15);
    `uvm_info(get_name(), "ING_ARB1_RSVD16 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD16),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD16);
    `uvm_info(get_name(), "ING_ARB1_RSVD17 at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(ING_ARB1_RSVD17),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_RSVD17);

    exp_data = 32'h0;
    `uvm_info(get_name(), "EGR_RXDM0_SCRATCH_REG at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(EGR_RXDM0_SCRATCH_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_SCRATCH_REG);
    `uvm_info(get_name(), "EGR_RXDM0_CONTROL_REG at 0x0 ", UVM_LOW)  
    axi_master_read(
            .address(EGR_RXDM0_CONTROL_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_CONTROL_REG);
    `uvm_info(get_name(), "EGR_RXDM0_DMA0_DROP_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1F0;
    axi_master_read(
            .address(EGR_RXDM0_DMA0_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA0_DROP_THR_REG);
    `uvm_info(get_name(), "EGR_RXDM0_DMA1_DROP_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1F0;
    axi_master_read(
            .address(EGR_RXDM0_DMA1_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA1_DROP_THR_REG);

    `uvm_info(get_name(), "EGR_RXDM0_DMA2_DROP_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1F0;
    axi_master_read(
            .address(EGR_RXDM0_DMA2_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA2_DROP_THR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP0_SCR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP0_SCR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP0_CTR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP0_CTR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP0_CFG_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h079C0400;
    axi_master_read(
            .address(ING_RX_WID_ADP0_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP0_CFG_THR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_SCR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_SCR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_CTR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(ING_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_CTR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_CFG_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h079C0400;
    axi_master_read(
            .address(ING_RX_WID_ADP1_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_CFG_THR_REG);

    `uvm_info(get_name(), "EGR_RX_WID_ADP0_SCR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(EGR_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_SCR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP0_CTR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(EGR_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_CTR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP0_CFG_DRP_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1F0;
    axi_master_read(
            .address(EGR_RX_WID_ADP0_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_CFG_DRP_THR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_SCR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(EGR_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP1_SCR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_CTR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h0;
    axi_master_read(
            .address(EGR_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP1_CTR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_CFG_DRP_THR_REG at 0x0 ", UVM_LOW)  
    exp_data = 32'h1F0;
    axi_master_read(
            .address(EGR_RX_WID_ADP1_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP1_CFG_DRP_THR_REG);

   //////////////////////////////////////////////////////
    `uvm_info(get_full_name(), "Body: PKT CLI0 STARTS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "PKTCLI0_CFG_PKT_CL_CTRL...", UVM_DEBUG)
    for (int k=0; k<32;k++)
    begin
      case(k)
      0    : begin
               exp_data = 32'h0;
             end 
      1,2  : begin
               exp_data = 32'hdeadc0de;
             end 
      3   : begin
               exp_data = 32'h1234;
             end
      4   : begin
               exp_data = 32'h56780ADD;
            end
      5   : begin
               exp_data = 32'h8765;
            end
      6   : begin
               exp_data = 32'h43210ADD;
            end
      7   : begin
               exp_data = 32'hA;
            end
      8   : begin
               exp_data = 32'h25800040;
            end
      21   : begin
               exp_data = 32'h0000001E;
            end
      default : begin
                  exp_data = 32'h0;
                end
      endcase 
      axi_master_read(
              .address(PKTCLI0_CFG_PKT_CL_CTRL+k*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"PKT CLI0",PKTCLI0_CFG_PKT_CL_CTRL+k*4);
    end
    `uvm_info(get_full_name(), "Body: PKT CLI0 ENDS...", UVM_DEBUG)


   //////////////////////////////////////////////////////
    `uvm_info(get_full_name(), "Body: PKT CLI1 STARTS...", UVM_DEBUG)
    `uvm_info(get_full_name(), "PKTCLI1_CFG_PKT_CL_CTRL...", UVM_DEBUG)
    for (int a=0; a<32; a++)
    begin
      case(a)
      0    : begin
               exp_data = 32'h0;
             end 
      1,2  : begin
               exp_data = 32'hdeadc0de;
             end 
      3   : begin
               exp_data = 32'h1234;
            end
      4   : begin
               exp_data = 32'h56780ADD;
            end
      5   : begin
               exp_data = 32'h8765;
            end
      6   : begin
               exp_data = 32'h43210ADD;
            end
      7   : begin
               exp_data = 32'hA;
            end
      8   : begin
               exp_data = 32'h25800040;
            end
      21   : begin
               exp_data = 32'h0000001E;
            end
      default : begin
                  exp_data = 32'h0;
                end
      endcase 
      axi_master_read(
              .address(PKTCLI1_CFG_PKT_CL_CTRL+a*4),
              .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
              .burst_length(1),
              .wdata(exp_data),
              .data(data)
      );
      check(exp_data,data[0][31:0],"PKT CLI1",PKTCLI1_CFG_PKT_CL_CTRL+a*4);
    end
    `uvm_info(get_full_name(), "Body: PKT CLI1 ENDS...", UVM_DEBUG)

    `uvm_info(get_full_name(), "Body: HSSI...", UVM_DEBUG)
    `uvm_info(get_full_name(), "HSSI_DEV_FEAT_HDR_LO...", UVM_DEBUG)
    exp_data = 32'h10003015;
    axi_master_read(
            .address(HSSI_DEV_FEAT_HDR_LO),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_DEV_FEAT_HDR_LO);
    `uvm_info(get_full_name(), "HSSI_DEV_FEAT_HDR_HI...", UVM_DEBUG)
    exp_data = 32'h30000000;
    axi_master_read(
            .address(HSSI_DEV_FEAT_HDR_HI),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_DEV_FEAT_HDR_HI);
    `uvm_info(get_full_name(), "HSSI_FEAT_GUID_L_LSB..", UVM_DEBUG)
    exp_data = 32'h18418B9D;
    axi_master_read(
            .address(HSSI_FEAT_GUID_L_LSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_GUID_L_LSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_GUID_L_MSB..", UVM_DEBUG)
    exp_data = 32'h99a078AD;
    axi_master_read(
            .address(HSSI_FEAT_GUID_L_MSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_GUID_L_MSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_GUID_H_LSB..", UVM_DEBUG)
    exp_data = 32'hd9db4a9b;
    axi_master_read(
            .address(HSSI_FEAT_GUID_H_LSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_GUID_H_LSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_GUID_H_MSB..", UVM_DEBUG)
    exp_data = 32'h4118a7cb;
    axi_master_read(
            .address(HSSI_FEAT_GUID_H_MSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_GUID_H_MSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_CSR_ADDR_LSB..", UVM_DEBUG)
    exp_data = 32'hc0;
    axi_master_read(
            .address(HSSI_FEAT_CSR_ADDR_LSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_CSR_ADDR_LSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_CSR_ADDR_MSB..", UVM_DEBUG)
    exp_data = 32'h0;
    axi_master_read(
            .address(HSSI_FEAT_CSR_ADDR_MSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_CSR_ADDR_MSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_CSR_ADDR_SG_LSB..", UVM_DEBUG)
    exp_data = 32'h0;
    axi_master_read(
            .address(HSSI_FEAT_CSR_ADDR_SG_LSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_CSR_ADDR_SG_LSB);
    `uvm_info(get_full_name(), "HSSI_FEAT_CSR_ADDR_SG_MSB..", UVM_DEBUG)
    exp_data = 32'h31C;
    axi_master_read(
            .address(HSSI_FEAT_CSR_ADDR_SG_MSB),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"HSSI",HSSI_FEAT_CSR_ADDR_SG_MSB);
    `uvm_info(get_full_name(), "Body: HSSI Exiting...", UVM_DEBUG)

    `uvm_info(get_full_name(), "Body: TCAM0 Starts...", UVM_DEBUG)
    exp_data = 32'h1;
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR);
    exp_data = 32'h0;
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR+'h4),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR+'h4);
    exp_data = 32'h00020000;
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR+'h8),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR+'h8);
    exp_data = 32'h0;
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR+'hC),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR+'hC);
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR+'h10),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR+'h10);
    axi_master_read(
            .address(PTP_TCAM0_BASE_ADDR+'h14),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM0",PTP_TCAM0_BASE_ADDR+'h14);
    `uvm_info(get_full_name(), "Body: TCAM0 Exiting...", UVM_DEBUG)

    `uvm_info(get_full_name(), "Body: TCAM1 Starts...", UVM_DEBUG)
    exp_data = 32'h1;
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR);
    exp_data = 32'h0;
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR+'h4),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR+'h4);
    exp_data = 32'h00020000;
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR+'h8),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR+'h8);
    exp_data = 32'h0;
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR+'hC),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR+'hC);
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR+'h10),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR+'h10);
    axi_master_read(
            .address(PTP_TCAM1_BASE_ADDR+'h14),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"TCAM1",PTP_TCAM1_BASE_ADDR+'h14);
    `uvm_info(get_full_name(), "Body: TCAM0 Exiting...", UVM_DEBUG)

    // R/W to all feasible registers

    data[0] = 256'h0000_0000_beed_babe_0000_0000_deed_beed;
    `uvm_info(get_full_name(), "Body: PTP R/W BRIDGE...", UVM_DEBUG)
     `uvm_info(get_name(), "ING_ARB0_SCRATCH__REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB0_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_ARB0_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_SCRATCH__REG);

    `uvm_info(get_name(), "ING_ARB0_CFG_PRI_DMA_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB0_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][11:0];
    axi_master_read(
            .address(ING_ARB0_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_CFG_PRI_DMA_REG);

    `uvm_info(get_name(), "ING_ARB0_CFG_PRI_USR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB0_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][3:0];
    axi_master_read(
            .address(ING_ARB0_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB0_CFG_PRI_USR_REG);

     `uvm_info(get_name(), "ING_ARB1_SCRATCH__REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB1_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_ARB1_SCRATCH__REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_SCRATCH__REG);

    `uvm_info(get_name(), "ING_ARB1_CFG_PRI_DMA_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB1_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_ARB1_CFG_PRI_DMA_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_CFG_PRI_DMA_REG);

    `uvm_info(get_name(), "ING_ARB1_CFG_PRI_USR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_ARB1_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_ARB1_CFG_PRI_USR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_ARB1_CFG_PRI_USR_REG);
    ///////////////////////////////////
    `uvm_info(get_name(), "EGR_RXDM0_SCRATCH_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RXDM0_SCRATCH_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RXDM0_SCRATCH_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_SCRATCH_REG);

    `uvm_info(get_name(), "EGR_RXDM0_CONTROL_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RXDM0_CONTROL_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][2:0];
    axi_master_read(
            .address(EGR_RXDM0_CONTROL_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_CONTROL_REG);
    `uvm_info(get_name(), "EGR_RXDM0_DMA0_DROP_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RXDM0_DMA0_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RXDM0_DMA0_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA0_DROP_THR_REG);
    `uvm_info(get_name(), "EGR_RXDM0_DMA1_DROP_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RXDM0_DMA1_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RXDM0_DMA1_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA1_DROP_THR_REG);
    `uvm_info(get_name(), "EGR_RXDM0_DMA2_DROP_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RXDM0_DMA2_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RXDM0_DMA2_DROP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RXDM0_DMA2_DROP_THR_REG);
    /////////////////////////////////////
    `uvm_info(get_name(), "ING_RX_WID_ADP0_SCR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP0_SCR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP0_CTR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][0];
    axi_master_read(
            .address(ING_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][0],"PTP BRIDGE",ING_RX_WID_ADP0_CTR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP0_CFG_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP0_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_RX_WID_ADP0_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP0_CFG_THR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_SCR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_SCR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_CTR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_CTR_REG);
    `uvm_info(get_name(), "ING_RX_WID_ADP1_CFG_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(ING_RX_WID_ADP1_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(ING_RX_WID_ADP1_CFG_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",ING_RX_WID_ADP1_CFG_THR_REG);

    `uvm_info(get_name(), "EGR_RX_WID_ADP0_SCR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RX_WID_ADP0_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_SCR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP0_CTR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RX_WID_ADP0_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_CTR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP0_CFG_DRP_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP0_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RX_WID_ADP0_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP0_CFG_DRP_THR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_SCR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RX_WID_ADP1_SCR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP1_SCR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_CTR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][31:0];
    axi_master_read(
            .address(EGR_RX_WID_ADP1_CTR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
    );
    check(exp_data,data[0][31:0],"PTP BRIDGE",EGR_RX_WID_ADP1_CTR_REG);
    `uvm_info(get_name(), "EGR_RX_WID_ADP1_CFG_DRP_THR_REG at 0x0 ", UVM_LOW)  
    axi_master_write(
            .address(EGR_RX_WID_ADP1_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .data(data),
            .burst_length(1),
            .wstrb(wstrb)
    );
    exp_data = data[0][0];
    axi_master_read(
            .address(EGR_RX_WID_ADP1_CFG_DRP_THR_REG),
            .burst_sz(svt_axi_transaction::BURST_SIZE_32BIT),
            .burst_length(1),
            .wdata(exp_data),
            .data(data)
   );
    check(exp_data,data[0][0],"PTP BRIDGE",EGR_RX_WID_ADP1_CFG_DRP_THR_REG);

    `uvm_info(get_full_name(), "Body: PTP R/W BRIDGE ENDS...", UVM_DEBUG) 
  endtask: body

   task check(bit[31:0] exp_data, bit[31:0] obs_data, string REG, bit[31:0] REGADDR);
    if (exp_data==obs_data) begin
      `uvm_info(get_full_name(), $sformatf(" REG BLOCK = %s,REG ADDR= `h%h,EXP_DATA = 'h%h, OBS_DATA = 'h%h",REG,REGADDR,exp_data,obs_data), UVM_DEBUG)
    end
    //else 
    if (exp_data!=obs_data) begin
      `uvm_error("get_full_name()", $sformatf(" REG BLOCK =%s, REG ADDR= `h%h, DATA MISMATCH SEEN, OBS_DATA = `h%h, EXP_DATA = `h%h ", REG,REGADDR,obs_data,exp_data ));
    end
   endtask

endclass : fptp_csr_seq
