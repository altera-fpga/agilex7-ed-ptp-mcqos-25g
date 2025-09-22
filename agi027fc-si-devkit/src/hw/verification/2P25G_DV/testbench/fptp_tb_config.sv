//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# FPTP TB Config
//########################################################################

`ifndef FPTP_TB_CONFIG_SVH
`define FPTP_TB_CONFIG_SVH

class fptp_tb_config extends uvm_object;

    `uvm_object_utils(fptp_tb_config)
    bit     dest_p0,dest_p1,dest_p2;
    bit     PO_P1_P2_DEST_P1;

    function new(string name = "fptp_tb_config");
        super.new(name);
    endfunction : new

endclass : fptp_tb_config

`endif // FPTP_TB_CONFIG_SVH

