//John Vennard example format for cfg_UART
module cfg_UART(RX_C,TX_C,cfg_data,frm_rdy,clr_frm_rdy,
			rsp_data,snd_rsp,clk,rst_n);

input RX_C, clr_frm_rdy,snd_rsp,clk,rst_n;
input [15:0] rsp_data;

output TX_C, frm_rdy;
output [23:0] cfg_data;

//code goes here
endmodule
