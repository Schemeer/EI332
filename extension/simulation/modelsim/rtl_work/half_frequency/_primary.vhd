library verilog;
use verilog.vl_types.all;
entity half_frequency is
    port(
        clk             : in     vl_logic;
        CLOCK           : out    vl_logic
    );
end half_frequency;
