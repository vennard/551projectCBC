//Kevin Blair
//HW4 P4

module UART(clk, rst_n, tx_data, trmt, tx_done, rx_data, rdy, clr_rdy, TX, RX);

	input clk;
	input rst_n;

	//tx 
	//inputs
	input [7:0] tx_data;
	input trmt;
	//outputs
	output tx_done;
	output TX;

	//rx 
	//inputs
	input clr_rdy;
	input RX;
	//outputs
	output [7:0] rx_data;
	output rdy;

	UART_tx TXER(.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), .tx_done(tx_done), .TX(TX));
	UART_rx RXER(.clk(clk), .rst_n(rst_n), .rx_data(rx_data), .rdy(rdy), .RX(RX), .clr_rdy(clr_rdy));

endmodule
