//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# FPTP ENV which instances for TB Components
//########################################################################
`ifndef FPTP_ENV_SV
`define FPTP_ENV_SV

`include "fptp_reset_sequencer.sv"
`include "cust_svt_axi_system_configuration.sv"

class fptp_err_demoter extends uvm_report_catcher;
    `uvm_object_utils(fptp_err_demoter)

    function new(string name="fptp_err_demoter");
        super.new(name);
    endfunction : new

    function action_e catch();
      if (((get_id() == "PKTCLIENT0") && (get_severity()== UVM_ERROR)) ||
          ((get_id() == "PKTCLIENT1") && (get_severity()== UVM_ERROR)) 
      )
      set_severity(UVM_INFO);
      return THROW;
    endfunction

endclass : fptp_err_demoter

class fptp_env extends uvm_env;
    `uvm_component_utils(fptp_env)

    svt_axi_system_env axi_system_env;
    fptp_reset_sequencer rst_sequencer;


    // AXI System Configuration
    cust_svt_axi_system_configuration cfg;
       
    fptp_scoreboard fptp_sb;
    fptp_tb_config  tb_cfg; 
    fptp_err_demoter err_demoter;
    bit run_lpbk;




    function new(string name= "fptp_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // create an instance of env
        axi_system_env = svt_axi_system_env::type_id::create("axi_system_env", this);
        fptp_sb   = fptp_scoreboard::type_id::create("fptp_sb", this);
        if(!uvm_config_db#(fptp_tb_config)::get(this,"","tb_cfg",tb_cfg))
            `uvm_fatal(get_name(), "failed to get tb_cfg ");
       fptp_sb.tb_cfg=tb_cfg;
       err_demoter = fptp_err_demoter::type_id::create("err_demoter",this);
       uvm_report_cb::add(null,err_demoter);

        
        // AXI4 
        cfg = cust_svt_axi_system_configuration::type_id::create("cfg");
	uvm_config_db#(svt_axi_system_configuration)::set(this, "axi_system_env", "cfg", cfg);
        rst_sequencer = fptp_reset_sequencer::type_id::create("rst_sequencer", this);

        `uvm_info("build_phase", "Exiting...", UVM_LOW)
     
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("connect_phase", "Entered...",UVM_LOW)
        `uvm_info("connect_phase", "Exiting...",UVM_LOW)
        axi_system_env.slave[0].monitor.item_observed_port.connect(fptp_sb.axi_port);
    endfunction : connect_phase

endclass : fptp_env

`endif // FPTP_ENV_SV
