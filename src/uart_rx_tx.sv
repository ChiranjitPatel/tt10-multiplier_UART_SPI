`timescale 1ns / 1ps

module uart_rx_tx 
	#(  parameter [23:0] BAUD_RATE = 24'd9600,
		parameter [27:0] CLOCK_FREQ = 28'd100000000
	)
	(	clk_int,
		uart_reset,
		uart_transmit_data,
		uart_rx_d_in,
		uart_tx_start,
		uart_tx_d_out,
		uart_received_data,
		uart_rx_valid,
		uart_tx_ready
	);
	
	
	input  logic clk_int;
	input  logic uart_reset;
	input  logic [7:0] uart_transmit_data;
	input  logic uart_rx_d_in;
	input  logic uart_tx_start;
	output logic uart_tx_d_out;
	output logic [7:0] uart_received_data;
	output logic uart_rx_valid;
	output logic uart_tx_ready;
	
	// Instantiate uart_tx
	uart_tx 
	#(
		.baud_rate(BAUD_RATE),
		.clock_freq(CLOCK_FREQ)
	) 
	uart_tx_inst (
		.uart_clock(clk_int),
		.uart_reset(uart_reset),
		.uart_start(uart_tx_start),
		.uart_d_in(uart_transmit_data),
		.uart_d_out(uart_tx_d_out),
		.uart_tx_ready(uart_tx_ready)
	);

	// Instantiate uart_rx 
	uart_rx 
	#(
		.baud_rate(BAUD_RATE),
		.clock_freq(CLOCK_FREQ)
	) 
	uart_rx_inst (
		.uart_clock(clk_int),
		.uart_reset(uart_reset),
		.uart_d_in(uart_rx_d_in),
		.uart_d_out(uart_received_data),
		.uart_valid(uart_rx_valid)
	);

endmodule
