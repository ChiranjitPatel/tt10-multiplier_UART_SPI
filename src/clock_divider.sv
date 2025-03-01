module clock_divider (
    input logic clk_in,  // Input clock (50MHz)
    input logic rst,     // Active-high reset
    output logic clk_1MHz,
    output logic clk_10MHz,
    output logic clk_20MHz,
    output logic clk_50MHz
);

    // Define counters for each frequency division
    int counter_1MHz = 0;
    int counter_10MHz = 0;
    int counter_20MHz = 0;
    int counter_50MHz = 0;
    
    always_ff @(posedge clk_in or posedge rst) begin
        if (rst) begin
            counter_1MHz  <= 0;
            counter_10MHz <= 0;
            counter_20MHz <= 0;
            counter_50MHz <= 0;
            clk_1MHz  <= 0;
            clk_10MHz <= 0;
            clk_20MHz <= 0;
            clk_50MHz <= 0;
        end else begin
            // Generate 1MHz clock (assuming 50MHz input, divide by 50)
            if (counter_1MHz == 24) begin
                counter_1MHz <= 0;
                clk_1MHz <= ~clk_1MHz;
            end else begin
                counter_1MHz <= counter_1MHz + 1;
            end

            // Generate 10MHz clock (divide by 5)
            if (counter_10MHz == 2) begin
                counter_10MHz <= 0;
                clk_10MHz <= ~clk_10MHz;
            end else begin
                counter_10MHz <= counter_10MHz + 1;
            end

            // Generate 20MHz clock (divide by 2.5 -> use integer division logic)
            if (counter_20MHz == 1) begin
                counter_20MHz <= 0;
                clk_20MHz <= ~clk_20MHz;
            end else begin
                counter_20MHz <= counter_20MHz + 1;
            end

            // Generate 50MHz clock (same as input clock)
            clk_50MHz <= clk_in;
        end
    end
endmodule
