//Bit Swizzlers
//HW5 P3

module cfg_UART(clk, rst_n, TX, RX, clr_frm_rdy, snd_rsp, rsp_data, frm_rdy, cfg_data);

	localparam IDLE = 4'b0000,
					GOTMSB = 4'b0001,
					WAITB2 = 4'b0010,
					GOTB2 = 4'b0011,
					WAITLSB = 4'b0100,
					CFGRDY = 4'b0101,
					WAITRSP = 4'b0110,
					WAITTX = 4'b0111,
					TXLSB = 4'b1000;

	input clk;
	input rst_n;

	input RX;
	input clr_frm_rdy;
	input snd_rsp;
	input [15:0] rsp_data;

	output TX;
	output reg frm_rdy;
	output [23:0] cfg_data;

	wire [7:0] tx_data;
	reg trmt;
	wire tx_done;
	wire [7:0] rx_data;
	wire rdy;
	reg clr_rdy;
	reg rsp_data_sel;
	
	reg msb_cfg_en;
	reg b2_cfg_en;

	reg [4:0] state;
	reg [4:0] nxt_state;

	reg [7:0] rsp_data_lsb;

	reg [7:0] cfg_data_msb;
	reg [7:0] cfg_data_b2;

	UART UART_mod(.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), 
		.tx_done(tx_done), .rx_data(rx_data), .rdy(rdy), 
		.clr_rdy(clr_rdy), .TX(TX), .RX(RX));

//=========TX DATA ASSIGNMENT=========
	assign tx_data = (rsp_data_sel) ? rsp_data_lsb : rsp_data[15:8];
	always@(posedge clk)begin
		if(snd_rsp)
			rsp_data_lsb <= rsp_data[7:0];
	end

//=========CFG DATA ASSIGNMENT=========
	assign cfg_data = {cfg_data_msb,cfg_data_b2,rx_data};

	always@(posedge clk)begin
		if(msb_cfg_en)
			cfg_data_msb <= rx_data;
	end

	always@(posedge clk)begin
		if(b2_cfg_en)
			cfg_data_b2 <= rx_data;
	end

//=========SM=========
//=========SM FLOPS=========

	always@(posedge clk, negedge rst_n)begin
		if(~rst_n)
			state <= 4'b0000;
		else
			state <= nxt_state;
	end

//=========SM COMB=========
	always@(*) begin
		clr_rdy = 1'b0;
		trmt = 1'b0;
		msb_cfg_en = 1'b0;
		b2_cfg_en = 1'b0;
		rsp_data_sel = 1'b0;
		frm_rdy = 1'b0;
		case (state)
				IDLE : begin
					if(rdy) begin
						nxt_state = GOTMSB;
						msb_cfg_en = 1'b1;
					end else
						nxt_state = IDLE;
				end
				GOTMSB : begin
					clr_rdy = 1'b1;
					nxt_state = WAITB2;
				end
				WAITB2 : begin
					if(rdy) begin
						nxt_state = GOTB2;
						b2_cfg_en = 1'b1;
					end else
						nxt_state = WAITB2;
				end
				GOTB2 : begin
					clr_rdy = 1'b1;
					nxt_state = WAITLSB;			
				end
				WAITLSB : begin
					if(rdy) begin
						nxt_state = CFGRDY;
						frm_rdy = 1'b1;
					end else
						nxt_state = WAITLSB;					
				end
				CFGRDY : begin
					if(clr_frm_rdy) begin
						clr_rdy = 1'b1;
						nxt_state = WAITRSP;
					end else begin
						frm_rdy = 1'b1;
						nxt_state = CFGRDY;
					end
				end
				WAITRSP : begin
					if(snd_rsp) begin
						trmt = 1'b1;
						nxt_state = WAITTX;
					end else
						nxt_state = WAITRSP;
				end
				WAITTX :	begin
					if(tx_done)begin
						trmt = 1'b1;
						rsp_data_sel = 1'b1;
						nxt_state = TXLSB;
					end else
						nxt_state = WAITTX;
				end
				TXLSB : begin
					if(tx_done)
						nxt_state = IDLE;
					else
						nxt_state = TXLSB;
				end
			default : nxt_state = IDLE;
		endcase
	end
endmodule
