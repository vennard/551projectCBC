//Not added code for checking corner cases
module cfg_UART_tb();
//CHANGE TO CHANGE THE NUMBER OF TESTS
localparam TESTNUM = 10;

//inputs
reg [23:0] cmd_data_in;
reg [15:0] rsp_data_in;
reg snd_frm,clr_frm_rdy,snd_rsp,clk,rst_n;

//outputs
wire [23:0] cmd_data_out;
wire [15:0] rsp_data_out;
wire frm_rdy;

//internal wires
wire TX,RX; //according to cfg_UART tx and rx
wire rsp_rdy;

//testing variables
integer tests;
integer k;
integer frm_rdy_wait;

//Instantiate cfg_UART
cfg_UART uart(.RX_C(RX),.TX_C(TX),.cmd_data(cmd_data_out),.frm_rdy(frm_rdy)
					,.clr_frm_rdy(clr_frm_rdy),.rsp_data(rsp_data_in),.snd_rsp(snd_rsp)
					,.clk(clk),.rst_n(rst_n));

//Instantiate reverse of UART (cfg_mstr)
cfg_mstr mstr(.RX_C(TX),.TX_C(RX),.rsp_rdy(rsp_rdy),.snd_frm(snd_frm)
					,.cmd_data(cmd_data_in),.resp(rsp_data_out),.clk(clk),.rst_n(rst_n));

//Set up clock (period of 2ns)
initial begin
clk = 0;
forever #2 clk = ~clk;
end

initial begin
	tests = 0;
	k = 0;
	frm_rdy_wait = 0;
	$display("Initializing Testing");
	cmd_data_in = 0;
	rsp_data_in = 0;
	snd_frm = 0;
	clr_frm_rdy = 0;
	snd_rsp = 0;
	//Leave Reset for 2 clock cycles -- deassert on the negedge clock
	rst_n = 0;
	repeat(2) @(posedge clk);
	@(negedge clk);
	rst_n = 1;
end

always @(posedge clk) begin
	if(k==0) begin
		$display("Starting Test #%d",tests);
		cmd_data_in = $random % 16777215; //Random 24bit value
		rsp_data_in = $random % 65535;	 //Random 16bit value
		//wait until after reset
		repeat(3) @(posedge clk);
		snd_frm = 1;		//tell cfg_mstr to start transmitting 24bit packet
		repeat(2) @(posedge clk);
		snd_frm = 0;
		k = k+1; //turn off new test trigger
		tests = tests + 1; //increment to next test
	end

	if((frm_rdy)&(!frm_rdy_wait)) begin //If cfg_UART has recieved 24bit packet
		//Check that it has recieved and is outputting the correct data
		$display("checking cmd_data then sending response");
		if(cmd_data_out!=cmd_data_in) begin
				$display("ERROR - cmd_data not correct");
				$display("cmd_data = x%x  -- should be x%x",cmd_data_out,cmd_data_in);
				$stop;	//end testing
				end
		else begin
		//correctly recieved data, so send response
		snd_rsp = 1;
		repeat(2) @(posedge clk);
		snd_rsp = 0;
		frm_rdy_wait = 1;	//don't re-enter until clr_frm_rdy
		end
	end

	if(rsp_rdy) begin //if cfg_UART has send a 16bit response
		$display("checking response data");
			if(rsp_data_in!=rsp_data_out) begin
					$display("ERROR - rsp_data not correct");
					$display("rsp_data = x%x -- should be x%x",rsp_data_out,rsp_data_in);
			end
		//clear data & start next test
		clr_frm_rdy = 1;
		repeat(2) @(posedge clk);
		frm_rdy_wait = 0;
		k = 0;
	end

	//Check to end after number of tests	
	if(tests==TESTNUM) begin
		$display("Finished %d tests",tests);
		$display("Ending ----------");
		$stop;
	end

end
endmodule
