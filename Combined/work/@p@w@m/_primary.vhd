library verilog;
use verilog.vl_types.all;
entity PWM is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        wrt_duty        : in     vl_logic;
        duty            : in     vl_logic_vector(13 downto 0);
        CH_A            : out    vl_logic;
        CH_B            : out    vl_logic
    );
end PWM;
