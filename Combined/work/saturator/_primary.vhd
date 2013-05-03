library verilog;
use verilog.vl_types.all;
entity saturator is
    port(
        \in\            : in     vl_logic_vector(13 downto 0);
        \out\           : out    vl_logic_vector(13 downto 0);
        multsat         : in     vl_logic;
        a13             : in     vl_logic;
        b13             : in     vl_logic;
        prod_msb        : in     vl_logic_vector(2 downto 0)
    );
end saturator;
