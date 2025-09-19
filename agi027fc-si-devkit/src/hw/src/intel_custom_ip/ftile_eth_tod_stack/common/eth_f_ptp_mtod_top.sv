//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 



//------------------------------------------------------------------------------
//
// Filename         : eth_f_ptp_mtod_top.sv
//
//==============================================================================

//------------------------------------------------------------------------------
//
// Description :-
// This module is a PTP Master Time-of-Day (TOD), which: 
// supports 1 Pulse Per Second,
// and provides 96-bit TOD data and 1-bit tod_valid outputs,
// as well as 1-pulse-per-second output.
//------------------------------------------------------------------------------

`timescale 1ns / 1ns
module eth_f_ptp_mtod_top
#(
    parameter MASTER_PPS_CYCLE = 100000
)(
    // Clock and Reset
    input  logic                    i_clk_reconfig,
    input  logic                    i_clk_tod,
    input  logic                    i_reconfig_rst_n,
    input  logic                    i_tod_rst_n,
    input  logic                    i_upstr_pll_lock,
    
    // CSR
    input  logic [3:0]              i_csr_addr,
    input  logic                    i_csr_write,
    input  logic [31:0]             i_csr_writedata,
    input  logic                    i_csr_read,
    output logic [31:0]             o_csr_readdata,
    output logic                    o_csr_waitrequest,
    // TOD load            
    input  logic                    i_tod_96b_load_valid,
    input  logic [95:0]             i_tod_96b_load_data,
    // Output TOD
    output logic                    o_tod_96b_valid,
    output logic [95:0]             o_tod_96b_data,
    // 1-Pulse-Per-Second
    output logic                    o_pps
);
    // Internal logics
    logic       pps_pll_refclk;
    logic       pps_pll_scanclk;
    logic       master_pll_locked;
    logic [1:0] w_pps_pll_rst_n;
    logic       pps_pll_rst_n;
    logic       pps_samp_clk;
    logic       pps_phased_clk;
    logic       pps_pll_locked;
    logic       pps_pll_phase_en;
    logic       pps_pll_phase_done;
    logic       pps_pll_updn;
    logic [2:0] pps_pll_num_phase_shifts;
    logic [4:0] pps_pll_cntsel;
    logic         csr_tod_load;
    logic         csr_tod_load_sync;
    logic [29:0] w_reconfig_to_pll;
    logic [10:0] w_reconfig_from_pll;
    logic [7:0]  pps_pll_mgmt_writedata;
    logic        pps_pll_mgmt_waitrequest;

    //---------------------------------------------------------------
    // Clocks and Reset
    ghrd_f_mtod_master_pll ghrd_mtod_master_pll (
        .refclk     (i_clk_tod),            // 100MHz refclk
        .rst        (~i_tod_rst_n),
        .outclk_0   (pps_pll_scanclk),      // 100mhz refclk/scanclk for pps_pll
        .permit_cal (i_upstr_pll_lock),
        .locked     (master_pll_locked)
    );
    assign pps_pll_refclk  = i_clk_tod;   // 100mhz refclk/scanclk for pps_pll
    eth_f_ptp_xcvr_resync_std #(
        .SYNC_CHAIN_LENGTH  (3),
        .WIDTH              (2),
        .INIT_VALUE         (0)
    ) scanclk_rst_sync (
        .clk                (pps_pll_scanclk),
        .reset              (1'b0),
        .d                  ({i_upstr_pll_lock, i_tod_rst_n}),
        .q                  (w_pps_pll_rst_n[1:0])
    ); 
    always @ (posedge pps_pll_scanclk) begin
        pps_pll_rst_n <= &w_pps_pll_rst_n;
    end
    
    ghrd_f_mtod_pps_pll ghrd_mtod_pps_pll (
        .refclk     (pps_pll_refclk),
        .rst        (~pps_pll_rst_n),
        .outclk_0   (pps_samp_clk),    // req106.66667 - act108.173.77
        .outclk_1   (pps_phased_clk),   // 156.25
        .locked     (pps_pll_locked),
        .permit_cal (i_upstr_pll_lock),
        // DPS reconfig ports
        .reconfig_to_pll    (w_reconfig_to_pll),
        .reconfig_from_pll  (w_reconfig_from_pll)
    );
    
    ghrd_f_mtod_pps_pll_rcfg ghrd_mtod_pps_pll_rcfg (
        .mgmt_clk        (pps_pll_scanclk),
        .mgmt_reset      (~pps_pll_rst_n),
        .mgmt_waitrequest  (pps_pll_mgmt_waitrequest),
        .mgmt_write        (pps_pll_phase_en),
        .mgmt_read         (1'b0),
        .mgmt_writedata    (pps_pll_mgmt_writedata),
        .mgmt_readdata     (/*not-used*/),
        .mgmt_address      (10'b1100000000),
        .reconfig_to_pll    (w_reconfig_to_pll),
        .reconfig_from_pll  (w_reconfig_from_pll)
	);
    // -----------------------------------------------
    // wiring between pps_pll_rcfg and TOD
    assign pps_pll_phase_done = ~pps_pll_mgmt_waitrequest; // TOD need to flop input
    assign pps_pll_mgmt_writedata = {pps_pll_cntsel[3:0], pps_pll_updn, pps_pll_num_phase_shifts};
    
    // -----------------------------------------------
    // Master TOD
    ghrd_f_master_tod ghrd_mtod (
        .clk                         (i_clk_reconfig),
        .rst_n                       (i_reconfig_rst_n),
        .period_clk                  (i_clk_tod),
        .period_rst_n                (i_tod_rst_n),
        .csr_address                 (i_csr_addr),
        .csr_write                   (i_csr_write),
        .csr_writedata               (i_csr_writedata),
        .csr_read                    (i_csr_read),
        .csr_readdata                (o_csr_readdata),
        .csr_waitrequest             (o_csr_waitrequest),
        .time_of_day_96b_load_valid  (i_tod_96b_load_valid),
        .time_of_day_96b_load_data   (i_tod_96b_load_data),
        .time_of_day_64b_load_valid  (1'b0),
        .time_of_day_64b_load_data   (64'h0),
        .time_of_day_96b             (o_tod_96b_data),
        .time_of_day_64b             (),
        // PPS interface
        .pps_sampling_clk       (pps_samp_clk),         // period_clk * 256 / 375
        .iopll_phased_clk       (pps_phased_clk),       // period_clk with phased
        .iopll_scan_clk         (pps_pll_scanclk),     // any clock <= 100MHz
        .iopll_locked           (pps_pll_locked),
        .iopll_phase_done       (pps_pll_phase_done),
        .iopll_phase_en         (pps_pll_phase_en),
        .iopll_updn             (pps_pll_updn),
        .iopll_num_phase_shifts (pps_pll_num_phase_shifts),
        .iopll_cnt_sel          (pps_pll_cntsel),
        .pps_pulse_per_second   (o_pps)
    );
    
    // -----------------------------------------------
    // synchronizers
    eth_f_altera_std_synchronizer_nocut csr_tod_load_sync_inst (
        .clk        (i_clk_tod),
        .reset_n    (1'b1),
        .din        (csr_tod_load),
        .dout       (csr_tod_load_sync)
    );
    // -----------------------------------------------
    // TOD valid generator
    localparam MTOD_CSR_ADDR_SECONDH = 4'h0;
    localparam S_IDLE                = 4'h0;
    localparam S_WAIT_LOAD           = 4'h1;
    localparam S_TOD_VALID           = 4'h2;
    localparam WAIT_CNT_CSR_LOAD     = 8'd100; // TODO
    localparam WAIT_CNT_INT_LOAD     = 8'd10;  // TODO

    logic [3:0]   todv_state;
    logic [7:0]   wait_cnt;
    
     always @(posedge i_clk_reconfig) begin
         if (~i_reconfig_rst_n)
             csr_tod_load <= 1'b0;
         else
             csr_tod_load <= (i_csr_write && i_csr_addr == MTOD_CSR_ADDR_SECONDH);
     end

    
    always @ (posedge i_clk_tod) begin
        if (~i_tod_rst_n) begin
            o_tod_96b_valid <= 1'b0;
            todv_state      <= S_IDLE;
            wait_cnt        <= 8'h0;   
        end
        else begin
            o_tod_96b_valid    <= (todv_state == S_TOD_VALID) ? 1'b1 : 1'b0;
            
            case (todv_state)
            S_IDLE: begin
                todv_state  <= S_TOD_VALID;
            end
            S_WAIT_LOAD: begin
                if (i_tod_96b_load_valid)   wait_cnt    <= WAIT_CNT_INT_LOAD;
                else if (csr_tod_load_sync) wait_cnt    <= WAIT_CNT_CSR_LOAD;
                else                        wait_cnt    <= wait_cnt - 8'h1;
                
                if (wait_cnt == 0) todv_state <= S_TOD_VALID;
                else               todv_state <= todv_state;
            end
            S_TOD_VALID: begin
                if (i_tod_96b_load_valid) begin
                    todv_state  <= S_WAIT_LOAD;
                    wait_cnt    <= WAIT_CNT_INT_LOAD;
                end
                else if (csr_tod_load_sync) begin
                    todv_state  <= S_WAIT_LOAD;
                    wait_cnt    <= WAIT_CNT_CSR_LOAD;
                end
                else begin
                    todv_state  <= S_TOD_VALID;
                end
            end
            default: begin
                todv_state      <= S_IDLE;
            end    
            endcase
        end // else
    end

endmodule : eth_f_ptp_mtod_top

