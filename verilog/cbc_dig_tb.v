`timescale 1 ns / 100 ps;
module cbc_dig_tb();
//////////////////
// Local Params //
/////////////////			
localparam INIT = 3'b000;
localparam BASIC = 3'b001;
localparam XSET = 3'b010;
localparam CMDMODE = 3'b011;
localparam ADVANCE = 3'b100;

////////////////////////////////////////////////
// Define any interconnects wider than 1-bit //
//////////////////////////////////////////////
wire [1:0] eep_addr;
wire [13:0] eep_rd_data;
wire [13:0] dst;
wire [15:0] rsp;
wire [13:0] duty;
//Added pull out wires
wire sumerr;
wire 

/////////////////////////////////////////////
// Define any registers used in testbench //
///////////////////////////////////////////
reg [23:0] cmd_data;		// used to provide commands/data to cfg_UART of DUT
reg initiate;			// kicks off command/data transmission to DUT 
reg clk,rst_n;
//Added Registers
reg [2:0] test;		//holds destination of next test

////////////////////
//Pull Out Values //
////////////////////
assign sumerr = DUT.iDIG.sumerr;


//////////////////////
// Instantiate DUT //
////////////////////
cbc_dig DUT(.clk(clk), .rst_n(rst_n), .RX_A(RX_A), .RX_C(RX_C), .TX_C(TX_C),
	.CH_A(CH_A), .CH_B(CH_B), .dst(dst), .eep_rd_data(eep_rd_data),
	.eep_addr(eep_addr), .eep_cs_n(eep_cs_n), .eep_r_w_n(eep_r_w_n),
	.chrg_pmp_en(chrg_pmp_en));
        
///////////////////////////////
// Instantiate EEPROM Model //
/////////////////////////////
eep iEEP(.clk(clk), .por_n(rst_n), .eep_addr(eep_addr), .wrt_data(dst),  .rd_data(eep_rd_data), .eep_cs_n(eep_cs_n),
         .eep_r_w_n(eep_r_w_n), .chrg_pmp_en(chrg_pmp_en));

////////////////////////////////
// Instantiate Config Master //
//////////////////////////////
cfg_mstr iCFG(.clk(clk), .rst_n(rst_n), .cmd_data(cmd_data), .initiate(initiate),
	      .RX_C(TX_C), .TX_C(RX_C), .rsp(rsp), .rsp_rdy(rsp_rdy));

///////////////////////////////
// Instantiate Accel Master //
/////////////////////////////
accel_mstr iACCEL(.clk(clk), .rst_n(rst_n), .TX_A(RX_A));

//////////////////////////////
// Instantiate PWM monitor //
////////////////////////////
pwm_monitor iMON(.clk(clk), .rst_n(rst_n), .CH_A(CH_A), .CH_B(CH_B),
	.duty(duty), .duty_valid(duty_valid));


always
  ///////////////////
  // 500MHz clock // 
  /////////////////
  #1 clk = ~clk;

/////////////////////////////////////////////////////////////////
// The following section actually implements the real testing //
///////////////////////////////////////////////////////////////
initial
  begin    
	//Initialize Test Variables
	
  end

always @(posedge clk) begin
/**************************************************************** 
*Initialization Test  
****************************************************************/ 	
	if(test==INIT) begin
	  	


`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
