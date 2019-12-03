
`timescale 1ns / 1ps


`include "uart_tx.v"
`include "uart_rx.v"
 
module uart_tb();
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8700; // NS
   
  reg r_clock = 0;
  reg r_tx_dv = 0; // tx data valid
  wire w_tx_done; // tx output
  reg [7:0] r_tx_byte = 0;
  reg r_rx_serial = 1;
  wire [7:0] w_rx_byte;

  // integer file_output; // for saving output
   
 
  // Takes in input byte and serializes it
  // Used to simulate the receiving serial signal
  task UART_WRITE_BYTE;
    input [7:0] i_data;
    integer     ii;
    begin
       
      // Send Start Bit
      r_rx_serial <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;

      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          r_rx_serial <= i_data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      r_rx_serial <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
   
   
  // UART receiver
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST (
    .i_clock(r_clock),
    .i_rx_serial(r_rx_serial),
    .o_rx_dv(),
    .o_rx_byte(w_rx_byte)
  );
   
  // UART transceiver
  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST (
    .i_clock(r_clock),
    .i_tx_dv(r_tx_dv),
    .i_tx_byte(r_tx_byte),
    .o_tx_active(),
    .o_tx_serial(),
    .o_tx_done(w_tx_done)
  );
 
   
  always
    #(c_CLOCK_PERIOD_NS/2) r_clock <= !r_clock;
   
  // Main Testing:
  initial
    begin       
   		$dumpfile("uart_tb.vcd");
      $dumpvars;

      // file_output = $fopen("uart_tb_output.txt");
      $display("time\tr_tx_byte\tw_tx_done\tr_rx_serial\tw_rx_byte");
      $monitor("%6d\t%2x\t%2x\t%2x\t%2x", $time, r_tx_byte, w_tx_done, r_rx_serial, w_rx_byte);
	
      // Tell UART to send a command (exercise Tx)
      @(posedge r_clock);
      @(posedge r_clock);
      r_tx_dv <= 1'b1;
      r_tx_byte <= 8'hAB;
      @(posedge r_clock);
      @(posedge r_clock);
      @(posedge r_clock);
      @(posedge r_clock);
      @(posedge r_clock);
      r_tx_dv <= 1'b0;
      @(posedge w_tx_done);
       
      // Send a command to the UART (exercise Rx)
      @(posedge r_clock);
      UART_WRITE_BYTE(8'h3F);
      @(posedge r_clock);
             
      // Check that the correct command was received
      if (w_rx_byte == 8'h3F) begin
        $display("Test Passed - Correct Byte Received");
		    $finish;
      end else begin
        $display("Test Failed - Incorrect Byte Received");
       	$finish;
		  end
    end
   
endmodule
