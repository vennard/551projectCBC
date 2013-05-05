module control(accel_vld, frm_rdy, clk, rst_n, cfg_data, c_prod, eep_addr,
               chrg_pmp_en, eep_r_w_n, clr_rdy, strt_tx_true, eep_cs_n, wrt_duty,
               c_err, c_duty, c_sumerr, c_diferr, c_xset, c_preverr, c_pid,
               c_init_prod, c_subtract, c_multsat, c_clr_duty, asrcsel, bsrcsel);
               
input accel_vld;
input frm_rdy;
input clk; 
input rst_n;
input [23:0] cfg_data;
input [1:0] c_prod;

output reg [1:0] eep_addr;
output reg chrg_pmp_en;
output reg eep_r_w_n;
output reg clr_rdy;
output strt_tx_true; //JOHN changed TODO also in sensitivity list ^ ^
//output reg strt_tx;
output reg eep_cs_n;
output reg wrt_duty;

output reg c_err; 
output reg c_duty; 
output reg c_sumerr; 
output reg c_diferr; 
output reg c_xset; 
output reg c_preverr; 
output reg c_pid; 
output reg c_init_prod;
output reg c_subtract; 
output reg c_multsat;
output reg c_clr_duty;

output reg [2:0] asrcsel;
output reg [2:0] bsrcsel;

reg [3:0] state; 
reg [3:0] next_state;
reg in_cmd;
reg set_in_cmd;

reg [21:0] cnt;
reg clr_cnt;
reg inc_cnt;
reg accel_vld_reg;

wire accel_became_vld;
wire eq_3ms;
wire prod_vld;
wire mult_sat;

//local params for all states
localparam  INIT           = 4'h0, 
            WAIT_ACCEL_VLD = 4'h1,
            CALC_ERR       = 4'h2,
            PMULT          = 4'h3,
            LOADI          = 4'h4,
            CALC_SUMERR    = 4'h5,
            IMULT          = 4'h6,
            LOADD          = 4'h7,
            CALC_DERR      = 4'h8,
            DMULT          = 4'h9,
            SET_PREVERR    = 4'hA,
            NEW_XSET       = 4'hB,
            CMDINTR        = 4'hC,
            CHRG_PMP       = 4'hD,
            WAIT_CMD       = 4'hE;

//CMD params
localparam  STRT_CMD    = 2'b00,
            READ_EEP    = 2'b01,
            WRITE_EEP   = 2'b10;
            
//selector A params
localparam	CFGDATA	= 3'b000,
				XMEAS 	= 3'b001,
				ERR		= 3'b010,
				PROD2815	= 3'b011,
				DUTY		= 3'b100,
				SUMERRA	= 3'b101,
				DIFERR	= 3'b110,
				ZEROA		= 3'b111;
				
//selector B params
localparam	XSET		= 3'b000,
				SUMERRB	= 3'b001,
				PREVERR	= 3'b010,
				ZEROB		= 3'b011,
				PID		= 3'b100,
				POSACKA5A= 3'b101,
				PROD2512	= 3'b110,
				EEPDATA	= 3'b111;

			
//JOHN ADDED CODE TODO -- fixing response problem - strt tx held for 2 clk
reg txCheck;
reg strt_tx;
always @(posedge clk, negedge rst_n)
	if(!rst_n)
	  txCheck <= 1'b0;
	else
	  txCheck <= strt_tx;

assign strt_tx_true = (strt_tx | txCheck);



always @(posedge clk, negedge rst_n)
   if(!rst_n)
      state <= 4'b0000;
   else
      state <= next_state;
      
always @(posedge clk, negedge rst_n)
   if(!rst_n)
      in_cmd <= 1'b0;
   else if(set_in_cmd)
      in_cmd <= 1'b1;
      
////////////////////////////////////
// Counter                        //
////////////////////////////////////
always @(posedge clk, negedge rst_n)
   if(!rst_n)
      cnt <= 22'h000000;
   else if(clr_cnt)
      cnt <= 22'h000000;
   else if(inc_cnt)
      cnt <= cnt + 1;
   else
      cnt <= cnt;
      
// @800Mhz 3ms = 0x249F00 // TODO: CHECK THIS NUMBER
assign eq_3ms = (cnt == 22'h249F00) ? 1'b1 : 1'b0;

// Counter to 14 for multiply
assign prod_vld = (cnt == 22'h00000E);
assign mult_sat = (cnt == 22'h00000F);


////////////////////////////////////
// Accel_vld posedge detection    //
////////////////////////////////////
always@(posedge clk)
   accel_vld_reg <= accel_vld;

assign accel_became_vld = (~accel_vld_reg & accel_vld);

////////////////////////////////////
// State Machine                  //
////////////////////////////////////
always @(state, accel_became_vld, prod_vld, c_prod, frm_rdy, in_cmd, cfg_data, eq_3ms) //TODO: check these
begin
   //TODO:DEFAULTS//
   next_state = INIT; //TODO: POSSIBLE DEFAULT STATE ???
   eep_addr = 2'b00;
   eep_r_w_n = 1'b1; // TODO: defualt to read?
   eep_cs_n = 1'b1;
   
   c_err = 1'b0; 
	c_duty = 1'b0;
	c_sumerr = 1'b0; 
	c_diferr = 1'b0; 
	c_xset = 1'b0; 
	c_preverr = 1'b0; 
	c_pid = 1'b0;

	c_init_prod = 1'b0;
 
	c_subtract = 1'b0;
	c_multsat = 1'b0;
	c_clr_duty = 1'b0;

	inc_cnt = 1'b0;
	clr_cnt = 1'b0;
	chrg_pmp_en = 1'b0;

	clr_rdy = 1'b0;
	strt_tx = 1'b0;

	wrt_duty = 1'b0;

	set_in_cmd = 1'b0;
	
   asrcsel = ZEROA;
   bsrcsel = ZEROB;

   case(state)
      INIT : begin
         // PrevErr = 0
         // SumErr = 0 both should be handled by rst_n       
         // Read EEP(00) = XSET
         eep_addr = 2'b00;
         eep_r_w_n = 1'b1;
         eep_cs_n = 1'b0;
         c_xset = 1'b1;
         asrcsel = ZEROA;
         bsrcsel = EEPDATA;
         next_state = WAIT_ACCEL_VLD;
      end //end INIT
      
      WAIT_ACCEL_VLD : begin
         if(accel_became_vld) begin
            // available cycle here so prepare for mult by loading PID with P
            // Read EEP(01) = P
            eep_addr = 2'b01;
            eep_r_w_n = 1'b1;
            eep_cs_n = 1'b0;
            c_pid = 1'b1;
            asrcsel = ZEROA;
            bsrcsel = EEPDATA;
            next_state = CALC_ERR;
         end   
         else
            next_state = WAIT_ACCEL_VLD;
      end //end WAIT_ACCEL_VLD       

      CALC_ERR : begin
         // Err = Xmeas - Xset
         c_err = 1'b1;
			c_subtract = 1'b1;
			asrcsel = XMEAS;
			bsrcsel = XSET;
			// Err into the prod reg
			c_init_prod = 1'b1;
			clr_cnt = 1'b1;
			next_state = PMULT;
      end //end CALC_ERR

      PMULT : begin
         // Duty = P*Err / 0x800
         if(~prod_vld & ~mult_sat)begin
				inc_cnt = 1'b1;
				next_state = PMULT;
				asrcsel = PROD2815;
				if(c_prod == 2'b10) begin
					bsrcsel = PID;
					c_subtract = 1'b1;
				end 
				else if(c_prod == 2'b01)
					bsrcsel = PID;
				else
					bsrcsel = ZEROB;						
			end
			else if(prod_vld) begin
			   inc_cnt = 1'b1;
			   next_state = PMULT;
			   bsrcsel = PROD2512;
				asrcsel = ZEROA;
				c_pid = 1'b1;
				c_multsat = 1'b1;
			end 
			else begin
			   // Multiply finished load Duty with multiply value
				bsrcsel = PID;
				asrcsel = ZEROA;
				c_duty = 1'b1;
				next_state = LOADI;
			end
      end //end PMULT
      
      LOADI : begin
         // Read EEP(10) = I
         eep_addr = 2'b10;
         eep_r_w_n = 1'b1;
         eep_cs_n = 1'b0;
         c_pid = 1'b1;
         asrcsel = ZEROA;
         bsrcsel = EEPDATA;
         next_state = CALC_SUMERR;
      end //end LOADI

      CALC_SUMERR : begin
         // SumErr = SumErr + Err
         c_sumerr = 1'b1;
         asrcsel = ERR;
         bsrcsel = SUMERRB;
         // SumErr into the prod reg
         c_init_prod = 1'b1;
         clr_cnt = 1'b1;
         next_state = IMULT;
      end //end CALC_SUMERR

      IMULT : begin
         // Duty = Duty + I*SumErr / 0x800
         if(~prod_vld & ~mult_sat)begin
				inc_cnt = 1'b1;
				next_state = IMULT;
				asrcsel = PROD2815;
				if(c_prod == 2'b10) begin
					bsrcsel = PID;
					c_subtract = 1'b1;
				end 
				else if(c_prod == 2'b01)
					bsrcsel = PID;
				else
					bsrcsel = ZEROB;						
			end
			else if(prod_vld) begin
			   inc_cnt = 1'b1;
			   next_state = IMULT;
			   bsrcsel = PROD2512;
				asrcsel = ZEROA;
				c_pid = 1'b1;
				c_multsat = 1'b1;
			end  
			else begin
			   // Multiply finished add to Duty the multiply value
				bsrcsel = PID;
				asrcsel = DUTY;
				c_duty = 1'b1;
				next_state = LOADD;
			end      
      end //end IMULT

      LOADD : begin
         // Read EEP(11) = D
         eep_addr = 2'b11;
         eep_r_w_n = 1'b1;
         eep_cs_n = 1'b0;
         c_pid = 1'b1;
         asrcsel = ZEROA;
         bsrcsel = EEPDATA;
         next_state = CALC_DERR;
      end //end LOADD

      CALC_DERR : begin
         //DErr = Err - PrevErr
         c_diferr = 1'b1;
			c_subtract = 1'b1;
			asrcsel = ERR;
			bsrcsel = PREVERR;
			// DErr into the prod reg
			c_init_prod = 1'b1;
			clr_cnt = 1'b1;
			next_state = DMULT;         
      end //end CALC_DERR

      DMULT : begin
         //Duty = Duty + D*Derr / 0x800
         if(~prod_vld & ~mult_sat)begin
				inc_cnt = 1'b1;
				next_state = DMULT;
				asrcsel = PROD2815;
				if(c_prod == 2'b10) begin
					bsrcsel = PID;
					c_subtract = 1'b1;
				end 
				else if(c_prod == 2'b01)
					bsrcsel = PID;
				else
					bsrcsel = ZEROB;						
			end
			else if(prod_vld) begin
			   inc_cnt = 1'b1;
			   next_state = DMULT;
			   bsrcsel = PROD2512;
				asrcsel = ZEROA;
				c_pid = 1'b1;
				c_multsat = 1'b1;
			end 
			else begin
			   // Multiply finished add to Duty the multiply value
				bsrcsel = PID;
				asrcsel = DUTY;
				// Write Duty to the PWM
				wrt_duty = 1'b1;
				c_duty = 1'b1;
				next_state = SET_PREVERR;
			end 
      end //end DMULT

      SET_PREVERR : begin
         //PrevErr = Err
         asrcsel = ERR;
         bsrcsel = ZEROB;
         clr_cnt = 1'b1;
         c_preverr = 1'b1;
         if(~frm_rdy)
            next_state = WAIT_ACCEL_VLD;
			 else if (cfg_data[19:18] == 2'b11) begin
            //clr_rdy = 1'b1;
				next_state = NEW_XSET;
			 end
         else
            next_state = CMDINTR;           
      end //end SET_PREVERR

      NEW_XSET : begin
     		clr_rdy = 1'b1;
         asrcsel = CFGDATA;
         bsrcsel = ZEROB;
         c_xset = 1'b1;
         strt_tx = 1'b1;
         //Echo back to master
         next_state = WAIT_ACCEL_VLD;
      end //end NEW_XSET

      CMDINTR : begin
         clr_rdy = 1'b1;
         clr_cnt = 1'b1;
         case(cfg_data[19:18])
            WRITE_EEP : begin
               if(in_cmd) begin
                  eep_addr = cfg_data[17:16];
                  asrcsel = cfg_data[13:0];
                  bsrcsel = ZEROB;
                  eep_cs_n = 1'b0;
                  eep_r_w_n = 1'b0;
                  chrg_pmp_en = 1'b1;
                  inc_cnt = 1'b1;
                  next_state = CHRG_PMP;
               end
               else begin //NEGACK
                  asrcsel = ZEROA;
                  bsrcsel = POSACKA5A;
                  c_subtract = 1'b1;
                  strt_tx = 1'b1;
                  next_state = WAIT_CMD;
               end
            end //end WRITE_EPP
            READ_EEP : begin
               if(in_cmd) begin
                  //read eeprom send data to UART
                  eep_addr = cfg_data[17:16];
                  eep_cs_n = 1'b0;
                  eep_r_w_n = 1'b1;
                  asrcsel = ZEROA;
                  bsrcsel = EEPDATA;
                  strt_tx = 1'b1;
                  next_state = WAIT_CMD;
               end
               else begin //NEGACK
                  asrcsel = ZEROA;
                  bsrcsel = POSACKA5A;
                  c_subtract = 1'b1;
                  strt_tx = 1'b1;
                  next_state = WAIT_CMD;
               end
            end // end READ_EEP
            STRT_CMD : begin
               if(&cfg_data[17:16]) begin
                  //set cmd mode send Posack
                  set_in_cmd = 1'b1;
                  asrcsel = ZEROA;
                  bsrcsel = POSACKA5A;
                  strt_tx = 1'b1;
                  next_state = WAIT_CMD;
               end
               else begin //NEGACK
                  asrcsel = ZEROA;
                  bsrcsel = POSACKA5A;
                  c_subtract = 1'b1;
                  strt_tx = 1'b1;
                  next_state = WAIT_CMD;
               end
            end // end STRT_CMD
            default : begin //NEGACK
               asrcsel = ZEROA;
               bsrcsel = POSACKA5A;
               c_subtract = 1'b1;
               strt_tx = 1'b1;
               next_state = WAIT_CMD;
            end // default
         endcase
      end //end CMDINTR

      CHRG_PMP: begin
         if(~eq_3ms) begin
            /*eep_addr = cfg_data[17:16];
            asrcsel = cfg_data[13:0];
            bsrcsel = ZEROB;*/ //TODO: Dont think these are needed
            eep_cs_n = 1'b0;
            eep_r_w_n = 1'b0;
            chrg_pmp_en = 1'b1;
            inc_cnt = 1'b1;
            next_state = CHRG_PMP;
         end
         else begin //POSACK
            asrcsel = ZEROA;
            bsrcsel = POSACKA5A;
            strt_tx = 1'b1;
            next_state = WAIT_CMD;
         end
      end //end CHRG_PMP

      WAIT_CMD : begin
         if(frm_rdy)
            next_state = CMDINTR;
         else begin
            //PWM Duty = 0
            c_clr_duty = 1'b1;
            asrcsel = ZEROA;
            bsrcsel = ZEROB;
            wrt_duty = 1'b1;
            next_state = WAIT_CMD;
         end
      end // end WAIT_CMD
      default : next_state = INIT;
   endcase
end


endmodule
