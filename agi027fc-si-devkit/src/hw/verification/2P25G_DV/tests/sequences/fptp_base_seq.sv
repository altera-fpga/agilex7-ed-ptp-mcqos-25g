//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Base seq which consists of API sequences for Write/Read transactions
//########################################################################
class fptp_base_seq extends uvm_sequence;
    `uvm_object_utils(fptp_base_seq)
    `uvm_declare_p_sequencer(svt_axi_system_sequencer)

   fptp_axi_master_base_seq mst_seq;


  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  function new(name = "fptp_base_seq");
    super.new(name);
  endfunction: new

  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  virtual task body();
    super.body();
  endtask: body


  // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task axi_master_write(
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0]        address,
    svt_axi_transaction::burst_size_enum     burst_sz,
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0]        data [],
    bit [`SVT_AXI_MAX_BURST_LENGTH_WIDTH:0]  burst_length,
    bit [`SVT_AXI_WSTRB_WIDTH-1:0]               wstrb []
  );

    //`uvm_create_on(mst_seq, p_sequencer)
    `uvm_create_on(mst_seq, p_sequencer.master_sequencer[0])

    if (!mst_seq.randomize() with {
            addr == address; // 'h100;
            xact_type == svt_axi_transaction::WRITE;
            burst_size == burst_sz; // svt_axi_transaction::BURST_SIZE_32BIT;
    }) `uvm_error(get_full_name(), "Randomization failure...")
    else begin
      mst_seq.burst_length = burst_length;
      mst_seq.data  = new[mst_seq.burst_length];
      mst_seq.wstrb = new[mst_seq.burst_length];
      foreach (mst_seq.data[i]) mst_seq.data[i] = data[i];
      foreach (mst_seq.wstrb[i]) mst_seq.wstrb[i] = wstrb[i];
      `uvm_info(get_full_name(),
                $sformatf(" mst_seq randomized with addr %0h\nxact_type %0s",
                            mst_seq.addr, mst_seq.xact_type),
                UVM_DEBUG)
      `uvm_info(get_full_name(), "Body: req is randomized", UVM_MEDIUM)
    end

    `uvm_send(mst_seq)
  endtask: axi_master_write

 // ----------------------------------------------------------------------
  // ----------------------------------------------------------------------
  task axi_master_read(
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0]        address,
    svt_axi_transaction::burst_size_enum     burst_sz,
    bit [`SVT_AXI_MAX_BURST_LENGTH_WIDTH:0]  burst_length,
    bit [31:0]                               wdata,   
    output bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] data []
  );

    //`uvm_create_on(mst_seq, p_sequencer)
    `uvm_create_on(mst_seq, p_sequencer.master_sequencer[0])

    if (!mst_seq.randomize() with {
            addr == address; // 'h100;
            xact_type == svt_axi_transaction::READ;
            burst_size == burst_sz; // svt_axi_transaction::BURST_SIZE_32BIT;
    }) `uvm_error(get_full_name(), "Randomization failure...")
    else begin
      mst_seq.burst_length = burst_length;
      `uvm_info(get_full_name(),
                $sformatf(" mst_seq randomized with addr %0h\nxact_type %0s",
                            mst_seq.addr, mst_seq.xact_type),
                UVM_DEBUG)
      `uvm_info(get_full_name(), "Body: req is randomized", UVM_DEBUG)
    end

    `uvm_send(mst_seq)

    $display($time, "wait for response object to be fetched");
    wait (mst_seq.rsp !== null);
    `uvm_info(get_full_name(),$sformatf(" print response object \n%s", mst_seq.rsp.sprint()), UVM_LOW)
    data = mst_seq.rsp.data;
  endtask: axi_master_read
endclass: fptp_base_seq

