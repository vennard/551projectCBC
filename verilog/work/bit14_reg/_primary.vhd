library verilog;
use verilog.vl_types.all;
entity bit14_reg is
    port(
        \in\            : in     vl_logic_vector(13 downto 0);
        \out\           : out    vl_logic_vector(13 downto 0);
        clk             : in     vl_logic;
        en              : in     vl_logic
    );
end bit14_reg;
