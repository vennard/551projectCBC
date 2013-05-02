library verilog;
use verilog.vl_types.all;
entity cbc_dig is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        RX_A            : in     vl_logic;
        RX_C            : in     vl_logic;
        TX_C            : out    vl_logic;
        CH_A            : out    vl_logic;
        CH_B            : out    vl_logic;
        dst             : out    vl_logic_vector(13 downto 0);
        eep_rd_data     : in     vl_logic_vector(13 downto 0);
        eep_addr        : out    vl_logic_vector(1 downto 0);
        eep_cs_n        : out    vl_logic;
        eep_r_w_n       : out    vl_logic;
        chrg_pmp_en     : out    vl_logic
    );
end cbc_dig;
