module dc_datapath(dst, c_prod, eep_rd_data, xmeas, cfg_data, clk, rst_n,
				c_asel, c_bsel, c_err, c_duty, c_sumerr, c_diferr, c_xset,
				c_preverr, c_pid, c_init_prod, c_subtract, c_multsat, c_clr_duty);

	//selector A params
	localparam	CFGDATA	= 3'b000,
					XMEAS 	= 3'b001,
					ERR		= 3'b010,
					PROD2815	= 3'b011,
					DUTY		= 3'b100,
					SUMERRA	= 3'b101,
					DIFERR	= 3'b110,
					ZEROA		= 3'b111;
	//selector B params
	localparam	XSET		= 3'b000,
					SUMERRB	= 3'b001,
					PREVERR	= 3'b010,
					ZEROB		= 3'b011,
					PID		= 3'b100,
					POSACKA5A= 3'b101,
					PROD2512	= 3'b110,
					EEPDATA	= 3'b111;

	input [13:0] eep_rd_data;
	input [13:0] xmeas;
	input [13:0] cfg_data;

	input [2:0] c_asel; 
	input [2:0] c_bsel; 

	input c_err; 
	input c_duty; 
	input c_sumerr; 
	input c_diferr; 
	input c_xset; 
	input c_preverr; 
	input c_pid; 
	input c_init_prod;
	input c_subtract; 
	input c_multsat;
	input c_clr_duty;

	input clk;
	input rst_n;

	output [13:0] dst;
	output [1:0] c_prod;

	wire [13:0] err; 
	wire [13:0] duty; 
	wire [13:0] sumerr; 
	wire [13:0] diferr; 
	wire [13:0] xset; 
	wire [13:0] preverr; 
	wire [13:0] pid; 

	reg [13:0] a;
	reg [13:0] braw;
 	wire [13:0] b_n;
	wire [13:0] b;
 	wire [13:0] rawsum;

 	reg [28:0] prod;
 	wire [28:0] nxt_prod;

	//========================working registers========================
	bit14_reg 		err_reg		(.in(dst), .out(err), 		.clk(clk), .en(c_err));
	bit14_reg_clr	duty_reg		(.in(dst), .out(duty), 		.clk(clk), .en(c_duty), 	.clr(c_clr_duty));
	bit14_reg 		diferr_reg	(.in(dst), .out(diferr),	.clk(clk), .en(c_diferr));
	bit14_reg 		xset_reg		(.in(dst), .out(xset), 		.clk(clk), .en(c_xset));
	bit14_reg_rst	sumerr_reg	(.in(dst), .out(sumerr),	.clk(clk), .en(c_sumerr),	.rst_n(rst_n));
	bit14_reg_rst	preverr_reg	(.in(dst), .out(preverr),	.clk(clk), .en(c_preverr),	.rst_n(rst_n));
	bit14_reg		pid_reg		(.in(dst), .out(pid), 		.clk(clk), .en(c_pid));

	//========================selectors========================
	always@(*)begin
		case(c_asel)
			CFGDATA:		a = cfg_data;
			XMEAS:		a = xmeas;
			ERR:			a = err;
			PROD2815:	a = prod[28:15];
			DUTY:			a = duty;
			SUMERRA:		a = sumerr;
			DIFERR:		a = diferr;
			ZEROA:		a = 14'h0000;
			default		a = 14'h0000;
		endcase
		case(c_bsel)
			XSET:			braw = xset;
			SUMERRB:		braw = sumerr;
			PREVERR:		braw = preverr;
			ZEROB:		braw = 14'h0000;
			PID:			braw = pid;
			POSACKA5A:	braw = 14'h0A5A;
			PROD2512:	braw = prod[25:12];
			EEPDATA:		braw = eep_rd_data;
			default		braw = 14'h0000;
		endcase
	end

	//========================b selection inverter========================
	assign b_n = ~braw;
	assign b = (c_subtract) ? b_n : braw;

	//========================adder========================
	assign rawsum = a + b + c_subtract;

	//========================saturator========================
	saturator satblock(.in(rawsum), .out(dst), .multsat(c_multsat), .a13(a[13]),
							 .b13(b[13]), .prod_msb(prod[28:26]));

	//========================booth multiply support hardware========================
	always @(posedge clk) begin
		prod <= nxt_prod;
	end
	assign nxt_prod = (c_init_prod) ? {14'h0000,dst,1'b0} : {dst[13],dst,prod[14:1]};

	assign c_prod = prod[1:0];

endmodule

