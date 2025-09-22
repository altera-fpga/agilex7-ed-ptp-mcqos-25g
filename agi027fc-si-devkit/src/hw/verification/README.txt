//************************************************************************
 How to setup UVM TB and run sumulation for UVM Testcase for FTILE PTP 
//************************************************************************

Initial set the resources as per the following order and set all the environemnt variables as per the setup.sh in the given order
1)  Set all tool paths vcs, python etc. Please make sure Tool versions used are as follows:
      VCS     : vcsmx/T-2022.06-SP2-3
      Python  : python/3.7.7
      Quartus : Quartus Version 25.1
      PERL    : perl/5.8.8
      CMAKE   : cmake/3.11.4
      GCC     : gcc/7.2.0
      PTP_ROOTDIR : <user path>/<repo name>/src/hw/verification/2P25G_DV
2)  Set the required environment and directory Structure variables (as shown below)
      source <user path>/<repo name>/src/hw/verification/2P25G_DV/env/setup.sh
      WORKDIR=$PTP_ROOTDIR
      DESIGN_DIR=$PTP_ROOTDIR/../../src
      QUARTUS_HOME=$QUARTUS_ROOTDIR
      QUARTUS_INSTALL_DIR=$QUARTUS_ROOTDIR
      DESIGNWARE_HOME= <synopsys vip location> verion -vip_R-2020.09A
      UVM_HOME=$VCS_HOME/etc/uvm-1.2
      SYNTH_DIR=$PTP_ROOTDIR/../../synth

//************************************************************************
# UVM TESTS 
# BASE TEST (Inculded as part of all tests as all tests are derived from base test only. Not part of the count)
fptp_base_test.svh 

# Total 3 tests

# IO/CSR TESTS ( DMA/PTPBRIDGE/TCAM/HSSI)
1.fptp_csr_test.svh

#  DATA PATH TESTS
2.fptp_dma_base_test.svh
3.fptp_qos_usr_test.svh

//************************************************************************
# How to Run UVM Testcases 
1)  cd $PTP_ROOTDIR/scripts
2)  For Compiling IPs and Subsystems, execute: “gmake -f Makefile.mk cmplib | tee cmp.log”
3)  For building RTL & TB QOS , execute: “gmake -f Makefile.mk build  HSSI_25G=1” 
4)  For tests run execute: “gmake -f Makefile.mk run TESTNAME=fptp_csr_test SEQNAME=fptp_csr_seq DUMP=1"[ DUMP is an option. If VPD is required, then use DUMP else it is not required] 
5)  Results are created in a sim directory ($PTP_ROOTDIR/sim/$TESTNAME).Check simulate_$TESTNAME.log for Simulation result. 
6)  If same test is  re-run, then the previous result dir gets renamed and moved as $PTP_ROOTDIR/verification/sim/$TESTNAME.#. E.g.fptp_csr_test.1, fptp_csr_test.2 .... and the latest test run result is created as $PTP_ROOTDIR/sim/$TESTNAME. 
