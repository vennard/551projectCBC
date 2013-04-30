//TESTBENCH HOW TO ----
//this test bench has a series of tests contained within it. It is set up to
//run from easiest to most difficult. To determine how far the test bench will
//go simply change the TESTHANDLE parameter to an integer corresponding to the
//number of tests you wish to run. 
//Default is 5, as there are a total of 5 types of tests

`timescale 1 ns / 100 ps;
module cbc_dig_tb();

//TODO should be defaulted to 5 -- 2 is as far as it is currently
localparam TESTHANDLE = 2;		//see above for functionality

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
wire [1:0] eep_addr,accelMode;
wire [13:0] eep_rd_data;
wire [13:0] dst;
wire [15:0] rsp;
wire [13:0] duty;
//Added pull out wires
wire [13:0] sumerr;
wire [13:0] preverr;
wire [13:0] xset;
wire [13:0] p,i,d;
wire [13:0] xmeas;
wire [13:0] err,duty,diferr;
wire accel_vld,frm_rdy,c_duty;
wire [3:0] state;

/////////////////////////////////////////////
// Define any registers used in testbench //
///////////////////////////////////////////
reg [23:0] cmd_data;		// used to provide commands/data to cfg_UART of DUT
reg initiate;			// kicks off command/data transmission to DUT 
reg clk,rst_n;
//Added Registers
reg [2:0] test;		//holds destination of next test\

/////////////////////
// File I/O values //	
/////////////////////
integer eepromFile,eepromTestData,i;
integer pTest,iTest,dTest,xsetTest;
integer count,testSumErr,testDuty;

////////////////////
//Pull Out Values //
////////////////////
assign sumerr = DUT.iDIG.sumerr;
assign preverr = DUT.iDIG.preverr;
assign xset = DUT.iDIG.xset;
assign p = DUT.iDIG.p;
assign i = DUT.iDIG.i;
assign d = DUT.iDIG.d;
assign accel_vld = DUT.iDIG.accel_vld;
assign err = DUT.iDIG.err;
assign duty = DUT.iDIG.duty;
assign diferr = DUT.iDIG.diferr;
assign xmeas = DUT.iDIG.xmeas;
assign frm_rdy = DUT.iDIG.frm_rdy; //TODO check value
assign wrt_duty = DUT.iDIG.wrt_duty; //TODO check
assign state = DUT.iDIG.ctrl.state;  
assign c_duty = DUT.iDIG.ctrl.c_duty;
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

/////////////////////////////////////
// Instantiate Accel Data Generator//
/////////////////////////////////////
accelGen iACCEL(.clk(clk),.rst_n(rst_n),.TX_A(RX_A),.mode(accelMode));
//accel_mstr iACCEL(.clk(clk), .rst_n(rst_n), .TX_A(RX_A));

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
	testDuty = 0;
	count = 0;
	testSumErr = 0;
	accelMode = 0; //Defaults to sending zero's as accel data
	//Start with 2 clock cycle reset & INIT check
	test = INIT;
	rst_n = 0;
	repeat(2) @ (posedge clk);
	rst_n = 1;

	//Initialize file I/O variables
	i = 0;
	eepromFile = $fopen("eeprom.txt","r");
	for(i = 0;i < 4;i = i+1) begin
	  	if (i == 0) eepromTestData = $fscanf(eepromFile,"%b\n",xsetTest);
	  	if (i == 1) eepromTestData = $fscanf(eepromFile,"%b\n",pTest);
	  	if (i == 2) eepromTestData = $fscanf(eepromFile,"%b\n",iTest);
	  	if (i == 3) eepromTestData = $fscanf(eepromFile,"%b\n",dTest);
	 end
  	$fclose(eepromFile);
  end

always @(posedge clk) begin
/**************************************************************** 
*Initialization Test  
****************************************************************/ 	
	if((test==INIT)&(rst_n)) begin
	  		$display("Initialization test running...");
			if(sumerr!=0) $display("ERROR - sumerr != 0");
			if(preverr!=0) $display("ERROR - preverr != 0");
			if(xset!=xsetTest) $display("ERROR - xset value should = x%x - actual xset = x%x",xsetTest,xset);
			if(p != 0) $display("ERROR - p does not initialize to zero");
			if(i != 0) $display("ERROR - i does not initialize to zero");
			if(d != 0) $display("ERROR - d does not initialize to zero");
			//Set up for next test
		 if(TESTHANDLE == 1) begin
			$display("End of Testing");
		  	$done;
			else begin
			$display("Finishing Initialization...");
			test = BASIC;
		 end
	end

/**************************************************************** 
*Basic Operation Test
****************************************************************/
	if(test==BASIC) begin
	  	 	$display("Basic test running...");
			//Test when accel data is zero	- Run through 5 times
			if(accel_vld) count = count + 1;
			if(count < 5) begin
			  $display("Basic test #%d --- accel data input = 0",count);
			  accelMode = 0;
			//Test when accel data is random values - run through 20 times
			else if((count > 4)&(count<26)) begin
			  $display("Basic test #%d --- accel data input = random",count);
			  accelMode = 1;
			//Test when accel data is corner cases - run 10 times
			else if ((count>25)&(count<36)) begin
			  $display("Basic test #%d --- accel data input is testing corner cases",count);
			  accelMode = 2;
			else begin
	  		  //Set up for next test
			  count = 0;
			  if(TESTHANDLE == 2) begin
	  				$display("End of Testing");
	  				$done;
			  else begin
 					$display("Finishing Basic Test...");
  					test = XSET;
			  end
			 end			  
		  	
				//TODO added multiply checker with saturation
			 //Check Calculation data
			 if(frm_rdy) begin
				$display("ERROR - entered command mode from basic operation test");
				$done;
			 end
			 //Check Err calculation
					if(state==4'h2) begin //In CALC_ERR state //TODO double check correct state values
				 		if(err != (xmeas - xset)) $display("ERROR - err calculation incorrect");
							end
			 //Check 1st duty calculation
			 		if(state==4'h3) begin //in PMULT state
					  if(c_duty) begin //multiply finished TODO must concatonate p*err value for /x800
						 	testDuty = duty;
		  					if(duty != (p*err)) $display("ERROR - 1st iteration of duty calculation incorrect");
		  				end
 					end

			 //Check sumerr calculation
			 		if(state==4'h5) begin  //in CALC_SUMERR state
					  	testSumErr = testSumErr + err;
  						if(sumerr != (err + testSumErr)) $display("ERROR - sumerr calculation incorrect"); 	
	 				end

			 //Check 2nd duty calculation
			 		if(state==4'h6) begin //in IMULT state
						testDuty = testDuty + ((i*testSumErr)/x800);	//TODO
						if(c_duty) begin
							if(duty != testDuty) $display("ERROR - 2nd iteration of duty calculation incorrect");
					 	end
				  end

			 //Check diferr calculation
			 		if(state==4'h8) begin //in CALC_DERR state
					 	if(diferr != (err - preverr)) $display("ERROR - diferr calculation incorrect");
					 end

			 //Check 3rd iteratino of duty calculation
			 		if(state==4'h9) begin //in DMULT state
						testDuty = testDuty + ((d*diferr)/x800); //TODO
						if(c_duty) begin
						  	if(duty != testDuty) $display("ERROR - 3rd iteration of duty calculation incorrect");
						 end
				  	end

			 //Check again that duty is correct when sending out to PWM
			 	 if(wrt_duty) begin
					 if(dst != testDuty) $display("ERROR - Sent incorrect value out to the PWM");
				  end

			 //Check that we store preverr correctly
			 	if(state==4'hA) begin
				  	if(preverr != err) $display("ERROR - did not save off preverr correctly");
				 end					
			 
			end
			
/**************************************************************** 
*Xset Test
****************************************************************/
	if(test == XSET) begin
		
		end
/**************************************************************** 
*Command Mode operation tests
*****************************************************************/
	if(test = CMDMODE) begin
		end

/**************************************************************** 
*Advanced Operation Test
****************************************************************/
	if(test = ADVANCE) begin
	 end
				
  end
			//Test random accel data
			//Test high and low corner cases for accel data


 //TODO added function for checking multiplies MUST CONTAIN SATURATION LOGIC
 
task checkMultiply;
 	output reg [14:0] SUM:
	input [14:0] A;
	input [14:0] B;

	SUM = A*B;
	if(SUM<=xVALUE) SUM = SUM_MIN;
	if(SUM>=xVALUE) SUM = SUM_MAX;

 endtask	

`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
