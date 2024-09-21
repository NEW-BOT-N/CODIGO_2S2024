LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY VGA_top_module IS
	PORT (
		clk                    : IN  STD_LOGIC;
		letter_number_selector : IN  STD_LOGIC;
		push_button_3x2        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
		bgcolor_selector       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
		jack_audio             : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		hsync                  : OUT STD_LOGIC;
		vsync                  : OUT STD_LOGIC;
		red                    : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		green                  : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		blue                   : OUT STD_LOGIC_VECTOR (2 DOWNTO 1)
	);
END VGA_top_module;
ARCHITECTURE Behavioral OF VGA_top_module IS
	COMPONENT CI
		PORT (
			CLKIN_IN  : IN  STD_LOGIC;
			CLKFX_OUT : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT VGA_sync
		PORT (
			Letter_number_selector : IN  STD_LOGIC;
			Push_button_3x2        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
			Bgcolor_selector       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
			Clk                    : IN  STD_LOGIC;
			hsync                  : OUT STD_LOGIC;
			vsync                  : OUT STD_LOGIC;
			Red                    : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			Green                  : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			Blue                   : OUT STD_LOGIC_VECTOR (2 DOWNTO 1)
		);
	END COMPONENT;
	COMPONENT morsegenerator
		PORT (
			clk                    : IN  STD_LOGIC;
			letter_number_selector : IN  STD_LOGIC;
			push_button_3x2        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
			jack_audio             : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL clock : STD_LOGIC := '0';
BEGIN
	Clocking_in : CI
	PORT MAP
	(
		Clk, clock
	);
	VGA_inst : VGA_sync
	PORT MAP
	(
		Letter_number_selector => letter_number_selector,
		Push_button_3x2        => push_button_3x2,
		Bgcolor_selector       => bgcolor_selector,
		Clk                    => clock,
		hsync                  => hsync,
		vsync                  => vsync,
		Red                    => Red,
		Green                  => Green,
		Blue                   => Blue
	);
	morsegenerator_inst : morsegenerator
	PORT MAP
	(
		letter_number_selector => letter_number_selector,
		push_button_3x2        => push_button_3x2,
		clk                    => clock,
		jack_audio             => jack_audio
	);
END Behavioral;