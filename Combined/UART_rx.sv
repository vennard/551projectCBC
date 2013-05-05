//John Vennard
//ECE551 HW4 Problem 1
//UART reciever
module UART_rx(rx_data,rdy,clr_rdy,clk,rst_n,RX);
/****************************************************************
* UART receiver Baud Rate = 921,600 with clk = 800MHz
* Starts reception after start bit
* After all 8 bits are captured asserted rdy signal
* rdy stays asserted until clr_rdy is asserted
* ****************************************************************/ 
//Inputs
input clr_rdy, clk, rst_n, RX;

//Outputs
output [7:0] rx_data;
output rdy;

//States
reg [1:0] s,sNext;
reg rdy;

reg [7:0] tempData; //holds incoming data
reg [3:0] bitCnt;	//Counts incoming bits, need to get 10
reg [9:0] baudCnt;	//Baud Rate timer
reg [8:0] shiftReg;//shift register
reg [7:0] rx_data; //Holds only VALID output data -- zeros otherwise

//outputs from state machine
reg shft, receiving, rstBitCnt, rxDone;

//Internal Wires
wire baudFull;
wire baudHalf;
/**************************************************************** 
*Implement state flops
****************************************************************/ 
always @(posedge clk,negedge rst_n)
	if(!rst_n)
	s <= 0;
	else
	s <= sNext;
	
/**************************************************************** 
*Baud Rate Counter -- Inferred flop
****************************************************************/ 
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		baudCnt <= 10'h000;
	else if(baudFull)
		baudCnt <= 10'h000;
	else if(receiving)
		baudCnt <= baudCnt + 1;
//Baud Counter logic
assign baudFull = (baudCnt == 10'h363) ? 1'b1 : 1'b0;
//add logic for testing half way through baud count
assign baudHalf = (baudCnt == 10'h1B1) ? 1'b1 : 1'b0;
/****************************************************************
*Implement rdy flop
****************************************************************/
always @(posedge clk,negedge rst_n)
	if(!rst_n)
		rdy <= 0;
	else if(clr_rdy)
		rdy <= 0;
	else if(rxDone)
		rdy <= 1;

/****************************************************************
*Implement shift register -- inferred flop
*Should end with valid data in top 8 bits
*shiftReg[0] should equal 1 at end [stop bit]
****************************************************************/ 
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		shiftReg <= 9'h1FF;
	else if(shft)
		shiftReg <= {RX,shiftReg[8:1]}; 
	else if(baudHalf)
		shiftReg <= {RX,shiftReg[7:0]};
	else
	  shiftReg <= shiftReg;


/****************************************************************
*rx_data output logic
*rx_data holds only valid data, otherwise zeros
*--Implied flop-- outputs last valid data until received new
*valid data
****************************************************************/
always @(posedge clk, negedge rst_n)	
	if(!rst_n)
		rx_data <= 8'h00;
	else if(rxDone)	//update output -- ONLY VALID WHEN rdy is high
		rx_data <= tempData;
else if(baudHalf)
    tempData <= shiftReg;

/**************************************************************** 
*Implement Bit Counter -- Inferred flop
****************************************************************/
always @(posedge clk, negedge rst_n)	
	if(!rst_n)
		bitCnt <= 4'h0;
	else if (rstBitCnt)
		bitCnt <= 4'h0;
	else if (shft)
		bitCnt <= bitCnt +1;

/**************************************************************** 
*State Machine
****************************************************************/
always @(*)
	begin
	//Defaults
	shft = 0;
	rstBitCnt = 0;
	sNext = 0;
	receiving = 0;
	rxDone = 0;
	casex(s)
		//IDLE
		2'b00: begin
			rstBitCnt = 1;
				if(RX)		//Detect start bit -- DOES NOT READ IN
					sNext = 1;
				end
		//RECEIVING
		2'b01: begin
				shft = baudFull;
				receiving = 1;
					if(bitCnt == 4'hA) begin
						sNext = 2;
						rxDone = 1;
						end
					else sNext = 1;
					end
			//WAITING FOR CLR_RDY SIGNAL
			2'b10: begin
			  if(clr_rdy) sNext = 0;
			    else sNext = 2;
				end
			
		endcase
end


endmodule

