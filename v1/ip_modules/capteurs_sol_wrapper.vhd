library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ===========================================================
--  Avalon-MM wrapper pour capteurs_sol_seuil (LTC2308)
--  Bus : 32 bits, pas d'IRQ (polling)
--
--  PLL interne : 50MHz → 40MHz (clk) + 2KHz (data_capture)
--
--  Carte mémoire (adresse sur 4 bits) :
--    0x0  NIVEAU    (écriture) : seuil de détection (8 bits)
--    0x1  STATUS    (lecture)  : bit0 = data_ready
--    0x2  VECT_CAPT (lecture)  : vecteur seuillé 7 bits (1 bit/capteur)
--    0x3  DATA0     (lecture)  : valeur brute capteur 0 (8 bits)
--    0x4  DATA1     (lecture)  : valeur brute capteur 1
--    0x5  DATA2     (lecture)  : valeur brute capteur 2
--    0x6  DATA3     (lecture)  : valeur brute capteur 3
--    0x7  DATA4     (lecture)  : valeur brute capteur 4
--    0x8  DATA5     (lecture)  : valeur brute capteur 5
--    0x9  DATA6     (lecture)  : valeur brute capteur 6
-- ===========================================================

entity capteurs_sol_wrapper is
    port (
        -- -----------------------------------------------
        -- Horloge 50MHz et reset (fournis par Qsys)
        -- -----------------------------------------------
        clk     : in std_logic;
        reset_n : in std_logic;

        -- -----------------------------------------------
        -- Interface Avalon-MM Slave (côté Nios II)
        -- -----------------------------------------------
        avs_address   : in  std_logic_vector(3 downto 0);
        avs_read      : in  std_logic;
        avs_write     : in  std_logic;
        avs_writedata : in  std_logic_vector(31 downto 0);
        avs_readdata  : out std_logic_vector(31 downto 0);

        -- -----------------------------------------------
        -- Signaux SPI vers le LTC2308 (pins physiques)
        -- -----------------------------------------------
        ADC_CONVST : out std_logic;
        ADC_SCK    : out std_logic;
        ADC_SDI    : out std_logic;
        ADC_SDO    : in  std_logic
    );
end entity capteurs_sol_wrapper;


architecture RTL of capteurs_sol_wrapper is

    -- -------------------------------------------------------
    -- PLL : 50MHz → 40MHz (c0) + 2KHz (c1)
    -- -------------------------------------------------------
    component pll_2freqs is
        port (
            areset : in  std_logic;
            inclk0 : in  std_logic;
            c0     : out std_logic;
            c1     : out std_logic
        );
    end component;

    -- -------------------------------------------------------
    -- Composant capteurs_sol_seuil (fichier du prof)
    -- -------------------------------------------------------
    component capteurs_sol_seuil is
        port (
            clk          : in  std_logic;
            reset_n      : in  std_logic;
            data_capture : in  std_logic;
            data_readyr  : out std_logic;
            data0r       : out std_logic_vector(7 downto 0);
            data1r       : out std_logic_vector(7 downto 0);
            data2r       : out std_logic_vector(7 downto 0);
            data3r       : out std_logic_vector(7 downto 0);
            data4r       : out std_logic_vector(7 downto 0);
            data5r       : out std_logic_vector(7 downto 0);
            data6r       : out std_logic_vector(7 downto 0);
            NIVEAU       : in  std_logic_vector(7 downto 0);
            vect_capt    : out std_logic_vector(6 downto 0);
            ADC_CONVSTr  : out std_logic;
            ADC_SCK      : out std_logic;
            ADC_SDIr     : out std_logic;
            ADC_SDO      : in  std_logic
        );
    end component;

    -- -------------------------------------------------------
    -- Signaux internes
    -- -------------------------------------------------------
    signal clk_40M    : std_logic;
    signal clk_2k     : std_logic;
    signal pll_areset : std_logic;

    signal data_ready : std_logic;
    signal vect_capt  : std_logic_vector(6 downto 0);
    signal data0      : std_logic_vector(7 downto 0);
    signal data1      : std_logic_vector(7 downto 0);
    signal data2      : std_logic_vector(7 downto 0);
    signal data3      : std_logic_vector(7 downto 0);
    signal data4      : std_logic_vector(7 downto 0);
    signal data5      : std_logic_vector(7 downto 0);
    signal data6      : std_logic_vector(7 downto 0);

    -- Registre NIVEAU (écrit par le Nios, défaut 0x69)
    signal reg_niveau : std_logic_vector(7 downto 0) := x"69";

begin

    pll_areset <= not reset_n;

    -- -------------------------------------------------------
    -- Instanciation PLL
    -- -------------------------------------------------------
    u_pll : pll_2freqs
        port map (
            areset => pll_areset,
            inclk0 => clk,
            c0     => clk_40M,
            c1     => clk_2k
        );

    -- -------------------------------------------------------
    -- Instanciation capteurs_sol_seuil
    -- -------------------------------------------------------
    u_capteurs : capteurs_sol_seuil
        port map (
            clk          => clk_40M,
            reset_n      => reset_n,
            data_capture => clk_2k,
            data_readyr  => data_ready,
            data0r       => data0,
            data1r       => data1,
            data2r       => data2,
            data3r       => data3,
            data4r       => data4,
            data5r       => data5,
            data6r       => data6,
            NIVEAU       => reg_niveau,
            vect_capt    => vect_capt,
            ADC_CONVSTr  => ADC_CONVST,
            ADC_SCK      => ADC_SCK,
            ADC_SDIr     => ADC_SDI,
            ADC_SDO      => ADC_SDO
        );

    -- -------------------------------------------------------
    -- Écriture Avalon : Nios écrit le seuil NIVEAU (0x0)
    -- -------------------------------------------------------
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_niveau <= x"69";   -- seuil par défaut
        elsif rising_edge(clk) then
            if avs_write = '1' and avs_address = "0000" then
                reg_niveau <= avs_writedata(7 downto 0);
            end if;
        end if;
    end process;

    -- -------------------------------------------------------
    -- Lecture Avalon (combinatoire, sans latence)
    -- -------------------------------------------------------
    process(avs_address, data_ready, vect_capt,
            data0, data1, data2, data3, data4, data5, data6,
            reg_niveau)
    begin
        case avs_address is
            when "0000" =>   -- NIVEAU (relecture)
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= reg_niveau;
            when "0001" =>   -- STATUS
                avs_readdata <= (0 => data_ready, others => '0');
            when "0010" =>   -- VECT_CAPT (7 bits seuillés)
                avs_readdata <= (others => '0');
                avs_readdata(6 downto 0) <= vect_capt;
            when "0011" =>   -- DATA0
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data0;
            when "0100" =>   -- DATA1
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data1;
            when "0101" =>   -- DATA2
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data2;
            when "0110" =>   -- DATA3
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data3;
            when "0111" =>   -- DATA4
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data4;
            when "1000" =>   -- DATA5
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data5;
            when "1001" =>   -- DATA6
                avs_readdata <= (others => '0');
                avs_readdata(7 downto 0) <= data6;
            when others =>
                avs_readdata <= (others => '0');
        end case;
    end process;

end architecture RTL;