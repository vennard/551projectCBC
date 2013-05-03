library verilog;
use verilog.vl_types.all;
entity accel_UART is
    port(
        RX_A            : in     vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        Xmeas           : out    vl_logic_vector(13 downto 0);
        accel_vld       : out    vl_logic
    );
end accel_UART;
