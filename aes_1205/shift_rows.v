module ShiftRows(
	input i_clock,
	input [0:127] i_data,
	input i_active,
	output [0:127] o_data
);

reg [0:127] r_data;

always @(negedge i_clock) begin
	if (i_active) begin
		r_data[0:7] <= i_data[0:7];
		r_data[32:39] <= i_data[32:39];
		r_data[64:71] <= i_data[64:71];
		r_data[96:103] <= i_data[96:103];

		r_data[8:15] <= i_data[40:47];
		r_data[40:47] <= i_data[72:79];
		r_data[72:79] <= i_data[104:111];
		r_data[104:111] <= i_data[8:15];

		r_data[16:23] <= i_data[80:87];
		r_data[48:55] <= i_data[112:119];
		r_data[80:87] <= i_data[16:23];
		r_data[112:119] <= i_data[48:55];

		r_data[24:31] <= i_data[120:127];
		r_data[56:63] <= i_data[24:31];
		r_data[88:95] <= i_data[56:63];
		r_data[120:127] <= i_data[88:95];
	end
end

assign o_data = r_data;

endmodule