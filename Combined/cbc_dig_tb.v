//TESTBENCH HOW TO ----
//this test bench has a series of tests contained within it. It is set up to
//run from easiest to most difficult. To determine how far the test bench will
//go simply change the TESTHANDLE parameter to an integer corresponding to the
//number of tests you wish to run. 
//Default is 5, as there are a total of 5 types of tests

`timescale 1 ns / 100 ps
module cbc_dig_tb();

localparam TESTHANDLE = 5;		//see above for functionality

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
wire [13:0] dst,dstActual;
wire [15:0] resp;
wire [13:0] duty;
wire rsp_rdy;


//Added pull out wires
//wire [13:0] sumerr;
//wire [13:0] preverr;
//wire [13:0] xset;
//wire in_cmd;

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
reg [13:0] checkVals[0:255];

/////////////////////
// File I/O values //	
/////////////////////
integer count;
integer strtTest;
integer xsetNew,xcnt;
integer cmdNew,cmdCnt;
integer runningAdvanced;
integer dontCheck;
integer checkIndex;
integer skip;
integer checkingBasic;

////////////////////
//Pull Out Values //
////////////////////
//Pull outs of datapath
//assign sumerr = DUT.iDIG.idatapath.sumerr;
//assign preverr = DUT.iDIG.idatapath.preverr;
//assign xset = DUT.iDIG.idatapath.xset;

//General Pull Outs
//assign accel_vld = DUT.iDIG.accel_vld;
assign dstActual = DUT.dst_internal;   //TODO not needed? 

//Control Pull Outs	-- USED FOR CHECKING COMMANDS
//assign in_cmd = DUT.iDIG.icntrl.in_cmd;
//assign eq_3ms = DUT.iDIG.icntrl.eq_3ms;

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
	      .RX_C(TX_C), .TX_C(RX_C), .resp(resp), .rsp_rdy(rsp_rdy));

/////////////////////////////////////
// Instantiate Accel Data Generator//
/////////////////////////////////////
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
    cmdNew = 0;
	 skip = 0;
    cmdCnt = 0;
    xsetNew = 0;
    xcnt = 0;
	 strtTest = 0;
    runningAdvanced = 0;
	 snd_frm = 0;
	 dontCheck = 0;
	 checkIndex = 0;
	 checkingBasic = 0;
	//Initialize Test Variables
	count = 0;
	//Start with 2 clock cycle reset & INIT check
	test = 0;
	rst_n = 0;
	repeat(1) @ (posedge clk);
	@(negedge clk);
	rst_n = 1;
  end

	//to detect the start of duty_valid
	reg duty_valid_strt;
	always @(posedge clk, negedge rst_n)
  		if(!rst_n)
			duty_valid_strt <= 1'b0;
  		else
 			duty_valid_strt <= duty_valid;		  



  //to detect start of rsp_rdy
  reg rspRdyTemp;
always @(posedge clk,negedge rst_n)
	if(!rst_n)
		rspRdyTemp <= 1'b0;
   else
 		rspRdyTemp <= rsp_rdy;	  

always @(posedge clk) begin
/**************************************************************** 
*Initialization Test  
****************************************************************/ 	
	if((test==INIT)&(rst_n)) begin
	  		$display("Initializing...");
			//REMOVED FOR POST SYNTH
			//if(sumerr!=0) $display("ERROR - sumerr != 0");
			//if(preverr!=0) $display("ERROR - preverr != 0");
			//if(xset!=eepCheck[0]) $display("ERROR - xset value should = x%x - actual xset = x%x",eepCheck[0],xset);
			//Set up for next test
		 if(TESTHANDLE == 1) begin
		  	$stop;
		  	end
			else begin
			test = BASIC;
		 end
	end

/**************************************************************** 
*Basic Operation Test
****************************************************************/
	if((test==BASIC)|(checkingBasic)) begin
	  		if(strtTest == 0) begin
	  	 		$display("Basic test running...");
				count = 0;
				strtTest = 1;
			 end

			 //Check Calculation data 
             if(duty_valid) begin		
                if((checkVals[checkIndex]) != duty) $display("ERROR - duty = x%x -- should be =x%x",duty,checkVals[checkIndex]);
                else $display("#%d duty written correctly",count);
					count = count + 1;
					checkIndex = checkIndex + 1;

             end
			
            //Ending Test Check - ends after 20 iterations
           	if(count>19) begin			
			//Set up for next test
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
            cmd_data = xsetVals[xcnt][23:0];
            snd_frm = 1;
            $display("Sending new xset value...");
            xsetNew = 1;
            end
        else snd_frm = 0;
		 		  
        if(((rsp_rdy)&(!rspRdyTemp))&(runningAdvanced==0)) begin
            //Check that control echo's xset back
            $display("Checking xset response...");
            if(cmd_data[13:0] != resp) $display("ERROR - resp is =x%x -- should be x%x",resp,cmd_data[13:0]);
				else $display("correct resp (x%x) matches xset (x%x)",resp,cmd_data[13:0]);
            //Prep to send another xset value
            xsetNew = 0;
            xcnt = xcnt + 1;
            end

            //End Xset test after 10 iterations
            if((xcnt==10)&(runningAdvanced==0)) begin
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
	       
			 dontCheck = dontCheck + 1; 
			 
            //Send command data
            if(cmdNew==0) begin
                cmd_data = cmdVals[cmdCnt][23:0];
                snd_frm = 1;
                $display("Sending new command...");
                cmdNew = 1;
                end
            else snd_frm = 0;

            //Check response
            if(((rsp_rdy)&(!rspRdyTemp))&(dontCheck>3)) begin
               //First 10 invalid
               if(cmdCnt<10) begin
                    if(resp != 14'h35A6) $display("ERROR - should be 35A6 -- resp = x%x",resp);
                    else $display("detected invalid command correctly");
                  end
               //The rest should be valid
               if((cmdCnt>9)&(cmd_data[19:18] != 2'b01)) begin
                    if(resp != 14'h0A5A) $display("ERROR - should be 0A5A  -- resp = x%x",resp);
                    else $display("Correct - sent out positive acknowledge");
               end
                //Check that we entered command mode correctly
                if((cmd_data[19:16])==4'h3) begin
                    //if(in_cmd) $display("entered command mode correctly");
                    $display("entered command mode");
                    //else $display("ERROR - in_cmd flop not set after enter command sent");
                   end
					
                //Prep and send new command
                cmdCnt = cmdCnt + 1;
                cmdNew = 0;
             end


				 	//Check a write
            	if(cmd_data[19:18]==2'b10) begin   
					//Check data is presented to the eeprom correctly
                    if((~eep_r_w_n)&(~eep_cs_n)) begin
                        //check data got sent through WAIT UNTIL AFTER CHRGPMP
								@(negedge chrg_pmp_en);
                        if(dst == (cmd_data[13:0])) $display("wrote correct data to eeprom"); 
                        else $display("ERROR - failed to write correct data out to eeprom");
                        //check address
                        if(eep_addr == (cmd_data[17:16])) $display("correct address");
                        else $display("ERROR - incorrect address");
                    end
              end

              //Check for read command
              if(cmd_data[19:18]==2'b01) begin
                    //check eeprom was presented with correct data 
                    if((eep_r_w_n)&(~eep_cs_n)) begin	 
                        if(eep_rd_data == eepCheck[(cmd_data[17:16])])
                            $display("correctly read data from eeprom addr %d",cmd_data[17:16]);
                        else $display("ERROR - failed to read data from eeprom");
                    end
						  //Check sends correct response data
						  if((rsp_rdy)&(!rspRdyTemp)) begin
							  if(resp == eepCheck[cmd_data[17:16]]) $display("correct response (x%x) = (x%x)"
								 ,resp, eepCheck[cmd_data[17:16]]);
							  else $display("ERROR - read response failed -- resp = (x%x) should be (x%x)"
								 ,resp, eepCheck[cmd_data[17:16]]);
						  end
             end
				
              //End test conditions -- gives 10 invalid commands and 20 valid
              if(cmdCnt == 14) begin
                  if(TESTHANDLE == 4) begin
    					$display("End of testing");
                        $stop;
			   		   end
				  else begin
                        test = ADVANCE;
		  				$display("Ending command operation tests...");
		  				$display("reseting...");
						//RESET!!
                  rst_n = 0;
						repeat(2) @(posedge clk);
						@(negedge clk);
						rst_n = 1;
						dontCheck = 0;
							  end
  						end
				 end						
                        
/**************************************************************** 
*Advanced Operation Test
****************************************************************/
	    if((test == ADVANCE)|(runningAdvanced>0)) begin
            //Place new Xset then run 10 accel_Val iterations through
				/*
				if(runningAdvanced == 0) begin
						strtTest = 0;
				  		$display("Advanced test starting...");
				  		runningAdvanced = 1; 
						test = XSET;
						xsetNew = 0;
						xcnt = 10;
						$display("Advanced test -- setting xset to be = x%x",xsetVals[10]);
					 end
				//End first new xset test --> move to second xset value
            else if(runningAdvanced == 1) begin
					 	if(accel_vld) begin  //then run basic tests
                    test = BASIC;
						  count = 0;
                    strtTest = 0;
                    runningAdvanced = 2;
						  checkIndex = 25;
						  $display("Checking duty values against new xset value...");
                	end
             end
				 //Run second new xset test
             else if(runningAdvanced == 2) begin
                if(count>=10) begin
		  					$display("reseting...");
                    	test = XSET;
							xsetNew = 0;
							xcnt = 11;
							count = 0;
						   strtTest = 0;
							runningAdvanced = 3;
						$display("Advanced test #2 -- setting xset to be = x%x",xsetVals[11]);
                end
             end
             //execute two commands then reset and run basic tests again
             else if(runningAdvanced == 3) begin
                    if(accel_vld) begin
                        test = BASIC;
  								strtTest = 0;
  								runningAdvanced = 4;
								checkIndex = 50;
								$display("Checking duty values against #2 xset value");								
  							 end
             end
             //run basic tests and finish
             else if(runningAdvanced == 4) begin
						if(count>=10) begin*/
                        $display("Finishing advanced test");
                        $stop;
							//end
    //         end

        end	

    end
 
//`include "/filespace/people/e/ejhoffman/ece551/project/project/cbc_dig/tb_tasks.v"

endmodule
