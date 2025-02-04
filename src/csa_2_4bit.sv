module csa_2_4bit(
	ia,
	ib,
	ot
	);
	
	input [3:0]ib;
	input [1:0]ia;
	output [4:0]ot;
	

	wire [4:0]wc;
	wire [0:0]ws;

	ha half_1(ot[0],wc[0],ia[0],ib[0]);
	ha half_2(ws[0],wc[1],ia[1],ib[1]);

	ha half_3(ot[1],wc[2],wc[0],ws[0]);
	fa full_1(ot[2],wc[3],wc[2],wc[1],ib[2]);
	ha half_4(ot[3],wc[4],wc[3],ib[3]);


endmodule