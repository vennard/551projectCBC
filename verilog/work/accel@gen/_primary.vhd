library verilog;
use verilog.vl_types.all;
entity accelGen is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TX_A            : out    vl_logic;
        mode            : in     vl_logic_vector(1 downto 0)
    );
end accelGen;
