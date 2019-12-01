
module aes_top(
	input i_clock,
	input [0:127] i_plain,
	input [0:127] i_key,
	output [0:127] o_cipher
);

reg [0:7] state [0:15];

integer i;

always @(posedge i_clock) begin

	// initialize states from input
	state[0] <= i_plain[0:7];
	state[1] <= i_plain[8:15];
	state[2] <= i_plain[16:23];
	state[3] <= i_plain[24:31];
	state[4] <= i_plain[32:39];
	state[5] <= i_plain[40:47];
	state[6] <= i_plain[48:55];
	state[7] <= i_plain[56:63];
	state[8] <= i_plain[64:71];
	state[9] <= i_plain[72:79];
	state[10] <= i_plain[80:87];
	state[11] <= i_plain[88:95];
	state[12] <= i_plain[96:103];
	state[13] <= i_plain[104:111];
	state[14] <= i_plain[112:119];
	state[15] <= i_plain[120:127];

end

// For Gtkwave debug
wire [0:7] state_0;
wire [0:7] state_1;
wire [0:7] state_2;
wire [0:7] state_3;
wire [0:7] state_4;
wire [0:7] state_5;
wire [0:7] state_6;
wire [0:7] state_7;
wire [0:7] state_8;
wire [0:7] state_9;
wire [0:7] state_10;
wire [0:7] state_11;
wire [0:7] state_12;
wire [0:7] state_13;
wire [0:7] state_14;
wire [0:7] state_15;

assign state_0 = state[0];
assign state_1 = state[1];
assign state_2 = state[2];
assign state_3 = state[3];
assign state_4 = state[4];
assign state_5 = state[5];
assign state_6 = state[6];
assign state_7 = state[7];
assign state_8 = state[8];
assign state_9 = state[9];
assign state_10 = state[10];
assign state_11 = state[11];
assign state_12 = state[12];
assign state_13 = state[13];
assign state_14 = state[14];
assign state_15 = state[15];

endmodule

