//Opposite of cfg_UART
//Used for testbench to avoid looking at serial data
module cfg_mstr(cmd_data,snd_frm,resp,TX_C,RX_C,rsp_rdy,clk,rst_n);

input [23:0] cmd_data;
input clk,rst_n,RX_C,snd_frm;

output [15:0] resp;
output TX_C,rsp_rdy;


endmodule
