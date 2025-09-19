//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 



//------------------------------------------------------------------------------
//
// Filename         : eth_f_ptp_stod_top.sv
//
//==============================================================================

//------------------------------------------------------------------------------
//
// Description :-
// This module is a PTP Subordinate Time-of-Day (TOD), which: 
// supports master TOD load,
// and provides 96-bit TOD data and 1-bit tod_valid outputs.
//------------------------------------------------------------------------------

`timescale 1ns / 1ns
module eth_f_ptp_stod_top
(
    // Clock and Reset
    input  logic                      i_clk_reconfig,
    input  logic                      i_clk_mtod,
    input  logic                      i_clk_stod,
    input  logic                      i_clk_todsync_sampling,
    input  logic                      i_reconfig_rst_n,
    input  logic                      i_mtod_rst_n,
    input  logic                      i_stod_rst_n,
    
    // Master TOD
    input  logic [95:0]               i_mtod_data,
    input  logic                      i_mtod_valid,
    // Output TOD
    output logic [95:0]               o_stod_data,
    output logic                      o_stod_valid
);
    // Internal logics
    logic        mtod_valid_sync;
    logic        tod_sync_valid;
    logic [95:0] tod_sync_data;
    
    // -----------------------------------------------
    // synchronizers
    eth_f_altera_std_synchronizer_nocut mtod_valid_sync_inst (
        .clk        (i_clk_stod),
        .reset_n    (1'b1),
        .din        (i_mtod_valid),
        .dout       (mtod_valid_sync)
    );
    
    // -----------------------------------------------
    // TOD Synchronizer
    eth_f_tod_sync tod_sync_inst (
        .clk_master                 (i_clk_mtod),
        .reset_master               (~i_mtod_rst_n),
        .clk_slave                  (i_clk_stod),
        .reset_slave                (~i_stod_rst_n),
        .clk_sampling               (i_clk_todsync_sampling),
        .start_tod_sync             (1'b1),
        .tod_master_data            (i_mtod_data),
        .tod_slave_valid            (tod_sync_valid),
        .tod_slave_data             (tod_sync_data)
    );

    // -----------------------------------------------
    // Subordinate TOD
    eth_f_tod tod_inst (
        .clk                         (i_clk_reconfig),
        .rst_n                       (i_reconfig_rst_n),
        .period_clk                  (i_clk_stod),
        .period_rst_n                (i_stod_rst_n),
        .csr_address                 (4'h0),
        .csr_write                   (1'b0),
        .csr_writedata               (32'h0),
        .csr_read                    (1'b0),
        .csr_readdata                (),
        .csr_waitrequest             (),
        .time_of_day_96b_load_valid  (tod_sync_valid),
        .time_of_day_96b_load_data   (tod_sync_data),
        .time_of_day_64b_load_valid  (1'b0),
        .time_of_day_64b_load_data   (64'h0),
        .time_of_day_96b             (o_stod_data),
        .time_of_day_64b             ()
    );
    // -----------------------------------------------
    // TOD valid generator
    localparam S_WAIT_MTOD_VALID = 0;
    localparam S_WAIT_LTOD_VALID = 1;
    localparam S_TOD_VALID       = 2;
    localparam WAIT_CNT_INT_LOAD = 12'd1040;
    // TODSync delay: reset release until 1st tod_slave_valid (4398ns or 1720cycles)
    // TODSync delay2: mtod_valid reassert until stod_slave_valid reassert ((2420ns/2.56)*1.1=1040cycles)
    // TOD load: 9 cycles, count as 10.
    logic [3:0] todv_state;
    logic [11:0] wait_cnt;
    
    always @ (posedge i_clk_stod) begin
        if (~i_stod_rst_n) begin
            o_stod_valid    <= 1'b0;
            todv_state      <= S_WAIT_MTOD_VALID;
            wait_cnt        <= 12'h0;   
        end
        else begin
            o_stod_valid    <= (todv_state == S_TOD_VALID) ? 1'b1 : 1'b0;
            
            case (todv_state)
            S_WAIT_MTOD_VALID: begin
                if (mtod_valid_sync) begin
                    todv_state      <= S_WAIT_LTOD_VALID;
                    wait_cnt        <= WAIT_CNT_INT_LOAD;
                end
            end
            S_WAIT_LTOD_VALID: begin
                if (wait_cnt != 12'h0) begin
                    wait_cnt    <= wait_cnt - 12'h1;
                end
                if      (~mtod_valid_sync)                      todv_state  <= S_WAIT_MTOD_VALID;
                else if ((wait_cnt == 12'h0) && tod_sync_valid) todv_state  <= S_TOD_VALID;
                else                                            todv_state  <= todv_state;
            end
            S_TOD_VALID: begin
                if (~mtod_valid_sync)   todv_state  <= S_WAIT_MTOD_VALID;
                else                    todv_state  <= S_TOD_VALID;
            end
            default: begin
                todv_state    <= S_WAIT_MTOD_VALID;
            end
            endcase
        end
    end


endmodule : eth_f_ptp_stod_top
