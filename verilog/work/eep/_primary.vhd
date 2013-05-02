library verilog;
use verilog.vl_types.all;
entity eep is
    port(
        clk             : in     vl_logic;
        por_n           : in     vl_logic;
        eep_addr        : in     vl_logic_vector(1 downto 0);
        wrt_data        : in     vl_logic_vector(13 downto 0);
        rd_data         : out    vl_logic_vector(13 downto 0);
        eep_cs_n        : in     vl_logic;
        eep_r_w_n       : in     vl_logic;
        chrg_pmp_en     : in     vl_logic
    );
end eep;
