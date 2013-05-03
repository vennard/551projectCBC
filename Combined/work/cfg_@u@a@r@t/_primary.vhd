library verilog;
use verilog.vl_types.all;
entity cfg_UART is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TX              : out    vl_logic;
        RX              : in     vl_logic;
        clr_frm_rdy     : in     vl_logic;
        snd_rsp         : in     vl_logic;
        rsp_data        : in     vl_logic_vector(15 downto 0);
        frm_rdy         : out    vl_logic;
        cfg_data        : out    vl_logic_vector(23 downto 0)
    );
end cfg_UART;
