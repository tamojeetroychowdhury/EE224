library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity PC is 
	port (S0 : in std_logic;
			ALU_out : in std_logic_vector(15 downto 0);
			NandAdd, ADI, StoreLoad, LHI, BEQ, JAL, JLR: in std_logic;
			regB : in std_logic_vector(15 downto 0);
			curr_PC_out, next_PC_out : out std_logic_vector(15 downto 0));
end PC;


architecture bhv of PC is
	signal curr_PC : std_logic_vector(15 downto 0);
	signal next_PC : std_logic_vector(15 downto 0);
	begin
	update : process(BEQ, JAL, JLR, curr_PC, next_PC)
	begin
		if (BEQ = '1' or JAL = '1') then
				next_PC <= ALU_out;
			elsif (JLR = '1') then
				next_PC <= regB;
			else
				next_PC <= std_logic_vector(unsigned(curr_PC) + 1);
			end if;
		if (S0'event and S0 = '0') then
			curr_PC <= next_PC;	
		end if;
	end process;
	
	curr_PC_out <= curr_PC;
	next_PC_out <= next_PC;
	
end bhv;


library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 


entity curr_ins_reg is
	port (S0 : in std_logic;
			mem_out : in std_logic_vector(15 downto 0);
			ins : out std_logic_vector(15 downto 0));
end entity;

architecture bhv of curr_ins_reg is
	begin	
	update : process(S0, mem_out)
	begin
		if (S0'event and S0 = '0') then
			ins <= mem_out;
		end if;
	end process;
end bhv;