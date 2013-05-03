library verilog;
use verilog.vl_types.all;
entity dig_core is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        Xmeas           : in     vl_logic_vector(13 downto 0);
        accel_vld       : in     vl_logic;
        cfg_data        : in     vl_logic_vector(23 downto 0);
        frm_rdy         : in     vl_logic;
        clr_rdy         : out    vl_logic;
        eep_rd_data     : in     vl_logic_vector(13 downto 0);
        eep_cs_n        : out    vl_logic;
        eep_r_w_n       : out    vl_logic;
        eep_addr        : out    vl_logic_vector(1 downto 0);
        chrg_pmp_en     : out    vl_logic;
        dst             : out    vl_logic_vector(13 downto 0);
        wrt_duty        : out    vl_logic;
        snd_rsp         : out    vl_logic
    );
end dig_core;
