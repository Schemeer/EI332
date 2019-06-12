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
        out_port0       : out    vl_logic_vector(31 downto 0);
        out_port1       : out    vl_logic_vector(31 downto 0);
        out_port2       : out    vl_logic_vector(31 downto 0);
        out_port3       : out    vl_logic_vector(31 downto 0);
        out_port4       : out    vl_logic_vector(31 downto 0);
        out_port5       : out    vl_logic_vector(31 downto 0);
        in_port0        : in     vl_logic_vector(4 downto 0);
        in_port1        : in     vl_logic_vector(4 downto 0)
    );
end sc_datamem;
