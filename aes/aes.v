
`include "sub_bytes.v"
`include "shift_rows.v"
`include "mix_columns.v"
`include "add_round_key.v"
`include "create_round_key.v"

module aes_top(
	input i_clock,
	input [0:127] i_plain,
	input [0:127] i_key,
	output [0:127] o_cipher
);

parameter s_INIT			= 5'b00000;
parameter s_LOAD_INPUT		= 5'b00001;
parameter s_INITIAL_ADD_ROUND_KEY = 5'b00010;
parameter s_SUB_BYTES 		= 5'b00011;
parameter s_SHIFT_ROWS 		= 5'b00100;
parameter s_MIX_COLUMNS		= 5'b00101;
parameter s_CREATE_ROUND_KEY = 5'b00110;
parameter s_CHANGE_ROUND_KEY = 5'b00111;
parameter s_ADD_ROUND_KEY	= 5'b01000;
parameter s_END = 5'b01001;

reg [4:0] r_sm_main = 0;

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
reg [0:2] clock_counter = 0;
reg [0:31] r_key0 = 32'h2b7e1516;
reg [0:31] r_key1 = 32'h28aed2a6;
reg [0:31] r_key2 = 32'habf71588;
reg [0:31] r_key3 = 32'h09cf4f3c;
wire [0:31] w_key0_next;
wire [0:31] w_key1_next;
wire [0:31] w_key2_next;
wire [0:31] w_key3_next;
reg [0:4] r_round_num = 0;


SubBytes sub_bytes (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_sub_bytes_active),
	.o_data(w_data_o_sub_byte)
);

ShiftRows shift_rows (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_shift_rows_active),
	.o_data(w_data_o_shift_rows)
);

MixColumns mix_columns (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_mix_columns_active),
	.o_data(w_data_o_mix_columns)
);

AddRoundKey add_round_key (
	.i_clock(i_clock),
	.i_data(r_data),
	.i_active(r_add_round_key_active),
	.i_key0(r_key0),
	.i_key1(r_key1),
	.i_key2(r_key2),
	.i_key3(r_key3),
	.o_data(w_data_o_add_round_key)
);

CreateRoundKey create_round_key (
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

wire [7:0] uart_IN_data;
wire uart_we;
wire uart_OUT_data;

uart uart0(
    .uart_tx(uart_OUT_data),
    .uart_wr_i(uart_we),
    .uart_dat_i(uart_IN_data),
    .sys_clk_i(i_clock),
    .sys_rstn_i(cpu_resetn)
);

assign uart_tx = uart_OUT_data;

always @(posedge i_clock) begin
	case (r_sm_main)
		s_INIT : // 000
			begin
				r_sm_main <= s_LOAD_INPUT;
			end
		s_LOAD_INPUT : // 001
			begin
				r_data <= i_plain;
				r_sm_main <= s_INITIAL_ADD_ROUND_KEY;
			end
		s_INITIAL_ADD_ROUND_KEY : // 010
			begin
				clock_counter = clock_counter + 1;
				r_add_round_key_active <= 1'b1;
				if (clock_counter == 3) begin
					r_data <= w_data_o_add_round_key;
					r_add_round_key_active <= 1'b0;
					clock_counter <= 0;
					r_sm_main <= s_SUB_BYTES;
				end
			end
		s_SUB_BYTES : // 011
			begin
				clock_counter = clock_counter + 1;
				r_sub_bytes_active <= 1'b1;
				if (clock_counter == 3) begin
					r_data <= w_data_o_sub_byte;
					r_sub_bytes_active <= 1'b0;
					clock_counter <= 0;
					r_sm_main <= s_SHIFT_ROWS;
				end
			end
		s_SHIFT_ROWS : // 100
			begin
				clock_counter = clock_counter + 1;
				r_shift_rows_active <= 1'b1;
				if (clock_counter == 3) begin
					r_data <= w_data_o_shift_rows;
					r_shift_rows_active <= 1'b0;
					clock_counter <= 0;
					r_sm_main <= s_MIX_COLUMNS;
				end
			end
		s_MIX_COLUMNS :
			begin
				if (r_round_num < 9) begin
					clock_counter = clock_counter + 1;
					r_mix_columns_active <= 1'b1;
					if (clock_counter == 3) begin
						r_data <= w_data_o_mix_columns;
						r_mix_columns_active <= 1'b0;
						clock_counter <= 0;
						r_sm_main <= s_CREATE_ROUND_KEY;
					end
				end else begin
					r_sm_main <= s_CREATE_ROUND_KEY;
				end
			end
		s_CREATE_ROUND_KEY : 
			begin
				clock_counter = clock_counter + 1;
				r_create_round_key_active <= 1'b1;
				if (clock_counter == 5) begin
					r_create_round_key_active <= 1'b0;
					clock_counter <= 0;
					r_sm_main <= s_CHANGE_ROUND_KEY;
				end
			end
		s_CHANGE_ROUND_KEY :
			begin
				r_key0 <= w_key0_next;
				r_key1 <= w_key1_next;
				r_key2 <= w_key2_next;
				r_key3 <= w_key3_next;
				r_sm_main <= s_ADD_ROUND_KEY;
			end
		s_ADD_ROUND_KEY : 
			begin
				clock_counter = clock_counter + 1;
				r_add_round_key_active <= 1'b1;
				if (clock_counter == 3) begin
					r_data <= w_data_o_add_round_key;
					r_add_round_key_active <= 1'b0;
					clock_counter <= 0;
					r_round_num <= r_round_num + 1;
					if (r_round_num < 9) begin
						r_sm_main <= s_SUB_BYTES;
					end else begin
						r_sm_main <= s_END;
					end
				end
			end
		s_END : 
			begin
				
			end
	endcase
end

assign o_cipher = r_data;

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

