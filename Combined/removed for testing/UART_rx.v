//Kevin Blair
//HW4 P3

module UART_rx(rx_data, rdy, RX, clr_rdy, clk, rst_n);

	localparam 	RST = 3'b000,
				S_BIT = 3'b001,
				RX0 = 3'b010,
				RX1 = 3'b011,
				RDY = 3'b100,
				IDLE = 3'b101;

	input clk;
	input rst_n;

	input RX;
	input clr_rdy;

	output reg rdy;
	output reg [7:0] rx_data;

	//state control
	reg [2:0] state;
	reg [2:0] nxt_state;	

	//counter and shift control from SM
	reg shift;

	reg bit_cnt_inc;
	reg bit_cnt_clr;

	reg numb_hbs_cnt_inc;
	reg numb_hbs_cnt_clr;

	reg hb_cnt_en;
	reg hb_cnt_clr;

	//counter and shift returns to SM
	wire negedge_rx;

	wire half_baud;

	wire numb_hbs_cnt_3;
	wire numb_hbs_cnt_2;

	wire got_byte;

	//RX input condition lines
	reg RX_f1;
	reg RX_f2;
	reg RX_in;

	//counter internals
	wire [8:0] nxt_hb_cnt;
	wire [1:0] nxt_numb_hbs_cnt;
	wire [2:0] nxt_bit_cnt;

	reg [8:0] hb_cnt;
	reg [1:0] numb_hbs_cnt;
	reg [2:0] bit_cnt;

//==============================Counters==============================
	//====================Assert on Half Baud====================
	always@(posedge clk) begin
		hb_cnt <= nxt_hb_cnt;
	end
	assign nxt_hb_cnt = (hb_cnt_clr) ?	9'h000 :
				(hb_cnt_en)  ? 	(hb_cnt+1) :
						hb_cnt;

	assign half_baud = (hb_cnt == 434);

	//====================Half Baud Count====================
	always@(posedge clk) begin
		numb_hbs_cnt <= nxt_numb_hbs_cnt;
	end
	assign nxt_numb_hbs_cnt = (numb_hbs_cnt_clr) ? 2'b00 :
				  (numb_hbs_cnt_inc) ? (numb_hbs_cnt+1) :
							   numb_hbs_cnt;

	assign numb_hbs_cnt_3 = (numb_hbs_cnt == 3);
	assign numb_hbs_cnt_2 = (numb_hbs_cnt == 2);

	//====================Count Bits RX'd====================
	always@(posedge clk) begin
		bit_cnt <= nxt_bit_cnt;
	end
	assign nxt_bit_cnt = (bit_cnt_clr) ? 3'b000 :
			 	(bit_cnt_inc) ? (bit_cnt+1) :
						 bit_cnt;

	assign got_byte = (bit_cnt == 0);

//==============================RX input & shift reg============================

	//====================RX input conditioning====================
	always@(posedge clk) begin
		RX_f1 <= RX;
	end
	always@(posedge clk) begin
		RX_f2 <= RX_f1;
	end
	always@(posedge clk) begin
		RX_in <= RX_f2;
	end

	//====================start bit detection====================
	assign negedge_rx = (~RX_f2) & RX_in;
	
	//====================Shift Register====================
	always@(posedge clk, negedge rst_n) begin
		if(!rst_n)		
			rx_data <= 8'h00;
		else if(shift)
			rx_data <= {RX_in,rx_data[7:1]};			
		else
			rx_data <= rx_data;
	end

//==============================SM==============================

	//====================SM Flop====================
	always@(posedge clk, negedge rst_n) begin
		if(!rst_n)
			state <= RST;
		else
			state <= nxt_state;
	end

	//====================SM Comb====================
	always@(*) begin
		rdy = 1'b0;

		shift = 1'b0;
		
		bit_cnt_inc = 1'b0;
		bit_cnt_clr = 1'b0;

		numb_hbs_cnt_inc = 1'b0;
		numb_hbs_cnt_clr = 1'b0;

		hb_cnt_en = 1'b1;
		hb_cnt_clr = 1'b0;

		nxt_state = IDLE;
		
		case(state)
			RST : begin
				if(negedge_rx) begin //start bit incoming
					bit_cnt_clr = 1'b1;
					numb_hbs_cnt_clr = 1'b1;					
					hb_cnt_clr = 1'b1;
					nxt_state = S_BIT;
				end else begin
					hb_cnt_en = 1'b0;
					nxt_state = RST;				
				end
			end
			S_BIT : begin //waiting for start bit
				if(half_baud) begin
					numb_hbs_cnt_inc = 1'b1;
					hb_cnt_clr = 1'b1;
					nxt_state = S_BIT;
				end else if(numb_hbs_cnt_3) begin
					shift = 1'b1;
					bit_cnt_inc = 1'b1;
					numb_hbs_cnt_clr = 1'b1;
					hb_cnt_clr = 1'b1;
					nxt_state = RX0;
				end else begin
					nxt_state = S_BIT;				
				end
			end
			RX0 : begin
				if(half_baud) begin
					numb_hbs_cnt_inc = 1'b1;
					hb_cnt_clr = 1'b1;
					nxt_state = RX1;
				end else if(got_byte) begin
					rdy = 1'b1;
					hb_cnt_en = 1'b0;
					nxt_state = RDY;			
				end else begin
					nxt_state= RX0;
				end
			end
			RX1 : begin
				if(numb_hbs_cnt_2) begin
					shift = 1'b1;
					bit_cnt_inc = 1'b1;
					numb_hbs_cnt_clr = 1'b1;
					nxt_state= RX0;
				end else begin
					nxt_state = RX0;
				end
			end
			RDY : begin
				if(clr_rdy) begin
					hb_cnt_en = 1'b0;	
					nxt_state = IDLE;
				end else begin
					rdy = 1'b1;
					hb_cnt_en = 1'b0;
					nxt_state = RDY;
				end
			end
			IDLE : begin
				if(negedge_rx) begin //start bit incoming
					bit_cnt_clr = 1'b1;
					numb_hbs_cnt_clr = 1'b1;					
					hb_cnt_clr = 1'b1;
					nxt_state = S_BIT;
				end else begin
					hb_cnt_en = 1'b0;
					nxt_state = RST;				
				end
			end
			default : nxt_state = IDLE;
		endcase
	end
endmodule
