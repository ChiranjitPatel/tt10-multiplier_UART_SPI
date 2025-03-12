// `timescale 1ns/1ps

module uart_spi_top 
	(
	clk,
	reset,
	freq_control,
	uart_rx_d_in,
	uart_tx_start,
	cs_bar,
	sclk,
	mosi,
	spi_start,
	uart_tx_d_out,
	miso,
	uart_rx_valid,
	uart_tx_ready,
	spi_rx_valid,
	spi_tx_done
	);

	input logic clk;
	input logic reset;
	input logic [1:0] freq_control;
	input logic uart_rx_d_in;
	input logic uart_tx_start;
	input logic cs_bar;
	input logic sclk;
	input logic mosi;
	input logic spi_start;
	output logic uart_tx_d_out;
	output logic miso;
	output logic uart_rx_valid;
	output logic uart_tx_ready;
	output logic spi_rx_valid;
	output logic spi_tx_done;
	// output logic frames_received;

    // logic [7:0] miso_reg_data;
    // logic [7:0] mosi_reg_data;

	
	// Instantiate the UART module
    uart_rx_tx_loopback uart_uut (
        .clk(clk),
        .reset(reset),
        .uart_rx_d_in(uart_rx_d_in),
        .uart_tx_start(uart_tx_start),
		.freq_control(freq_control),
        .uart_tx_d_out(uart_tx_d_out),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

	// Instantiate the SPI module
	spi_slave spi_uut (
		.clk(clk),           
		.reset(reset),
		.spi_start(spi_start),
		// .miso_reg_data(miso_reg_data),
		.mosi(mosi),
		.cs_bar(cs_bar),       
		.sclk(sclk),
		.miso(miso),	
		// .mosi_reg_data(mosi_reg_data),
		.rx_valid(spi_rx_valid),
		.tx_done(spi_tx_done)
	);

endmodule

