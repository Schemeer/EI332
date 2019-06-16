library verilog;
use verilog.vl_types.all;
entity sc_datamem is
    port(
        addr            : in     vl_logic_vector(31 downto 0);
        datain          : in     vl_logic_vector(31 downto 0);
        dataout         : out    vl_logic_vector(31 downto 0);
        we              : in     vl_logic;
        clock           : in     vl_logic;
        mem_clk         : in     vl_logic;
        dmem_clk        : out    vl_logic;
        clrn            : in     vl_logic;
        out_port        : out    vl_logic_vector(31 downto 0);
        in_port0        : in     vl_logic_vector(3 downto 0);
        in_port1        : in     vl_logic_vector(3 downto 0)
    );
end sc_datamem;
