`timescale 1ns / 1ns

module tb_tt_um_uart_spi;

    // parameter integer BAUD_RATE = 1500000;
    parameter integer CLOCK_FREQ = 10000000;
    parameter real CLK_PERIOD = 20.0; // 20 ns for 50 MHz
	localparam SCLK_PERIOD = 1000; // SPI clock

	logic [7:0] ui_in;
	logic [7:0] uo_out; 
	logic [7:0] uio_in; 
	logic [7:0] uio_out;
    logic [7:0] uio_oe;
    
    logic ena;
	logic clk;
    logic rst_n;
	
	
 tt_um_uart_spi tt_top_uut	
 (
	.ui_in(ui_in),
	.uo_out(uo_out),
	.uio_in(uio_in),
	.uio_out(uio_out),
	.uio_oe(uio_oe),
	.ena(ena),
	.clk(clk),
	.rst_n(rst_n)
	);

////////////////////// UART //////////////////////////
    // Generate clock signal
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk; // Generate clock
    end

     // Task to send serial data
    task send_serial(input [7:0] data);
        int i;
        ui_in[2] = 0; // Start bit
        #104160; // Assuming 9600 baud rate (1/9600 sec per bit at 100MHz clock)
        for (i = 0; i < 8; i = i + 1) begin
            ui_in[2] = data[i];
            #104160;
        end
        ui_in[2] = 1; // Stop bit
        #104160;
    endtask
    
    // Test sequence
    initial begin
        // Initialize signals
        rst_n = 0;
        ui_in[2] = 1;
        ui_in[3] = 0;
        ui_in[1:0] = 2'b00;
        
        #100 rst_n = 1;
        
        #200;
        send_serial(8'hA5); // Send byte 0xA5 over UART RX
        
        #200000;
        send_serial(8'h5A); // Send another byte 0x5A over UART RX
        
        #500000;
		ui_in[3] = 1'b1;
		#1000;
		ui_in[3] = 1'b0;
        // $stop;
    end
////////////////////// UART //////////////////////////


////////////////////// SPI //////////////////////////
initial begin
        ui_in[5] = 0;
		forever #(SCLK_PERIOD / 2) ui_in[5] = ~ui_in[5];
    end

    // Test miso_reg_data and control signals
    logic [15:0] test_data [0:15];
    integer i;

    initial begin
        // Initialize test miso_reg_data (e.g., 16 frames with varying channel_id)
        for (i = 0; i <=15; i++) begin
            test_data[i] = {12'd0, i[3:0]}; // Channel ID is i, miso_reg_data is 0xABC
        end

        // Initialize signals
        rst_n = 0;
		ui_in[4] = 0;
        ui_in[7] = 0;
        ui_in[6] = 0;
        // mosi_reg_data = 0;

        // Wait for rst_n
        #200;
		rst_n = 1;
		ui_in[4] = 1;

        // Simulate sending 16 frames of 16-bit miso_reg_data
        for (i = 0; i <=15; i++) begin

			// if (i==0) begin
				// miso_reg_data = 16'hF1F1; // Example 16-bit miso_reg_data value
			// end
			// else begin
				// miso_reg_data = 0;
			// end
			
			@(posedge clk);
            ui_in[7] = 1;

            // Simulate MISO miso_reg_data from the ADC
            repeat (16) begin
                @(negedge ui_in[5]); // Wait for falling edge of ui_in[5]
				ui_in[6] = test_data[i][15]; // Send MSB first
                test_data[i] = test_data[i] << 1; // Shift to next bit
            end

            // Wait for miso_reg_data to be received
            @(posedge clk);
            ui_in[7] = 0;
            while (!uo_out[4]) @(posedge clk);

			if (i==0) begin
				// slave_tx_start = 0;
				#10000;
			end
			else begin
				ui_in[6] = 0;
				#10000; // Delay between frames
			end
		end
    end
////////////////////// SPI //////////////////////////

endmodule
