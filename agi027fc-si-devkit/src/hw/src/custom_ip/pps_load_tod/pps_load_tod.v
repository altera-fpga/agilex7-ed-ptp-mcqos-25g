//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

// pps_load_tod.v

// This file was auto-generated as a prototype implementation of a module
// created in component editor.  It ties off all outputs to ground and
// ignores all inputs.  It needs to be edited to make it do something
// useful.
// 
// This file will not be automatically regenerated.  You should check it in
// to your version control system if you want to keep it.

`timescale 1 ps / 1 ps
module pps_load_tod (
		input  wire        period_clock,                //          period_clock.clk
		input  wire        reset,                       //                 reset.reset
		input  wire        csr_clock,                   //             csr_clock.clk
		input  wire        csr_reset,                   //             csr_reset.reset
		output reg  [31:0] csr_readdata,                //                   csr.readdata
		input  wire        csr_write,                   //                      .write
		input  wire        csr_read,                    //                      .read
		input  wire [31:0] csr_writedata,               //                      .writedata
		output wire        csr_waitrequest,             //                      .waitrequest
		input  wire [5:0]  csr_address,                 //                      .address
		input  wire        pps_pulse_per_second,        //         pps_interface.pulse_per_second
		input  wire [95:0] time_of_day_96b,             //       time_of_day_96b.data
		output wire        pps_irq,                     // IRQ to HPS based on 1PPS for ToD Sampling
		output wire [95:0] time_of_data_96b_load_data,  // time_of_data_96b_load.data
		output wire        time_of_data_96b_load_valid  //                      .valid
	);


reg pps_control;
reg pps_control_1d;
reg pps_control_2d;

reg pps_in_delay_1d;
reg pps_in_delay_2d;
reg pps_in_delay_3d;
reg pps_in_delay_4d;

reg pps_in_csr_1d;
reg pps_in_csr_2d;

wire pps_pos_in_irq;
wire pps_pos_d1;

wire pps_in_pos;
wire pps_in_neg;

reg pps_irq_reg;

reg [2:0] read_latch;

reg [95:0] latched_tod_master_96b;

reg  [31:0] tod_secondsh_d1;
reg  [31:0] tod_secondsl_d1;
reg  [31:0] tod_nseconds_d1;

reg  [31:0] tod_secondsh_d2;
reg  [31:0] tod_secondsl_d2;
reg  [31:0] tod_nseconds_d2;

reg  [24:0] secondsl_p1;
reg  [24:0] secondsh_p1;
wire [31:0] nseconds_ptodperiod;
wire [15:0] fnseconds_ptodperiod;

reg [95:0] tod_master_96b_load_data;
reg        tod_master_96b_load_valid;



// Outputs    
assign pps_irq         = pps_irq_reg; // Triggering an IRQ with the 2x delayed 1PPS (level trigger), to relax timing 
assign csr_waitrequest = 1'b0;

assign time_of_data_96b_load_valid = tod_master_96b_load_valid;
assign time_of_data_96b_load_data  = tod_master_96b_load_data;
   
// Positive edge of 1PPS, generated 1 CC later for IRQ generation
assign pps_pos_in_irq = pps_in_csr_1d & (~pps_in_csr_2d);
// Positive edge of 1PPS, generated 1 CC later for latching ToD output
assign pps_pos_d1 = pps_in_delay_1d & (~pps_in_delay_2d);


// Positive edge of 1PPS, generated 3 CCs later
assign pps_in_pos = pps_in_delay_3d & (~pps_in_delay_4d);
// Negative edge of 1PPS, generated 2 CCs later
assign pps_in_neg = pps_in_delay_3d & (~pps_in_delay_2d);

// Adding 5 ToD periods to the nanosecond field: 3 for latching 1PPS positive edge, 1 for valid generation, 1 for ToD load to take effect in the master ToD  
// This assumes 156.25MHz ToD clock, so 6.4ns X 5 = 3225.6ns
assign nseconds_ptodperiod  = 32'd32;
assign fnseconds_ptodperiod = 16'd0;


// HPS Address Decoding
always @ (posedge csr_clock or posedge csr_reset)
begin
    if (csr_reset)
    begin
        pps_control <= 1'b0;
    end
    else  
    begin
        case(csr_address)
        6'd3:
        begin
            if(csr_write)
                pps_control <= csr_writedata[0];
        end
        endcase
    end
end

// CSR Read back of 3x ToD 32b latched fields when pps control is enabled
always @ (posedge csr_clock or posedge csr_reset)
begin
    if (csr_reset)
    begin
       csr_readdata <= 32'b00000000000000000000000000000000;
    end
    else
    begin
        case(csr_address)
        6'd19:
        begin
            if(csr_read & pps_control)
                csr_readdata <= tod_secondsh_d2;
        end
        6'd20:
        begin
            if(csr_read & pps_control)
                csr_readdata <= tod_secondsl_d2;
        end
        6'd21:
        begin
            if(csr_read & pps_control)
                csr_readdata <= tod_nseconds_d2;
        end
        endcase
    end
end

// Latch all 3x read actions of ToD 32b reg fields for IRQ clearence when pps control is enabled, clear when all of them are read
always @ (posedge csr_clock or posedge csr_reset)
begin
    if (csr_reset)
    begin
        read_latch  <= 3'd0;
    end
    else
    begin
        case(csr_address)
    6'd19:
        begin
            if(csr_read)
                read_latch[2] <= pps_control;
            else if(read_latch[2] & read_latch[1] & read_latch[0])
                read_latch  <= 3'd0;
        end
    6'd20:
        begin
            if(csr_read)
                read_latch[1] <= pps_control;
            else if(read_latch[2] & read_latch[1] & read_latch[0])
                read_latch  <= 3'd0;
        end
    6'd21:
        begin
            if(csr_read)
                read_latch[0] <= pps_control;
            else if(read_latch[2] & read_latch[1] & read_latch[0])
                read_latch  <= 3'd0;
        end
    default: begin
            if(read_latch[2] & read_latch[1] & read_latch[0])
                read_latch  <= 3'd0;
        end
        endcase
    end
end

// IRQ Generation
always @ (posedge csr_clock or posedge csr_reset)
begin
if (csr_reset)
     pps_irq_reg <= 1'b0;  
else if (pps_pos_in_irq)                                // On the positive 1PPS edge, trigger an IRQ if pps control is enabled by SW.
     pps_irq_reg <= pps_control;
else if (read_latch[2] & read_latch[1] & read_latch[0])   // If all 3x ToD 32b fields are read, clear the IRQ.
     pps_irq_reg <= 1'b0; 
end



// Synchronizing the pps control enable signal
always @ (posedge period_clock)
begin : PIPE_DELAY
    if(reset) 
    begin
        pps_control_1d <=  1'b0;
        pps_control_2d <=  1'b0;
    end
    else
    begin
        pps_control_1d <=  pps_control;
        pps_control_2d <=  pps_control_1d;
    end
end
 
// 1PPS delay line
always @ (posedge period_clock)
 begin
  if (reset)
  begin
      pps_in_delay_1d <= 1'b0;
      pps_in_delay_2d <= 1'b0;
      pps_in_delay_3d <= 1'b0;  
      pps_in_delay_4d <= 1'b0;
  end
  else
  begin
     pps_in_delay_1d <= pps_pulse_per_second;
     pps_in_delay_2d <= pps_in_delay_1d;
     pps_in_delay_3d <= pps_in_delay_2d;
     pps_in_delay_4d <= pps_in_delay_3d;
  end
 end
 
// 1PPS delay line sampled by CSR clock for IRQ generation
always @ (posedge csr_clock or posedge csr_reset)
 begin
  if (csr_reset)
  begin
      pps_in_csr_1d <= 1'b0;
      pps_in_csr_2d <= 1'b0;
  end
  else
  begin
     pps_in_csr_1d 	<= pps_pulse_per_second;
     pps_in_csr_2d 	<= pps_in_csr_1d;
  end
 end

// Latch the Master ToD output 96b on the Falling Edge of the 1PPS (mid of second), 2 CCs later (it doesn't affect because we ignore the ns field)
always @ (posedge period_clock)
begin
if (reset)
    latched_tod_master_96b <= 96'b0;
else if (pps_in_neg & pps_control_2d)
    latched_tod_master_96b <= time_of_day_96b;
end

// 1 Delay of ToD 96b output
always @ (posedge period_clock)
begin
    if (reset)   
    begin
        tod_secondsh_d1 <= 32'b0;
        tod_secondsl_d1 <= 32'b0;
        tod_nseconds_d1 <= 32'b0;
    end
    else if (pps_control_2d)
    begin
        tod_secondsh_d1 <= {16'b0, time_of_day_96b[95:80]};
        tod_secondsl_d1 <= time_of_day_96b[79:48];
        tod_nseconds_d1 <= time_of_day_96b[47:16];
    end
end
// Sample the Delayed (1cc) Master ToD output 96b only on the Delayed (1cc) Rising Edge of the 1PPS
always @ (posedge period_clock)
begin
if (reset)
    begin
        tod_secondsh_d2 <= 32'b0;
        tod_secondsl_d2 <= 32'b0;
        tod_nseconds_d2 <= 32'b0;
    end
    else if (pps_control_2d & pps_pos_d1)
    begin
        tod_secondsh_d2 <= tod_secondsh_d1;
        tod_secondsl_d2 <= tod_secondsl_d1;
        tod_nseconds_d2 <= tod_nseconds_d1;
    end
end



// Add 1 second to the latched value of the ToD output, latency is not important
always @ (posedge period_clock)
begin
if (reset)
    secondsl_p1 <= 25'b0;
else if (pps_control_2d)
    secondsl_p1 <= latched_tod_master_96b[71:48] + 1;
end

always @ (posedge period_clock)
begin
if (reset)
    secondsh_p1 <= 25'b0;
else if (pps_control_2d)
    secondsh_p1 <= latched_tod_master_96b[95:72] + secondsl_p1[24];
end


// Generate a load valid to the Master ToD 4 CCs later (pps_in_delay_3d)
always @ (posedge period_clock)
begin
if (reset)
    tod_master_96b_load_valid <= 1'b0;
else if (pps_control_2d)
    tod_master_96b_load_valid <= pps_in_pos;
else
    tod_master_96b_load_valid <= 1'b0;
end


// Generate a load data output to the Master ToD 4 CCs later (pps_in_delay_3d)
always @ (posedge period_clock)
begin
if (reset)
    tod_master_96b_load_data <= 96'b0;
else if (pps_control_2d)
    tod_master_96b_load_data <= {secondsh_p1[23:0], secondsl_p1[23:0], nseconds_ptodperiod, fnseconds_ptodperiod};
end


endmodule
