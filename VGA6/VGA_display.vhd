LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY VGA_display IS
	PORT 
	(
		letter_number_selector : IN STD_LOGIC;
		push_button_3x2        : IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		bgcolor_selector       : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		clock    : IN std_logic;
		hcounter : IN INTEGER RANGE 0 TO 1023;
		vcounter : IN INTEGER RANGE 0 TO 1023;
		pixels   : OUT std_logic_vector(7 DOWNTO 0)
	);
END VGA_display;

ARCHITECTURE Behavioral OF VGA_display IS
	SIGNAL prev_state_3x2_push    : STD_LOGIC_VECTOR (5 DOWNTO 0) := "111111";
	SIGNAL braille_pattern_set    : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000000";
	SIGNAL debounce_delay_counter : INTEGER RANGE 0 TO 6000000;
	SIGNAL prev_state_bt1     : STD_LOGIC := '1';
	SIGNAL background_color : std_logic_vector(7 DOWNTO 0) := "01001101";--11000101 rojizocrosa 10100001 rojizo1 10101010 rosado 01001101 verde 01001001 gris
	CONSTANT letter_color     : std_logic_vector(7 DOWNTO 0) := "11111111";
	CONSTANT dot_color        : std_logic_vector(7 DOWNTO 0) := "11111111";
	TYPE matrix_20x20_type IS ARRAY (0 TO 19) OF std_logic_vector(0 TO 19);
	SIGNAL braille_matrix : matrix_20x20_type := (
		0 =>x"00000",
		1 =>x"00000",
		2 =>x"00000",
		3 =>x"030C0",
		4 =>x"030C0",
		5 =>x"00000",
		6 =>x"00000",
		7 =>x"00000",
		8 =>x"00000",
		9 =>x"030C0",
		10 =>x"030C0",
		11 =>x"00000",
		12 =>x"00000",
		13 =>x"00000",
		14 =>x"00000",
		15 =>x"030C0",
		16 =>x"030C0",
		17 =>x"00000",
		18 =>x"00000",
		19 =>x"00000"
	);
	TYPE matrix_10x12_type IS ARRAY (0 TO 9) OF std_logic_vector(0 TO 11);
	SIGNAL letter_matrix : matrix_10x12_type := (
		0 => x"000", 
		1 => x"000", 
		2 => x"000", 
		3 => x"000", 
		4 => x"000", 
		5 => x"000", 
		6 => x"000", 
		7 => x"000", 
		8 => x"000", 
		9 => x"000"
	);
		CONSTANT letter_Null : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"000",
		2 =>x"000",
		3 =>x"000",
		4 =>x"000",
		5 =>x"000",
		6 =>x"000",
		7 =>x"000",
		8 =>x"000",
		9 =>x"000"
		);
	CONSTANT letter_A : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"738",
		3 =>x"618",
		4 =>x"618",
		5 =>x"7F8",
		6 =>x"618",
		7 =>x"618",
		8 =>x"618",
		9 =>x"000"
		);
	CONSTANT letter_B : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"7F0",
		5 =>x"7F0",
		6 =>x"618",
		7 =>x"618",
		8 =>x"7F0",
		9 =>x"000"
	);
	CONSTANT letter_C : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"600",
		4 =>x"600",
		5 =>x"600",
		6 =>x"600",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT letter_D : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7E0",
		2 =>x"630",
		3 =>x"618",
		4 =>x"618",
		5 =>x"618",
		6 =>x"618",
		7 =>x"630",
		8 =>x"7E0",
		9 =>x"000"
	);
	CONSTANT letter_E : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F0",
		2 =>x"600",
		3 =>x"600",
		4 =>x"7E0",
		5 =>x"7E0",
		6 =>x"600",
		7 =>x"600",
		8 =>x"7F0",
		9 =>x"000"	
	);
	CONSTANT letter_F : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F0",
		2 =>x"600",
		3 =>x"600",
		4 =>x"7E0",
		5 =>x"7E0",
		6 =>x"600",
		7 =>x"600",
		8 =>x"600",
		9 =>x"000"
	);
	CONSTANT letter_G : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F8",
		2 =>x"600",
		3 =>x"600",
		4 =>x"678",
		5 =>x"678",
		6 =>x"618",
		7 =>x"618",
		8 =>x"3F8",
		9 =>x"000"
	);
	CONSTANT letter_H : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"618",
		3 =>x"618",
		4 =>x"7F8",
		5 =>x"7F8",
		6 =>x"618",
		7 =>x"618",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_I : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F8",
		2 =>x"7F8",
		3 =>x"0C0",
		4 =>x"0C0",
		5 =>x"0C0",
		6 =>x"0C0",
		7 =>x"7F8",
		8 =>x"7F8",
		9 =>x"000"
	);
	CONSTANT letter_J : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"1F8",
		2 =>x"1F8",
		3 =>x"018",
		4 =>x"018",
		5 =>x"018",
		6 =>x"618",
		7 =>x"7F8",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT letter_K : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"630",
		2 =>x"660",
		3 =>x"6C0",
		4 =>x"780",
		5 =>x"780",
		6 =>x"6C0",
		7 =>x"660",
		8 =>x"630",
		9 =>x"000"
	);
	CONSTANT letter_L : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"600",
		2 =>x"600",
		3 =>x"600",
		4 =>x"600",
		5 =>x"600",
		6 =>x"600",
		7 =>x"7F0",
		8 =>x"7F0",
		9 =>x"000"
	);
	CONSTANT letter_M : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"738",
		3 =>x"7F8",
		4 =>x"6D8",
		5 =>x"618",
		6 =>x"618",
		7 =>x"618",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_N : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"718",
		3 =>x"798",
		4 =>x"6D8",
		5 =>x"678",
		6 =>x"638",
		7 =>x"618",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_O : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"618",
		6 =>x"618",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT letter_P : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"7F0",
		6 =>x"600",
		7 =>x"600",
		8 =>x"600",
		9 =>x"000"
	);
	CONSTANT letter_Q : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"618",
		6 =>x"678",
		7 =>x"610",
		8 =>x"3E8",
		9 =>x"000"
	);
	CONSTANT letter_R : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"7F0",
		6 =>x"660",
		7 =>x"630",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_S : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"600",
		4 =>x"3F0",
		5 =>x"018",
		6 =>x"018",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT letter_T : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F8",
		2 =>x"7F8",
		3 =>x"0C0",
		4 =>x"0C0",
		5 =>x"0C0",
		6 =>x"0C0",
		7 =>x"0C0",
		8 =>x"0C0",
		9 =>x"000"
	);
	CONSTANT letter_U : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"618",
		6 =>x"618",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT letter_V : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"618",
		6 =>x"330",
		7 =>x"1E0",
		8 =>x"0C0",
		9 =>x"000"
	);
	CONSTANT letter_W : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"6D8",
		6 =>x"7F8",
		7 =>x"738",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_X : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"738",
		3 =>x"330",
		4 =>x"0C0",
		5 =>x"0C0",
		6 =>x"330",
		7 =>x"738",
		8 =>x"618",
		9 =>x"000"
	);
	CONSTANT letter_Y : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"618",
		2 =>x"618",
		3 =>x"330",
		4 =>x"1E0",
		5 =>x"0C0",
		6 =>x"0C0",
		7 =>x"0C0",
		8 =>x"0C0",
		9 =>x"000"
	);
	CONSTANT letter_Z : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F8",
		2 =>x"038",
		3 =>x"070",
		4 =>x"0E0",
		5 =>x"1C0",
		6 =>x"380",
		7 =>x"700",
		8 =>x"7F8",
		9 =>x"000"
	);
	CONSTANT number_1 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"0C0",
		2 =>x"1C0",
		3 =>x"3C0",
		4 =>x"0C0",
		5 =>x"0C0",
		6 =>x"0C0",
		7 =>x"0C0",
		8 =>x"0C0",
		9 =>x"000"
	);
	CONSTANT number_2 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"018",
		4 =>x"070",
		5 =>x"1C0",
		6 =>x"300",
		7 =>x"600",
		8 =>x"7F8",
		9 =>x"000"
	);
	CONSTANT number_3 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"018",
		4 =>x"070",
		5 =>x"070",
		6 =>x"018",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	CONSTANT number_4 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"0E0",
		2 =>x"1E0",
		3 =>x"360",
		4 =>x"660",
		5 =>x"7F8",
		6 =>x"060",
		7 =>x"060",
		8 =>x"060",
		9 =>x"000"
	);
	CONSTANT number_5 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F8",
		2 =>x"600",
		3 =>x"600",
		4 =>x"7E0",
		5 =>x"010",
		6 =>x"018",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	
	CONSTANT number_6 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"600",
		4 =>x"7F0",
		5 =>x"7F8",
		6 =>x"618",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	
	CONSTANT number_7 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"7F8",
		2 =>x"618",
		3 =>x"030",
		4 =>x"060",
		5 =>x"0C0",
		6 =>x"180",
		7 =>x"300",
		8 =>x"600",
		9 =>x"000"
	);
	
	CONSTANT number_8 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"3F0",
		5 =>x"3F0",
		6 =>x"618",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	
	CONSTANT number_9 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"618",
		4 =>x"618",
		5 =>x"3F0",
		6 =>x"018",
		7 =>x"418",
		8 =>x"3F0",
		9 =>x"000"
	);
	
	CONSTANT number_0 : matrix_10x12_type := (
		0 =>x"000",
		1 =>x"3F0",
		2 =>x"618",
		3 =>x"638",
		4 =>x"658",
		5 =>x"698",
		6 =>x"718",
		7 =>x"618",
		8 =>x"3F0",
		9 =>x"000"
	);
	
	
	
	SIGNAL braille_row_index : INTEGER RANGE 0 TO 255;
	SIGNAL braille_col_index : INTEGER RANGE 0 TO 255;
	SIGNAL letter_row_index : INTEGER RANGE 0 TO 255;
	SIGNAL letter_col_index : INTEGER RANGE 0 TO 255;
BEGIN
PROCESS (clock)
BEGIN
IF rising_edge (clock) THEN	
		debounce_delay_counter <= debounce_delay_counter + 1;
			IF debounce_delay_counter = 60000 THEN
				debounce_delay_counter <= 0;
				FOR i IN 0 TO 5 LOOP
					IF (push_button_3x2(i) = '0' AND prev_state_3x2_push(i) = '1') THEN
						braille_pattern_set(i) <= NOT braille_pattern_set(i);
						CASE i IS
						WHEN 0 => braille_matrix(15)(12) <= NOT braille_matrix(15)(12);
									 braille_matrix(15)(13) <= NOT braille_matrix(15)(13);
									 braille_matrix(16)(12) <= NOT braille_matrix(16)(12);
									 braille_matrix(16)(13) <= NOT braille_matrix(16)(13);
						WHEN 1 => braille_matrix(15)(6) <= NOT braille_matrix(15)(6);
									 braille_matrix(15)(7) <= NOT braille_matrix(15)(7);
									 braille_matrix(16)(6) <= NOT braille_matrix(16)(6);
									 braille_matrix(16)(7) <= NOT braille_matrix(16)(7);
									 
						WHEN 2 => braille_matrix(9)(12) <= NOT braille_matrix(9)(12);
									 braille_matrix(9)(13) <= NOT braille_matrix(9)(13);
									 braille_matrix(10)(12) <= NOT braille_matrix(10)(12);
									 braille_matrix(10)(13) <= NOT braille_matrix(10)(13);
						WHEN 3 => braille_matrix(9)(6) <= NOT braille_matrix(9)(6);
									 braille_matrix(9)(7) <= NOT braille_matrix(9)(7);
									 braille_matrix(10)(6) <= NOT braille_matrix(10)(6);
									 braille_matrix(10)(7) <= NOT braille_matrix(10)(7);
									 
						WHEN 4 => braille_matrix(3)(12) <= NOT braille_matrix(3)(12);
									 braille_matrix(3)(13) <= NOT braille_matrix(3)(13);
									 braille_matrix(4)(12) <= NOT braille_matrix(4)(12);
									 braille_matrix(4)(13) <= NOT braille_matrix(4)(13);
						WHEN 5 => braille_matrix(3)(6) <= NOT braille_matrix(3)(6);
									 braille_matrix(3)(7) <= NOT braille_matrix(3)(7);
									 braille_matrix(4)(6) <= NOT braille_matrix(4)(6);
									 braille_matrix(4)(7) <= NOT braille_matrix(4)(7);
						WHEN OTHERS => NULL;
						END CASE;
						
					END IF;
					prev_state_3x2_push(i) <= push_button_3x2(i);
				END LOOP; 
			END IF;
			
	braille_pattern_set(6) <= NOT letter_number_selector;
	
			CASE braille_pattern_set IS
				WHEN "0100000" => letter_matrix <= letter_A; --A >.-
				WHEN "0101000" => letter_matrix <= letter_B; --B >-...
				WHEN "0110000" => letter_matrix <= letter_C; --C >-.-.
				WHEN "0110100" => letter_matrix <= letter_D; --D >-..
				WHEN "0100100" => letter_matrix <= letter_E; --E >.
				WHEN "0111000" => letter_matrix <= letter_F; --F >..-.
				WHEN "0111100" => letter_matrix <= letter_G; --G >--.
				WHEN "0101100" => letter_matrix <= letter_H; --H >....
				WHEN "0011000" => letter_matrix <= letter_I; --I >..
				WHEN "0011100" => letter_matrix <= letter_J; --J >.---
				WHEN "0100010" => letter_matrix <= letter_K; --K >-.-
				WHEN "0101010" => letter_matrix <= letter_L; --L >.-..
				WHEN "0110010" => letter_matrix <= letter_M; --M >--
				WHEN "0110110" => letter_matrix <= letter_N; --N >-.
				WHEN "0100110" => letter_matrix <= letter_O; --O >---
				WHEN "0111010" => letter_matrix <= letter_P; --P >.--.
				WHEN "0111110" => letter_matrix <= letter_Q; --Q >--.-
				WHEN "0101110" => letter_matrix <= letter_R; --R >.-.
				WHEN "0011010" => letter_matrix <= letter_S; --S >...
				WHEN "0011110" => letter_matrix <= letter_T; --T >-
				WHEN "0100011" => letter_matrix <= letter_U; --U >..-
				WHEN "0101011" => letter_matrix <= letter_V; --V >...-
				WHEN "0011101" => letter_matrix <= letter_W; --W >.--
				WHEN "0110011" => letter_matrix <= letter_X; --X >-..-
				WHEN "0110111" => letter_matrix <= letter_Y; --Y >-.--
				WHEN "0100111" => letter_matrix <= letter_Z; --Z >--..
				WHEN "1100000" => letter_matrix <= number_1; --1 >.----
				WHEN "1101000" => letter_matrix <= number_2; --2 >..---
				WHEN "1110000" => letter_matrix <= number_3; --3 >...--
				WHEN "1110100" => letter_matrix <= number_4; --4 >....-
				WHEN "1100100" => letter_matrix <= number_5; --5 >.....
				WHEN "1111000" => letter_matrix <= number_6; --6 >-....
				WHEN "1111100" => letter_matrix <= number_7; --7 >--...
				WHEN "1101100" => letter_matrix <= number_8; --8 >---..
				WHEN "1011000" => letter_matrix <= number_9; --9 >----.
				WHEN "1011100" => letter_matrix <= number_0; --0 >-----
				WHEN OTHERS => letter_matrix <= letter_Null;
			END CASE;
			END IF;
END PROCESS;

	video_output : PROCESS (clock)
	BEGIN
		IF rising_edge (clock) THEN	
			CASE bgcolor_selector IS
			WHEN "00" => background_color <= "01001101";
			WHEN "01" => background_color <= "11000101";
			WHEN "10" => background_color <= "10100001";
			WHEN "11" => background_color <= "10101010";
			WHEN OTHERS => NULL;
			END CASE;
			
			letter_row_index <= (vcounter - 80)/32; 
			letter_col_index <= hcounter/32 - 10; 
			braille_row_index <= vcounter/16 - 5;
			braille_col_index <= hcounter/16;
			
			IF (hcounter >= 0) AND (hcounter < 639) AND (vcounter >= 0) AND (vcounter < 80)
			 THEN
						pixels <= background_color;


					
			 ELSIF (hcounter >= 0) AND (hcounter < 320) AND (vcounter >= 80) AND (vcounter < 399)
				 THEN
				 IF (braille_matrix(braille_row_index)(braille_col_index) = '1') THEN
						pixels <= dot_color;
					ELSE
						pixels <= background_color;
					END IF;
				ELSIF (hcounter >= 320) AND (hcounter < 639) AND (vcounter >= 80) AND (vcounter < 399)
					THEN
					IF (letter_matrix(letter_row_index)(letter_col_index) = '1') THEN
						pixels <= letter_color;
					ELSE
						pixels <= background_color;
					END IF;
				ELSIF (hcounter >= 0) AND (hcounter < 639) AND (vcounter >= 320) AND (vcounter < 479)
					THEN
					pixels <= background_color;
				ELSE
					pixels <= "00000000";
				END IF;

			END IF;
		END PROCESS;
END Behavioral;