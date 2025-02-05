// 8-bit UT veridc multiplier
module i8bit_mul(
	a, 
	b, 
	prod
);

	input 	[7:0] a;
	input 	[7:0] b;
	output 	[15:0] prod;
	// output 	[7:0] prod_low;
	// output 	[7:0] prod_high;
	
	wire [40:0]w;
	
	i4bit_mul N1 (a[3:0], b[3:0], w[7:0]);
	i4bit_mul N2 (a[7:4], b[3:0], w[15:8]);
	i4bit_mul N3 (a[3:0], b[7:4], w[23:16]);
	i4bit_mul N4 (a[7:4], b[7:4], w[31:24]);
	
	assign prod[3:0] = w[3:0];
	
	csa_1_8bit C1 (w[23:16], w[15:8] , w[7:4], w[40:32]);
	assign prod[7:4] = w[35:32];
	csa_2_8bit C2 (w[31:24], w[40:36], prod[15:8]);
	
endmodule
