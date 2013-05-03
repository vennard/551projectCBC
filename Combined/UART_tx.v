// Kevin Blair
// ECE 551
// Hw 3
// Problem 3

module UART_tx(clk, rst_n, tx_data, trmt, tx_done, TX);

  localparam IDLE = 1'b0,
              TXing = 1'b1;

  input clk;
  input rst_n;

  input [7:0] tx_data;
  input trmt;
  

  output TX;

  reg state;
  reg nxt_state;

  reg set_tx_done;
  reg clr_tx_done;

  // SM ouputs
  output tx_done;
  reg tx_done;

  reg shift;
  reg load;
  reg clr_tx_cnt;
  reg clr_b_cnt;
  reg en_tx_cnt;
  reg inc_b_cnt;

  // counter outputs to SM
  wire tx10b;
  wire txb_t;

  // counters
  reg [3:0] b_cnt;
  reg [9:0] tx_cnt;

  // shift/tx reg
  reg [8:0] shift_tx;
  reg [8:0] nxt_shift_tx;

  
// ==========state machine==========

  // ==========SM Flop==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      state <= IDLE;
    else
      state <= nxt_state;
  end

  // ==========SM comb==========
  always@(*) begin

    set_tx_done = 0;
    clr_tx_done = 0;

    shift = 0;
    load = 0;
    clr_tx_cnt = 0;
    clr_b_cnt = 0;
    en_tx_cnt = 1;
    inc_b_cnt = 0;
    nxt_state = IDLE;

    case(state)
      IDLE : begin
        en_tx_cnt = 0;
        if(!trmt) begin
          nxt_state = IDLE;
        end 
        else begin
          clr_tx_done = 1;
          load = 1;
          clr_tx_cnt = 1;
          clr_b_cnt = 1;
          nxt_state = TXing;
        end
      end
      TXing : begin
        if(tx10b) begin
          en_tx_cnt = 0;
          set_tx_done = 1;
          nxt_state = IDLE;
        end else if(txb_t) begin
          inc_b_cnt = 1;
          shift = 1;
          clr_tx_cnt = 1;
          nxt_state = TXing;
        end else
          nxt_state = TXing;
      end
    endcase
  end

// ==========SM supporting counters==========

  // ==========bits txed counter==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      b_cnt <= 0;
    else
      b_cnt <= (clr_b_cnt) ? 4'h0 :
               (inc_b_cnt) ? (b_cnt + 1) :
                              b_cnt;
  end

  assign tx10b = (b_cnt == 10);

  // ==========cycles bit txed counter==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      tx_cnt <= 0;
    else
      tx_cnt <= (clr_tx_cnt) ? 10'h000 :
                (en_tx_cnt)  ? (tx_cnt + 1) :
                               tx_cnt;
  end

  assign txb_t = (tx_cnt == 867);

// ==========tx/shift register==========
    
  // ==========tx/shift register flop==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      shift_tx <= 9'h001;
    else
      shift_tx <= nxt_shift_tx;
  end

  // ==========tx/shift register comb==========
  always@(*) begin
    if(load)
      nxt_shift_tx = {tx_data[7:0],1'b0};
    else if(shift)
      nxt_shift_tx = {1'b1,shift_tx[8:1]};
    else
      nxt_shift_tx = shift_tx;
  end

  assign TX = shift_tx[0];

// ==========tx_done logic==========

  // ==========tx_done flop==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      tx_done <= 1'b0;
    else
      tx_done <= (set_tx_done) ? 1'b1 :
                 (clr_tx_done) ? 1'b0 :
                                 tx_done;
  end

endmodule
