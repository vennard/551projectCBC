library verilog;
use verilog.vl_types.all;
entity UART_tx is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        tx_data         : in     vl_logic_vector(7 downto 0);
        trmt            : in     vl_logic;
        tx_done         : out    vl_logic;
        TX              : out    vl_logic
    );
end UART_tx;
