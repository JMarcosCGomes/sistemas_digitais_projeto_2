library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    port (
        clk, reset: in std_logic;
        ps2d, ps2c: in std_logic;
        led_out: out std_logic_vector(7 downto 0)
    );
end main;


architecture arch of main is
    signal kb_not_empty, kb_buf_empty: std_logic;
    signal key_code, ascii_code: std_logic_vector(7 downto 0);

    begin
        kb_code_unit: entity work.kb_code(arch)
        port map(
            clk=>clk, reset=>reset, ps2d=>ps2d, ps2c=>ps2c, 
            rd_key_code=>kb_not_empty, key_code=>key_code, 
            kb_buf_empty=>kb_buf_empty
        );

        key2a_unit: entity work.key2ascii(arch)
        port map(
            key_code=>key_code, ascii_code=>ascii_code
        );

        kb_not_empty <= not kb_buf_empty;
        
        -- using led_out as an example
        led_out <= ascii_code;

end arch;