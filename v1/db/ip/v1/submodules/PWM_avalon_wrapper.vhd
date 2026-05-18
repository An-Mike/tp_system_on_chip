library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_avalon_wrapper is
port(
    clk         : in  std_logic;
    reset_n     : in  std_logic;

    -------------------------------------------------
    -- Avalon-MM Slave
    -------------------------------------------------

    address     : in  std_logic_vector(1 downto 0);
    write       : in  std_logic;
    read        : in  std_logic;
    writedata   : in  std_logic_vector(31 downto 0);
    readdata    : out std_logic_vector(31 downto 0);
    chipselect  : in  std_logic;

    -------------------------------------------------
    -- sorties moteurs
    -------------------------------------------------

    dc_motor_p_R : out std_logic;
    dc_motor_n_R : out std_logic;
    dc_motor_p_L : out std_logic;
    dc_motor_n_L : out std_logic
);

end entity;

architecture rtl of PWM_avalon_wrapper is

    signal regR : std_logic_vector(13 downto 0) := (others=>'0');
    signal regL : std_logic_vector(13 downto 0) := (others=>'0');

begin

-------------------------------------------------
-- Gestion écriture Avalon
-------------------------------------------------

process(clk, reset_n)

begin

    if reset_n='0' then

        regR <= (others=>'0');
        regL <= (others=>'0');

    elsif rising_edge(clk) then

        if chipselect='1' and write='1' then

            case address is

                when "00" =>
                    regR <= writedata(13 downto 0);

                when "01" =>
                    regL <= writedata(13 downto 0);

                when others =>
                    null;

            end case;

        end if;

    end if;

end process;

-------------------------------------------------
-- Lecture Avalon
-------------------------------------------------

process(address, regR, regL)

begin

    case address is

        when "00" =>
            readdata <= (31 downto 14 => '0') & regR;

        when "01" =>
            readdata <= (31 downto 14 => '0') & regL;

        when others =>
            readdata <= (others=>'0');

    end case;

end process;

-------------------------------------------------
-- Instanciation du composant 
-------------------------------------------------

u_pwm : entity work.PWM_generation

port map(

    clk => clk,
    reset_n => reset_n,

    s_writedataR => regR,
    s_writedataL => regL,

    dc_motor_p_R => dc_motor_p_R,
    dc_motor_n_R => dc_motor_n_R,
    dc_motor_p_L => dc_motor_p_L,
    dc_motor_n_L => dc_motor_n_L

);

end architecture;