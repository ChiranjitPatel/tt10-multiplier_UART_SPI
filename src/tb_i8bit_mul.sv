
module tb_i8bit_mul;

    logic [7:0] a;
    logic [7:0] b;
    logic [15:0] s;

    // Instantiate the multiplier
    i8bit_mul uut (
        .prod(s),
        .a(a),
        .b(b)
    );

    initial begin
        // Initialize inputs
        a = 8'b00000000;
        b = 8'b00000000;

        // Apply test vectors
        #10 a = 8'b00001100; b = 8'b00000101; // 12 * 5 = 60
        #10 a = 8'b11110000; b = 8'b00001111; // 240 * 15 = 3600
        #10 a = 8'b10101010; b = 8'b01010101; // 170 * 85 = 14450
        #10 a = 8'b11111111; b = 8'b11111111; // 255 * 255 = 65025
		#10 a = 8'b10101011; b = 8'b11001101; // 
        #10 a = 8'b11101110; b = 8'b11111111; // 
        #10 a = 8'b00011111; b = 8'b00001111; // 
        #10 a = 8'b00001111; b = 8'b00011111; // 

        // Finish simulation
 //       #10 $finish;
    end

    // Monitor signals
    initial begin
        $monitor("At time %t: a = %b, b = %b -> product = %b (%0d)", 
                 $time, a, b, s, s);
    end

endmodule


