library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity main is
    port (
        clk, reset: in std_logic;
        ps2d, ps2c: in std_logic;
        RS, RW    : out std_logic;
        E         : out std_logic;  
        DB        : out std_logic_vector(7 downto 0);
        led_out   : out std_logic_vector(7 downto 0)
    );
end main;

architecture arch of main is
    signal kb_not_empty, kb_buf_empty: std_logic;
    signal key_code, ascii_code: std_logic_vector(7 downto 0);

    signal lcd_rs, lcd_rw, lcd_e : bit;
    signal lcd_db : bit_vector(7 downto 0);

    -- LCD Phrase Control (4 mapped bits)
    signal msg_id : bit_vector(3 downto 0) := "0000";

    -- Main FSM
    type state_type is (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12);
    signal present_state, next_state : state_type := S0;
    
    signal enter_pressed : std_logic := '0';

    signal a, b, c, d : std_logic_vector(7 downto 0) := (others => '0');
    signal f, g, h, i : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- ========================================================
    -- PORT MAP DO DISPLAY
    -- ========================================================
    lcd_display_unit: entity work.lcd_controller(hardware)
        generic map (
            fclk => 50_000_000
        )
        port map (
            clk => clk,
            msg_id => msg_id,
            RS => lcd_rs,
            RW => lcd_rw,
            E  => lcd_e,
            DB => lcd_db
        );

    -- Automatic conversion of Bit to STD_LOGIC data
    RS <= '1' when lcd_rs = '1' else '0';
    RW <= '1' when lcd_rw = '1' else '0';
    E  <= '1' when lcd_e  = '1' else '0';
    DB <= to_stdlogicvector(lcd_db);

    -- PS/2 Keyboard Instantiation
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

    kb_not_empty  <= not kb_buf_empty;
    enter_pressed <= '1' when (kb_not_empty = '1' and ascii_code = x"0D") else '0';

    -- FSM Sequential Process
    process(clk, reset)
    begin
        if reset = '1' then
            present_state <= S0;
            a <= (others => '0'); b <= (others => '0'); c <= (others => '0'); d <= (others => '0');
            f <= (others => '0'); g <= (others => '0'); h <= (others => '0'); i <= (others => '0');
        elsif rising_edge(clk) then
            if enter_pressed = '1' then
                present_state <= next_state;
            end if;

            if kb_not_empty = '1' and ascii_code /= x"0D" then
                case present_state is
                    when S1 => a <= ascii_code;
                    when S2 => b <= ascii_code;
                    when S3 => c <= ascii_code;
                    when S4 => d <= ascii_code;
                    when S6 => f <= ascii_code;
                    when S7 => g <= ascii_code;
                    when S8 => h <= ascii_code;
                    when S9 => i <= ascii_code;
                    when others => null;
                end case;
            end if;
        end if;
     end process;

    -- FSM Combinational Logic (Applies the flowchart msg_ids)
    process(present_state, a, b, c, d, f, g, h, i)
    begin
        next_state  <= present_state;
        led_out     <= x"00";
        msg_id <= "0000"; 

        case present_state is
            when S0 =>
                next_state <= S1;
            
            when S1 =>
                msg_id <= "0001"; -- Shows "Insira a senha"
                led_out     <= x"01";
                next_state  <= S2;
            
            when S2 =>
                msg_id <= "0010"; -- Shows "Insira a senha *"
                led_out     <= x"02";
                next_state  <= S3;
            
            when S3 =>
                msg_id <= "0011"; -- Shows "Insira a senha **"
                led_out     <= x"03";
                next_state  <= S4;
                    
            when S4 =>
                msg_id <= "0100"; -- Shows "Insira a senha ***"
                led_out     <= x"04";
                next_state  <= S5;

            when S5 =>
                msg_id <= "0101"; -- Shows "Insira a senha ****"
                led_out     <= x"05"; 
                next_state  <= S6; 
            
            when S6 =>
                msg_id <= "0110"; -- Shows "Insira a tentativa"
                led_out     <= x"06";
                next_state  <= S7;
            
            when S7 =>
                msg_id <= "0111"; -- Shows "Insira a tentativa *"
                led_out     <= x"07";
                next_state  <= S8;
            
            when S8 =>
                msg_id <= "1000"; -- Shows "Insira a tentativa **"
                led_out     <= x"08";
                next_state  <= S9;

            when S9 =>
                msg_id <= "1001"; -- Shows "Insira a tentativa ***"
                led_out     <= x"09";
                next_state  <= S10;

            when S10 =>
                msg_id <= "1010"; -- Shows "Insira a tentativa ****"
                led_out     <= x"0A";
                if (a = f) and (b = g) and (c = h) and (d = i) then 
                    next_state <= S11; 
                else 
                    next_state <= S12; 
                end if;
            
            when S11 =>
                msg_id <= "1011"; -- Shows "Acessou"
                led_out     <= x"0B";
                next_state  <= S1;

            when S12 =>
                msg_id <= "1100"; -- Shows "Errou Tente Novamente"
                led_out     <= x"0C";
                next_state  <= S6;
                     
            when others =>
                next_state <= S0;
        end case;
    end process;

end arch;