//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 


`timescale 1 ps / 1 ps
module pp_tod_stack #(
        parameter NUMPORTS               = 1

    )(
        input   wire             i_reconfig_clk,
        input   wire             i_reconfig_reset,

        input  wire              i_todsync_sel,
        input  wire              i_clk_tx_tod,
        input  wire              i_clk_rx_tod,
        input  wire              i_clk_master_tod,
        input  wire              i_clk_todsync_sample,
        input  wire              i_clk_todsync_sample_locked,
        input  wire              i_clk_todsync_sample_10g,
        input  wire              i_clk_todsync_sample_locked_10g,
        input  wire              i_ptp_master_tod_rst_n,
        input  wire [95:0]       i_ptp_master_tod,
        input  wire              i_ptp_master_tod_valid,
        input  wire              i_tx_pll_locked,

        output reg  [95:0]       ptp_tx_tod_muxed,
        output reg               ptp_tx_tod_valid_muxed,
        output reg  [95:0]       ptp_rx_tod_muxed,
        output reg               ptp_rx_tod_valid_muxed
);


//---------------------------------------------------------------
    // PTP signals
    logic                        clk_tx_tod;
    logic                        clk_rx_tod;
    logic                        tx_tod_rst_n;
    logic                        rx_tod_rst_n;

    logic                        tx_tod_rst_n_10g;
    logic                        rx_tod_rst_n_10g;

    logic [95:0]                 ptp_tx_tod;
    logic [95:0]                 ptp_rx_tod;
    logic                        ptp_tx_tod_valid;
    logic                        ptp_rx_tod_valid;

    logic [95:0]                 ptp_tx_tod_10g;
    logic [95:0]                 ptp_rx_tod_10g;
    logic                        ptp_tx_tod_valid_10g;
    logic                        ptp_rx_tod_valid_10g;
	
    logic                        tx_pll_locked_sync;
    logic                        tx_todsync_sampling_clk_locked_sync;
    logic                        rx_todsync_sampling_clk_locked_sync;
    logic                        tx_todsync_sampling_clk_locked_sync_10g;
    logic                        rx_todsync_sampling_clk_locked_sync_10g;


//---------------------------------------------------------------


logic tx_pll_locked_reconfig_sync;


eth_f_altera_std_synchronizer_nocut tx_pll_locked_reconfig_sync_inst (
    .clk        (i_reconfig_clk),
    .reset_n    (1'b1),
    .din        (i_tx_pll_locked),
    .dout       (tx_pll_locked_reconfig_sync)
);


    // PTP Timestamp Accuracy Mode = "1:Advanced"
    assign clk_tx_tod  = i_clk_tx_tod;
    assign clk_rx_tod  = i_clk_rx_tod;

    logic tx_pll_locked_reg;

    always @(posedge i_reconfig_clk) begin
        tx_pll_locked_reg   <= tx_pll_locked_reconfig_sync;
    end
	
    eth_f_altera_std_synchronizer_nocut tx_pll_locked_sync_inst (
        .clk        (clk_tx_tod),
        .reset_n    (1'b1),
        .din        (tx_pll_locked_reg),
        .dout       (tx_pll_locked_sync)
    );
	
    //------------------------------------------------------------------------------------
    logic tx_tod_rst_n_wire;
    logic tx_tod_rst_n_reg;
    logic rx_tod_rst_n_wire;
    logic rx_tod_rst_n_reg;

    eth_f_altera_std_synchronizer_nocut tx_todsync_sampling_locked_sync_inst (
        .clk        (clk_tx_tod),
        .reset_n    (1'b1),
        .din        (i_clk_todsync_sample_locked),
        .dout       (tx_todsync_sampling_clk_locked_sync)
    );
    eth_f_altera_std_synchronizer_nocut rx_todsync_sampling_locked_sync_inst (
        .clk        (clk_rx_tod),
        .reset_n    (1'b1),
        .din        (i_clk_todsync_sample_locked),
        .dout       (rx_todsync_sampling_clk_locked_sync)
    );

    assign tx_tod_rst_n_wire = tx_pll_locked_sync & tx_todsync_sampling_clk_locked_sync;
    assign rx_tod_rst_n_wire = rx_todsync_sampling_clk_locked_sync;
    
    // flops to fix recovery time violation from tx_tod_rst_n to tod_sync inst
    always @(posedge clk_tx_tod) begin
        tx_tod_rst_n_reg   <= tx_tod_rst_n_wire;
        tx_tod_rst_n       <= tx_tod_rst_n_reg;
    end
    always @(posedge clk_rx_tod) begin
        rx_tod_rst_n_reg   <= rx_tod_rst_n_wire;
        rx_tod_rst_n       <= rx_tod_rst_n_reg;
    end

    eth_f_ptp_stod_top tx_tod (
        .i_clk_reconfig             (i_reconfig_clk),
        .i_reconfig_rst_n           (~i_reconfig_reset),
        .i_clk_mtod                 (i_clk_master_tod),
        .i_clk_stod                 (clk_tx_tod),
        .i_clk_todsync_sampling     (i_clk_todsync_sample),
        .i_mtod_rst_n               (i_ptp_master_tod_rst_n),
        .i_stod_rst_n               (tx_tod_rst_n),
        .i_mtod_data                (i_ptp_master_tod),
        .i_mtod_valid               (i_ptp_master_tod_valid),
        .o_stod_data                (ptp_tx_tod),
        .o_stod_valid               (ptp_tx_tod_valid)
    );
    eth_f_ptp_stod_top rx_tod (
        .i_clk_reconfig             (i_reconfig_clk),
        .i_reconfig_rst_n           (~i_reconfig_reset),
        .i_clk_mtod                 (i_clk_master_tod),
        .i_clk_stod                 (clk_rx_tod),
        .i_clk_todsync_sampling     (i_clk_todsync_sample),
        .i_mtod_rst_n               (i_ptp_master_tod_rst_n),
        .i_stod_rst_n               (rx_tod_rst_n),
        .i_mtod_data                (i_ptp_master_tod),
        .i_mtod_valid               (i_ptp_master_tod_valid),
        .o_stod_data                (ptp_rx_tod),
        .o_stod_valid               (ptp_rx_tod_valid)
    );

    //------------------------------------------------------------------------------------
    logic tx_tod_rst_n_wire_10g;
    logic tx_tod_rst_n_reg_10g;
    logic rx_tod_rst_n_wire_10g;
    logic rx_tod_rst_n_reg_10g;

    eth_f_altera_std_synchronizer_nocut tx_todsync_sampling_locked_sync_inst_10g (
        .clk        (clk_tx_tod),
        .reset_n    (1'b1),
        .din        (i_clk_todsync_sample_locked_10g),
        .dout       (tx_todsync_sampling_clk_locked_sync_10g)
    );
    eth_f_altera_std_synchronizer_nocut rx_todsync_sampling_locked_sync_inst_10g (
        .clk        (clk_rx_tod),
        .reset_n    (1'b1),
        .din        (i_clk_todsync_sample_locked_10g),
        .dout       (rx_todsync_sampling_clk_locked_sync_10g)
    );

    assign tx_tod_rst_n_wire_10g = tx_pll_locked_sync & tx_todsync_sampling_clk_locked_sync_10g;
    assign rx_tod_rst_n_wire_10g = rx_todsync_sampling_clk_locked_sync_10g;
    
    // flops to fix recovery time violation from tx_tod_rst_n to tod_sync inst
    always @(posedge clk_tx_tod) begin
        tx_tod_rst_n_reg_10g   <= tx_tod_rst_n_wire_10g;
        tx_tod_rst_n_10g       <= tx_tod_rst_n_reg_10g;
    end
    always @(posedge clk_rx_tod) begin
        rx_tod_rst_n_reg_10g   <= rx_tod_rst_n_wire_10g;
        rx_tod_rst_n_10g       <= rx_tod_rst_n_reg_10g;
    end

    eth_f_ptp_stod_top_10g tx_tod_10g (
        .i_clk_reconfig             (i_reconfig_clk),
        .i_reconfig_rst_n           (~i_reconfig_reset),
        .i_clk_mtod                 (i_clk_master_tod),
        .i_clk_stod                 (clk_tx_tod),
        .i_clk_todsync_sampling     (i_clk_todsync_sample),
        .i_mtod_rst_n               (i_ptp_master_tod_rst_n),
        .i_stod_rst_n               (tx_tod_rst_n_10g),
        .i_mtod_data                (i_ptp_master_tod),
        .i_mtod_valid               (i_ptp_master_tod_valid),
        .o_stod_data                (ptp_tx_tod_10g),
        .o_stod_valid               (ptp_tx_tod_valid_10g)
    );
    eth_f_ptp_stod_top_10g rx_tod_10g (
        .i_clk_reconfig             (i_reconfig_clk),
        .i_reconfig_rst_n           (~i_reconfig_reset),
        .i_clk_mtod                 (i_clk_master_tod),
        .i_clk_stod                 (clk_rx_tod),
        .i_clk_todsync_sampling     (i_clk_todsync_sample),
        .i_mtod_rst_n               (i_ptp_master_tod_rst_n),
        .i_stod_rst_n               (rx_tod_rst_n_10g),
        .i_mtod_data                (i_ptp_master_tod),
        .i_mtod_valid               (i_ptp_master_tod_valid),
        .o_stod_data                (ptp_rx_tod_10g),
        .o_stod_valid               (ptp_rx_tod_valid_10g)
    );

   //------------------------------------------------------------------------------------
    logic tx_todsync_sel_sync;
    logic rx_todsync_sel_sync;

    eth_f_altera_std_synchronizer_nocut tx_todsync_sel_sync_inst (
        .clk        (clk_tx_tod),
        .reset_n    (1'b1),
        .din        (i_todsync_sel),                              
        .dout       (tx_todsync_sel_sync)
    );
	
    always @(posedge clk_tx_tod) begin
       if (tx_todsync_sel_sync == 1'h1) begin
         ptp_tx_tod_muxed        <= ptp_tx_tod_10g;
         ptp_tx_tod_valid_muxed  <= ptp_tx_tod_valid_10g;
       end else begin
         ptp_tx_tod_muxed        <= ptp_tx_tod;
         ptp_tx_tod_valid_muxed  <= ptp_tx_tod_valid;
       end
    end

    eth_f_altera_std_synchronizer_nocut rx_todsync_sel_sync_inst (
        .clk        (clk_rx_tod),
        .reset_n    (1'b1),
        .din        (i_todsync_sel),                              
        .dout       (rx_todsync_sel_sync)
    );
	
    always @(posedge clk_rx_tod) begin
       if (rx_todsync_sel_sync == 1'h1) begin
         ptp_rx_tod_muxed        <= ptp_rx_tod_10g;
         ptp_rx_tod_valid_muxed  <= ptp_rx_tod_valid_10g;
       end else begin
         ptp_rx_tod_muxed        <= ptp_rx_tod;
         ptp_rx_tod_valid_muxed  <= ptp_rx_tod_valid;
       end
    end



//---------------------------------------------------------------
endmodule //

