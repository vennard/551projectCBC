
module bit14_reg_clr(in, out, clk, en, clr);

	input [13:0] in;
	input clk;
	input en;
	input clr;

	output reg [13:0] out;

	wire [13:0] nxt;

	always @(posedge clk) begin
		out <= nxt;
	end
	assign nxt = (en) ? ((clr) ? 14'h0000 : in) : out;

endmodule
