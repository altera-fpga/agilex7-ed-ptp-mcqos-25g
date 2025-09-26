//************************************************************************
 How to setup UVM TB and run sumulation for UVM Testcase for FTILE PTP 
//************************************************************************

//************************************************************************
1) Initial set all tool paths vcs, python etc as follow. 

      VCS     : vcsmx/T-2022.06-SP2-3
      Python  : python/3.7.7
      Quartus : Quartus Version 25.1.1
      PERL    : perl/5.8.8
      CMAKE   : cmake/3.11.4
      GCC     : gcc/7.2.0
      PTP_ROOTDIR : <user path>/<repo name>/src/hw/verification/2P25G_DV
Note: There is no hard rule to maintain the same version for tools like perl, cmake,python,gcc.Versions mentioned above are for reference only.

//************************************************************************
//************************************************************************

2)  Set all the environemnt variables as per the setup.sh
      Refer <user path>/<repo name>/src/hw/verification/2P25G_DV/env/setup.sh
      WORKDIR=$PTP_ROOTDIR
      DESIGN_DIR=$PTP_ROOTDIR/../../src
      QUARTUS_HOME=$QUARTUS_ROOTDIR
      QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
      DESIGNWARE_HOME= <synopsys vip location> 
      UVM_HOME=$VCS_HOME/etc/uvm-1.2
      SYNTH_DIR=$PTP_ROOTDIR/../../synth


//************************************************************************
//************************************************************************

3) Details about the Design and Testbench and tests/sequences.

The main blocks of the design (DUT) are DMA Subsystem which has MSGDMA IP,PTP Bridge,Packet Client and HSSI Subsystem which has Ethernet IP which has 2 ports. Apart from this many quartus IPs are present in the design.
In the testbench, two VIP instances are present. AXI4 instance for initiating CSR access ACE_LITE instance for data flow. 
Data flows from ACE LITE VIP to HSSI SS. At the output of HSSI Subsystem serial lines are looped back at the Testbench level so that data gets routed back to ACE LITE VIP. Packet client data will also send toHSSI SS and gets looped back. 
Clock and reset are given from the testbench to the DUT.

verification
    ├── 2P25G_DV
    │   ├── env
    │   │   └── setup.sh              -> Details about the env variables.
    │   ├── scripts
    │   │   ├── Makefile.mk           -> Makefile consists of all commands to be executed to compile, elaborate and run the design. It consists of scripts to generate ips,list files for RTL and testbench
    │   │   ├── gen_ip_sim_setup.sh   -> Script to generate IP sims and to compile them.
    │   │   ├── generate_ip.sh        -> Script to generate IPs.
    │   │   ├── ip_script.pl          -> This perl script will convert the ip list tcl file to ip list.f
    │   │   ├── parser_for_PTP.pl     -> The perl script to edit the qsys top and move it to testbench folder
    │   │   ├── rename_prev_testdir.sh-> This script will rename the previous test dir when the same test is re-run. 
    │   │   ├── rtl_script.pl         -> This script will convert the rtl list tcl file to rtl list.f file
    │   │   ├── support_logic_gen.sh  -> Scripts to generate the spd files
    │   │   ├── top_auto_tiles        -> Auto tiles will be generated and copied here
    │   │   │   └── dummy.v
    │   │   └── vpd_dump.key          -> vpd file for providing dump options.
    │   ├── testbench
    │   │   ├── cust_svt_axi_system_configuration.sv -> AXI Configuration file which details about the type of VIP, its address width, data width and instance
    │   │   ├── fptp_axi_reset_if.sv                 -> Reset interface file
    │   │   ├── fptp_defines.sv                      -> Contains the defines that are used in Test bench
    │   │   ├── fptp_env.sv                          -> Top level env which instantiates all tb components like axi vip,scoreboard.
    │   │   ├── fptp_reset_sequencer.sv              -> Reset Sequencer 
    │   │   ├── fptp_scoreboard.sv                   -> Scoreboard used for checking the dma data integrity.
    │   │   ├── fptp_tb_config.sv                    -> TB config file
    │   │   ├── fptp_tb_pkg.svh                      -> TB package file
    │   │   ├── fptp_top_tb.sv                       -> Testbench top file which instantiate DUT, generates clocks, reset  
    │   │   └── svt_axi_user_defines.svi             -> SVT defines
    │   ├── tests
    │   │   ├── fptp_base_test.svh                   -> This is the base test which is needed for all tests to run
    │   │   ├── fptp_csr_test.svh                    -> CSR test. This test checks default value of all registers in MSGDMA, Packet client,PTP Bridge and HSSI. It also does  Write and Read and checks data integrity for R/W registers
    │   │   ├── fptp_dma_base_test.svh               -> DMA Base test which test the DMA path. There are 6 channels in the DMA Subsystem each having TX and RX. DMA data on Ch0,Ch1 and Ch2 are sent to PTP Bridge -> HSSI Port1 and gets looped back to PTP Bridge->Ch0,Ch1 and Ch2 of DMA Subsytem.MA data on Ch3,Ch4 and Ch5 are sent to PTP Bridge -> HSSI Port2 and gets looped back to PTP Bridge->Ch3,Ch4 and Ch5 of DMA Subsytem.
    │   │   ├── fptp_qos_usr_test.svh                -> Same as above DMA base test. In addition it sends data from Packet client blocks. Packet client0 will send data to HSSI Port1 an gets looped back to Packet client0. Packet client1 will send data to HSSI Port2 an gets looped back to Packet client1 
    │   │   ├── fptp_test_pkg.svh                    -> Contains all Tests
    │   │   └── sequences
    │   │       ├── axi_base_sequence_pkg.sv         -> Contains user defined structs.
    │   │       ├── axi_simple_reset_sequence.sv     -> Reset  sequence   
    │   │       ├── fptp_axi_derived_base_seq.sv     -> AXI Derived sequence
    │   │       ├── fptp_axi_slave_host_response_seq.sv -> AXI Slave sequence to send reseponse to DUT Read requests. Also sends responds to DUT Write requests
    │   │       ├── fptp_base_seq.sv                    -> Base Sequence
    │   │       ├── fptp_csr_seq.sv                     -> CSR Sequence for the CSR test(fptp_csr_test)
    │   │       ├── fptp_data_traffic_cfg_seq.sv        -> Configures the DMA Channels and Packet client registers.
    │   │       ├── fptp_dma_base_seq.sv                -> DMA Base seq for DMA base test (fptp_dma_base_test)
    │   │       ├── fptp_null_virtual_seq.sv            -> Null seq
    │   │       ├── fptp_ptp_bridge_cfg_dma_seq.sv      -> PTP Bridge needs to be configured with TCAM registers for dma data flow. All those configurations are done in this sequence.
    │   │       ├── fptp_ptp_bridge_cfg_usr_seq.sv      -> PTP Bridge needs to be configured with TCAM registers for packet client data flow. All those configurations are done in this sequence.
    │   │       ├── fptp_qos_usr_seq.sv                 -> QOS Usr Sequence for QOS USR test (fptp_qos_usr_test).
    │   │       ├── fptp_seq_lib.svh                    -> Contains all Sequences
    │   │       └── fptp_user_traffic_check_seq.sv      -> Checks for the data integrity for packet client data flow.
    │   └── ver_list.f                                  -> Contains TB files.
    └── README.txt                                      -> Verification READ ME.


//************************************************************************
//************************************************************************

4) Test Flow:

1)  cd $PTP_ROOTDIR/scripts [Path to run all test commands]

2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib | tee cmp.log”
    Design consists of various IPs. When above command is executed, all IPs will be generated and its relevant libraries will also be generated and compiled. Additionally the testbench uses AXI VIP for initiating transactions and vip folder also will also be generated. This command has to be generated only once for the entire simulation.

Note: 
Cmplib command will take 30-40mts to execute.

3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_25G=1” 
    Once IPs are generated and relevant libraries are compiled, next step is compile and elaborate the design and testbench. The "build" command will do the same. 
    This command is also required to be executed once. But if any design and testbench files updates are required, then this command needs to be executed accordingly as per the requirement before the test run. Mostly design files won't be updated.

Note: 
Build command will take 30-40mts to execute.

4)  For tests run execute: “gmake -f Makefile.mk run TESTNAME=fptp_csr_test SEQNAME=fptp_csr_seq <DUMP=1> <SEED=<seed number>>. [DUMP is an option. If VPD is required,DUMP=1 option is used] [SEED is an option.To rerun the failure test, SEED=<seed number> is used]

Note:
Test run command will take 1-1.5 hrs of time. Once the test run starts, it will wait for the HSSI link up for both the ports to be ready. Once link is up, test flow starts. For dma base seq and qos usr seq, initial configuration needs to be done and then data traffic starts. 

5)  Results are created in a sim directory ($PTP_ROOTDIR/sim/$TESTNAME).Check simulate_$TESTNAME.log for Simulation result. 
              Whenever the test is run, a seed value is seen in the simulate_$TESTNAME.log. If there is a requirement for any testbench updates and want to see same result, then simulation can be run with same seed by providing the option [SEED=<seed number] in the run command.

6)  If same test is  re-run, then the previous test dir gets renamed and moved as $PTP_ROOTDIR/verification/sim/$TESTNAME.#. E.g.fptp_csr_test.1, fptp_csr_test.2 .... and the latest test run result is created as $PTP_ROOTDIR/sim/$TESTNAME. 

//************************************************************************
//************************************************************************

5) UVM TESTS 
# BASE TEST (Inculded as part of all tests as all tests are derived from base test only. Not part of the count)
fptp_base_test.svh 

# Total 3 tests

# CSR TESTS (DMA/PTPBRIDGE/HSSI)
1.fptp_csr_test.svh
  fptp_csr_seq.sv -> Extended from base seq. Does read and write to all DUT registers

#  DATA PATH TESTS
2.fptp_dma_base_test.svh
  fptp_dma_base_seq.sv -> Extended from base seq. Has instances of fptp_data_traffic_cfg_seq, fptp_ptp_bridge_cfg_dma_seq which does initial configuration and fptp_axi_slave_host_response_seq. 

3.fptp_qos_usr_test.svh
  fptp_qos_usr_seq.sv  -> Extended from base seq.Has instances of fptp_data_traffic_cfg_seq,fptp_ptp_bridge_cfg_usr_seq, fptp_ptp_bridge_cfg_dma_seq which does initial configuratio,fptp_axi_slave_host_response_seq and fptp_user_traffic_check_seq


//************************************************************************
//************************************************************************
