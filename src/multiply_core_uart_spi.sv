`timescale 1ns/1ns

module multiply_core_uart_spi 
	#(  
		parameter N = 16,
		parameter M = 9,
		parameter [23:0] BAUD_RATE = 24'd9600,
        parameter [25:0] CLOCK_FREQ = 26'd50000000
    )
	(
	clk,
	reset,
	uart_rx,
	mul_enable,
	uart_tx,
	frames_received

	);

	input logic clk;
	input logic reset;
	input logic uart_rx;
	input logic mul_enable;
	output logic uart_tx;
	output logic frames_received;

	localparam integer NUM_FRAMES = (N)/8;
	localparam integer DELAY_TIME = 100;
	localparam integer UART_TX_DELAY = 100000;
	localparam integer UART_TX_DELAY_BITS = $clog2(UART_TX_DELAY);
	localparam integer NUM_FRAME_BITS = $clog2(NUM_FRAMES);

	logic uart_clock_50M;

	logic [N-1:0] mul_ip_BA; // B is [15:8], A is [7:0]
	logic [N-1:0] mul_op_prod; // 16-bit output of multipler
	logic [7:0] rx_frames [NUM_FRAMES-1:0];
	
	// UART
    logic       uart_tx_start;
    logic [7:0] uart_transmit_data;
    logic [7:0] uart_received_data;
    logic       uart_rx_valid;
    logic       uart_tx_ready;
	logic       uart_rx_valid_edge;
	logic 		uart_tx_ready_edge;
	logic [UART_TX_DELAY_BITS-1:0]  uart_tx_delay_count;
	
	logic [NUM_FRAME_BITS-1:0]    rx_frames_count;
	logic [NUM_FRAME_BITS-1:0]    tx_frames_count;
	logic [7:0] delay_count;
	
	typedef enum logic[2:0] {Init, Rx_Frames, Delay, Tx_Data, Tx_Delay, Finish} state_machine;
    state_machine state;
	
	// Instantiate clock Wizard
	clk_wiz_0 clk_wiz_inst (
        .clk_out1(uart_clock_50M),
        .reset(1'b0),
        .clk_in1(clk)
    );

	
	// Instantiate the uart_rx_tx module
    uart_rx_tx #(
        .BAUD_RATE(BAUD_RATE),
        .CLOCK_FREQ(CLOCK_FREQ)
    ) uart_uut (
        .clk_10ns(clk),
        .uart_clock(uart_clock_50M),
        .uart_reset(reset),
        .uart_transmit_data(uart_transmit_data),
        .uart_rx_d_in(uart_rx),
        .uart_tx_start(uart_tx_start),
        .uart_tx_d_out(uart_tx),
        .uart_received_data(uart_received_data),
        .uart_rx_valid(uart_rx_valid),
        .uart_tx_ready(uart_tx_ready)
    );

	// i8bit_mul multiplier_uut
		// (
		// .mul_ip_A(mul_ip_A), 
		// .mul_ip_B(mul_ip_B), 
		// .prod_low(prod_low),
		// .prod_high(prod_high)
		// );
	
	i8bit_mul_interface multiplier_interface_uut
		(
		.mul_ip_BA(mul_ip_BA), 
		.mul_op_prod(mul_op_prod),
		.mul_ready(mul_ready),
		.mul_start(mul_start)
		);
	
	always_comb begin
		//direct mapping possible?
		mul_ip_BA[7:0] = rx_frames[0]; 
		mul_ip_BA[15:8] = rx_frames[1]; 
	end
	
	always_ff @(posedge clk or negedge reset) begin
	
		if (~reset) begin
			frames_received <= 1'b0;
			uart_rx_valid_edge <= 0;
			rx_frames_count <= 5'b0;
			tx_frames_count <= 0;
			rx_frames <= '{NUM_FRAMES{8'h00}};
			delay_count <= 8'b0;
			uart_tx_start <= 1'b0;
			uart_transmit_data <= 8'b0;
			uart_tx_ready_edge <= 0;
			uart_tx_delay_count <= 0;
			state <= Init;
		end
	
		else begin
			case(state)
				Init		:	begin
									if (mul_enable) 
										state <= Rx_Frames;
									else 
										state <= Init;
								end
		
				Rx_Frames   :	begin
									uart_rx_valid_edge <= uart_rx_valid;
									if (~uart_rx_valid_edge & uart_rx_valid) begin
										rx_frames[rx_frames_count] <= uart_received_data;
										if (rx_frames_count == (NUM_FRAMES-1)) begin
											rx_frames_count <= 0;
											frames_received <= 1'b1;
											state <= Delay;
										end
										else
											rx_frames_count <= rx_frames_count + 1'b1;
									end
									else
										state <= Rx_Frames;
								end
								
							
				Delay   	:	begin
									if (delay_count == DELAY_TIME) begin
										delay_count <= 8'b0;
										state <= Tx_Data;
									end
									else
										delay_count <= delay_count + 1'b1;
								end
							
				Multiply    :	begin
									if (mul_ready) begin
										mul_op_prod
									end
									else
										state <= Multiply;
								end
	
				Tx_Data		:	begin
									uart_tx_ready_edge <= uart_tx_ready;
									
									if (uart_tx_ready) begin
										if ((~uart_tx_ready_edge & uart_tx_ready) == 1) begin
											uart_tx_start <= 1'b0;
											uart_transmit_data <= 0;
											if (tx_frames_count == NUM_FRAMES/2) begin
												tx_frames_count <= 0;
												state <= Finish;
											end
											else begin
												state <= Tx_Delay;
											end
										end
										
										else begin
											uart_tx_start <= 1'b1;
											uart_transmit_data <= ciphertext[tx_frames_count * 8 +: 8];
										end
									end
									
									else begin
										if ((uart_tx_ready_edge & ~uart_tx_ready) == 1) begin
											uart_tx_start <= 1'b0;
											tx_frames_count <= tx_frames_count + 1'b1;
										end
										else
											state <= Tx_Data;
									end
								end
				
				Tx_Delay	:	begin
									if (uart_tx_delay_count == UART_TX_DELAY) begin
										uart_tx_delay_count <= 0;
										state <= Tx_Data;
									end
									else
										uart_tx_delay_count <= uart_tx_delay_count + 1'b1;
								end
	
				Finish		:	state <= Init;
				default		:	state <= Init;
	
				
			endcase
		end
	end
endmodule

