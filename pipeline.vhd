----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.04.2026 17:09:20
-- Design Name: 
-- Module Name: test_env - Behavioral
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

entity pipeline is
Port (
btn: in std_logic_vector(4 downto 0);
clk: in std_logic;
sw: in std_logic_vector(15 downto 0);
led: out std_logic_vector(15 downto 0);
cat: out std_logic_vector(6 downto 0);
an: out std_logic_vector(7 downto 0) );
end pipeline;

architecture Behavioral of pipeline is
signal JumpAddress, RD1,RD2,Ext_Imm: std_logic_vector(31 downto 0):=(others=>'0');

signal instruction, pc4,rez,alurez, MemData, outpt: std_logic_vector(31 downto 0):=(others=>'0');
signal ALUResMem,alurez2,BranchAddress,instruction_if_id, pcp4_if_id, RD1_id_ex, RD2_id_ex, ExtImm_id_ex, pcp4_id_ex, BrAddr_ex_mem, ALURes_ex_mem, RD2_ex_mem, ALURes_mem_wb,MemData_mem_wb: std_logic_vector(31 downto 0):=(others=>'0');
signal RegDst2,gtz, getz,zro,en,ExtOp,PCSrc,Br_gtz, ALUSrc,Bgtz_id_ex, Bgetz_id_ex,Bgtz_ex_mem, Bgetz_ex_mem,Branch,Jump,MemWrite,MemToReg,RegWrite,RegDst,Br_getz, RegDst_id_ex, ALUSrc_id_ex, Branch_id_ex, MemWr_id_ex, Mem2R_id_ex,Mem2R_ex_mem, RegWr_id_ex, Branch_ex_mem, MemWr_ex_mem, Mem3R_ex_mem,RegWr_ex_mem,Zero_ex_mem,GTZ_ex_mem,GETZ_ex_mem, Mem2R_mem_wb, RegWr_mem_wb:std_logic:='0';
signal ALUOp,ALUOp_id_ex: std_logic_vector(1 downto 0):=(others=>'0');
signal func,func_id_ex: std_logic_vector(5 downto 0):=(others=>'0');
signal rt,rd,sa,sa_id_ex, rtmem,rdmem,rwa,rd_id_ex, rt_id_ex, WA_ex_mem, WA_mem_wb: std_logic_vector(4 downto 0):=(others=>'0');

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component MPG;

component ifetch is
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
end component ifetch;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component SSD;

component id is
Port (
clk: in std_logic;
en: in std_logic;
RegWrite: in std_logic;
Instr: in std_logic_vector(25 downto 0);
WA: in std_logic_vector(4 downto 0);
WD: in std_logic_vector(31 downto 0);
ExtOp: in std_logic;
RD1: out std_logic_vector(31 downto 0);
RD2: out std_logic_vector(31 downto 0);
ExtImm: out std_logic_vector(31 downto 0);
func: out std_logic_vector(5 downto 0);
sa: out std_logic_vector(4 downto 0);
rt: out std_logic_vector(4 downto 0);
rd: out std_logic_vector(4 downto 0)
 );
end component id;

component uc is
Port (
Instr: in std_logic_vector(5 downto 0);
Br_gtz: out std_logic;
ALUSrc: out std_logic;
Branch: out std_logic;
Jump: out std_logic;
ALUOp: out std_logic_vector(1 downto 0);
MemWrite: out std_logic;
MemToReg: out std_logic;
RegWrite: out std_logic;
ExtOp: out std_logic;
RegDst: out std_logic;
Br_getz: out std_logic );
end component uc;

component ex is
Port (
RD1: in std_logic_vector(31 downto 0);
RD2: in std_logic_vector(31 downto 0);
Ext_Imm: in std_logic_vector(31 downto 0);
Pc4: in std_logic_vector(31 downto 0);
AluSRC: in std_logic;
sa: in std_logic_vector(4 downto 0);
func: in std_logic_vector(5 downto 0);
AluOp: in std_logic_vector(1 downto 0);
GTZ: out std_logic;
GETZ: out std_logic;
Zero: out std_logic;
ALURes: out std_logic_vector(31 downto 0);
rt: in std_logic_vector(4 downto 0);
rd: in std_logic_vector(4 downto 0);
rwa: out std_logic_vector(4 downto 0);
RegDst: in std_logic;

BranchAddress: out std_logic_vector(31 downto 0) );
end component ex;

component mem is
Port (
MEMWrite: in std_logic;
Address: in std_logic_vector(31 downto 0);
WriteData: in std_logic_vector(31 downto 0);
clk: in std_logic;
en: in std_logic;
ALUResIn: in std_logic_vector(31 downto 0);
ALUResOut: out std_logic_vector(31 downto 0);
ReadData:out std_logic_vector(31 downto 0));
end component mem;

begin

MPG1: MPG port map(en, btn(0),clk);
ifetch1: ifetch port map(clk,en,btn(1),Jump,PCSrc,instruction,pc4,JumpAddress,BrAddr_ex_mem);
SSD1:SSD port map(clk,outpt,an,cat);
uc1: uc port map(instruction_if_id(31 downto 26), Br_gtz, ALUSrc,Branch,Jump,ALUOp,MemWrite,MemToReg,RegWrite,ExtOp,RegDst,Br_getz);
id1: id port map(clk,en,RegWr_mem_wb,instruction_if_id(25 downto 0),WA_mem_wb,rez,ExtOp,RD1,RD2,Ext_Imm,func,sa,rt,rd);
ue1: ex port map(RD1_id_ex,RD2_id_ex,ExtImm_id_ex,pcp4_id_ex,ALUSrc_id_ex,sa_id_ex,func_id_ex, ALUOp_id_ex,gtz,getz,zro,alurez2,rt_id_ex,rd_id_ex,rwa,RegDst_id_ex,BranchAddress);
mem1: mem port map(MemWr_ex_mem,ALURes_ex_mem,RD2_ex_mem,clk,en,ALURes_ex_mem, ALUResMem,MemData);

PCSrc<=(Bgtz_ex_mem and GTZ_ex_mem) or (Bgetz_ex_mem and GETZ_ex_mem) or (Branch_ex_mem and Zero_ex_mem);
JumpAddress<=pcp4_if_id(31 downto 28)&instruction_if_id(25 downto 0)&"00";
rez<=MemData_mem_wb when Mem2R_mem_wb='1' else ALURes_mem_wb;
led(7)<=RegDst_id_ex;
led(6)<=ExtOp;
led(5)<=ALUSrc_id_ex;
led(4)<=Branch_ex_mem;
led(3)<=Jump;
led(2)<=MemWr_ex_mem;
led(1)<=Mem2R_mem_wb;
led(0)<=RegWr_mem_wb;
led(9 downto 8)<=ALUOp_id_ex;

process(clk)
begin

   if rising_edge(clk) then
      if en='1' then
         instruction_if_id<=instruction;
         pcp4_if_id<=pc4;
         
         RD1_id_ex<=RD1;
         RD2_id_ex<=RD2;
         ExtImm_id_ex<=Ext_Imm;
         func_id_ex<=func;
         sa_id_ex<=sa;
         rd_id_ex<=rd;
         rt_id_ex<=rt;
         pcp4_id_ex<=pcp4_if_id;
         RegDst_id_ex<=RegDst;
         ALUSrc_id_ex<=ALUSrc;
         Branch_id_ex<=Branch;
         Bgtz_id_ex<=Br_gtz;
         Bgetz_id_ex<=Br_getz;
         ALUOp_id_ex<=ALUOp;
         MemWr_id_ex<=MemWrite;
         Mem2R_id_ex<=MemToReg;
         RegWr_id_ex<=RegWrite;
         
         Zero_ex_mem<=zro;
         GTZ_ex_mem<=gtz;
         GETZ_ex_mem<=getz;
         Branch_ex_mem<=Branch_id_ex;
         Bgtz_ex_mem<=Bgtz_id_ex;
         Bgetz_ex_mem<=Bgetz_id_ex;
         MemWr_ex_mem<=MemWr_id_ex;
         Mem2R_ex_mem<=Mem2R_id_ex;
         RegWr_ex_mem<=RegWr_id_ex;
         BrAddr_ex_mem<=BranchAddress;
         ALURes_ex_mem<=alurez2;
         WA_ex_mem<=rwa;
         RD2_ex_mem<=RD2_id_ex;
         
         ALURes_mem_wb<=ALUResMem;
         MemData_mem_wb<=MemData;
         WA_mem_wb<=WA_ex_mem;
         Mem2R_mem_wb<=Mem2R_ex_mem;
         RegWr_mem_wb<=RegWr_ex_mem;
         
      end if;
   end if;

end process;

process(sw,instruction_if_id,pcp4_if_id,RD1_id_ex,RD2_id_ex,ExtImm_id_ex,ALURes_ex_mem,MemData_mem_wb,rez)
begin
       case sw(7 downto 5) is
       when "000" => outpt<=instruction_if_id;
       when "001" => outpt<=pcp4_if_id;
       when "010" => outpt<=RD1_id_ex;
       when "011" => outpt<=RD2_id_ex;
       when "100" => outpt<=ExtImm_id_ex;
       when "101" => outpt<=ALURes_ex_mem; 
       when "110" => outpt<=MemData_mem_wb;
       when others => outpt<=rez;    
       end case;
end process;

end behavioral;
