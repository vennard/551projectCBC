onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /cbc_dig_tb/eep_addr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/eep_rd_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/dst
add wave -noupdate -radix hexadecimal /cbc_dig_tb/resp
add wave -noupdate -radix hexadecimal /cbc_dig_tb/duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/rsp_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/cfg_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/sumerr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/preverr
add wave -noupdate -radix hexadecimal /cbc_dig_tb/xset
add wave -noupdate -radix hexadecimal /cbc_dig_tb/err
add wave -noupdate -radix hexadecimal /cbc_dig_tb/accel_vld
add wave -noupdate -radix hexadecimal /cbc_dig_tb/frm_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/c_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/state
add wave -noupdate -radix hexadecimal /cbc_dig_tb/in_cmd
add wave -noupdate -radix hexadecimal /cbc_dig_tb/cmd_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/clk
add wave -noupdate -radix hexadecimal /cbc_dig_tb/rst_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/snd_frm
add wave -noupdate -radix hexadecimal /cbc_dig_tb/test
add wave -noupdate -radix hexadecimal /cbc_dig_tb/count
add wave -noupdate -radix hexadecimal /cbc_dig_tb/strtTest
add wave -noupdate -radix hexadecimal /cbc_dig_tb/xsetNew
add wave -noupdate -radix hexadecimal /cbc_dig_tb/xcnt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/cmdNew
add wave -noupdate -radix hexadecimal /cbc_dig_tb/cmdCnt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/runningAdvanced
add wave -noupdate -radix hexadecimal /cbc_dig_tb/wrt_duty
add wave -noupdate -radix hexadecimal /cbc_dig_tb/prod_vld
add wave -noupdate -radix hexadecimal /cbc_dig_tb/strt_tx
add wave -noupdate -radix hexadecimal /cbc_dig_tb/RX_A
add wave -noupdate -radix hexadecimal /cbc_dig_tb/RX_C
add wave -noupdate -radix hexadecimal /cbc_dig_tb/TX_C
add wave -noupdate -radix hexadecimal /cbc_dig_tb/CH_A
add wave -noupdate -radix hexadecimal /cbc_dig_tb/CH_B
add wave -noupdate -radix hexadecimal /cbc_dig_tb/eep_cs_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/eep_r_w_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/chrg_pmp_en
add wave -noupdate -radix hexadecimal /cbc_dig_tb/duty_valid
add wave -noupdate -divider cfg_UART
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/clk
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rst_n
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/RX
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/clr_frm_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/snd_rsp
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rsp_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/TX
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/frm_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/cfg_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/tx_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/trmt
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/tx_done
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rx_data
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/clr_rdy
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rsp_data_sel
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/msb_cfg_en
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/b2_cfg_en
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/state
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/nxt_state
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/rsp_data_lsb
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/cfg_data_msb
add wave -noupdate -radix hexadecimal /cbc_dig_tb/DUT/iCFG/cfg_data_b2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1517191000 ps} 0}
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
WaveRestoreZoom {1232430900 ps} {1743611700 ps}
