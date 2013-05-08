library verilog;
use verilog.vl_types.all;
entity mult_synth is
    port(
        wrtp            : in     vl_logic;
        wrti            : in     vl_logic;
        wrtd            : in     vl_logic;
        wrtxset         : in     vl_logic;
        chngxset        : in     vl_logic;
        xmeas           : in     vl_logic_vector(13 downto 0);
        cfg_data        : in     vl_logic_vector(13 downto 0);
        accel_vld       : in     vl_logic;
        duty            : out    vl_logic_vector(13 downto 0);
        duty_vld        : out    vl_logic
    );
end mult_synth;
