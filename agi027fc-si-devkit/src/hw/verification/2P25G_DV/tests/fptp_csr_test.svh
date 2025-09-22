//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Default Read and R/W to DMA, PTP Bridge, TCAM, PKT CLIENT and HSSI Registers
//########################################################################

`ifndef FPTP_CSR__TEST_SVH
`define FPTP_CSR__TEST_SVH

class fptp_csr_test extends fptp_base_test;
    `uvm_component_utils(fptp_csr_test)

    fptp_env    env;
    cust_svt_axi_system_configuration cfg;
    uvm_table_printer printer;
    int               regress_mode_en;
    int               timeout;
    int               test_pass = 1;
    int               sim_length_reached;
    uvm_report_object reporter;
    bit               exp_timeout = 0;
    int                 num_max_quit_count;
    
    function new(string name = "fptp_csr_test", uvm_component parent = null);
        super.new(name, parent);
        dis_sb=1'b1;
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction : build_phase

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction : end_of_elaboration_phase


   virtual function void start_of_simulation_phase(uvm_phase phase);
      super.start_of_simulation_phase(phase);
   endfunction : start_of_simulation_phase

   //----------------------------------------
   // Run Phase
   //----------------------------------------
   virtual task run_phase(uvm_phase phase);
       super.run_phase(phase);
   endtask : run_phase
   
   //----------------------------------------
   // Report Phase
   //----------------------------------------
   virtual function void report_phase(uvm_phase phase);
      super.report_phase(phase);
   endfunction : report_phase
   
   //----------------------------------------
   // Check Phase
   //----------------------------------------
   virtual function void check_phase(uvm_phase phase);
       super.check_phase(phase);
   endfunction : check_phase

endclass : fptp_csr_test

`endif // FPTP_CSR__TEST_SVH
