library verilog;
use verilog.vl_types.all;
entity UART is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        tx_data         : in     vl_logic_vector(7 downto 0);
        trmt            : in     vl_logic;
        tx_done         : out    vl_logic;
        rx_data         : out    vl_logic_vector(7 downto 0);
        rdy             : out    vl_logic;
        clr_rdy         : in     vl_logic;
        TX              : out    vl_logic;
        RX              : in     vl_logic
    );
end UART;
