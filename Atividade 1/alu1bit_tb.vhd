entity alu1bit_tb is
end entity;

architecture tb of alu1bit_tb is
	component alu1bit is
		port (
			a, b, less, cin: in bit;
			result, cout, set, overflow: out bit;
			ainvert, binvert: in bit;
			operation: in bit_vector (1 downto 0)
		);
	end component;
	
	signal clock_in: bit;
	constant clockPeriod: time := 2 ns; -- periodo do clock
	signal simulando : bit := '0';
	
	signal a_in, b_in, less_in, cin_in: bit;
	signal result_out, cout_out, set_out, overflow_out: bit;
	signal ainvert_in, binvert_in: bit;
	signal operation_in: bit_vector (1 downto 0);
begin
	DUT: alu1bit port map(a_in, b_in, less_in, cin_in, result_out, 
						  cout_out, set_out, overflow_out, 
						  ainvert_in, binvert_in,
						  operation_in);
						  
	clock_in <= (simulando and (not clock_in)) after clockPeriod/2;
	
	estimulos: process is
		type pattern_type is record 
			a, b, less, cin: bit;
			ainvert, binvert: bit;
			operation: bit_vector (1 downto 0);
			result, cout, set, overflow: bit;
		end record;
		
		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns: pattern_array := 
	   --  a    b  less  cin  ai   bi  oper | res cout  set  ovf
		(('0', '0', '0', '0', '0', '0', "00", '0', '0', '0', '0'), -- 00 testa AND
		 ('0', '1', '0', '1', '0', '0', "00", '0', '1', '0', '0'), -- 01 testa AND
		 ('1', '1', '0', '0', '0', '0', "00", '1', '1', '0', '1'), -- 02 testa AND
		 ('1', '0', '1', '0', '0', '1', "00", '1', '1', '0', '1'), -- 03 testa AND
		 ('0', '0', '0', '1', '0', '0', "01", '0', '0', '1', '1'), -- 04 testa OR
		 ('1', '0', '0', '1', '0', '0', "01", '1', '1', '0', '0'), -- 05 testa OR
		 ('1', '1', '0', '0', '1', '1', "01", '0', '0', '0', '0'), -- 06 testa OR
		 ('1', '1', '0', '0', '0', '0', "01", '1', '1', '0', '1'), -- 07 testa OR
		 ('1', '0', '0', '0', '0', '0', "10", '1', '0', '1', '0'), -- 08 testa ADD
		 ('0', '0', '0', '1', '1', '0', "10", '0', '1', '0', '0'), -- 09 testa ADD
		 ('1', '1', '0', '0', '0', '0', "10", '0', '1', '0', '1'), -- 10 testa ADD
		 ('1', '1', '0', '1', '0', '0', "10", '1', '1', '1', '0'), -- 11 testa ADD
		 ('0', '0', '0', '0', '0', '0', "11", '0', '0', '0', '0'), -- 12 testa STL
		 ('0', '0', '1', '0', '0', '0', "11", '1', '0', '0', '0'), -- 13 testa STL
		 ('0', '0', '1', '1', '0', '0', "11", '1', '0', '1', '1'), -- 14 testa STL
		 ('0', '0', '0', '1', '0', '1', "11", '0', '1', '0', '0'));  -- 15 testa STL
		 
	begin
		assert false report "Testes iniciados" severity note;
		simulando <= '1'; -- Habilita clock
		
		for i in patterns'range loop
			a_in <= patterns(i).a;
			b_in <= patterns(i).b;
			less_in <= patterns(i).less;
			cin_in <= patterns(i).cin;
			ainvert_in <= patterns(i). ainvert;
			binvert_in <= patterns(i).binvert;
			operation_in <= patterns(i).operation;
			
			
			wait for clockPeriod;
			
			assert result_out = patterns(i).result
			report "Erro no sinal result do teste " & integer'image(i)  
			severity error;
			
			assert cout_out = patterns(i).cout
			report "Erro no sinal cout do teste " & integer'image(i)  
			severity error;
			
			assert set_out = patterns(i).set
			report "Erro no sinal set do teste " & integer'image(i)  
			severity error;
			
			assert overflow_out = patterns(i).overflow
			report "Erro no sinal overflow do teste " & integer'image(i)  
			severity error;
		end loop;
		assert false report "Testes concluidos" severity note;
		simulando <= '0'; -- Desabilita clock		
		wait;  -- para a execução do simulador, caso contrário este process é reexecutado indefinidamente.
	end process;
end architecture;