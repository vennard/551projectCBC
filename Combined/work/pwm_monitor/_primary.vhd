library verilog;
use verilog.vl_types.all;
entity pwm_monitor is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        CH_A            : in     vl_logic;
        CH_B            : in     vl_logic;
        duty            : out    vl_logic_vector(13 downto 0);
        duty_valid      : out    vl_logic
    );
end pwm_monitor;
