library verilog;
use verilog.vl_types.all;
entity cfg_mstr is
    port(
        cmd_data        : in     vl_logic_vector(23 downto 0);
        snd_frm         : in     vl_logic;
        resp            : out    vl_logic_vector(15 downto 0);
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        TX_C            : out    vl_logic;
        RX_C            : in     vl_logic;
        rsp_rdy         : out    vl_logic
    );
end cfg_mstr;
