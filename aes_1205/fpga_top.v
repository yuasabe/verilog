`timescale 1ns / 1ps

`include "uart.v"
`include "aes.v"

module fpga_top(
	input clk, // AD8 100MHz
	input rst_n, // T23
	input BUTTON_C, // B21
	output uart_tx, // AD14
	output LED_C, // T22
	output LED_E, // Y18
	output LED_W, // AA18
	output LED_S, // AA8
	output LED_N, // Y8
	output [7:0] LED
);

reg r_LED_W = 0;
reg r_LED_E = 0;
reg r_LED_S = 0;
reg r_LED_C = 0;
assign LED_E = r_LED_E;
assign LED_S = r_LED_S;
assign LED_N = BUTTON_C;
assign LED_C = r_LED_C;
assign LED_W = r_LED_W;
 
reg [7:0] r_tx_byte;

assign LED = r_tx_byte;
  
wire uart_we;
reg r_uart_we;
wire uart_OUT_data;
wire uart_busy;

reg [0:127] r_plain = 128'h3243f6a8885a308d313198a2e0370734;
reg [0:127] r_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
wire [0:127] w_cipher;
wire w_is_done;
	 
uart uart0(
	.uart_tx(uart_OUT_data),
	.uart_busy(uart_busy),
	.uart_wr_i(uart_we),
	.uart_dat_i(r_tx_byte),
	.sys_clk_i(clk),
	.sys_rstn_i(rst_n)
);

aes_top aes_top(
	.i_clock(clk),
	.i_plain(r_plain),
	.i_key(r_key),
	.o_cipher(w_cipher),
	.o_is_done(w_is_done)
);
	 
assign uart_tx = uart_OUT_data;
assign uart_we = r_uart_we;
	
wire [0:7] w_data [0:16];
assign w_data[0] = w_cipher[0:7];
assign w_data[1] = w_cipher[8:15];
assign w_data[2] = w_cipher[16:23];
assign w_data[3] = w_cipher[24:31];
assign w_data[4] = w_cipher[32:39];
assign w_data[5] = w_cipher[40:47];
assign w_data[6] = w_cipher[48:55];
assign w_data[7] = w_cipher[56:63];
assign w_data[8] = w_cipher[64:71];
assign w_data[9] = w_cipher[72:79];
assign w_data[10] = w_cipher[80:87];
assign w_data[11] = w_cipher[88:95];
assign w_data[12] = w_cipher[96:103];
assign w_data[13] = w_cipher[104:111];
assign w_data[14] = w_cipher[112:119];
assign w_data[15] = w_cipher[120:127];
assign w_data[16] = 8'h00;
reg [2:0] r_sm_main = 0;
reg [2:0] counter = 5'b00000;
reg r_rst_sm = 0;

parameter s_ENCODE = 3'b000;
parameter s_UART_BEGIN = 3'b001;
parameter s_UART_TRANSFERING = 3'b010;
parameter s_UART_TRANSFERING_2 = 3'b011;
parameter s_UART_WAIT_DONE = 3'b100;
parameter s_UART_RETURN = 3'b101;
parameter s_FINISH = 3'b110;

always @(posedge clk) begin
	case (r_sm_main)
		s_ENCODE : begin
			r_LED_W <= 1;
			// r_plain <= 128'h3243f6a8885a308d313198a2e0370734;
			// r_key <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
			if (w_is_done) begin
				r_LED_E <= 1;
				r_sm_main <= s_UART_BEGIN;
			end
		end
		s_UART_BEGIN : begin
			if(counter != 5'b10000) begin 
				r_rst_sm <= 0;
				r_LED_W <= 0;
				r_uart_we <= 1;
				r_tx_byte <= w_data[counter];
				r_sm_main <= s_UART_TRANSFERING;
			end else begin
				r_sm_main <= s_FINISH;
			end
		end
		s_UART_TRANSFERING : begin
			r_uart_we <= 0;
			r_sm_main <= s_UART_TRANSFERING_2;
		end
		s_UART_TRANSFERING_2 : begin
			r_sm_main <= s_UART_WAIT_DONE;
		end
		s_UART_WAIT_DONE : begin
			if (~uart_busy) begin // not busy
				r_LED_W <= 1;
				r_sm_main <= s_UART_RETURN;
			end
		end
		s_UART_RETURN : begin
			r_sm_main <= s_UART_BEGIN;
			counter <= counter + 1;
		end
		s_FINISH : begin
			r_LED_C <= 1;
		end
	endcase
end


endmodule
