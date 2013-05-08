
module mult_synth(wrtp, wrti, wrtd, wrtxset, chngxset, xmeas, cfg_data, accel_vld, duty, duty_vld);

	input wrtp; 
	input wrti; 
	input wrtd; 
	input wrtxset; 
	input chngxset; 
	input [13:0] xmeas; 
	input [13:0] cfg_data; 
	input accel_vld; 
	output reg [13:0] duty; 
	output reg duty_vld;

	reg [13:0] p;
	reg [13:0] i;
	reg [13:0] d;
	reg [13:0] xset_eep;
	reg [13:0] xset_work;
	reg [13:0] sumerr;
	reg [13:0] preverr;
	reg [13:0] err;

	reg [13:0] pmul;
	reg [13:0] imul;
	reg [13:0] dmul;

	initial begin
		sumerr = 1'b0;
		preverr = 1'b0;
	end


	always@(posedge accel_vld) begin
		err = (xmeas-xset_work);
		sumerr = add_sat(sumerr,err);

		pmul = mult(err,p);

  	imul = mult(sumerr,i);

		dmul = mult((err-preverr),d);
		
		duty = add_sat(add_sat(pmul,imul),dmul);

		duty_vld = 1;
	end

	always@(posedge wrtp) begin
		p <= cfg_data;		
	end
	always@(posedge wrti) begin
		i <= cfg_data;		
	end
	always@(posedge wrtd) begin
		d <= cfg_data;		
	end
	always@(posedge wrtxset) begin
		xset_eep <= cfg_data;		
	end
	always@(posedge chngxset) begin
		xset_work <= cfg_data;		
	end


	function [13:0] mult;
		input [13:0] mul0;
		input [13:0] mul1;
		reg [28:0] prod;
		reg [13:0] negmul1;
		begin 
		prod = {14'h0000,mul0,1'b0};
		negmul1 = (~mul1)+1;
		repeat(14)begin		
			if(prod[1:0]==2'b10)
				prod[28:15] = add_sat(prod[28:15], negmul1);
			else if(prod[1:0]==2'b01)
				prod[28:15] = add_sat(prod[28:15], mul1);				
			prod = {prod[28],prod[28:1]};
		end
		mult = multsat(prod);
		end
	endfunction

	function [13:0] multsat;
		input [28:0] prod;
		begin
		if(prod[28]&(~&prod[27:25])) //neg overflow for prod
			multsat = 14'h2000;
		else if((~prod[28])&(|prod[27:25]))
			multsat = 14'h1FFF;
		else
			multsat = prod[25:12];
		end
	endfunction

	function [13:0] add_sat;
		input [13:0] add1;
		input [13:0] add2;
		reg [13:0] temp;
		begin
		temp = add1 + add2;
		if(add1[13]==add2[13]) begin
			if((add1[13] == 1'b1) & (add1[13]!=temp[13])) begin //negative sat
				add_sat = 14'h2000;
			end else if((add1[13] == 1'b0) & (add1[13]!=temp[13])) //pos sat
				add_sat = 14'h1fff;
			else
				add_sat = temp;
		end else
			add_sat = temp;
		end
	endfunction

endmodule

