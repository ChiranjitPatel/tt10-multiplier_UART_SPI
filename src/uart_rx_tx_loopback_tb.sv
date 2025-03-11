`timescale 1ns / 1ns

module uart_rx_tx_loopback_tb;

    // parameter integer BAUD_RATE = 1500000;
    parameter integer CLOCK_FREQ = 10000000;
    parameter real CLK_PERIOD = 20.0; // 20 ns for 50 MHz

    logic clk;
    logic reset;
	// logic [7:0] uart_transmit_data; // 8-bit transmit data
    logic uart_rx_d_in;
    logic uart_tx_start;
    logic uart_tx_d_out;
    logic [1:0] freq_control;
    // logic [7:0] uart_received_data;
    logic uart_rx_valid;
    logic uart_tx_ready;

	logic [7:0] uart_reg_data;

    // Instantiate the uart_rx_tx module
	        // .BAUD_RATE(BAUD_RATE),

    uart_rx_tx_loopback
	// #(
        // .CLOCK_FREQ(CLOCK_FREQ)
    // ) 
	uut (
        .clk(clk),
        .reset(reset),
        // .uart_transmit_data(uart_transmit_data),
        .uart_rx_d_in(uart_rx_d_in),
        .uart_tx_start(uart_tx_start),
        .uart_tx_d_out(uart_tx_d_out),
        .freq_control(freq_control),
        // .uart_received_data(uart_received_data),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

    // Generate clock signal
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Generate clock
    end

    // UART loopback
    // assign uart_rx_d_in = uart_tx_d_out; // Loop back tx_d_out to rx_d_in

    

     // Task to send serial data
    task send_serial(input [7:0] data);
        int i;
        uart_rx_d_in = 0; // Start bit
        #104160; // Assuming 9600 baud rate (1/9600 sec per bit at 100MHz clock)
        for (i = 0; i < 8; i = i + 1) begin
            uart_rx_d_in = data[i];
            #104160;
        end
        uart_rx_d_in = 1; // Stop bit
        #104160;
    endtask
    
    // Test sequence
    initial begin
        // Initialize signals
        reset = 0;
        uart_rx_d_in = 1;
        uart_tx_start = 0;
        freq_control = 2'b00;
        
        #100 reset = 1;
        
        #200;
        send_serial(8'hA5); // Send byte 0xA5 over UART RX
        
        #200000;
        send_serial(8'h5A); // Send another byte 0x5A over UART RX
        
        #500000;
		uart_tx_start = 1'b1;
		#1000;
		uart_tx_start = 1'b0;
        // $stop;
    end

endmodule
