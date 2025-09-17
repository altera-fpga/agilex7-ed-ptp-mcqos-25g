//# ######################################################################## 
//# Copyright (C) 2025 Altera Corporation.
//# SPDX-License-Identifier: MIT
//# ######################################################################## 

module tod_conduit_split (
  input  wire [95:0] data_conduit_in,
  input  wire        valid_conduit_in,
  output wire [95:0] data_conduit_out_1 ,
  output wire [95:0] data_conduit_out_2 ,
  output wire [95:0] data_conduit_out_3 ,
  output wire [95:0] data_conduit_out_4 ,
  output wire [95:0] data_conduit_out_5 ,
  output wire [95:0] data_conduit_out_6 ,
  output wire [95:0] data_conduit_out_7 ,
  output wire [95:0] data_conduit_out_8 ,
  output wire [95:0] data_conduit_out_9 ,
  output wire [95:0] data_conduit_out_10 ,
  output wire        valid_conduit_out_1 ,
  output wire        valid_conduit_out_2 ,
  output wire        valid_conduit_out_3 ,
  output wire        valid_conduit_out_4 ,
  output wire        valid_conduit_out_5 ,
  output wire        valid_conduit_out_6 ,
  output wire        valid_conduit_out_7 ,
  output wire        valid_conduit_out_8 ,
  output wire        valid_conduit_out_9 ,
  output wire        valid_conduit_out_10 
);

assign data_conduit_out_1  = data_conduit_in;
assign data_conduit_out_2  = data_conduit_in;
assign data_conduit_out_3  = data_conduit_in;
assign data_conduit_out_4  = data_conduit_in;
assign data_conduit_out_5  = data_conduit_in;
assign data_conduit_out_6  = data_conduit_in;
assign data_conduit_out_7  = data_conduit_in;
assign data_conduit_out_8  = data_conduit_in;
assign data_conduit_out_9  = data_conduit_in;
assign data_conduit_out_10 = data_conduit_in;
assign valid_conduit_out_1 = valid_conduit_in;
assign valid_conduit_out_2 = valid_conduit_in;
assign valid_conduit_out_3 = valid_conduit_in;
assign valid_conduit_out_4 = valid_conduit_in;
assign valid_conduit_out_5 = valid_conduit_in;
assign valid_conduit_out_6 = valid_conduit_in;
assign valid_conduit_out_7 = valid_conduit_in;
assign valid_conduit_out_8 = valid_conduit_in;
assign valid_conduit_out_9 = valid_conduit_in;
assign valid_conduit_out_10 = valid_conduit_in;

endmodule
