library verilog;
use verilog.vl_types.all;
entity control is
    port(
        accel_vld       : in     vl_logic;
        frm_rdy         : in     vl_logic;
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        cfg_data        : in     vl_logic_vector(23 downto 0);
        c_prod          : in     vl_logic_vector(1 downto 0);
        eep_addr        : out    vl_logic_vector(1 downto 0);
        chrg_pmp_en     : out    vl_logic;
        eep_r_w_n       : out    vl_logic;
        clr_rdy         : out    vl_logic;
        strt_tx         : out    vl_logic;
        eep_cs_n        : out    vl_logic;
        wrt_duty        : out    vl_logic;
        c_err           : out    vl_logic;
        c_duty          : out    vl_logic;
        c_sumerr        : out    vl_logic;
        c_diferr        : out    vl_logic;
        c_xset          : out    vl_logic;
        c_preverr       : out    vl_logic;
        c_pid           : out    vl_logic;
        c_init_prod     : out    vl_logic;
        c_subtract      : out    vl_logic;
        c_multsat       : out    vl_logic;
        c_clr_duty      : out    vl_logic;
        asrcsel         : out    vl_logic_vector(2 downto 0);
        bsrcsel         : out    vl_logic_vector(2 downto 0);
        c_eep_reg       : out    vl_logic
    );
end control;
