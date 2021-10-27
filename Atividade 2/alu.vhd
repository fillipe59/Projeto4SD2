entity alu is
    generic(
        size : natural := 10 --bit size
    ); 
    port(
        A, B : in  bit_vector(size-1 downto 0); -- inputs
        F    : out bit_vector(size-1 downto 0); -- outputs
        S    : in  bit_vector(3 downto 0); -- op selection
        Z    : out bit; -- zero flag
        Ov   : out bit; -- overflow flag
        Co   : out bit -- carry out
    );
end entity;

architecture arch of alu is
    component alu1bit is
        port (
            a, b, less, cin: in bit;
            result, cout, set, overflow: out bit;
            ainvert, binvert: in bit;
            operation: in bit_vector (1 downto 0)
        );       
    end component;

    signal opa, opb: bit_vector(size-1 downto 0); -- operandos a partir de A e B
    signal res, Couts, sets, ovfls, Cins: bit_vector(size-1 downto 0); -- vetores que armazenam resultado, overflows, carry outs, sets e carry ins
    signal menor: bit; -- sinal que indica se a eh menor que b
    signal res_final: bit_vector(size-1 downto 0); -- resultado final
    signal zero_vector: bit_vector(size-1 downto 0) := (others => '0'); -- vetor com zeros para comparacao

begin
    Cins(0) <= '1' when S(2 downto 1) = "11" else '0';

    Cins_att: for j in size-1 downto 1 generate
        Cins(j) <= Couts(j-1);
    end generate;

    bit1alus: for i in size-1 downto 0 generate
        ula1bit: alu1bit port map(A(i), B(i), '0', Cins(i), res(i), Couts(i), sets(i), ovfls(i), S(3), S(2), S(1 downto 0));
    end generate;

    menor <= sets(size-1);

    res_final <= res(size-1 downto 1) & menor when S(1 downto 0) = "11" else res;

    F <=  res_final;
    Z <= '1' when res_final = zero_vector else '0';
    Ov <= ovfls(size-1);
    Co <= Couts(size-1);
end arch;

-- Entity da alu de 1 bit
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
	signal soma, carry: bit; --! sinais intermediarios de soma e overflow
	
	component fulladder is 
		  port (
			a, b, cin: in bit;
			s, cout: out bit
		  );
	end component;
	
begin
	opa <= a when ainvert = '0' else (not a);
	opb <= b when binvert = '0' else (not b);

	somador_subtrator: fulladder port map(opa, opb, cin, soma, carry);
	
	cout <= carry;
	set <= soma;
	overflow <= cin xor carry;
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