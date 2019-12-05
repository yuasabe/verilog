module AddRoundKey(
	input i_clock,
	input [0:127] i_data,
	input i_active,
	input [0:31] i_key0,
	input [0:31] i_key1,
	input [0:31] i_key2,
	input [0:31] i_key3,
	output [0:127] o_data
);

reg [0:127] r_data;
// reg [0:7] r_state [0:15];

function [31 : 0] roundkeyw(input [31 : 0] w, input [31:0] key);
begin
	roundkeyw = w ^ key;
end
endfunction // roundkeyw

function [0:127] roundkey(
	input [0:127] data,
	input [0:31] key0,
	input [0:31] key1,
	input [0:31] key2,
	input [0:31] key3
);
reg [0:31] w0, w1, w2, w3;
reg [0:31] ws0, ws1, ws2, ws3;
begin
  w0 = data[0:31];
  w1 = data[32:63];
  w2 = data[64:95];
  w3 = data[96:127];

  ws0 = roundkeyw(w0, key0);
  ws1 = roundkeyw(w1, key1);
  ws2 = roundkeyw(w2, key2);
  ws3 = roundkeyw(w3, key3);

  roundkey = {ws0, ws1, ws2, ws3};
end
endfunction // roundkey


always @(negedge i_clock) begin
	if (i_active) begin
		r_data <= roundkey(i_data, i_key0, i_key1, i_key2, i_key3);
	end
end

assign o_data = r_data;

endmodule