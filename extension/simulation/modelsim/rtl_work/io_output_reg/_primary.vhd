library verilog;
use verilog.vl_types.all;
entity io_output_reg is
    port(
        addr            : in     vl_logic_vector(31 downto 0);
        datain          : in     vl_logic_vector(31 downto 0);
        write_io_enable : in     vl_logic;
        io_clk          : in     vl_logic;
        clrn            : in     vl_logic;
        out_port        : out    vl_logic_vector(31 downto 0)
    );
end io_output_reg;
