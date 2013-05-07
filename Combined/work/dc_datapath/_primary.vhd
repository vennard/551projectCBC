library verilog;
use verilog.vl_types.all;
entity dc_datapath is
    port(
        dst             : out    vl_logic_vector(13 downto 0);
        c_prod          : out    vl_logic_vector(1 downto 0);
        eep_rd_data     : in     vl_logic_vector(13 downto 0);
        xmeas           : in     vl_logic_vector(13 downto 0);
        cfg_data        : in     vl_logic_vector(13 downto 0);
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        c_asel          : in     vl_logic_vector(2 downto 0);
        c_bsel          : in     vl_logic_vector(2 downto 0);
        c_err           : in     vl_logic;
        c_duty          : in     vl_logic;
        c_sumerr        : in     vl_logic;
        c_diferr        : in     vl_logic;
        c_xset          : in     vl_logic;
        c_preverr       : in     vl_logic;
        c_pid           : in     vl_logic;
        c_init_prod     : in     vl_logic;
        c_subtract      : in     vl_logic;
        c_multsat       : in     vl_logic;
        c_clr_duty      : in     vl_logic;
        c_eep_reg       : in     vl_logic
    );
end dc_datapath;
