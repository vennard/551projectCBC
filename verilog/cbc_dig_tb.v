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
wire [1:0] in_cmd;

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
integer xSetIndex,cmdIndex;

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
assign in_cmd = DUT.iDIG.ctrl.in_cmd;

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
    cmdIndex = 0;
    xSetIndex = 0;
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
		  	
			 //Check Calculation data
			        //TODO implement 

			 //Check again that duty is correct when sending out to PWM
			 	 if(wrt_duty) begin
					 if(dst != testDuty) $display("ERROR - Sent incorrect value out to the PWM");
				  end

			end
			
/**************************************************************** 
*Xset Test ---- TODO
****************************************************************/
	if(test == XSET) begin
	    //Start process to send data to the config UART
        //IE load data from file then increment index       --xsetvals.txt
        xSetIndex = xSetIndex + 1;
        if (frm_rdy) begin
            if(state==4'hB) begin //in NEW_XSET state
                //TODO check xset value against loaded value
            else begin
            $display("ERROR -- did not detect new Xset load correctly");
            $stop;
                end
            end
            //End Xset test after 20 iterations
            if(xSetIndex==20) begin
                if(TESTHANDLE == 3) begin
                    $display("End of Testing");
                    $done;
                else begin
                    $display("Finishing Xset test...");
                    test = CMDMODE;
                    end
                end
		end
/**************************************************************** 
*Command Mode operation tests
*****************************************************************/
	if(test = CMDMODE) begin
        //Start process by sending invalid commands         --cmdvals.txt
        cmdIndex = cmdIndex + 1;
        if(state==4'hC) $display("Entered into command mode aka ALL Zone"); //state is CMDINTR
        //First 10 iterations invalid commands
        if(cmdIndex<11) begin
            //Look for neg acknowledge
            if((strt_tx)&(dst==14'h05A5)) $display("NEGACK sent out of iDIG");
            else $display("ERROR - didn't send NEGACK in response to invalid command");
           end
        //10th iteration is a write EEPROM command test
        if(cmdIndex==10) begin
            //Check command was correct (cfg_data[19:18]) TODO
            //Check that CHRG_PMP is asserted for long enough
            //Check that sends positive acknowledge
            if((strt_tx)&(dst==14'h0A5A)) $display("POSACK sent out of iDIG -- write eeprom");
            else $display("ERROR - did not send back POSACK response to write eeprom cmd");
          end
        //11th iteration is a read EEPROM command test
        if(cmdIndex==11) begin
            //Check that command was correct (cfg_data[19:18) TODO
            //Check that dst bus contains EEPDATA!
            //if((strt_tx)&(dst==EEPDATA)) 
           end
        //12 iteration is a start_CM check 
        if(cmdIndex==12) begin
            //Check detected correctly
            //Check sends out positive acknowledge
            end

        //TODO set cmdIndex to randomly repeat 10-12 for X number of times --
        //repeat 5 times if it fails

        //TODO RESET everything to return to normal operation -- test
        //initialization again
                
		end

/**************************************************************** 
*Advanced Operation Test
****************************************************************/
	if(test = ADVANCE) begin
	 end
				
  end
			//Test random accel data
			//Test high and low corner cases for accel data


 
`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
