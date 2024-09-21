LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.Numeric_STD.ALL;
LIBRARY work;
ENTITY VGA_sync IS
	PORT (
		Letter_number_selector : IN  STD_LOGIC;
		Bgcolor_selector       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		Push_button_3x2        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
		Clk                    : IN  STD_LOGIC;
		Reset                  : IN  STD_LOGIC;
		Hsync                  : OUT STD_LOGIC;
		Vsync                  : OUT STD_LOGIC;
		Red                    : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		Green                  : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		Blue                   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END VGA_sync;
ARCHITECTURE Behavioral OF VGA_sync IS
	SIGNAL clock : STD_LOGIC := '0';
	SIGNAL prev_state_bt1 : STD_LOGIC := '1';
	SIGNAL rgb : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL hcount : INTEGER RANGE 0 TO 1023 := 640;
	SIGNAL vCount : INTEGER RANGE 0 TO 1023 := 480;
	SIGNAL nextHcount : INTEGER RANGE 0 TO 1023 := 641;
	SIGNAL nextVcount : INTEGER RANGE 0 TO 1023 := 481;
BEGIN
	devideClock : PROCESS (clk)
	BEGIN
		IF rising_edge (clk) THEN
			clock <= NOT clock;
		END IF;
	END PROCESS;
	VGA_display : ENTITY work.VGA_display
		PORT MAP(
			letter_number_selector => Letter_number_selector,
			push_button_3x2        => Push_button_3x2,
			bgcolor_selector       => Bgcolor_selector,
			clock                  => clock,
			hcounter               => nextHCount,
			vcounter               => nextVCount,
			pixels                 => rgb
		);
	vgasignal : PROCESS (clock)
		VARIABLE divide_by_2 : STD_LOGIC := '0';
	BEGIN
		IF rising_edge(clock) THEN
			IF divide_by_2 = '1' THEN
				IF (hCount = 799) THEN
					hCount <= 0;
					IF (vCount = 524) THEN
						vCount <= 0;
					ELSE
						vCount <= vCount + 1;
					END IF;
				ELSE
					hCount <= hCount + 1;
				END IF;
				IF (nextHCount = 799) THEN
					nextHCount <= 0;
					IF (nextVCount = 524) THEN
						nextVCount <= 0;
					ELSE
						nextVCount <= vCount + 1;
					END IF;
				ELSE
					nextHCount <= hCount + 1;
				END IF;
				IF (vCount >= 490 AND vCount < 492) THEN
					vsync <= '0';
				ELSE
					vsync <= '1';
				END IF;
				IF (hCount >= 656 AND hCount < 752) THEN
					hsync <= '0';
				ELSE
					hsync <= '1';
				END IF;
				IF (hCount < 640 AND vCount < 480) THEN
					Red <= rgb (7 DOWNTO 5);
					Green <= rgb (4 DOWNTO 2);
					Blue <= rgb (1 DOWNTO 0);
				END IF;
			END IF;
			divide_by_2 := NOT divide_by_2;
		END IF;
	END PROCESS;
END Behavioral;