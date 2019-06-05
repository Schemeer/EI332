library verilog;
use verilog.vl_types.all;
entity sc_computer is
    port(
        resetn          : in     vl_logic;
        clock           : in     vl_logic;
        mem_clk         : in     vl_logic;
        pc              : out    vl_logic_vector(31 downto 0);
        inst            : out    vl_logic_vector(31 downto 0);
        aluout          : out    vl_logic_vector(31 downto 0);
        memout          : out    vl_logic_vector(31 downto 0);
        in_port0        : in     vl_logic_vector(4 downto 0);
        in_port1        : in     vl_logic_vector(4 downto 0);
        hex0            : out    vl_logic_vector(6 downto 0);
        hex1            : out    vl_logic_vector(6 downto 0);
        hex2            : out    vl_logic_vector(6 downto 0);
        hex3            : out    vl_logic_vector(6 downto 0);
        hex4            : out    vl_logic_vector(6 downto 0);
        hex5            : out    vl_logic_vector(6 downto 0);
        leds            : out    vl_logic_vector(9 downto 0)
    );
end sc_computer;
