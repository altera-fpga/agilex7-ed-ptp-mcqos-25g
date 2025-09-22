//########################################################################
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//########################################################################

/**
 * Abstract:
 * Class cust_svt_axi_system_configuration is used to encapsulate all the 
 * configuration information.  It extends the system configuration and 
 * set the appropriate fields like number of masters/slaves, create 
 * master/slave configurations etc..., which are required by System agent.
 */

`ifndef CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV
`define CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV


class cust_svt_axi_system_configuration extends svt_axi_system_configuration;

  /** UVM Object Utility macro */
  `uvm_object_utils (cust_svt_axi_system_configuration)

  /** Class Constructor */
  function new (string name = "cust_svt_axi_system_configuration");

    super.new(name);

    /** Assign the necessary configuration parameters. This example uses single
      * master and single slave configuration.
      */
    this.num_masters = `NUM_MASTERS;
    this.num_slaves  = `NUM_SLAVES;
    this.system_monitor_enable = 0;
    this.common_clock_mode = 0;

    /** Create port configurations */
    this.create_sub_cfgs(`NUM_MASTERS, `NUM_SLAVES);

    /** Enable protocol file generation for Protocol Analyzer */
    this.master_cfg[0].enable_xml_gen = 0;
    this.slave_cfg[0].enable_xml_gen = 0;
    
    this.master_cfg[0].pa_format_type = svt_xml_writer::FSDB;
    this.slave_cfg[0].pa_format_type= svt_xml_writer::FSDB;

    this.master_cfg[0].transaction_coverage_enable = 0;
    this.slave_cfg[0].transaction_coverage_enable = 0;

    this.master_cfg[0].axi_interface_type = svt_axi_port_configuration::AXI4;
    this.master_cfg[0].data_width = 32;
    this.master_cfg[0].addr_width = 27;
    this.master_cfg[0].id_width = 4;

    this.slave_cfg[0].axi_interface_type = svt_axi_port_configuration::ACE_LITE;
    this.slave_cfg[0].data_width = 512;
    this.slave_cfg[0].addr_width = 34;
    this.slave_cfg[0].id_width = 5;
    slave_cfg[0].awlock_enable = 0;
    slave_cfg[0].awcache_enable = 0;
    slave_cfg[0].arlock_enable = 0;
    slave_cfg[0].arcache_enable = 0;

    // newly added
    slave_cfg[0].rlast_enable = 1;
    slave_cfg[0].wlast_enable = 1;
    slave_cfg[0].awlen_enable = 1;
    slave_cfg[0].arlen_enable = 1;
    slave_cfg[0].awsize_enable = 1;
    slave_cfg[0].arsize_enable = 1;
    slave_cfg[0].awburst_enable = 1;
    slave_cfg[0].arburst_enable = 1;

    this.set_addr_range(0,64'h0,64'hffff_ffff_ffff_ffff);
  endfunction
endclass
`endif //CUST_SVT_AXI_SYSTEM_CONFIGURATION_SV
