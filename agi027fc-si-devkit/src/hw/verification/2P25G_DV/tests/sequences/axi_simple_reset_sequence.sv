//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//#Simple Reset sequence used for TB
//########################################################################
`ifndef AXI_SIMPLE_RESET_SEQUENCE_SV
`define AXI_SIMPLE_RESET_SEQUENCE_SV

class axi_simple_reset_sequence extends uvm_sequence;

  /** UVM Object Utility macro */
  `uvm_object_utils(axi_simple_reset_sequence)

  /** Declare a typed sequencer object that the sequence can access */
  `uvm_declare_p_sequencer(fptp_reset_sequencer)

  /** Class Constructor */
  function new (string name = "axi_simple_reset_sequence");
    super.new(name);
  endfunction : new

  virtual task pre_body();
    uvm_phase starting_phase;

    `uvm_info(get_full_name(), "pre_body: enter get_Starting_phase", UVM_DEBUG)
    starting_phase = get_starting_phase();
    `uvm_info(get_full_name(), "pre_body: exit get_Starting_phase", UVM_DEBUG)
    `uvm_info(get_full_name(), "pre_body : starting phase is null", UVM_DEBUG)
  endtask
  
  virtual task body();
    //`uvm_info(get_full_name(),"body", "Entered...", UVM_LOW)

    //p_sequencer.reset_mp.reset <= 1'b1;

    repeat(10) @(posedge p_sequencer.reset_mp.clk);
    #2;
    p_sequencer.reset_mp.reset <= 1'b0;

    repeat(10) @(posedge p_sequencer.reset_mp.clk);
    p_sequencer.reset_mp.reset <= 1'b1;

    //`uvm_info(get_full_name(),"body", "Exiting...", UVM_LOW)
  endtask: body

  virtual task post_body();
    uvm_phase starting_phase;

    `uvm_info(get_full_name(), "post_body: enter get_Starting_phase", UVM_DEBUG)
    starting_phase = get_starting_phase();
    `uvm_info(get_full_name(), "post_body: exit get_Starting_phase", UVM_DEBUG)
    `uvm_info(get_full_name(), "post_body : starting phase is null", UVM_DEBUG)
  endtask
endclass: axi_simple_reset_sequence

`endif //AXI_SIMPLE_RESET_SEQUENCE_SV
