//John Vennard
//UART module
//Structural verilog only
module UART(tx_data,trmt,tx_done,clk,rst_n,TX,RX
				,rx_data,rdy,clr_rdy);

//Inputs
input [7:0] tx_data;
input trmt,clk,rst_n,clr_rdy,RX;

//outputs
output [7:0] rx_data;
output rdy,tx_done,TX;

//Instantiate UART receiver
UART_rx rx(.rx_data(rx_data),.rdy(rdy),.clr_rdy(clr_rdy)
				,.clk(clk),.rst_n(rst_n),.RX(RX));

//Instantiate UART transfer
UART_tx tx(.tx_data(tx_data),.trmt(trmt),.tx_done(tx_done)
				,.TX(TX),.clk(clk),.rst_n(rst_n));

endmodule
