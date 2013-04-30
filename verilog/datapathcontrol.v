
module datapath_control();

	wire [13:0] dst; 

	//sm use
	wire [1:0] c_prod;
	reg c_err, c_duty, c_sumerr, c_diferr, c_xset, c_preverr,
			c_pid, c_init_prod, c_subtract, c_multsat, c_clr_duty;
	reg [2:0] c_asel, c_bsel;

	reg [2:0] state;
	reg [2:0] nxt_state;

	reg [3:0] adds;
	reg clr_adds;
	reg inc_adds;

	wire prod_vld;

	//tb controlled
	reg gogo, clk, rst_n;
	reg [13:0] eep_rd_data, xmeas, cfg_data; 

	//datapath block
	dc_datapath dp(.dst(dst), .c_prod(c_prod), .eep_rd_data(eep_rd_data), 
				.xmeas(xmeas), .cfg_data(cfg_data), .clk(clk), .rst_n(rst_n),
				.c_asel(c_asel), .c_bsel(c_bsel), .c_err(c_err), .c_duty(c_duty), 
				.c_sumerr(c_sumerr), .c_diferr(c_diferr), .c_xset(c_xset),
				.c_preverr(c_preverr), .c_pid(c_pid), .c_init_prod(c_init_prod), 
				.c_subtract(c_subtract), .c_multsat(c_multsat), 
				.c_clr_duty(c_clr_duty));

	//state machine==============================================================
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

	//state params
	localparam LDP = 3'b000,
					LDXSET = 3'b001,
					SETERR = 3'b010,
					MULTINIT = 3'b011,
					MULT = 3'b100;
	always@(posedge clk, negedge rst_n) begin
		if(~rst_n)
			state <= 3'b000;
		else	
			state <= nxt_state;
	end
	always@(*)begin
		//defaults
		c_err = 1'b0; 
		c_duty = 1'b0;
		c_sumerr = 1'b0; 
		c_diferr = 1'b0; 
		c_xset = 1'b0; 
		c_preverr = 1'b0; 
		c_pid = 1'b0;
		c_init_prod = 1'b0;
 
		c_subtract = 1'b0;
		c_multsat = 1'b0;
		c_clr_duty = 1'b0;

		inc_adds = 1'b0;
		clr_adds = 1'b0;
		
		c_asel = ZEROA; 
		c_bsel = ZEROB;

		nxt_state = LDP;
		case(state)
			LDP: begin
				if(gogo) begin
					c_pid = 1'b1;
					c_bsel = EEPDATA;
					c_asel = ZEROA;
					nxt_state = LDXSET;
				end else				
					nxt_state = LDP;
			end
			LDXSET: begin
				c_xset = 1'b1;
				c_bsel = EEPDATA;
				c_asel = ZEROA;
				nxt_state = SETERR;
			end
			SETERR: begin
				c_err = 1'b1;
				c_subtract = 1'b1;
				c_asel = XMEAS;
				c_bsel = XSET;
				nxt_state = MULTINIT;
			end
			MULTINIT: begin
				c_init_prod = 1'b1;
				c_asel = ERR;
				c_bsel = ZEROB;
				clr_adds = 1'b1;				
				nxt_state = MULT;
			end
			MULT: begin
				if(~prod_vld)begin
					inc_adds = 1'b1;
					nxt_state = MULT;
					c_asel = PROD2815;
					if(c_prod == 2'b10) begin
						c_bsel = PID;
						c_subtract = 1'b1;
					end else if(c_prod == 2'b01)
						c_bsel = PID;
					else
						c_bsel = ZEROB;						
				end else begin
					c_bsel = PROD2512;
					c_asel = ZEROA;
					c_multsat = 1'b1;
					nxt_state = LDP;
				end
			end
		endcase
	end
	//counter
	always @(posedge clk, negedge rst_n)begin
		if(~rst_n)	
			adds <= 4'b0000;
		else if(clr_adds)
			adds <= 4'b0000;
		else if(inc_adds)
			adds <= adds + 1;
		else
			adds <= adds;
	end
	assign prod_vld = (adds == 4'hE);
	//===========================================================================


	//testbench stuff
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial begin
		rst_n = 0;
		repeat(3) @(negedge clk);
		rst_n = 1;
	end
	
	//need to set eep_rd_data, xmeas, and cfg_data to simulate commands
	initial begin
		gogo = 1'b1;
		eep_rd_data = 14'h0555;
		xmeas = 14'h0666; 
		cfg_data = 14'h0000;
		@(posedge rst_n);
		@(state == LDP);
		eep_rd_data = 14'h0000;
		@(negedge clk);		
		@(state == LDXSET);
		eep_rd_data = 14'h0000;
		gogo = 1'b0;
		@(negedge clk)
		@(state == MULTINIT);
		xmeas = 14'h0666;
		@(state == LDP)
		repeat(3)@(posedge clk);
		$finish();		
	end

	initial begin
		$dumpfile("datapath.vcd");
		$dumpvars();	
	end

endmodule
