
module bit14_reg_rst(in, out, clk, en, rst_n);

	input [13:0] in;
	input clk;
	input en;
	input rst_n;

	output reg [13:0] out;

	wire [13:0] nxt;

	always @(posedge clk or negedge rst_n) begin
		if(~rst_n)		
			out <= 14'h0000;
		else
			out <= nxt;			
	end
	assign nxt = (en) ? in : out;

endmodule
