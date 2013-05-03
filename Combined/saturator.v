
module saturator(in, out, multsat, a13, b13, prod_msb);

	input [13:0] in;
	input multsat;
	input a13;
	input b13;
	input [2:0] prod_msb;
	
	output [13:0] out;

	wire overflow;
	wire underflow;

	wire [13:0] normout;
	wire [13:0] multsatout;
	
	wire [13:0] prodoverflow;
	wire [13:0] produnderflow;


	assign out = (multsat) ? multsatout : normout;

	assign multsatout = (prodoverflow)		?	14'h1FFF :
								(produnderflow)	?	14'h2000 :
															in;

	assign prodoverflow = ~prod_msb[2] & (|{prod_msb[1:0],in[13]});
	assign produnderflow = prod_msb[2] & (~&{prod_msb[1:0],in[13]});

	assign normout = (overflow) 	? 	14'h1FFF :
							(underflow) ? 	14'h2000 :
												in;

	assign overflow = ~a13 & ~b13 & in[13];
	assign underflow = a13 & b13 & ~in[13];


endmodule
