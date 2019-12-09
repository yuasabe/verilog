
`include "inv_sub_bytes.v"
`include "inv_shift_rows.v"
`include "inv_mix_columns.v"
// `include "add_round_key.v"
// `include "create_round_key.v"


module aes_dec_top(
	input i_clock,
	input i_rst,
	input i_is_active,
	input [0:127] i_cipher,
	input [0:127] i_key,
	output [0:127] o_plain,
	output o_is_done
);

parameter s_INIT			= 5'b00000;
parameter s_LOAD_INPUT		= 5'b00001;
parameter s_INITIAL_ADD_ROUND_KEY_BEGIN = 5'b00010;
parameter s_SUB_BYTES_BEGIN 		= 5'b00011;
parameter s_SHIFT_ROWS_BEGIN 		= 5'b00100;
parameter s_MIX_COLUMNS_BEGIN		= 5'b00101;
parameter s_CREATE_ROUND_KEY_0 = 5'b00110;
parameter s_CHANGE_ROUND_KEY = 5'b00111;
parameter s_ADD_ROUND_KEY_BEGIN	= 5'b01000;
parameter s_END = 5'b01001;
parameter s_SUB_BYTES_DONE = 5'b01010;
parameter s_INITIAL_ADD_ROUND_KEY_DONE = 5'b01011;
parameter s_SHIFT_ROWS_DONE = 5'b01100;
parameter s_MIX_COLUMNS_DONE = 5'b01101;
parameter s_CREATE_ROUND_KEY_1 = 5'b01110;
parameter s_CREATE_ROUND_KEY_2 = 5'b01111;
parameter s_CREATE_ROUND_KEY_3 = 5'b10000;
parameter s_CREATE_ROUND_KEY_DONE = 5'b10001;
parameter s_ADD_ROUND_KEY_DONE = 5'b10010;
parameter s_IDLE = 5'b10011;



reg [4:0] r_sm_main = s_INIT;

reg [0:7] state [0:15];
reg [0:127] r_data = 0;
wire [0:127] w_data_o_sub_byte;
wire [0:127] w_data_o_shift_rows;
wire [0:127] w_data_o_mix_columns;
wire [0:127] w_data_o_add_round_key;
reg r_sub_bytes_active = 0;
reg r_shift_rows_active = 0;
reg r_mix_columns_active = 0;
reg r_add_round_key_active = 0;
reg r_create_round_key_active = 0;
reg [0:31] r_key0;
reg [0:31] r_key1;
reg [0:31] r_key2;
reg [0:31] r_key3;
wire [0:31] w_key0_next;
wire [0:31] w_key1_next;
wire [0:31] w_key2_next;
wire [0:31] w_key3_next;
reg [0:4] r_round_num = 0;
reg r_is_done = 0;
reg [0:127] r_round_keys [0:12];
reg [0:4] r_key_gen_round_num;
reg [0:4] r_round_num_key;


InvSubBytes sub_bytes (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_sub_bytes_active),
	.o_data(w_data_o_sub_byte)
);

InvShiftRows shift_rows (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_shift_rows_active),
	.o_data(w_data_o_shift_rows)
);

InvMixColumns mix_columns (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_mix_columns_active),
	.o_data(w_data_o_mix_columns)
);

AddRoundKey add_round_key_dec (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_add_round_key_active),
	.i_key0(r_key0),
	.i_key1(r_key1),
	.i_key2(r_key2),
	.i_key3(r_key3),
	.o_data(w_data_o_add_round_key)
);

CreateRoundKey create_round_key_dec (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_create_round_key_active),
	.i_key0(r_key0),
	.i_key1(r_key1),
	.i_key2(r_key2),
	.i_key3(r_key3),
	.i_round_num(r_round_num),
	.o_key0(w_key0_next),
	.o_key1(w_key1_next),
	.o_key2(w_key2_next),
	.o_key3(w_key3_next)
);

always @(posedge i_clock) begin
	if (i_rst) begin
		r_sm_main <= s_INIT;
		// r_key0 <= i_key[0:31];
		// r_key1 <= i_key[32:63];
		// r_key2 <= i_key[64:95];
		// r_key3 <= i_key[96:127];
		r_data <= 0;
		r_round_num <= 0;
	end else begin
		if (i_is_active) begin
			case (r_sm_main)
				s_INIT : // 000
					begin
						r_is_done <= 0;
						r_round_num <= 0;
						r_key_gen_round_num <= 0;
						r_round_num_key <= 10;
						r_sm_main <= s_LOAD_INPUT;
					end
				s_LOAD_INPUT : // 001
					begin
						r_data <= i_cipher;
						r_key0 <= i_key[0:31];
						r_key1 <= i_key[32:63];
						r_key2 <= i_key[64:95];
						r_key3 <= i_key[96:127];
						r_round_keys[r_key_gen_round_num] <= {i_key[0:31], i_key[32:63], i_key[64:95], i_key[96:127]};
						r_sm_main <= s_CREATE_ROUND_KEY_0;
						// r_sm_main <= s_INITIAL_ADD_ROUND_KEY_BEGIN;
					end
				s_INITIAL_ADD_ROUND_KEY_BEGIN : // 010
					begin
						r_add_round_key_active <= 1'b1;
						r_key0 <= r_round_keys[r_round_num_key][0:31];
						r_key1 <= r_round_keys[r_round_num_key][32:63];
						r_key2 <= r_round_keys[r_round_num_key][64:95];
						r_key3 <= r_round_keys[r_round_num_key][96:127];
						r_sm_main <= s_INITIAL_ADD_ROUND_KEY_DONE;
					end
				s_INITIAL_ADD_ROUND_KEY_DONE : 
					begin
						r_data <= w_data_o_add_round_key;
						r_add_round_key_active <= 1'b0;
						r_sm_main <= s_SHIFT_ROWS_BEGIN;
					end
				s_SUB_BYTES_BEGIN : // 011
					begin
						r_sub_bytes_active <= 1'b1;
						r_sm_main <= s_SUB_BYTES_DONE;
					end
				s_SUB_BYTES_DONE : // 011
					begin
						r_data <= w_data_o_sub_byte;
						r_sub_bytes_active <= 1'b0;
						r_round_num_key <= r_round_num_key - 1'b1;
						r_sm_main <= s_ADD_ROUND_KEY_BEGIN;
					end
				s_SHIFT_ROWS_BEGIN : // 100
					begin
						r_shift_rows_active <= 1'b1;
						// r_round_num <= r_round_num + 1'b1;
						r_sm_main <= s_SHIFT_ROWS_DONE;
					end
				s_SHIFT_ROWS_DONE :
					begin
						r_data <= w_data_o_shift_rows;
						r_shift_rows_active <= 1'b0;
						r_sm_main <= s_SUB_BYTES_BEGIN;
					end
				s_MIX_COLUMNS_BEGIN :
					begin
						r_mix_columns_active <= 1'b1;
						r_sm_main <= s_MIX_COLUMNS_DONE;
					end
				s_MIX_COLUMNS_DONE :
					begin
						r_data <= w_data_o_mix_columns;
						r_mix_columns_active <= 1'b0;
						r_sm_main <= s_SHIFT_ROWS_BEGIN;
					end
				s_CREATE_ROUND_KEY_0 : 
					begin
						r_create_round_key_active <= 1'b1;
						r_key_gen_round_num <= r_key_gen_round_num + 1'b1;
						r_sm_main <= s_CREATE_ROUND_KEY_1;
					end
				s_CREATE_ROUND_KEY_1 :
					begin
						r_sm_main <= s_CREATE_ROUND_KEY_2;
					end
				s_CREATE_ROUND_KEY_2 :
					begin
						r_sm_main <= s_CREATE_ROUND_KEY_3;
					end
				s_CREATE_ROUND_KEY_3 :
					begin
						r_sm_main <= s_CREATE_ROUND_KEY_DONE;
					end
				s_CREATE_ROUND_KEY_DONE :
					begin
						r_create_round_key_active <= 1'b0;
						r_sm_main <= s_CHANGE_ROUND_KEY;
					end
				s_CHANGE_ROUND_KEY :
					begin
						if (r_key_gen_round_num < 12) begin
							r_key0 <= w_key0_next;
							r_key1 <= w_key1_next;
							r_key2 <= w_key2_next;
							r_key3 <= w_key3_next;
							r_round_keys[r_key_gen_round_num] <= {w_key0_next, w_key1_next, w_key2_next, w_key3_next};
							r_round_num <= r_round_num + 1;
							r_sm_main <= s_CREATE_ROUND_KEY_0;
						end else begin
							r_sm_main <= s_INITIAL_ADD_ROUND_KEY_BEGIN;
						end
					end
				s_ADD_ROUND_KEY_BEGIN : 
					begin
						r_add_round_key_active <= 1'b1;
						r_key0 <= r_round_keys[r_round_num_key][0:31];
						r_key1 <= r_round_keys[r_round_num_key][32:63];
						r_key2 <= r_round_keys[r_round_num_key][64:95];
						r_key3 <= r_round_keys[r_round_num_key][96:127];
						r_sm_main <= s_ADD_ROUND_KEY_DONE;
					end
				s_ADD_ROUND_KEY_DONE :
					begin
						r_data <= w_data_o_add_round_key;
						r_add_round_key_active <= 1'b0;
						if (r_round_num_key > 0) begin
							r_sm_main <= s_MIX_COLUMNS_BEGIN;
						end else begin
							r_sm_main <= s_END;
						end
					end
				s_END : 
					begin
						r_is_done <= 1;
						// r_sm_main <= s_IDLE;
					end
			endcase
		end
	end
end

assign o_plain = r_data;
assign o_is_done = r_is_done;

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

wire [0:127] w_roundkey0;
wire [0:127] w_roundkey1;
wire [0:127] w_roundkey2;
wire [0:127] w_roundkey3;
wire [0:127] w_roundkey4;
wire [0:127] w_roundkey5;
wire [0:127] w_roundkey6;
wire [0:127] w_roundkey7;
wire [0:127] w_roundkey8;
wire [0:127] w_roundkey9;
wire [0:127] w_roundkey10;
wire [0:127] w_roundkey11;

assign w_roundkey0 = r_round_keys[0];
assign w_roundkey1 = r_round_keys[1];
assign w_roundkey2 = r_round_keys[2];
assign w_roundkey3 = r_round_keys[3];
assign w_roundkey4 = r_round_keys[4];
assign w_roundkey5 = r_round_keys[5];
assign w_roundkey6 = r_round_keys[6];
assign w_roundkey7 = r_round_keys[7];
assign w_roundkey8 = r_round_keys[8];
assign w_roundkey9 = r_round_keys[9];
assign w_roundkey10 = r_round_keys[10];

endmodule

