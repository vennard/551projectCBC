//TESTBENCH HOW TO ----
//this test bench has a series of tests contained within it. It is set up to
//run from easiest to most difficult. To determine how far the test bench will
//go simply change the TESTHANDLE parameter to an integer corresponding to the
//number of tests you wish to run. 
//Default is 5, as there are a total of 5 types of tests

`timescale 1 ns / 100 ps
module cbc_dig_tb();

//TODO should be defaulted to 5 -- 2 is as far as it is currently
localparam TESTHANDLE = 3;		//see above for functionality

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
wire rsp_rdy;
wire [23:0] cfg_data;


//Added pull out wires
wire [13:0] sumerr;
wire [13:0] preverr;
wire [13:0] xset;
wire [13:0] p,i,d;
wire [13:0] xmeas;
wire [13:0] err,diferr,accelData;
wire accel_vld,frm_rdy,c_duty;
wire [3:0] state;
wire [1:0] in_cmd;


/////////////////////////////////////////////
// Define any registers used in testbench //
///////////////////////////////////////////
reg [23:0] cmd_data;		// used to provide commands/data to cfg_UART of DUT
reg clk,rst_n;
reg snd_frm;
//Added Registers
reg [2:0] test;		//holds destination of next test
reg [23:0] xsetVals[0:255];
reg [23:0] cmdVals[0:255];
reg [13:0] dutyCheck[0:255];
reg [13:0] eepCheck[0:3];

/////////////////////
// File I/O values //	
/////////////////////
integer eepromFile,eepromTestData,count1;
integer count,testSumErr,testDuty;
integer xSetIndex,cmdIndex;
integer testErr,testDifErr,testPrevErr;
integer loadXset,match;
integer newCmd,xsetFile,count2,cmdFile,xsetTest;
integer temp,sndCfgData,accelMode;
integer strtTest;
integer checkCount;
integer xsetNew,xcnt;
integer cmdNew,cmdCnt;
integer runningAdvanced;

////////////////////
//Pull Out Values //
////////////////////
//assign sumerr = DUT.iDIG.sumerr;
//assign preverr = DUT.iDIG.preverr;
assign xset = DUT.iDIG.idatapath.xset;
//assign p = DUT.iDIG.p;
//assign i = DUT.iDIG.i;
//assign d = DUT.iDIG.d;
assign accel_vld = DUT.iDIG.accel_vld;
assign err = DUT.iDIG.idatapath.err;
assign duty = DUT.iDIG.idatapath.duty;
//assign diferr = DUT.iDIG.diferr;
assign xmeas = DUT.iDIG.Xmeas;
assign frm_rdy = DUT.iDIG.frm_rdy; 
assign wrt_duty = DUT.iDIG.wrt_duty; 

assign state = DUT.iDIG.icntrl.state;  
assign c_duty = DUT.iDIG.icntrl.c_duty;
assign in_cmd = DUT.iDIG.icntrl.in_cmd;
assign prod_vld = DUT.iDIG.icntrl.prod_vld;
assign cfg_data = DUT.iDIG.cfg_data;
assign strt_tx = DUT.iDIG.icntrl.strt_tx;
assign in_cmd = DUT.iDIG.icntrl.in_cmd;

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
cfg_mstr iCFG(.clk(clk), .rst_n(rst_n), .cmd_data(cmd_data), .snd_frm(snd_frm),
	      .RX_C(TX_C), .TX_C(RX_C), .resp(rsp), .rsp_rdy(rsp_rdy));

/////////////////////////////////////
// Instantiate Accel Data Generator//
/////////////////////////////////////
//accelGen iACCEL(.clk(clk),.rst_n(rst_n),.TX_A(RX_A),.mode(accelMode));
accel_mstr iACCEL(.clk(clk), .rst_n(rst_n), .TX_A(RX_A));

//////////////////////////////
// Instantiate PWM monitor //
////////////////////////////
pwm_monitor iMON(.clk(clk), .rst_n(rst_n), .CH_A(CH_A), .CH_B(CH_B),
	.duty(duty), .duty_valid(duty_valid));


  ///////////////////
  // 500MHz clock // 
  /////////////////
  initial begin
	 clk = 0;
	 forever #1 clk = ~clk;
	end


/////////////////////////////////////////////////////////////////
// The following section actually implements the real testing //
///////////////////////////////////////////////////////////////
initial
  begin    
    //Load Files
    $readmemh("xsetVals.txt",xsetVals);
    $readmemh("cmdVals.txt",cmdVals);
    $readmemh("checkVals.txt",checkVals);
    $readmemh("eep_init.txt",eepCheck);
    checkCount = 0;
    cmdNew = 0;
    cmdCnt = 0;
    xsetNew = 0;
    xcnt = 0;
	strtTest = 0;
		temp = 0;
    runningAdvanced = 0;
	
	//Initialize Test Variables
	newCmd = 0;
	match = 0;
	loadXset = 0;
    cmdIndex = 0;
    xSetIndex = 0;
	count = 0;
	//Start with 2 clock cycle reset & INIT check
	test = 0;
	rst_n = 0;
	repeat(1) @ (posedge clk);
	@(negedge clk);
	rst_n = 1;

  end

always @(posedge clk) begin
/**************************************************************** 
*Initialization Test  
****************************************************************/ 	
	if((test==INIT)&(rst_n)) begin
	  		$display("Initialization test running...");
			if(sumerr!=0) $display("ERROR - sumerr != 0");
			if(preverr!=0) $display("ERROR - preverr != 0");
			if(xset!=eepCheck[0]) $display("ERROR - xset value should = x%x - actual xset = x%x",xsetTest,xset);
			//Set up for next test
		 if(TESTHANDLE == 1) begin
			$display("End of Testing");
		  	$stop;
		  	end
			else begin
			$display("Finishing Initialization...");
			test = BASIC;
		 end
	end

/**************************************************************** 
*Basic Operation Test
****************************************************************/
	if(test==BASIC) begin
	  		if(strtTest == 0) begin
	  	 		$display("Basic test running...");
				strtTest = 1;
			 end
		   	
            if(accel_vld) count = count + 1;
					
			 //Check Calculation data 
             if(wrt_duty) begin
                if((checkVals[count]) != dst) $display("ERROR - duty written to PWM incorrect");
                else $display("#%d duty written correctly");
             end
			
            //Ending Test Check - ends after 20 iterations
           	if(count>20) begin			
			//Set up for next test
			  count = 0;
			  if(TESTHANDLE == 2) begin
	  				$display("End of Testing");
	  				$stop;
	  				end
			  else begin
 					$display("Finishing Basic Test...");
  					test = XSET;
					strtTest = 0;
			  end
			 end	
			end
			
/**************************************************************** 
*Xset Test
****************************************************************/
	if(test == XSET) begin
	  	 if(strtTest == 0) begin
			$display("Starting Xset testing");
			strtTest = 1;
		 end

	    //Start process to send data to the config UART
		if(xsetNew==0) begin
            //Load and Send data to DUT
            cmd_data = xsetVals[xcnt];
            snd_frm = 1;
            $display("Sending new xset value...");
            xsetNew = 1;
            end
        else snd_frm = 0;

        if(rsp_rdy) begin
            //Check that control echo's xset back
            $display("Checking xset response...");
            if(xset != resp) $display("ERROR - #%d xset response value not correct",xcnt);
            //Prep to send another xset value
            xsetNew = 0;
            xcnt = xcnt + 1;
            end

            //End Xset test after 20 iterations
            if(xCnt==20) begin
                if(TESTHANDLE == 3) begin
                    $display("End of Testing");
                    $stop;
                  end
                else begin
                    $display("Finishing Xset test...");
				    strtTest = 0;
                    test = CMDMODE;
                    end
                end
		end
/**************************************************************** 
*Command Mode operation tests
*****************************************************************/
	if(test == CMDMODE) begin
		    if(strtTest == 0) begin
			 $display("starting command mode tests");
			 strtTest = 1;
		    end
	        
            //Send command data
            if(cmdNew==0) begin
                cmd_data = cmdVals[cmdCnt];
                snd_frm = 1;
                $display("Sending new command...");
                cmdNew = 1;
                end
            else snd_frm = 0;

            //Check response
            if(rsp_rdy) begin
               //First 10 invalid
               if(cmdCnt<10) begin
                    if(rsp != 14'h05A5) $display("ERROR - did not send correct response to invalid command");
                    else $display("detected invalid command correctly");
                  end
               //The rest should be valid
               if(cmdCnt>9) begin
                    if(rsp == 14'h0A5A) $display("Correctly returned positive acknowledge");
                    else $display("ERROR - did not return positive acknowledge");
               end
                //Check that we entered command mode correctly
                if((cmd_data[19:16])==4'h3) begin
                    if(in_cmd) $display("entered command mode correctly");
                    else $display("ERROR - in_cmd flop not set after enter command sent");
                   end
                //Prep and send new command
                cmdCnt = cmdCnt + 1;
                cmdNew = 0;
             end

       		 //Check for write command
             if((in_cmd)&((cmd_data[19:18])==2'b10)) begin
                  //Check data is presented to the eeprom correctly
                    if((~eep_r_w_n)&(~eep_cs_n)) begin
                        //check data got sent through
                        if(dst == (cmd_data[13:0])) $display("wrote correct data to eeprom"); 
                        else $display("ERROR - failed to write correct data out to eeprom");
                        //check address
                        if(eep_addr == (cmd_data[17:16])) $display("correct address");
                        else $display("ERROR - incorrect address");
                    end
              end

              //Check for read command
              if((in_cmd)&((cmd_data[19:18])==2'b01)) begin
                    //check eeprom was presented with correct data
                    if((eep_r_w_n)&(~eep_cs_n)) begin
                        if(eep_rd_data == eepCheck[(cmd_data[17:16])])
                            $display("correctly read data from eeprom addr %d",cmd_data[17:16]);
                        else $display("ERROR - failed to read data from eeprom");
                    end
             end

              //End test conditions -- gives 10 invalid commands and 20 valid
              if(cmdCnt > 20) begin
                  if(TESTHANDLE == 4) begin
    					$display("End of testing");
                        $stop;
			   		   end
				  else begin
                        test = ADVANCE;
		  				$display("Ending command operation tests...");
						//RESET!!
                        rst_n = 0;
						repeat(2) @(posedge clk);
						rst_n = 1;
							  end
  						end
				 end						
                        
/**************************************************************** 
*Advanced Operation Test
****************************************************************/
	    if((test == ADVANCE)|(runningAdvanced>0)) begin
            if(runningAdvanced == 0) runningAdvanced = 1; 
            //Place new Xset then run 10 accel_Val iterations through
            if(runningAdvanced == 1) begin
                test = XSET;
                xsetNew = 0;
                xcnt = $random % 20; //pick a random value out of xsetVals.txt
                if(accel_vld) begin  //then run basic tests
                    test = BASIC;
                    strtTest = 0;
                    runningAdvanced = 2;
                end
             end

             //End running new xset test, write new p value and reset and run
             if(runningAdvanced == 2) begin
                if(count==10) begin
                    test = CMDMODE;
                    cmdCnt = 10;
                    cmdNew = 0;
                    runningAdvanced = 3;
                end
             end
             //execute two commands then reset and run basic tests again
             if(runningAdvanced == 3) begin
                    if(cmdCnt > 12) begin
                        test = BASIC;
                        strtTest = 0;
                        rst_n = 0;
                        repeat(1) @(posedge clk);
                        @(negedge clk);
                        rst_n = 1;
                        runningAdvanced = 4;
                    end
             end
             //run basic tests and finish
             if(runningAdvanced == 4) begin
                    if(count > 5) begin
                        $display("SUCCESS! Finishing advanced test");
                        $stop
                    end
             end

        end	

    end
			//Test random accel data
			//Test high and low corner cases for accel data


 
//`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
