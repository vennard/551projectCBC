
module bit14_reg(in, out, clk, en);

	input [13:0] in;
	input clk;
	input en;

	output reg [13:0] out;

	wire [13:0] nxt;

	always @(posedge clk) begin
		out <= nxt;
	end
	assign nxt = (en) ? in : out;

endmodule
