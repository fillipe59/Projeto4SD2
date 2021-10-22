entity alu1bit is
	port (
		a, b, less, cin: in bit;
		result, cout, set, overflow: out bit;
		ainvert, binvert: in bit;
		operation: in bit_vector (1 downto 0)
	);
end entity;

architecture arch of alu1bit is
	signal opa, opb: bit; --! operandos a partir de a e b
	signal soma, ovf: bit; --! sinais intermediarios de soma e overflow
	
	component fulladder is 
		  port (
			a, b, cin: in bit;
			s, cout: out bit
		  );
	end component;
	
begin
	opa <= a when ainvert = '0' else (not a);
	opb <= b when binvert = '0' else (not b);

	somador_subtrator: fulladder port map(opa, opb, cin, soma, ovf);
	
	cout <= ovf;
	set <= soma;
	overflow <= ovf;
	result <= opa and opb when operation = "00" else
			  opa or opb  when operation = "01" else
			  soma        when operation = "10" else
			  less        when operation = "11";
	
end arch;

entity fulladder is
  port (
    a, b, cin: in bit;
    s, cout: out bit
  );
 end entity;

architecture structural of fulladder is
  signal axorb: bit;
begin
  axorb <= a xor b;
  s <= axorb xor cin;
  cout <= (axorb and cin) or (a and b);
 end architecture;