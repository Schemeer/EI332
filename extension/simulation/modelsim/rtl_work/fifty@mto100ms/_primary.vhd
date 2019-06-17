library verilog;
use verilog.vl_types.all;
entity fiftyMto100ms is
    port(
        clk             : in     vl_logic;
        CLOCK           : out    vl_logic
    );
end fiftyMto100ms;
