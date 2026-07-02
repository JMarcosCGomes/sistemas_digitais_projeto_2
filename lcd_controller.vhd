--
-- Código do Display Adaptado Dinamicamente para o Sistema de Senha
-- Baseado no modelo original da WR Kits (Eng. Wagner Rambo)
--
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_controller is
    generic (fclk: natural := 50_000_000); -- 50MHz, board crystal
    port (
        clk          : in std_logic; 
        msg_id  : in bit_vector(3 downto 0); -- Identifies the main FSM state
        RS, RW       : out bit;
        E            : buffer bit;  
        DB           : out bit_vector(7 downto 0)
    );
end lcd_controller;

architecture hardware of lcd_controller is
    type state is (FunctionSetl, FunctionSet2, FunctionSet3, FunctionSet4, FunctionSet5, 
                   FunctionSet6, FunctionSet7, FunctionSet8, FunctionSet9, FunctionSet10, 
                   FunctionSet11, FunctionSet12, FunctionSet13, FunctionSet14, FunctionSet15, 
                   FunctionSet16, FunctionSet17, FunctionSet18, FunctionSet19, ClearDisplay, 
                   DisplayControl, EntryMode, WriteDatal, SetAddress1, 
                   WriteData2, WriteData3, WriteData4, WriteData5, WriteData6, WriteData7, 
                   WriteData8, WriteData9, WriteData10, WriteData11, WriteData12, WriteData13, 
                   WriteData14, WriteData15, WriteData16, WriteData17, WriteData18, WriteData19, ReturnHome);
    signal pr_state, nx_state: state; 
begin

    -- Clock Generator (E -> 500Hz)
    process (clk)
        variable count: natural range 0 to fclk/1000; 
    begin
        if (clk' event and clk = '1') then 
            count := count + 1;
            if (count=fclk/1000) then 
                 E <= not E; 
                 count := 0; 
            end if; 
        end if; 
    end process;
    
    -- LCD FSM state update
    process (E) 
    begin
        if (E' event and E = '1') then 
            pr_state <= nx_state; 
        end if; 
    end process;
    
    -- Combinational Write Logic based on the provided diagram
    process (pr_state, msg_id) 
    begin
        case pr_state is
            -- LCD Physical Initialization States
            when FunctionSetl => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet2; 
            when FunctionSet2 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet3; 
            when FunctionSet3 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet4;
            when FunctionSet4 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet5;
            when FunctionSet5 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet6;
            when FunctionSet6 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet7;
            when FunctionSet7 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet8;
            when FunctionSet8 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet9;
            when FunctionSet9 => RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet10;
            when FunctionSet10=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet11;
            when FunctionSet11=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet12;
            when FunctionSet12=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet13;
            when FunctionSet13=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet14;
            when FunctionSet14=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet15;
            when FunctionSet15=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet16;
            when FunctionSet16=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet17;
            when FunctionSet17=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet18;
            when FunctionSet18=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= FunctionSet19;
            when FunctionSet19=> RS<= '0'; RW<= '0'; DB<= "00111000"; nx_state <= ClearDisplay;

            when ClearDisplay => RS<= '0'; RW<= '0'; DB <= "00000001"; nx_state <= DisplayControl; 
            when DisplayControl=>RS<= '0'; RW<= '0'; DB <= "00001100"; nx_state <= EntryMode; 
            when EntryMode    => RS<= '0'; RW<= '0'; DB <= "00000110"; nx_state <= WriteDatal; 

            when WriteDatal =>
                RS<= '1'; RW <='0'; DB <= "00100000"; -- Writes space
                nx_state <= SetAddress1; 

            when SetAddress1 =>
                RS<= '0'; RW<= '0'; DB <= "10000000"; -- Positions at the beginning of Line 0
                nx_state <= WriteData2; 

            ------------------------------------------------------------------
            -- DYNAMIC ALTERATION
            ------------------------------------------------------------------
            when WriteData2 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"49"; -- 'I' (Insert Password)
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"49"; -- 'I' (Insert attempt)
                    when "1011" => DB <= X"41"; -- 'A' (Correct, Acess granted)
                    when "1100" => DB <= X"45"; -- 'E' (Wrong, Try again)
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData3; 

            when WriteData3 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"6E"; -- 'n'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"6E"; -- 'n'
                    when "1011" => DB <= X"63"; -- 'c'
                    when "1100" => DB <= X"72"; -- 'r'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData4; 

            when WriteData4 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"73"; -- 's'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"73"; -- 's'
                    when "1011" => DB <= X"65"; -- 'e'
                    when "1100" => DB <= X"72"; -- 'r'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData5; 

            when WriteData5 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"69"; -- 'i'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"69"; -- 'i'
                    when "1011" => DB <= X"73"; -- 's'
                    when "1100" => DB <= X"6F"; -- 'o'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData6; 

            when WriteData6 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"72"; -- 'r'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"72"; -- 'r'
                    when "1011" => DB <= X"73"; -- 's'
                    when "1100" => DB <= X"75"; -- 'u'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData7; 

            when WriteData7 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"61"; -- 'a'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"61"; -- 'a'
                    when "1011" => DB <= X"6F"; -- 'o'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData8; 

            when WriteData8 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"20"; -- ' '
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"20"; -- ' '
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData9; 

            when WriteData9 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"61"; -- 'a'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"61"; -- 'a'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData10; 

            when WriteData10 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"20"; -- ' '
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"20"; -- ' '
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData11; 

            when WriteData11 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"73"; -- 's'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"74"; -- 't' (attempt)
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData12; 

            when WriteData12 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"65"; -- 'e'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"65"; -- 'e'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData13; 

            when WriteData13 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"6E"; -- 'n'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"6E"; -- 'n'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData14; 

            when WriteData14 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"68"; -- 'h'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"74"; -- 't'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData15; 

            when WriteData15 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0001"|"0010"|"0011"|"0100"|"0101" => DB <= X"61"; -- 'a'
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"61"; -- 'a'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData16; 

            when WriteData16 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"74"; -- 't' (attempt)
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData17; 

            when WriteData17 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"69"; -- 'i'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData18; 

            when WriteData18 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    when "0110"|"0111"|"1000"|"1001"|"1010" => DB <= X"76"; -- 'v'
                    when others => DB <= X"20";
                end case;
                nx_state <= WriteData19; 

            ------------------------------------------------------------------
            -- DYNAMIC CONTROL FOR PRINTING ASTERISKS (*)
            ------------------------------------------------------------------
            when WriteData19 =>
                RS<= '1'; RW<= '0';
                case msg_id is
                    -- Password States (with cumulative asterisks on the display)
                    when "0001" => DB <= X"61"; -- 'a' de senha puro
                    when "0010" => DB <= X"2A"; -- '*' (Estado S2)
                    when "0011" => DB <= X"2A"; -- '*' (Estado S3)
                    when "0100" => DB <= X"2A"; -- '*' (Estado S4)
                    when "0101" => DB <= X"2A"; -- '*' (Estado S5)
                    -- Attempt States
                    when "0110" => DB <= X"61"; -- 'a' de tentativa puro
                    when "0111" => DB <= X"2A"; -- '*' (Estado S7)
                    when "1000" => DB <= X"2A"; -- '*' (Estado S8)
                    when "1001" => DB <= X"2A"; -- '*' (Estado S9)
                    when "1010" => DB <= X"2A"; -- '*' (Estado S10)
                    when others => DB <= X"20";
                end case;
                nx_state <= ReturnHome; 

            when ReturnHome =>
                RS<= '0'; RW<= '0'; DB <= "10000000";
                nx_state <= WriteDatal; 
                
            when others =>
                nx_state <= FunctionSetl;
        end case; 
    end process;
end hardware;