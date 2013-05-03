library verilog;
use verilog.vl_types.all;
entity pwm is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        duty            : in     vl_logic_vector(13 downto 0);
        wrt_duty        : in     vl_logic;
        CH_A            : out    vl_logic;
        CH_B            : out    vl_logic
    );
end pwm;
