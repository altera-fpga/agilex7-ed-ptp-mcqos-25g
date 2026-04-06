//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################
//# Description: Base UVM test class for the FPTP testbench. Provides
//#              common infrastructure including UVM environment creation,
//#              AXI system configuration, reset sequencing, run-phase
//#              sequence dispatch from the command-line (+seqname arg),
//#              simulation timeout management, and pass/fail reporting.
//# Purpose    : To serve as the parent class for all FPTP tests, handling
//#              shared build, run, and final phase logic so that derived
//#              tests only need to specialize their specific behavior.
//########################################################################
`ifndef FPTP_BASE_TEST_SVH
`define FPTP_BASE_TEST_SVH
`include "uvm_pkg.sv"
`include "uvm_macros.svh"

class fptp_base_test extends uvm_test;
    `uvm_component_utils(fptp_base_test)

    fptp_tb_config tb_cfg;
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
    bit               dis_sb;
    
    //svt_err_catcher err_catcher;
    function new(string name = "fptp_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        string regress_mode_en_str;
        super.build_phase(phase);
        cfg = cust_svt_axi_system_configuration::type_id::create("cfg");
        tb_cfg = fptp_tb_config::type_id::create("tb_cfg", this);
        uvm_config_db #(fptp_tb_config)::set(this, "*","tb_cfg", tb_cfg);


       /** Set configuration in environment */
        uvm_config_db#(cust_svt_axi_system_configuration)::set(this, "env", "cfg", this.cfg);

	
	env = fptp_env::type_id::create("env", this);
    
        printer = new();
        printer.knobs.depth = 5;
        printer.knobs.name_width = 40;
        printer.knobs.type_width = 32;
        printer.knobs.value_width = 32;

       uvm_config_db#(uvm_object_wrapper)::set(this, "env.axi_system_env.sequencer.main_phase", "default_sequence", fptp_null_virtual_seq::type_id::get());

       /** Apply the default reset sequence */
        uvm_config_db#(uvm_object_wrapper)::set(this, "env.rst_sequencer.reset_phase", "default_sequence", axi_simple_reset_sequence::type_id::get());

        uvm_config_db#(uvm_object_wrapper)::set(this, "env.axi_system_env.master*.sequencer.main_phase", "default_sequence", fptp_null_virtual_seq::type_id::get());

        if(!$value$plusargs("UVM_MAX_QUIT_COUNT=%d",num_max_quit_count)) begin
                num_max_quit_count = 100;
            end

            //reporter.set_max_quit_count(num_max_quit_count);
    endfunction : build_phase




    virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    `uvm_info("reset_phase", "Entered...", UVM_LOW)
    `uvm_info("reset_phase", "Exiting...", UVM_LOW)
    endtask


    function void end_of_elaboration_phase(uvm_phase phase);
    `SVT_XVM(root) root = `SVT_XVM(root)::get();
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
    root.print_topology();
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
  endfunction: end_of_elaboration_phase



    //virtual task main_phase(uvm_phase phase);
    virtual task run_phase(uvm_phase phase);
    // run the sequence
    uvm_object    tmp_object;
    uvm_factory   m_factory;
    uvm_sequence  exec_seq;

    string seq_name;
    super.run_phase(phase);

    phase.raise_objection(this);

    `uvm_info("main_phase", "MAIN_PHASE Entered...", UVM_LOW)
    m_factory = uvm_factory::get();

    wait (fptp_top_tb.tb_reset === 1);

    `uvm_info("main_phase", "MAIN_PHASE SEQ PICKED...", UVM_LOW)
    if($value$plusargs("seqname=%s", seq_name)) begin
        `uvm_info(get_full_name(), $sformatf("Sequence Name = %s",seq_name), UVM_MEDIUM)
        tmp_object = m_factory.create_object_by_name(seq_name);
        assert($cast(exec_seq,tmp_object));
        exec_seq.start(env.axi_system_env.sequencer,null);
    end else
    `uvm_fatal("", $psprintf("There is no sequence from command line, please review run command"));


    phase.drop_objection(this);
    `uvm_info("main_phase", "Exiting MAIN_PHASE...", UVM_LOW);
  endtask 


        //----------------------------------------
        // Report Phase
        //----------------------------------------
        virtual function void final_phase(uvm_phase phase);
            uvm_report_server   svr;
            `uvm_info("final_phase", "Entered...",UVM_LOW)
            super.final_phase(phase); 
 
            svr = uvm_report_server::get_server();
      if((svr.get_severity_count(UVM_FATAL) +
        svr.get_severity_count(UVM_ERROR)== 0))
      `uvm_info("FINAL_PHASE", "\n TEST : Passed\n", UVM_LOW)
       else
      `uvm_info("FINAL_PHASE", "\n TEST: Failed\n", UVM_LOW)
 

        endfunction : final_phase

        //----------------------------------------
        // Check Phase
        //----------------------------------------
        virtual function void check_phase(uvm_phase phase);
            super.check_phase(phase);
        endfunction : check_phase





    virtual task timeout_watch(uvm_phase phase);
        string msgid;
        int timeout,flush_timeout;
        string timeout_str;
        
        msgid = get_name();
        timeout=this.timeout;

        if(!timeout) begin
            if($value$plusargs("TIMEOUT=%s", timeout_str)) begin
                timeout = timeout_str.atoi();   // in us
            end else
                timeout = 2000;
        end

        `uvm_info(get_full_name(), $psprintf("TIMEOUT = %d", timeout), UVM_LOW)
        repeat(timeout) begin
            # 1us;
        end
        `uvm_info(get_full_name(), "Reached simulation duration, finishing test...", UVM_LOW)

   
        //Regress mode tests run for 'timeout', so need larger flush times       
        flush_timeout=(timeout>2000)?2*timeout:2000;

        repeat(flush_timeout) begin
            # 1us;         
        end
        test_pass = 0;
        if(regress_mode_en) phase.phase_done.display_objections();
        if (exp_timeout) begin
            `uvm_warning(msgid, "*** TIMED OUT! ***")   
            phase.phase_done.display_objections();
        end else begin
            `uvm_fatal(msgid, "*** TIMED OUT! ***")    
        end
    endtask : timeout_watch



endclass : fptp_base_test

`endif // FPTP_BASE_TEST_SVH
