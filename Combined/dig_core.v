module dig_core(clk, rst_n, Xmeas, accel_vld,
	            cfg_data, frm_rdy, clr_rdy,
	            eep_rd_data, eep_cs_n, eep_r_w_n,
	            eep_addr, chrg_pmp_en, dst,
	            wrt_duty, snd_rsp);
	            
input clk;
input rst_n;
input accel_vld;
input [13:0] Xmeas;
input [23:0] cfg_data;
input frm_rdy;
input [13:0] eep_rd_data;

output clr_rdy;
output eep_cs_n;
output eep_r_w_n;
output [1:0] eep_addr;
output chrg_pmp_en;
output [13:0] dst;
output wrt_duty;
output snd_rsp;

//////////////////////////////////////////
// Internal net needed for connections //
////////////////////////////////////////
wire [1:0] c_prod;
wire c_err;
wire c_duty;
wire c_sumerr;
//wire c_differr;
wire c_xset;
wire c_preverr;
wire c_pid;
wire c_init_prod;
wire c_subtract;
wire c_multsat;
wire c_clr_duty;
wire c_eep_reg;
wire [2:0] asrcsel;
wire [2:0] bsrcsel;

wire c_diferr;
wire init_prod;


///////////////////////////////
// Instantiate StateMachine Control
/////////////////////////////
control icntrl(.accel_vld(accel_vld),
               .frm_rdy(frm_rdy),
               .clk(clk),
               .rst_n(rst_n),
               .cfg_data(cfg_data),
               .c_prod(c_prod),
               .eep_addr(eep_addr),
               .chrg_pmp_en(chrg_pmp_en),
               .eep_r_w_n(eep_r_w_n),
               .clr_rdy(clr_rdy),
               .strt_tx(snd_rsp),		
               .eep_cs_n(eep_cs_n),
               .wrt_duty(wrt_duty),
               .c_err(c_err),
               .c_duty(c_duty),
               .c_sumerr(c_sumerr),
//             .c_diferr(c_diferr),
               .c_xset(c_xset),
               .c_preverr(c_preverr),
               .c_pid(c_pid),
               .c_init_prod(c_init_prod),
               .c_subtract(c_subtract),
               .c_multsat(c_multsat),
               .c_clr_duty(c_clr_duty),
					.c_eep_reg(c_eep_reg),
               .asrcsel(asrcsel),
               .bsrcsel(bsrcsel));


///////////////////////////////
// Instantiate Datapath
/////////////////////////////
dc_datapath idatapath(.dst(dst),
                      .c_prod(c_prod),
                      .eep_rd_data(eep_rd_data),
                      .xmeas(Xmeas),
                      .cfg_data(cfg_data[13:0]),
                      .clk(clk),
                      .rst_n(rst_n),
				          .c_asel(asrcsel),
				          .c_bsel(bsrcsel),
				          .c_err(c_err),
				          .c_duty(c_duty),
				          .c_sumerr(c_sumerr),
//				          .c_diferr(c_diferr),
				          .c_xset(c_xset),
				          .c_preverr(c_preverr),
				          .c_pid(c_pid),
				          .c_init_prod(c_init_prod),
				          .c_subtract(c_subtract),
				          .c_multsat(c_multsat), 
				          .c_clr_duty(c_clr_duty),
							 .c_eep_reg(c_eep_reg));
				         


endmodule
