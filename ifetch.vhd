----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2026 16:31:22
-- Design Name: 
-- Module Name: ifetch - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ifetch is
Port (
clk: in std_logic;
en: in std_logic;
rst: in std_logic;
jump: in std_logic;
pcsrc: in std_logic;
instruction: out std_logic_vector(31 downto 0);
pc4: out std_logic_vector(31 downto 0);
jumpAddress: in std_logic_vector(31 downto 0);
branchAddress: in std_logic_vector(31 downto 0) );
end entity ifetch;

architecture Behavioral of ifetch is

signal pc, q: std_logic_vector(31 downto 0):=(others=>'0');


type mat is array(63 downto 0) of std_logic_vector(31 downto 0);
signal mem: mat:=(
    0=>B"001010_00000_00001_0000000000000000", --x"28010000" | LW $1, 0($0)       | incarc in registrul 1 dimensiunea sirului de numere din memorie
    1=>B"000000_00010_00010_00010_00000_000111", --x"00421007" | XOR $2, $2, $2   | ma asigur ca registrul 2 este zero, acesta avand rol de index/pointer in parcurgerea sirului
    2=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0   | NOP
    3=>B"001001_00001_00001_1111111111111111", --x"2421FFFF" | ADDI $1, $1, -1    | decrementez valoarea din registrul 1 deoarece voi efectua o comparatie ulterioara si am nevoie de valoarea N-1
    4=>B"001010_00010_00101_0000000000000100", --x"28450004" | LW $5, 4($2)       | salvez in registrul 5 valoarea primului element din sir (adresa 4), aceasta fiind necesara ulterior pentru modificarea ultimului element
    5=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0   | NOP
    6=>B"001100_00001_00000_0000000000001101", --x"3020000D" | BEQ $1, $0, 13     | verific daca valoarea din registrul 1 a ajuns la 0; in caz afirmativ sar peste bucla de modificare
    7=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0   | NOP
    8=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0   | NOP
    9=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0   | NOP
    10=>B"001010_00010_00011_0000000000000100", --x"28430004" | LW $3, 4($2)      | salvez in registrul 3 valoarea elementului curent din sir
    11=>B"001010_00010_00100_0000000000001000", --x"28440008" | LW $4, 8($2)      | salvez in registrul 4 valoarea elementului urmator din sir
    12=>B"001001_00001_00001_1111111111111111", --x"2421FFFF" | ADDI $1, $1, -1   | decrementez contorul din registrul 1
    13=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    14=>B"000000_00011_00100_00011_00000_000001", --x"00641801" | ADD $3, $3, $4  | adun elementul curent cu cel urmator si salvez rezultatul in registrul 3 (xn = xn + xn+1)
    15=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    16=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    17=>B"001011_00010_00011_0000000000000100", --x"2C430004" | SW $3, 4($2)      | salvez valoarea modificata a elementului curent in memorie
    18=>B"001001_00010_00010_0000000000000100", --x"24420004" | ADDI $2, $2, 4    | avansez pointerul la urmatorul element din sir
    19=>B"001110_00001_00000_1111111111110110", --x"3820FFF6" | BGTZ $1, -10      | daca registrul 1 este inca pozitiv, reiau bucla de modificare de la instructiunea 10
    20=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    21=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    22=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    23=>B"001010_00010_00011_0000000000000100", --x"28430004" | LW $3, 4($2)      | salvez in registrul 3 valoarea ultimului element din sir, acesta urmand sa fie modificat cu primul element initial
    24=>B"001010_00000_00001_0000000000000000", --x"28010000" | LW $1, 0($0)      | reincarc in registrul 1 dimensiunea sirului
    25=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    26=>B"000000_00011_00101_00011_00000_000001", --x"00651801" | ADD $3, $3, $5  | adun valoarea ultimului element cu valoarea primului element initial (salvata in registrul 5) (xn-1 = xn-1 + x0)
    27=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    28=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    29=>B"001011_00010_00011_0000000000000100", --x"2C430004" | SW $3, 4($2)      | salvez valoarea modificata a ultimului element in memorie
    30=>B"000000_00000_00000_00010_00000_001000", --x"00001008" | SLLV $2, $0, $0 | resetez registrul 2 la zero, pregatindu-ma pentru bucla de citire
    31=>B"001100_00001_00000_0000000000001000", --x"30200008" | BEQ $1, $0, 8     | verific daca dimensiunea sirului este 0; in caz afirmativ sar peste bucla de citire
    32=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    33=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    34=>B"000000_00000_00000_00000_00000_000111", --x"00000007" | XOR $0, $0, $0  | NOP
    35=>B"001001_00001_00001_1111111111111111", --x"2421FFFF" | ADDI $1, $1, -1   | decrementez contorul din registrul 1
    36=>B"001010_00010_00011_0000000000000100", --x"28430004" | LW $3, 4($2)      | salvez in registrul 3 valoarea elementului curent din sir pentru citire
    37=>B"001001_00010_00010_0000000000000100", --x"24420004" | ADDI $2, $2, 4    | avansez pointerul la urmatorul element din sir
    38=>B"001101_00001_00000_1111111111111101", --x"3420FFFD" | BGEZ $1, -3       | daca registrul 1 este pozitiv sau zero, reiau bucla de citire de la instructiunea 37
    others=>x"00000007");--noopuri
                  

begin

process(clk,rst)
begin
      if rst='1' then
         q<=x"00000000";
      elsif rising_edge(clk) then 
         if en='1' then
         q<=pc;
         end if;
      end if;
end process;

process(jump, pcsrc, jumpAddress, branchAddress, q)
begin
      if jump='1' then
         pc<=jumpAddress;
      else
         if pcsrc='1' then
             pc<=branchAddress;
         else
            pc<=q+4;
         end if;
      end if;


end process;

pc4<=q+4;
instruction<=mem(conv_integer(q(7 downto 2)));


end Behavioral;
