library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
library work;
use work.Gates.all;



entity MUX is
	port (
		in0: in std_logic_vector(15 downto 0);
		in1: in std_logic_vector(15 downto 0);
		ctrl: in std_logic;
		op: out std_logic_vector(15 downto 0));
end MUX;

architecture normal of MUX is
	begin
	proc : process(in0, in1, ctrl) 
	begin
		if (ctrl='0') then
			op <= in0;
		else
			op <= in1;
		end if;
	end process;
end normal;


library ieee;
use ieee.std_logic_1164.all;
entity REG is
	port (
		D: in std_logic_vector(15 downto 0);
		Q: out std_logic_vector(15 downto 0);
		clk: in std_logic);
end REG;

architecture normal of REG is
	begin
		dff_set_proc: process (clk)
		begin
			if (clk'event and (clk='1')) then
				Q <= D;
			end if;
	end process dff_set_proc;
end normal;


library ieee;
use ieee.std_logic_1164.all;
entity FA16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		sum: out std_logic_vector(15 downto 0);
		C: out std_logic;
		Z: out std_logic);
end FA16;

architecture normal of FA16 is
	signal carry : std_logic_vector(15 downto 0):= (others => '0');
	signal sum_buf : std_logic_vector(15 downto 0):= (others=>'0');
	begin
	proc : process(A, B, carry, sum_buf)
	begin
		L1: for i in 0 to 15 loop
			if i=0 then
				sum_buf(i) <= A(i) xor B(i);
				carry(i) <= A(i) and B(i) ;
			else
				sum_buf(i) <= A(i) xor B(i) xor carry(i-1);
				carry(i) <= (A(i) and B(i)) or (B(i) and carry(i-1)) or (A(i) and carry(i-1));
			end if;
		end loop L1;
		C <= carry(15);
		sum <= sum_buf;
		if (A = B) then
			Z <= '1';
		else
			Z <='0';
	end if;
	end process;
end normal;


library ieee;
use ieee.std_logic_1164.all;	
entity NAND16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		op: out std_logic_vector(15 downto 0));
end NAND16;

architecture normal of NAND16 is
	begin
	proc : process(A, B)
	begin
		L1: for i in 0 to 15 loop
			op(i) <= A(i) nand B(i);
		end loop L1;
	end process;
end normal;











library ieee;
use ieee.std_logic_1164.all;
entity CPU is
	port ( 
		clk: in std_logic);
end CPU;


architecture normal of CPU is

	component MUX is 
	port (		
		in0: in std_logic_vector(15 downto 0);
		in1: in std_logic_vector(15 downto 0);
		ctrl: in std_logic;
		op: out std_logic_vector(15 downto 0));
	end component;
	
	component FA16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		sum: out std_logic_vector(15 downto 0);
		C: out std_logic;
		Z: out std_logic);
	end component;
	
	component NAND16 is
	port (
		A: in std_logic_vector(15 downto 0);
		B: in std_logic_vector(15 downto 0);
		op: out std_logic_vector(15 downto 0));
	end component;
	
	
	
	

	signal memory : std_logic_vector(0 to 1023) := (others=>'0');
	signal reg_file : std_logic_vector(127 downto 0);
	signal regA : std_logic_vector(15 downto 0);
	signal regB : std_logic_vector(15 downto 0);
	signal regC : std_logic_vector(15 downto 0);
	signal PC : std_logic_vector(15 downto 0) := (others=>'0');
	signal i : std_logic_vector(15 downto 0) := memory(0 to 15);
	
	signal m1_out : std_logic_vector(15 downto 0);
	signal m2_out : std_logic_vector(15 downto 0);
	signal m3_out : std_logic_vector(15 downto 0);
	signal m4_out : std_logic_vector(15 downto 0);
	signal m5_out : std_logic_vector(15 downto 0);
	
	signal adder_out : std_logic_vector(15 downto 0);
	signal nand_out : std_logic_vector(15 downto 0);
	signal alu_out : std_logic_vector(15 downto 0);
	
	signal C_new : std_logic := '0';
	signal Z_new : std_logic := '0';
	signal C_prev : std_logic := '0';
	signal Z_prev : std_logic := '0';
	
	signal clock_for_C : std_logic;
	signal clk_z1 : std_logic;
	signal clk_z2 : std_logic;
	signal clk_z3 : std_logic;
	signal clock_for_Z : std_logic;
	signal clock_for_regC : std_logic;
	signal clock_for_regB : std_logic;
	
	signal n : std_logic_vector(2 downto 0) := (others=>'0');
	
	signal A2 : integer := 0;
	signal A1 : integer := 0;
	signal A0 : integer := 0;
	signal Anum : integer := 0; 
	
	signal B2 : integer := 0;
	signal B1 : integer := 0;
	signal B0 : integer := 0;
	signal Bnum : integer := 0; 
	
	signal C2 : integer := 0;
	signal C1 : integer := 0;
	signal C0 : integer := 0;
	signal Cnum : integer := 0; 
	
	signal padded_imm5 : std_logic_vector(15 downto 0);
	signal padded_imm8 : std_logic_vector(15 downto 0);
	signal padded_n : std_logic_vector(15 downto 0);

	begin
	num_proc : process(i)
	begin	
		if i(11)='1' then
			A2 <= 1;
		end if;
		if i(10)='1' then
			A1 <= 1;
		end if;
		if i(9)='1' then
			A0 <= 1;
		end if;

		if i(8)='1' then
			B2 <= 1;
		end if;
		if i(7)='1' then
			B1 <= 1;
		end if;
		if i(6)='1' then
			B0 <= 1;
		end if;	
			
		if i(5)='1' then
			C2 <= 1;
		end if;
		if i(4)='1' then
			C1 <= 1;
		end if;
		if i(3)='1' then
			C0 <= 1;
		end if;
	end process;
		
	Anum <= A2*4 + A1*2 + A0;
	Bnum <= B2*4 + B1*2 + B0;
	Cnum <= C2*4 + C1*2 + C0;
		
	update_inreg_proc : process(clk, reg_file, A2, A1, A0, B2, B1, B0, C2, C1, C0)
		begin
		if (clk'event and (clk='1')) then
			regA <= reg_file(Anum*16+15 downto Anum*16);
			regB <= reg_file(Bnum*16+15 downto Bnum*16);
		end if;
		end process;
		
	alu_proc : process(regA, regB, PC, i)
	begin
	if (i(5)='0') then
		padded_imm5 <= "0000000000" & i(5 downto 0);
	else
		padded_imm5 <= "1111111111" & i(5 downto 0);
	end if;
	
	if (i(8)='0') then
		padded_imm8 <= "0000000" & i(8 downto 0);
	else
		padded_imm8 <= "1111111" & i(8 downto 0);
	end if;
	end process;
	
	padded_n <= "0000000000000" & n(2 downto 0);
	M1 : MUX port map (in0 => regB, in1 => padded_imm5, ctrl => i(12), op => m1_out);
	M2 : MUX port map (in0 => m1_out, in1 => padded_n, ctrl => i(14) and i(13), op => m2_out);
	M3 : MUX port map (in0 => regA, in1 => PC, ctrl => i(15), op => m3_out);
	M4 : MUX port map (in0 => padded_imm8, in1 => padded_imm5, ctrl => i(14), op => m4_out);
	M5 : MUX port map (in0 => m2_out, in1 => m4_out, ctrl => i(15), op => m5_out);
	
	ADD1 : FA16 port map (A => m3_out, B => m5_out, sum => adder_out, C => C_new, Z => Z_new);
	NAND1 : NAND16 port map (A => regA, B => regB, op => nand_out);
	M6 : MUX port map (in0 => adder_out, in1 => nand_out, ctrl => not i(14) and i(13) and not i(12), op => alu_out);
	
	clock_for_C <= not (i(15) or i(14) or i(13)) and clk;
	
	clk_z1 <= not i(15) and not i(14) and not i(13) and clk;
	clk_z2 <= not i(15) and not i(14) and not i(12) and clk;
	clk_z3 <= not i(15) and i(14) and not i(13) and not i(12) and clk;
	clock_for_Z <= clk_z1 or clk_z2 or clk_z3;
	
	clock_for_regC <= ((not i(1) and not i(0)) or (i(1) and not i(0) and Z_prev) or (not i(1) and i(0) and C_prev) or i(12)) and clk and not i(15) and not i(14) and not i(12);
	clock_for_regB <= not i(15) and not i(14) and not i(13) and i(12) and clk;
	
	CZ_modify_proc : process (C_new, Z_new, clock_for_C, clock_for_Z)
	begin
		if (clock_for_C'event and (clock_for_C='1')) then
			C_prev <= C_new;
		end if;
		if (clock_for_Z'event and (clock_for_Z='1')) then
			Z_prev <= Z_new;
		end if;
	end process;
	
	
	ALU_RF_update_proc : process (i, alu_out, clock_for_regC, clock_for_regB)
	begin
		case i(12) is
		when '1' =>
			if (clock_for_regB'event and (clock_for_regB='1')) then
				reg_file(Bnum*16+15 downto Bnum*16) <= alu_out;
			end if;
		when '0' =>
			if (clock_for_regC'event and (clock_for_regC='1')) then
				reg_file(Cnum*16+15 downto Cnum*16) <= alu_out;
			end if;	
		end case;
	end process;
		
	

	
end normal;