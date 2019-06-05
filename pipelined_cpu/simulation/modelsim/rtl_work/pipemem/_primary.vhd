library verilog;
use verilog.vl_types.all;
entity pipemem is
    port(
        mwmem           : in     vl_logic;
        malu            : in     vl_logic_vector(31 downto 0);
        mb              : in     vl_logic_vector(31 downto 0);
        clock           : in     vl_logic;
        clrn            : in     vl_logic;
        mem_clock       : in     vl_logic;
        mmo             : out    vl_logic_vector(31 downto 0);
        in_port0        : in     vl_logic_vector(3 downto 0);
        in_port1        : in     vl_logic_vector(3 downto 0);
        out_port0       : out    vl_logic_vector(31 downto 0);
        out_port1       : out    vl_logic_vector(31 downto 0);
        out_port2       : out    vl_logic_vector(31 downto 0);
        out_port3       : out    vl_logic_vector(31 downto 0);
        out_port4       : out    vl_logic_vector(31 downto 0);
        out_port5       : out    vl_logic_vector(31 downto 0)
    );
end pipemem;
