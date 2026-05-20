LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY lights IS
	PORT (

		---------------------------------
		-- Horloge / reset
		---------------------------------

		CLOCK_50 : IN STD_LOGIC;
		KEY      : IN STD_LOGIC_VECTOR(0 DOWNTO 0);

		---------------------------------
		-- Switches / LEDs
		---------------------------------

		SW  : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);

		---------------------------------
		-- SDRAM
		---------------------------------

		DRAM_CLK  : OUT STD_LOGIC;
		DRAM_CKE  : OUT STD_LOGIC;

		DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		DRAM_CS_N  : OUT STD_LOGIC;
		DRAM_CAS_N : OUT STD_LOGIC;
		DRAM_RAS_N : OUT STD_LOGIC;
		DRAM_WE_N  : OUT STD_LOGIC;

		DRAM_DQ  : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

		---------------------------------
		-- Moteurs
		---------------------------------

		MTRR_P : OUT STD_LOGIC;
		MTRR_N : OUT STD_LOGIC;

		MTRL_P : OUT STD_LOGIC;
		MTRL_N : OUT STD_LOGIC;

		MTR_SLEEP_n : OUT STD_LOGIC

	);

END lights;

ARCHITECTURE Structure OF lights IS

	COMPONENT v1
		PORT (

			clk_clk          : IN    STD_LOGIC;
			reset_reset_n    : IN    STD_LOGIC;

			led_export       : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
			sw_export        : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);

			sdram_wire_addr  : OUT   STD_LOGIC_VECTOR(12 DOWNTO 0);
			sdram_wire_ba    : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);

			sdram_wire_cas_n : OUT   STD_LOGIC;
			sdram_wire_cke   : OUT   STD_LOGIC;
			sdram_wire_cs_n  : OUT   STD_LOGIC;

			sdram_wire_dq    : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);

			sdram_wire_dqm   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);

			sdram_wire_ras_n : OUT   STD_LOGIC;
			sdram_wire_we_n  : OUT   STD_LOGIC;

			sdram_clk_clk    : OUT   STD_LOGIC;

			---------------------------------
			-- PWM moteurs
			---------------------------------

			motor_p_r_export : OUT STD_LOGIC;
			motor_n_r_export : OUT STD_LOGIC;

			motor_p_l_export : OUT STD_LOGIC;
			motor_n_l_export : OUT STD_LOGIC

		);

	END COMPONENT;

BEGIN

	---------------------------------
	-- Réveil driver moteur
	---------------------------------

	MTR_SLEEP_n <= '1';

	---------------------------------
	-- Instanciation Qsys
	---------------------------------

	u0 : v1

	PORT MAP (

		---------------------------------
		-- Horloge / reset
		---------------------------------

		clk_clk       => CLOCK_50,
		reset_reset_n => KEY(0),

		---------------------------------
		-- LEDs / switches
		---------------------------------

		led_export => LED,
		sw_export  => SW,

		---------------------------------
		-- SDRAM
		---------------------------------

		sdram_wire_addr  => DRAM_ADDR,
		sdram_wire_ba    => DRAM_BA,

		sdram_wire_cas_n => DRAM_CAS_N,
		sdram_wire_cke   => DRAM_CKE,
		sdram_wire_cs_n  => DRAM_CS_N,

		sdram_wire_dq    => DRAM_DQ,

		sdram_wire_dqm   => DRAM_DQM,

		sdram_wire_ras_n => DRAM_RAS_N,
		sdram_wire_we_n  => DRAM_WE_N,

		sdram_clk_clk    => DRAM_CLK,

		---------------------------------
		-- Moteurs
		---------------------------------

		motor_p_r_export => MTRR_P,
		motor_n_r_export => MTRR_N,

		motor_p_l_export => MTRL_P,
		motor_n_l_export => MTRL_N

	);

END Structure;