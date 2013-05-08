// Kevin Blair
// ECE 551
// Hw3
// Problem 2

module PWM (clk, rst_n, wrt_duty, duty, CH_A, CH_B);

  input clk;
  input rst_n;
  input wrt_duty;
  input [13:0] duty;

  output reg CH_A;
  output reg CH_B;

  reg [13:0] duty_ff;

  reg [12:0] cnt;

  wire [12:0] duty_2s;

	wire empty;
	wire eq;
	wire CH_A_nxt;
	wire CH_B_nxt;

  // ==========DUTY FLOPPING==========
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      duty_ff <= 0;
    else if(wrt_duty == 1)
      duty_ff <= duty;
    else
      duty_ff <= duty_ff;
  end


  // ==========13bit Counter========== 
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      cnt <= 0;
	 else if(wrt_duty)
		cnt <= 0;
    else
      cnt <= cnt + 1;
  end

  assign empty = ~|cnt;

  // ==========eq Comb==========

  assign duty_2s = (~duty_ff[12:0]) + 1;
  assign eq = (cnt == (duty_ff[13] ? duty_2s[12:0] : duty_ff[12:0]));

  // ==========CH_A COMB==========
  assign CH_A_nxt = (duty_ff[13] || eq) ? 0 :
                    empty               ? 1 :
                    CH_A;


  // ==========CH_A FLOPPING==========
  always@(posedge clk or negedge rst_n) begin
      if(!rst_n)
        CH_A <= 0;
      else if(wrt_duty)
			CH_A <= 0;
		else
        CH_A <= CH_A_nxt;
  end


  // ==========CH_B COMB==========
  assign CH_B_nxt = ((!duty_ff[13]) || eq) ? 0 :
                    empty                  ? 1 :
                    CH_B;            

  // ==========CH_B FLOPPING==========
  always@(posedge clk or negedge rst_n) begin
      if(!rst_n)
        CH_B <= 0;
      else if(wrt_duty)
		  CH_B <= 0;	//TODO Added
		else
        CH_B <= CH_B_nxt;
  end

endmodule
