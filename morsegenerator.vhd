LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY morsegenerator IS
	PORT
	(
		clk                    : IN  STD_LOGIC;
		letter_number_selector : IN  STD_LOGIC;
		push_button_3x2        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
		jack_audio             : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END morsegenerator;
ARCHITECTURE Behavioral OF morsegenerator IS
	SIGNAL clock                  : STD_LOGIC                     := '0';
	SIGNAL prev_state_3x2_push    : STD_LOGIC_VECTOR (5 DOWNTO 0) := "111111";
	SIGNAL braille_pattern_set    : STD_LOGIC_VECTOR(6 DOWNTO 0)  := "0000000";
	SIGNAL debounce_delay_counter : INTEGER RANGE 0 TO 6000000;
	SIGNAL dac_out                : STD_LOGIC;
	SIGNAL bit_index_increment    : STD_LOGIC                 := '0';
	SIGNAL bit_time               : INTEGER                   := 0;
	SIGNAL bit_index              : INTEGER                   := 0;
	SIGNAL bit_sequence           : STD_LOGIC_VECTOR(0 TO 21) := "0000000000000000000000";
	SIGNAL bit_tone_period        : INTEGER RANGE 0 TO 200000;
	CONSTANT bit_sequence_length  : INTEGER := 22;
BEGIN
	devideClock : PROCESS (clk)
	BEGIN
		IF rising_edge (clk) THEN
			clock <= NOT clock;
		END IF;
	END PROCESS;
	jack_audio <= dac_out & dac_out;
	PROCESS (clk, bit_sequence, bit_index_increment, bit_index_increment)
	BEGIN
		IF rising_edge(clock) THEN
			debounce_delay_counter <= debounce_delay_counter + 1;
			IF debounce_delay_counter = 60000 THEN
				debounce_delay_counter <= 0;
				FOR i IN 0 TO 5 LOOP
					IF (push_button_3x2(i) = '0' AND prev_state_3x2_push(i) = '1') THEN
						bit_index_increment    <= '1';
						braille_pattern_set(i) <= NOT braille_pattern_set(i);
					END IF;
					prev_state_3x2_push(i) <= push_button_3x2(i);
				END LOOP;
			END IF;
			IF bit_time = 5000000 THEN
				bit_time        <= 0;
				bit_tone_period <= 0;
				IF bit_index = bit_sequence_length OR bit_index_increment = '1' THEN
					bit_index           <= 0;
					bit_index_increment <= '0';
					ELSE
					bit_index <= bit_index + 1;
				END IF;
				ELSE
				bit_time <= bit_time + 1;
			END IF;
			bit_tone_period <= bit_tone_period + 1;
			IF bit_tone_period = 66666 THEN
				bit_tone_period <= 0;
				IF bit_sequence(bit_index) = '1' THEN
					dac_out <= NOT dac_out;
					ELSE
					dac_out <= '0';
				END IF;
			END IF;
			braille_pattern_set(6) <= NOT letter_number_selector;
			CASE braille_pattern_set IS
				WHEN "0100000" => bit_sequence <= "1001110000000000000000"; --A >.-
				WHEN "0101000" => bit_sequence <= "0111010101000000000000"; --B >-...
				WHEN "0110000" => bit_sequence <= "0111010011101000000000"; --C >-.-.
				WHEN "0110100" => bit_sequence <= "0111010100000000000000"; --D >-..
				WHEN "0100100" => bit_sequence <= "1000000000000000000000"; --E >.
				WHEN "0111000" => bit_sequence <= "1010011101000000000000"; --F >..-.
				WHEN "0111100" => bit_sequence <= "0111011101000000000000"; --G >--.
				WHEN "0101100" => bit_sequence <= "1010101000000000000000"; --H >....
				WHEN "0011000" => bit_sequence <= "1010000000000000000000"; --I >..
				WHEN "0011100" => bit_sequence <= "1001110111011100000000"; --J >.---
				WHEN "0100010" => bit_sequence <= "1001110111011100000000"; --K >-.-
				WHEN "0101010" => bit_sequence <= "1001110101000000000000"; --L >.-..
				WHEN "0110010" => bit_sequence <= "0111011100000000000000"; --M >--
				WHEN "0110110" => bit_sequence <= "0111010000000000000000"; --N >-.
				WHEN "0100110" => bit_sequence <= "0111011101110000000000"; --O >---
				WHEN "0111010" => bit_sequence <= "1001110111010000000000"; --P >.--.
				WHEN "0111110" => bit_sequence <= "0111011101001110000000"; --Q >--.-
				WHEN "0101110" => bit_sequence <= "1001110100000000000000"; --R >.-.
				WHEN "0011010" => bit_sequence <= "1010100000000000000000"; --S >...
				WHEN "0011110" => bit_sequence <= "0111000000000000000000"; --T >-
				WHEN "0100011" => bit_sequence <= "1010011100000000000000"; --U >..-
				WHEN "0101011" => bit_sequence <= "1010100111000000000000"; --V >...-
				WHEN "0011101" => bit_sequence <= "1001110111000000000000"; --W >.--
				WHEN "0110011" => bit_sequence <= "0111010100111000000000"; --X >-..-
				WHEN "0110111" => bit_sequence <= "0111010011101110000000"; --Y >-.--
				WHEN "0100111" => bit_sequence <= "0111011101001000000000"; --Z >--..
				WHEN "1100000" => bit_sequence <= "1001110111011101110000"; --1 >.----
				WHEN "1101000" => bit_sequence <= "1010011101110111000000"; --2 >..---
				WHEN "1110000" => bit_sequence <= "1010100111011100000000"; --3 >...--
				WHEN "1110100" => bit_sequence <= "1010101001110000000000"; --4 >....-
				WHEN "1100100" => bit_sequence <= "1010101010000000000000"; --5 >.....
				WHEN "1111000" => bit_sequence <= "0111010101010000000000"; --6 >-....
				WHEN "1111100" => bit_sequence <= "0111011101010100000000"; --7 >--...
				WHEN "1101100" => bit_sequence <= "0111011101110101000000"; --8 >---..
				WHEN "1011000" => bit_sequence <= "0111011101110111010000"; --9 >----.
				WHEN "1011100" => bit_sequence <= "0111011101110111011100"; --0 >-----
				WHEN OTHERS    => bit_sequence    <= "0000000000000000000000";
			END CASE;
		END IF;
	END PROCESS;
END Behavioral;