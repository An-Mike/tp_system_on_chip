LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY lights IS
	PORT (
		SW : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		CLOCK_50 : IN STD_LOGIC;
		LED : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		DRAM_CLK, DRAM_CKE : OUT STD_LOGIC;
		DRAM_ADDR : OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
		DRAM_BA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		DRAM_CS_N, DRAM_CAS_N, DRAM_RAS_N, DRAM_WE_N : OUT STD_LOGIC;
		DRAM_DQ : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DRAM_DQM : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) );
	END lights;
	
ARCHITECTURE Structure OF lights IS
	COMPONENT v1
		PORT (
			clk_clk          : in    std_logic                     := 'X';             -- clk
            reset_reset_n    : in    std_logic                     := 'X';             -- reset_n
            led_export       : out   std_logic_vector(7 downto 0);                     -- export
            sw_export        : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
            sdram_wire_addr  : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_wire_ba    : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_wire_cas_n : out   std_logic;                                        -- cas_n
            sdram_wire_cke   : out   std_logic;                                        -- cke
            sdram_wire_cs_n  : out   std_logic;                                        -- cs_n
            sdram_wire_dq    : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
            sdram_wire_dqm   : out   std_logic_vector(1 downto 0);                     -- dqm
            sdram_wire_ras_n : out   std_logic;                                        -- ras_n
            sdram_wire_we_n  : out   std_logic;
				sdram_clk_clk    : out   std_logic 
			);                                         -- we_n
	END COMPONENT;

	BEGIN
		NiosII: v1
		PORT MAP (
			clk_clk          => CLOCK_50,          --        clk.clk
            reset_reset_n    => KEY(0),    --      reset.reset_n
            led_export       => LED,       --        led.export
            sw_export        => SW,        --         sw.export
            sdram_wire_addr  => DRAM_ADDR,  -- sdram_wire.addr
            sdram_wire_ba    => DRAM_BA,    --           .ba
            sdram_wire_cas_n => DRAM_CAS_N, --           .cas_n
            sdram_wire_cke   => DRAM_CKE,   --           .cke
            sdram_wire_cs_n  => DRAM_CS_N,  --           .cs_n
            sdram_wire_dq    => DRAM_DQ,    --           .dq
            sdram_wire_dqm   => DRAM_DQM,   --           .dqm
            sdram_wire_ras_n => DRAM_RAS_N, --           .ras_n
            sdram_wire_we_n  => DRAM_WE_N,
				sdram_clk_clk    => DRAM_CLK
		);
	END Structure;
