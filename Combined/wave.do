onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/rst_n
add wave -noupdate /cbc_dig_tb/DUT/iDIG/icntrl/clk
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/dst
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/eep_rd_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/eep_addr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/eep_cs_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/eep_r_w_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/chrg_pmp_en
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/cfg_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/Xmeas
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/accel_vld
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/frm_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/clr_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/wrt_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/snd_rsp
add wave -noupdate /cbc_dig_tb/DUT/iDIG/icntrl/accel_vld
add wave -noupdate /cbc_dig_tb/DUT/iDIG/icntrl/frm_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/cfg_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_prod
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/eep_addr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/chrg_pmp_en
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/eep_r_w_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/clk
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/clr_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/strt_tx
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/eep_cs_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_xset
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/wrt_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_err
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_sumerr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_diferr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_preverr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_pid
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_init_prod
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_subtract
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_multsat
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/c_clr_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/asrcsel
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/bsrcsel
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/state
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/next_state
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/in_cmd
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/set_in_cmd
add wave -noupdate -radix unsigned /cbc_dig_tb/DUT/iDIG/icntrl/cnt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/clr_cnt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/inc_cnt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/accel_vld_reg
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/accel_became_vld
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/eq_3ms
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/icntrl/prod_vld
add wave -noupdate -divider datapath
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/eep_rd_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/xmeas
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/cfg_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_asel
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/a
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_bsel
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/b
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_err
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_sumerr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_diferr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_xset
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_preverr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_pid
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_init_prod
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_subtract
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_multsat
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_clr_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/clk
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/rst_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/dst
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/c_prod
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/err
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/sumerr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/diferr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/xset
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/preverr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/pid
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/braw
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/b_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/rawsum
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/prod
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/nxt_prod
add wave -noupdate -divider Saturator
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/in
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/multsat
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/a13
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/b13
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/prod_msb
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/out
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/overflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/underflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/normout
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/multsatout
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/prodoverflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/produnderflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/in
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/multsat
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/a13
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/b13
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/prod_msb
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/out
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/overflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/underflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/normout
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/multsatout
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/prodoverflow
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iDIG/idatapath/satblock/produnderflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {64939000 ps} 0}
configure wave -namecolwidth 194
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {64921600 ps} {64952500 ps}
