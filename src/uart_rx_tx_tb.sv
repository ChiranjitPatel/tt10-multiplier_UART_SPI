`timescale 1ns / 1ns

module uart_rx_tx_tb;

    // parameter integer BAUD_RATE = 1500000;
    parameter integer CLOCK_FREQ = 10000000;
    parameter real CLK_PERIOD = 20.0; // 20 ns for 50 MHz

    logic clk_int;
    logic uart_reset;
	logic [7:0] uart_transmit_data; // 8-bit transmit data
    logic uart_rx_d_in;
    logic uart_tx_start;
    logic uart_tx_d_out;
    logic [1:0] freq_control;
    logic [7:0] uart_received_data;
    logic uart_rx_valid;
    logic uart_tx_ready;

    // Instantiate the uart_rx_tx module
	        // .BAUD_RATE(BAUD_RATE),

    uart_rx_tx 
	// #(
        // .CLOCK_FREQ(CLOCK_FREQ)
    // ) 
	uut (
        .clk_int(clk_int),
        .uart_reset(uart_reset),
        .uart_transmit_data(uart_transmit_data),
        .uart_rx_d_in(uart_rx_d_in),
        .uart_tx_start(uart_tx_start),
        .uart_tx_d_out(uart_tx_d_out),
        .freq_control(freq_control),
        .uart_received_data(uart_received_data),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

    // Generate clock signal
    initial begin
        clk_int = 0;
        forever #(CLK_PERIOD / 2) clk_int = ~clk_int; // Generate clock
    end

    // UART loopback
    assign uart_rx_d_in = uart_tx_d_out; // Loop back tx_d_out to rx_d_in

    // Monitor received data
    always @(posedge clk_int) begin
        if (uart_rx_valid) begin
            $display("Received data: %h (%s)", uart_received_data, uart_received_data);
        end
    end

    // Simulation process
    initial begin
        uart_reset = 0;
		uart_tx_start = 1'b0;
        uart_transmit_data = 8'h00; // Initialize transmit data
		

        // Reset release
        #(4 * CLK_PERIOD);
        uart_reset = 1;

		freq_control = 2'b11;
        // Start sending data in a loop
        repeat (1) begin
            // Simulate sending data
            #50000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h02; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
            
            #50000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h0A; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
        end
        
		freq_control = 2'b10;
        // Start sending data in a loop
        repeat (1) begin
            // Simulate sending data
            #50000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h02; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
            
            #50000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h0A; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
        end
		
		freq_control = 2'b00;
        // Start sending data in a loop
        repeat (1) begin
            // Simulate sending data
            #50000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h02; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
            
            #120000; // Wait a bit before starting transmission
            // uart_transmit_data = (uart_transmit_data == 8'h31) ? 8'h30 : 8'h31; // Toggle between ASCII '1' and '0'
			uart_tx_start = 1'b1;
            uart_transmit_data = 8'h0A; // Toggle between ASCII '1' and '0'
			wait(uart_tx_ready == 0);
			uart_tx_start = 1'b0;
            #10000; // Wait for a bit
        end
		
        // Allow enough time to observe multiple transmissions
        #(100 * CLK_PERIOD);
		
    end

endmodule
