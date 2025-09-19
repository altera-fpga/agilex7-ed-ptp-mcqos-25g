# ######################################################################## 
# Copyright (C) 2025 Altera Corporation.
# SPDX-License-Identifier: MIT
# ######################################################################## 

set_false_path -from [get_keepers -no_duplicates {*|*_lane_current_state_r[*]}] -to [get_keepers -no_duplicates {*|U_base_profile|eth_f_0|sip_inst|*_port_current_state_1[*][*]}]				 

#########################################################################################################################
#########################################################################################################################
proc eth_f_constraint_net_delay {from_reg to_reg max_net_delay {check_exist 0} {get_pins 1} {set_skew_constraint 1} {set_mstable 1} {set_no_synchronizer 0}} {
    
    # Check for instances
    set inst [get_registers -nowarn ${to_reg}]
    
    # Check number of instances
    set inst_num [llength [query_collection -report -all $inst]]
    if {$inst_num > 0} {
        # Uncomment line below for debug purpose
        #puts "${inst_num} ${to_reg} instance(s) found"
    } else {
        # Uncomment line below for debug purpose
        #puts "No ${to_reg} instance found"
    }

  if {($set_skew_constraint == 0)} {   
    if {($check_exist == 0) || ($inst_num > 0)} {
        if { [string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
            if {$set_no_synchronizer == 1} {
                set_max_delay -no_synchronizer -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ns
            } else {
                set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ns
            }
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -200ns
        } else {
            if {$get_pins == 0} {
                set_net_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -max $max_net_delay
            } else {
                set_net_delay -from [get_pins -compatibility_mode ${from_reg}|q] -to [get_registers ${to_reg}] -max $max_net_delay
            }
            
            # Relax the fitter effort
            if {$set_no_synchronizer == 1} {
                set_max_delay -no_synchronizer -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ns
            } else {
                set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 200ns
            }
            set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -200ns
        }
    }
  } else {   
        #set skew and min/max delay for EFIFO
        # control skew for bits
        set_max_skew -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
        # path delay (exception for net delay)
        if { ![string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
            set_net_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        }
        #relax setup and hold calculation
        if {$set_no_synchronizer == 1} {
            set_max_delay -no_synchronizer -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 100
        } else {
            set_max_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] 100
        }
        set_min_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -100		
  }
	
    #set Meta stability for EFIFO 
    if {($set_mstable == 1)} {
		if { ![string equal "quartus_sta" $::TimeQuestInfo(nameofexecutable)] } {
			set_net_delay -from [get_registers ${from_reg}] -to [get_registers ${to_reg}] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
		}
    }
}


#########################################################################################################################
#########################################################################################################################
# Common contraints per SS
    set_false_path -to [get_registers *|resync_chains[0].synchronizer_nocut|din_s1]
 
  eth_f_constraint_net_delay   "*hssi_ss*|U_eth_f_inst_p*|eth_f_top_p*|U_base_profile|eth_f_0|sip_inst|o_fec_not_locked_aib[*][*]" \
                               "*hssi_ss*|U_sts_sync_p*|resync_chains[*].synchronizer_nocut|din_s1" \
                                2.2ns 1 0 0 0 0

  eth_f_constraint_net_delay   "*hssi_ss*|U_eth_f_inst_p*|eth_f_top_p*|U_base_profile|eth_f_0|sip_inst|o_fec_not_align_aib[*]" \
                               "*hssi_ss*|U_sts_sync_p*|resync_chains[*].synchronizer_nocut|din_s1" \
                                2.2ns 1 0 0 0 0




    eth_f_constraint_net_delay "*hssi_ss*|U_hssi_ss_ip_wrapper_p*|U_st_bridge_instance|axist_to_avst_bridge_inst|U_axist_to_avst_tx_mac_seg_if_inst*" \
                               "*hssi_ss*|U_hssi_ss_ip_wrapper_p*|U_PARITY_ERR_SYNC|resync_chains\[*\].synchronizer_nocut|din_s1" \
                                2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|led_pulse_reg*" \
                               "*hssi_ss*|U_hssi_ss_led_p*|*x_pulse_sync|din_s1" \
                                2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|out_sync_nios_rstn|dreg[1]" \
                               "*hssi_ss*|U_hssi_ss_led_p*|pulse_10msec_*x_d1" \
                                2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|out_sync_nios_rstn|dreg[1]" \
                               "*hssi_ss*|U_hssi_ss_led_p*|*x_sig_det" \
                                2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_hssi_ss_led_p*|*x_sig_det" \
                               "*hssi_ss*|U_hssi_ss_led_p*|led_status[2]" \
                                2.2ns 1 0 0 0 0


#    eth_f_constraint_net_delay "resp_rst_sync|dreg[1]" \
                                * \
                                2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay "ptp_rst_n_src" \
                               "master_tod_rst_sync|resync_chains\[*\].synchronizer_nocut|din_s1" \
                                2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|SS_RST_SEQ|gen_resp_rst_sync\[*\].resp_rst_sync|dreg[1]" \
                                * \
                                2.2ns 1 0 0 0 0

   eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p*_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p*|eth_f_top_p*|U_base_profile|eth_f_0|sip_inst|px_rx_dp_rst_s\[*\]" \
                               2.2ns 1 0 0 0 0

   eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p*_out_sync_tx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p*|eth_f_top_p*|U_base_profile|eth_f_0|sip_inst|px_tx_dp_rst_s\[*\]" \
                               2.2ns 1 0 0 0 0



	  eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|out_sync_nios_rstn|dreg[1]" \
															 "*hssi_ss*|ptp_adpt_f|ptp_adpt|sip_inst|ptp_tx_dsk_inst|dsk_cnt\[*\]" \
															  2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|out_sync_nios_rstn|dreg[1]" \
                               "*hssi_ss*|ptp_adpt_f|ptp_adpt|sip_inst|ptp_tx_dsk_inst|o_dsk[0]" \
															  2.2ns 1 0 0 0 0 

#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|ip_tod|mtod_valid_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|todsync_sampling_locked_sync|din_s1" \
                                2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|ip_tod_locked_sync|din_s1" \
                                2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay "master_tod_rst_sync|resync_chains\[*\].synchronizer_nocut|dreg[1]" \
 	 													   "U_hssi_ss_f_hw_ip_top|master_tod|scanclk_rst_sync|resync_chains\[*\].synchronizer_nocut|din_s1" \
  														  2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|master_tod|csr_tod_load_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0


#	 eth_f_constraint_net_delay  * \
#	 												     "*auto_tiles|z1577a_x388_y166_n0|hdpldadapt_tx_chnl_8~pld_tx_clk1_dcm.reg" \
#															  2.2ns 1 0 0 0 0

#########################################################################################################################
		eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p0_out_sync_csr_rstn|dreg[1]" \
	                             "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|rx_status_sync0|resync_chains[*].synchronizer_nocut|din_s1" \
                                2.2ns 1 0 0 0 0

   
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p0_out_sync_csr_rstn|dreg[1]" \
                               "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|tx_status_sync0|resync_chains[*].synchronizer_nocut|din_s1" \
                               2.2ns 1 0 0 0 0
     
    
    
    #eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|reg_*\[*\]" \
    #                           * \
    #                           2.2ns 1 0 0 0 0
    
    # Taken from eth_f
    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|pkt_client_rst_n" \
                               * \
                               2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|reg_00\[*\]" \
                                * \
                                2.2ns 1 0 0 0 0
    # packet client csr counters
    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_cnt_vld" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|*|cnt_vld_sync" \
                                2.2ns 1 0 0 0 0
    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_*_cnt\[*\]" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|u_*_cnt|cnt_*\[*\]" \
                                2.2ns 1 0 0 0 0
    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_cnt_vld" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|*|cnt_vld_sync" \
                                2.2ns 1 0 0 0 0
    #eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_*_cnt\[*\]" \
    #                            "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|u_*_cnt|cnt_*\[*\]" \
    #                            2.2ns 1 0 0 0 0
    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|eth_f_loopback_fifo|o_wr_full_err" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|loopback_fifo_wr_full_err" \
                                2.2ns 1 0 0 0 0
    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_top|pkt_gen_top|pkt_gen_pingpong_bf|full*" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_top|pkt_gen_top|pkt_gen_rom|pkt_altsyncram|auto_generated|altera_syncram_impl1|ram_block*" \
                                2.2ns 1 0 0 0 0


    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|latency_cnt|lat_cnt_done" \
                               "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_lat_stat_sync_inst|sync[8].synchronizer_nocut_inst|din_s1" \
                               2.2ns 1 0 0 0 0 


    #eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_*_cnt\[*\]" \
    #* \
    #2.2ns 1 0 0 0 0

    #eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p0_out_sync_*_rstn|dreg[1]" \
    #                           "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|px_rx_lane_desired_state_sync|sync[0].synchronizer_nocut_inst|din_s1" \
    #                           2.2ns 1 0 0 0 0
#####################################################################################################################
##
##    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|latency_cnt|lat_cnt\[*" \
##                               "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_lat_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                               2.2ns 1 0 0 0 0
##
##    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_eop_cnt\[*\]" \
##	                             "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##														   2.2ns 1 0 0 0 0
##
##	  eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_sop_cnt\[*\]" \
##	 	 													 "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##															 2.2ns 1 0 0 0 0
##
##    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_eop_cnt\[*\]" \
##                               "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_txif_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                                2.2ns 1 0 0 0 0
##
##   eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_sop_cnt\[*\]" \
##                              "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_txif_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                               2.2ns 1 0 0 0 0
##                          
##    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_err_cnt\[*\]" \
##                               "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_txif_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                                2.2ns 1 0 0 0 0                       
##
##    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_cnt_vld" \
##	 														 "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_txif_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                               2.2ns 1 0 0 0 0
## 
##   eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p0_out_sync_rx_rstn|dreg[1]" \
##                              "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|px_rx_lane_desired_state_sync|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                              2.2ns 1 0 0 0 0 
##
##
##   eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|reg_*\[*\]" \
##                              "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|latency_cnt|stat_lat_clkpll_sync|resync_chains\[*\].synchronizer_nocut|din_s1" \
##                               2.2ns 1 0 0 0 0 
##
##   eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_csr|reg_*\[*\ " \
##                              "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|cfg_rom_data_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                               2.2ns 1 0 0 0 0 
##
##   eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_cnt_vld" \
##                              "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync\[*\].synchronizer_nocut_inst|din_s1" \
##                               2.2ns 1 0 0 0 0 
##                   
##
##############################################################################################################################

    #eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|latency_cnt|lat_cnt\[*\]" \
    #* \
    #2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|tx_pll_locked_sync_int_clk_inst|sync[0].synchronizer_nocut_inst|dreg[1]" \
    * \
    2.2ns 1 0 0 0 0

    #eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|stat_counter|stat_cnt_vld" \
    #"U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync[24].synchronizer_nocut_inst|din_s1" \
    #2.2ns 1 0 0 0 0
    
#    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|eth_f_loopback_fifo|o_rd_empty_err" \
    "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync[26].synchronizer_nocut_inst|din_s1" \
    2.2ns 1 0 0 0 0
    
#    eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|loopback_client|eth_f_loopback_fifo|o_wr_full_err" \
    "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|lpbk_cli_stat_sync_inst|sync[25].synchronizer_nocut_inst|din_s1" \
    2.2ns 1 0 0 0 0
    
    eth_f_constraint_net_delay "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|o_rx_pcs_ready\[*\]" \
    "*hssi_ss*|U_link_sts_sync_p0|resync_chains\[*\].synchronizer_nocut|din_s1" \
    2.2ns 1 0 0 0 0    
    
    eth_f_constraint_net_delay "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|o_tx_lanes_stable\[*\]" \
     "*hssi_ss*|U_link_sts_sync_p0|resync_chains\[*\].synchronizer_nocut|din_s1" \
    2.2ns 1 0 0 0 0
    
    #eth_f_constraint_net_delay "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|packet_client_tx_if|stat_counter|stat_cnt_vld" \
    #"U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|pkt_cli_txif_stat_sync_inst|sync[24].synchronizer_nocut_inst|din_s1" \
    #2.2ns 1 0 0 0 0
     
    eth_f_constraint_net_delay "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|rx_status_sync0|resync_chains\[*\].synchronizer_nocut|dreg[1]" \
     "*hssi_ss*|U_sts_sync_p0|resync_chains\[*\].synchronizer_nocut|din_s1" \
    2.2ns 1 0 0 0 0    
    
    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p0_out_sync_tx_rstn|dreg[1]" \
     "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|px_tx_lane_desired_state_sync|sync[0].synchronizer_nocut_inst|din_s1" \
     2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p8_out_sync_tx_rstn|dreg[1]" \
     "*hssi_ss*|U_eth_f_inst_p8|eth_f_top_p8|sip_inst|tx_lane_desired_state_reg\[*\]" \
     2.2ns 1 0 0 0 0  

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p9_out_sync_tx_rstn|dreg[1]" \
     "*hssi_ss*|U_eth_f_inst_p9|eth_f_top_p9|sip_inst|tx_lane_desired_state_reg\[*\]" \
     2.2ns 1 0 0 0 0 

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p12_out_sync_tx_rstn|dreg[1]" \
     "*hssi_ss*|U_eth_f_inst_p12|eth_f_top_p12|sip_inst|tx_lane_desired_state_reg\[*\]" \
     2.2ns 1 0 0 0 0 

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p8_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p8|eth_f_top_p8|sip_inst|rx_lane_desired_state_reg\[*\]" \
                              2.2ns 1 0 0 0 0 

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p9_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p9|eth_f_top_p9|sip_inst|rx_lane_desired_state_reg\[*\]" \
                              2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p12_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p12|eth_f_top_p12|sip_inst|rx_lane_desired_state_reg\[*\]" \
                              2.2ns 1 0 0 0 0 

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p8_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p8|eth_f_top_p8|sip_inst|rx_dp_rst_*" \
                               2.2ns 1 0 0 0 0

   eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p8_out_sync_tx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p8|eth_f_top_p8|sip_inst|tx_dp_rst_*" \
                              2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p9_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p9|eth_f_top_p9|sip_inst|rx_dp_rst_*" \
                               2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p9_out_sync_tx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p9|eth_f_top_p9|sip_inst|tx_dp_rst_*" \
                              2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p12_out_sync_rx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p12|eth_f_top_p12|sip_inst|rx_dp_rst_*" \
                               2.2ns 1 0 0 0 0

    eth_f_constraint_net_delay "*hssi_ss*|U_SRC_RST_CONTROLLER|p12_out_sync_tx_rstn|dreg[1]" \
                              "*hssi_ss*|U_eth_f_inst_p12|eth_f_top_p12|sip_inst|tx_dp_rst_*" \
                              2.2ns 1 0 0 0 0


  #######################################################################

  ##PTP eth_f consraints
    # --------------------------------------
    # PTP Components	
		# --------------------------------------

    # reset synchronizers for tx/rx tod modules in advanced timing mode
#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.rx_cdr_lock_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0

 #   eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.tx_pll_locked_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0
#    eth_f_constraint_net_delay  * \
                                " U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.rx_todsync_sampling_locked_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0
#    eth_f_constraint_net_delay  * \
                                " U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.tx_todsync_sampling_locked_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0

    # fifo crossing and reset synchronizers within PTP monitor
#    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_MON.ptp_monitor|*|wr_ptr_sync|b2g_input_ptr|gray_value\[*\]" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_MON.ptp_monitor|*|wr_ptr_sync|ptr_sync|bit_loop\[*\].sync|mem\[*\]" \
                                2.2ns 1 0 0 0 0
#    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|rs*x|synchronizer_nocut_inst|dreg\[1\]" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_MON.ptp_monitor|*fifo|rst_sync_rd|synchronizer_nocut_inst|*" \
                                2.2ns 1 0 0 0 0
    # mtod/stod synchronizers
#    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|master_tod|o_tod_96b_valid" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.rx_tod|mtod_valid_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0
#    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|master_tod|o_tod_96b_valid" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|PTP_LOGIC.tx_tod|mtod_valid_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0

    # packet_client_top: clock crosser - synchronizer
#		eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_TX_ITS_GEN.*_clk_crosser|in_to_out_synchronizer|din_s1" \
                                2.2ns 1 0 0 0 0
#    eth_f_constraint_net_delay  * \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_TX_ITS_GEN.*_clk_crosser|out_to_in_synchronizer|din_s1" \
                                2.2ns 1 0 0 0 0

#    eth_f_constraint_net_delay  "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_TX_ITS_GEN.*_clk_crosser|in_data_buffer\[*\]" \
                                "U_hssi_ss_f_hw_ip_top|U_p0_mac_packet_client_top|packet_client_top|PTP_TX_ITS_GEN.*_clk_crosser|out_data_buffer\[*\]" \
                                2.2ns 1 0 0 0 0

    #need to check the below 2
    eth_f_constraint_net_delay  "*auto_tiles|z1577a_x388_y166_n0|z1577a~aib_hssi_pld_pcs_tx_clk_out_ch*.reg"  \
                                "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_wrapper_inst|ref_ts_per_pl_gen[0].ptp_ref_ts_capture_u|gen_rollover_lane[0].tx_rollover_cnt|sclk_return_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0
    eth_f_constraint_net_delay  "*auto_tiles|z1577a_x388_y166_n0|z1577a~aib_hssi_pld_pcs_tx_clk_out_ch*.reg" \
                                "*hssi_ss*|U_eth_f_inst_p0|eth_f_top_p0|U_base_profile|eth_f_0|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_ref_ts_capture_wrapper_inst|ref_ts_per_pl_gen[0].ptp_ref_ts_capture_u|gen_rollover_lane[0].rx_rollover_cnt|sclk_return_sync_inst|din_s1" \
                                2.2ns 1 0 0 0 0



###set_multicycle_path -from [get_keepers -no_duplicates {*auto_tiles|z1577a_x388_y166_n0|hdpldadapt_rx_chnl_8~pld_rx_clk1_dcm.reg}] -to [get_keepers -no_duplicates {*hssi_ss*|U_eth_f_inst_p20|eth_f_top_p20|U_base_profile|eth_f_0|sip_inst|rx_aib_dsk_r[0]}] -setup -end 	
###set_multicycle_path -from [get_keepers -no_duplicates {*hssi_ss*|U_eth_f_inst_p20|eth_f_top_p20|U_base_profile|eth_f_0|sip_inst|PTP_SOFT_GEN.soft_ptp|ptp_opcode_writer_wrapper_u|o_tx_data[0][20]}] -to [get_keepers -no_duplicates {*auto_tiles|z1577a_x388_y166_n0|hdpldadapt_tx_chnl_8~pld_tx_clk1_dcm.reg}] -setup -end 
 ####### end of PTP


