library verilog;
use verilog.vl_types.all;
entity accel_mstr is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TX_A            : out    vl_logic
    );
end accel_mstr;
