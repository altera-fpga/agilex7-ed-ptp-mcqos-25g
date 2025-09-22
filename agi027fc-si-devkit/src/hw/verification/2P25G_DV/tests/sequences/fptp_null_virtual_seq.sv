//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Null Virtual sequence developed for TB
//########################################################################
`ifndef FPTP_NULL_VIRTUAL_SEQ__SV
`define FPTP_NULL_VIRTUAL_SEQ__SV

class fptp_null_virtual_seq extends uvm_sequence;
  `uvm_object_utils(fptp_null_virtual_seq)
  
  function new(string name = "fptp_null_virtual_seq");
    super.new(name);
  endfunction: new

  virtual task body();
  endtask: body
endclass: fptp_null_virtual_seq

`endif // FPTP_NULL_VIRTUAL_SEQ__SV
