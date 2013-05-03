module accel_UART(RX_A, clk, rst_n, Xmeas, accel_vld);

input RX_A, clk, rst_n;

output [13:0] Xmeas;
output reg accel_vld;

reg [5:0] xmeas_high;
reg [7:0] xmeas_low;
reg [2:0] state, next_state;
reg clr_rdy, next_accel, high_vld, low_vld;

wire [7:0] rx_data;
wire rdy;

wire [5:0] next_high;
wire [7:0] next_low;

localparam IDLE = 3'b000;
localparam HIGH = 3'b001;
localparam LOW = 3'b010;
localparam DONE = 3'b011;
localparam WAIT = 3'b100;

UART_rx rx(.clk(clk), .rst_n(rst_n), .rx_data(rx_data), .rdy(rdy), .clr_rdy(clr_rdy), .RX(RX_A));

//state flop
always @(posedge clk,negedge rst_n)
    if (!rst_n)
      state <= IDLE;
    else
      state <= next_state;

//Xmeas registers
always @(posedge clk,negedge rst_n)
    if (!rst_n)
      xmeas_high <= 6'h00;
    else
      xmeas_high <= next_high;

always @(posedge clk,negedge rst_n)
    if (!rst_n)
      xmeas_low <= 8'h00;
    else
      xmeas_low <= next_low;

//accel_vld register
always @(posedge clk,negedge rst_n)
    if (!rst_n)
      accel_vld <= 1'b0;
    else
      accel_vld <= next_accel;

//muxes selecting xmeas flop inputs
assign next_high = (high_vld) ? rx_data[5:0] : xmeas_high;
assign next_low = (low_vld) ? rx_data[7:0] : xmeas_low;

assign Xmeas = {xmeas_high, xmeas_low};

always @(state, rdy) // state machine
begin
   next_accel = 1'b0;
   clr_rdy = 1'b0;
   high_vld = 1'b0;
   low_vld = 1'b0;
   next_state = IDLE;
   case (state)
      IDLE: begin
            if(rdy)
               next_state = HIGH;
               high_vld = 1'b1;
            end
      HIGH: begin
               next_state = LOW;
               clr_rdy = 1'b1;
            end
      LOW:  begin
               if(rdy) begin
                  next_state = DONE;
                  low_vld = 1'b1;
                  next_accel = 1'b1;
                  end
               else begin
                  next_state = LOW;
                  end
            end
      DONE: begin
               next_state = WAIT;
               next_accel = 1'b1;
               clr_rdy = 1'b1;
            end
      WAIT: begin
               if(rdy) begin
                  next_state = HIGH;
                  high_vld = 1'b1;
                  end
               else begin
                  next_state = WAIT;
                  next_accel = 1'b1;
                  end
            end
      default: next_state = IDLE;
   endcase
end  


endmodule
