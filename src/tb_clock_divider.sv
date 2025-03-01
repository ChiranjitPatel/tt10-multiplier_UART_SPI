module tb_clock_divider;
    logic clk_in;
    logic rst;
    logic clk_1MHz;
    logic clk_10MHz;
    logic clk_20MHz;
    logic clk_50MHz;
    
    frequency_divider uut (
        .clk_in(clk_in),
        .rst(rst),
        .clk_1MHz(clk_1MHz),
        .clk_10MHz(clk_10MHz),
        .clk_20MHz(clk_20MHz),
        .clk_50MHz(clk_50MHz)
    );
    
    // Generate 50MHz clock (20ns period)
    initial begin
        clk_in = 0;
        forever #10 clk_in = ~clk_in;
    end
    
    // Test sequence
    initial begin
        rst = 1;
        #50 rst = 0;
        #1000 $stop;
    end
endmodule