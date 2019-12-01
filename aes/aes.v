
`include "sub_bytes.v"

module aes_top(
	input i_clock,
	input [0:127] i_plain,
	input [0:127] i_key,
	output [0:127] o_cipher
);

parameter s_INIT			= 3'b000;
parameter s_LOAD_INPUT		= 3'b001;
parameter s_SUB_BYTES 		= 3'b010;
parameter s_SHIFT_ROWS 		= 3'b011;
parameter s_MIX_COLUMNS		= 3'b100;
parameter s_ADD_ROUND_KEY	= 3'b101;

reg [2:0] r_sm_main = 0;

reg [0:7] state [0:15];
reg [0:127] r_data = 0;
wire [0:127] w_data_o_sub_byte;
reg r_sub_bytes_active = 0;
reg [0:2] clock_counter = 0;

SubBytes sub_bytes (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_sub_bytes_active),
	.o_data(w_data_o_sub_byte)
);

always @(posedge i_clock) begin
	case (r_sm_main)
		s_INIT :
			begin
				r_sm_main <= s_LOAD_INPUT;
			end
		s_LOAD_INPUT : // 001
			begin
				r_data <= i_plain;
				r_sm_main <= s_SUB_BYTES;
			end
		s_SUB_BYTES : // 010
			begin
				clock_counter = clock_counter + 1;
				r_sub_bytes_active <= 1'b1;
				if (clock_counter == 3) begin
					r_data <= w_data_o_sub_byte;
					r_sub_bytes_active <= 1'b0;
					r_sm_main <= s_SHIFT_ROWS;
				end
			end
		s_SHIFT_ROWS : 
			begin
				
			end
	endcase
end

always @(r_data) begin
	state[0] <= r_data[0:7];
	state[1] <= r_data[8:15];
	state[2] <= r_data[16:23];
	state[3] <= r_data[24:31];
	state[4] <= r_data[32:39];
	state[5] <= r_data[40:47];
	state[6] <= r_data[48:55];
	state[7] <= r_data[56:63];
	state[8] <= r_data[64:71];
	state[9] <= r_data[72:79];
	state[10] <= r_data[80:87];
	state[11] <= r_data[88:95];
	state[12] <= r_data[96:103];
	state[13] <= r_data[104:111];
	state[14] <= r_data[112:119];
	state[15] <= r_data[120:127];
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

