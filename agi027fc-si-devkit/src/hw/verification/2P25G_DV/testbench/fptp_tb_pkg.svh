//######################################################################### 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//#########################################################################
//# Containts all TB Files in TB PKG
//#########################################################################

`ifndef FPTP_TB_PKG_SVH
`define FPTP_TB_PKG_SVH

    `include "uvm_pkg.sv"
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import svt_uvm_pkg::*;
    import svt_axi_uvm_pkg::*;

    `define NUM_MASTERS 1
    `define NUM_SLAVES  1


  `include "svt_axi.uvm.pkg"
  `include "svt_axi_system_configuration.uvm.pkg"
  import svt_uvm_pkg::*;
  import svt_axi_uvm_pkg::*;
  import svt_axi_system_configuration_uvm_pkg::*;
  `include "svt_axi_master_if.svi"
  `include "svt_axi_if.svi"
  `include "svt_axi_master_sequencer.svp"
    `include "svt_axi_system_env.sv"
    `include "svt_axi_user_defines.svi" 
    `include "fptp_axi_reset_if.sv"
    `include "fptp_defines.sv"
    `include "fptp_tb_config.sv"
    `include "fptp_scoreboard.sv"
    `include "fptp_env.sv"

`endif // FPTP_TB_PKG_SVH
