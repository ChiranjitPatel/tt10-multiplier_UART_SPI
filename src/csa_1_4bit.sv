module csa_1_4bit(
	ia,
	ib,
	ot
	);

input [3:0]ia;
input [3:0]ib;
input [1:0]ic;
output [4:0]ot;

wire [6:0]wc;
wire [2:0]ws;

fa fa_1(ot[0],wc[0],ia[0],ib[0],ic[0]);
fa fa_2(ws[0],wc[1],ia[1],ib[1],ic[1]);
ha ha_1(ws[1],wc[2],ia[2],ib[2]);
ha ha_2(ws[2],wc[3],ia[3],ib[3]);

ha ha_3(ot[1],wc[4],wc[0],ws[0]);
fa fa_3(ot[2],wc[5],wc[1],ws[1],wc[4]);
fa fa_4(ot[3],wc[6],wc[2],ws[2],wc[5]);
//or or_1(ot[4],wc[3],wc[6]);
assign ot[4] = wc[3]|wc[6];
endmodule