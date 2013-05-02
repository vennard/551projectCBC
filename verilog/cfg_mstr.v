module cfg_mstr(cmd_data, snd_frm, resp, clk, rst_n, TX_C, RX_C, rsp_rdy);

input [23:0] cmd_data;
input snd_frm, RX_C, clk, rst_n;

output reg [15:0] resp;
output reg rsp_rdy;
output TX_C;


wire [7:0] rx_data, tx_data;

reg [2:0] state, next_state;
reg [1:0] sel_tx, sel_rx;
reg trmt, clr_rdy;
wire tx_done;
wire rdy;

UART uart(.clk(clk), .rst_n(rst_n), .trmt(trmt), .tx_done(tx_done), .tx_data(tx_data), .rx_data(rx_data), .rdy(rdy), .clr_rdy(clr_rdy), .TX(TX_C), . RX(RX_C));


localparam IDLE = 3'b000;
localparam WaitH = 3'b001;
localparam WaitM = 3'b010;
localparam WaitL = 3'b011;
localparam FrmCmplt = 3'b100;
localparam WaitRsp = 3'b101;
localparam RspCmplt = 3'b110;
localparam BuffByte = 3'b111;

// STATE FLOP
always @(posedge clk,negedge rst_n)
   if (!rst_n)
     state <= IDLE;
   else
     state <= next_state;
     
//response flop      
always @(posedge clk,negedge rst_n)
   if (!rst_n)
      resp = 16'h0000;
   else if(sel_rx == 2'b01)
      resp[15:8] <= rx_data;
   else if(sel_rx == 2'b10)
      resp[7:0] <= rx_data;
      
//RX_Data TX_Data Selection
assign tx_data = (sel_tx == 2'b10) ? cmd_data[23:16] :
                 (sel_tx == 2'b01) ? cmd_data[15:8]  :
                 (sel_tx == 2'b00) ? cmd_data[7:0]   : 8'h00;

      
// STATE MACHINE
always @(state, snd_frm, tx_done, rdy) 
begin
   sel_tx = 2'b10;
   sel_rx = 2'b00;
   trmt = 1'b0;
   //frm_cmplt = 1'b0;
   rsp_rdy = 1'b0;
   next_state = IDLE;
  clr_rdy = 1'b0;
   case (state)
      IDLE: begin
               if(snd_frm)
                  begin
                  next_state = WaitH;
                  trmt = 1'b1;
                  end
               end
      WaitH: begin
               if(tx_done)
                  begin
                  next_state = WaitM;
                  trmt = 1'b1;
                  sel_tx = 2'b01;
                  end
               else
                  next_state = WaitH; 
            end
      WaitM: begin
               if(tx_done)
                  begin
                  next_state = WaitL;
                  trmt = 1'b1;
                  sel_tx = 2'b00;
                  end
               else
                  begin
                  next_state = WaitM;
                  sel_tx = 2'b01;
                  end
            end
      WaitL: begin
               if(tx_done)
                  begin
                  next_state = FrmCmplt;
                  //frm_cmpt = 1'b1;
                  end
               else
                  begin
                  next_state = WaitL;
                  sel_tx = 2'b00;
                  end
            end
      FrmCmplt: begin
               if(rdy)
                  begin
                  next_state = BuffByte;
                  sel_rx = 2'b01;
                  end
               else
                  begin
                  //frm_cmplt = 1'b1;
                  next_state = FrmCmplt;
                  end
            end
      BuffByte: begin
        clr_rdy = 1'b1;
        next_state = WaitRsp;  
      end
      WaitRsp: begin
               if(rdy)
                  begin
                  next_state = RspCmplt;
                  sel_rx = 2'b10;
                  end
               else
                  next_state = WaitRsp;              
            end
      RspCmplt: begin
               if(snd_frm)
                  begin
                  next_state = WaitH;
                  trmt = 1'b1;
                  clr_rdy = 1'b1;
                  end
               else 
                  begin
                  next_state = RspCmplt;
                  rsp_rdy = 1'b1;
                  end
            end
      default: next_state = IDLE;
   endcase
end      

endmodule
