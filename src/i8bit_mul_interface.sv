module i8bit_mul_interface(
	clk, 
	reset, 
	mul_start,
	mul_ip_BA, 
	mul_op_prod,
	mul_ready,
	
);

	input  logic clk;
	input  logic reset;
	input  logic mul_start;
	input  logic [15:0] mul_ip_BA;
	output logic [15:0] mul_op_prod;
	output logic mul_ready;
	
	
	logic [15:0] mul_op_prod_int;
	
	i8bit_mul
	(
		.mul_ip_A(mul_ip_BA[7:0]), 
		.mul_ip_B(mul_ip_BA[15:8]), 
		.prod_low(mul_op_prod_int[7:0]),
		.prod_high(mul_op_prod_int[15:8])
	);
	
	// Mul_ready signal indicates that the multiplier is ready for a new operation
	always_ff @(posedge clk or negedge reset) begin
			if (~reset) begin
				mul_ready <= 1'b1;
				mul_op_prod <= 16'b0;
			end 
			
			else begin
				if (mul_start) begin
					mul_ready <= 1'b0;
					mul_op_prod <= mul_op_prod_int;
				end
				else
					mul_ready <= 1'b1;
			end
		end

endmodule
