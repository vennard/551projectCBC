library verilog;
use verilog.vl_types.all;
entity UART_rx is
    port(
        rx_data         : out    vl_logic_vector(7 downto 0);
        rdy             : out    vl_logic;
        RX              : in     vl_logic;
        clr_rdy         : in     vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic
    );
end UART_rx;
