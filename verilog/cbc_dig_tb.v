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
wire sendCfgData,rsp,rsp_rdy;
wire [23:0] cmd_data;


//Added pull out wires
wire [13:0] sumerr;
wire [13:0] preverr;
wire [13:0] xset;
wire [13:0] p,i,d;
wire [13:0] xmeas,cfg_data;
wire [13:0] err,duty,diferr,accelData;
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
integer eepromFile,eepromTestData,count1;
integer count,testSumErr,testDuty;
integer xSetIndex,cmdIndex;
integer testErr,testDifErr,testPrevErr;
integer loadXset,match;
integer newCmd;

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
assign prod_vld = DUT.iDIG.ctrl.prod_vld;
assign cfg_data = DUT.iDIG.ctrl.cfg_data;

assign accelData = iACCEL.tx_data;

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
cfg_mstr iCFG(.clk(clk), .rst_n(rst_n), .cmd_data(cmd_data), .snd_frm(sendCfgData),
	      .RX_C(TX_C), .TX_C(RX_C), .resp(rsp), .rsp_rdy(rsp_rdy));

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
	newCmd = 0;
	match = 0;
	loadXset = 0;
	testErr = 0;
	testDifErr = 0;
	testPrevErr = 0;
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

	//Initialize files for I/O variables
	//XSet File init
	
	count1 = 0;
	xsetFile = $fopen("xsetVals.txt","r");
	if(xsetFile!=1) $display("failed to load xsetVals.txt");
	count2 = 0;
 	cmdFile = $fopen("cmdVals.txt","r");
	if(cmdFile!=1) $display("failed to load cmdVals.txt");

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
					 if(state==4'h2)  //in state CALC_ERR
					  	 	testErr = xmeas - xset;
					 if(state==4'h3)	begin //in state PMULT
						if(prod_vld) begin
						 	   testDuty = ((p*testErr)[25:12]);	//TODO potential problem	
								//OVERFLOW & UNDERFLOW CHECKING
							 	if(((p[28])==0)&(|(p[27:25]))) testDuty = 16'h1FFF; //overflow
								if((p[28])&(~(&(p[27:25])))) testDuty = 16'h2000; //underflow			
							 end
						end
					 if(state==4'h5) //in state CALC_SUMERR
								testSumErr = testSumErr + testErr;
					 if(state==4'h6) begin //in state IMULT
						if(prod_vld) begin
						      testDuty = testDuty + ((i*testSumErr)[25:12]);
								//OVERFLOW & UNDERFLOW CHECKING
							 	if(((i[28])==0)&(|(i[27:25]))) testDuty = 16'h1FFF; //overflow
								if((i[28])&(~(&(i[27:25])))) testDuty = 16'h2000; //underflow			
							 end
						end
	 				 if(state==4'h8) //in state CALC_DERR
	  							testDifErr = testErr - testPrevErr;
					 if(state==4'h9) begin //in state DMULT
						if(prod_vld) begin
						  testDuty = testDuty + ((d*testDifErr)[25:12]);
									//OVERFLOW & UNDERFLOW CHECKING
							 	if(((d[28])==0)&(|(d[27:25]))) testDuty = 16'h1FFF; //overflow
								if((d[28])&(~(&(d[27:25])))) testDuty = 16'h2000; //underflow			
							 end
						end
					 if(state==4'hA) //in state SET_PREVERR
								testPrevErr = testErr;					
			 //Check that duty is correct when sending out to PWM
			 	 if(wrt_duty) begin
					 if(dst != testDuty) $display("ERROR - Sent incorrect value out to the PWM");
				  end

			end
			
/**************************************************************** 
*Xset Test ---- TODO
****************************************************************/
	if(test == XSET) begin
	    //Start process to send data to the config UART	-- TODO check
		 //implementation with cfg_mstr
		  if(loadXset==0) begin
			 match = $fscanf(xsetFile,"%h",cmd_data);
			 sndCfgData = 1;
			 loadXset = 1;
          xSetIndex = xSetIndex + 1;
			else sndCfgData = 0;

        if (frm_rdy) begin
            if(state==4'hB) begin //in NEW_XSET state
  						if(xset != (cmd_data[13:0])) $display("ERROR - xset value not set correctly");
	  					loadXset = 0;					
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
		  if(newCmd==0) begin
		 		match = $fscanf(cmdFile, "%h", cmd_data);
				sndCfgData = 1;
				newCmd = 1;
				cmdIndex = cmdIndex + 1;
			else sndCfgData = 0;
		  
        if(state==4'hC) $display("Entered into command mode aka ALL Zone"); //state is CMDINTR
        //First 10 iterations invalid commands
        if(cmdIndex<10) begin
            //Look for neg acknowledge
				if((strt_tx)&(dst==14'h05A5)) newCmd = 0;
            else $display("ERROR - didn't send NEGACK in response to invalid command");
           end
        //10th iteration is a write EEPROM command test
        if(cmdIndex==10) begin
			 	if((cfg_data[19:18])!=(2'b10)) $display("Read command bits not read in correctly");
            //Check that CHRG_PMP is asserted for long enough TODO add?
            //Check that sends positive acknowledge
            if((strt_tx)&(dst==14'h0A5A)) newCmd = 0;
  				  else $display("ERROR - did not send back POSACK response to write eeprom cmd");
          end
        //11th iteration is a read EEPROM command test
        if(cmdIndex==11) begin
            //Check that command was correct
			 	if((cfg_data[19:18])!=(2'b01)) $display("write command bits not read in correctly");
            //Check that dst bus contains data that is being read
					if(strt_tx) begin
				  newCmd = 0;
				  case(cmd_data[17:16])
					 2'b00 : if(xset!= dst) $display("ERROR - dst != eeprom[0]");
					 2'b01 : if(p != dst) $display("ERROR - dst != eeprom[1]");
					 2'b10 : if(i != dst) $display("ERROR - dst != eeprom[2]");
					 2'b11 : if(d != dst) $display("ERROR - dst != eeprom[3]");
				  endcase
				  end
        //12 iteration is a start_CM check 
        if(cmdIndex==12) begin
			 	if((~(|cfg_data[19:18]))&(&cfg_data[17:16])) begin
				  $display("entered command mode correctly");
					if(dst!=14'h0A5A) $display("ERROR positive acknowledge not sent from command mode start");
				  newCmd = 0;
				  else $display("ERROR - did not enter start command mode correctly");
				end
	            end
		
					//Repeats correct commands each 5 times, then resets and moves
					//on to advanced tests	
					if(cmdIndex > 12) begin
			  				count1 = count1 + 1;
				   		if(count1<5) cmdIndex = 10;
			 				if(count1==5) begin
							  if(TESTHANDLE == 4) begin
			  						$display("End of testing");
			  					   $done;
							  else begin
		 							test = ADVANCE;
		  							$display("Ending command operation tests...");
									//RESET!!!!
									rst_n = 0;
									repeat(2) @(posedge clk);
									rst_n = 1;
							  end
  						end
				 end						
                        
		end

/**************************************************************** 
*Advanced Operation Test
****************************************************************/
	if(test = ADVANCE) begin
	  $done; //TODO not added yet
	 end
				
  end
			//Test random accel data
			//Test high and low corner cases for accel data


 
`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
