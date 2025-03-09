`timescale 1ns/1ps

module tb_i8bit_mul_interface;

    // Signals for DUT
    logic [15:0] mul_ip_BA;
    logic [15:0] mul_op_prod;
    logic mul_ready;
    logic mul_start;
    logic clk, reset;

    // Instantiate the DUT
    i8bit_mul_interface dut (
		.clk(clk),
		.reset(reset),
        .mul_ip_BA(mul_ip_BA),
        .mul_op_prod(mul_op_prod),
        .mul_ready(mul_ready),
        .mul_start(mul_start)
    );

    // Clock generation
    localparam CLK_PERIOD = 80; 
	initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end
	
    // Test sequence
    initial begin
        // Initialize signals
        clk = 0;
        reset = 0;
        mul_ip_BA = 16'd0;
        mul_start = 0;

        // Apply reset
        #20 reset = 1;
        // #10;

        // Test Case 1: Multiply 8'h02 * 8'h03
        mul_ip_BA = {8'h02, 8'h03}; // A = 2, B = 3
        mul_start = 1;
        // #30;
		wait(~mul_ready);
        mul_start = 0;

        // Wait for multiplication to complete
        wait(mul_ready);
        $display("Test Case 1: A=2, B=3, Product=%h", mul_op_prod);
        #20;

        // Test Case 2: Multiply 8'hFF * 8'h01
        mul_ip_BA = {8'hFF, 8'hFF}; // A = 255, B = 1
        mul_start = 1;
        // #30;
		wait(~mul_ready);
        mul_start = 0;

        wait(mul_ready);
        $display("Test Case 2: A=255, B=1, Product=%h", mul_op_prod);
        #20;

        // Test Case 3: Multiply 8'h10 * 8'h10
        mul_ip_BA = {8'hAA, 8'hAA}; // A = 16, B = 16
        mul_start = 1;
        // #30;
		wait(~mul_ready);
        mul_start = 0;

        wait(mul_ready);
        $display("Test Case 3: A=16, B=16, Product=%h", mul_op_prod);
        #20;

    end

endmodule
