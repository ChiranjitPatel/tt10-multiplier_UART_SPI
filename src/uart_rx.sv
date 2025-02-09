//--------------------------------------------------------------------------------------------------------------------------------------------------
// Company:			NUS
// Engineer:		Vivek Adi (email : vivek.adishesha@u.nus.edu ) 
// 
// Creation Date: 	(c) 2024 NUS
// Design Name:		System Verilog Logic of UART-Protocol Receiver 
// Module Name: 	uart_rx - Behavioral
// Project Name: 	MRAM Statistical Data Collection
// Target Devices: 	AMD Zedboard ZYNQ (ZED) - Xilinx XC7Z020-1CSG484CES EPP
// Tool Versions: 	AMD Vivado 2024.1
// Description: 	
// Dependencies: 	
// Revision:		Revision 0.01 - File Created
// Comments:
//--------------------------------------------------------------------------------------------------------------------------------------------------
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

`timescale 1ns / 1ps

module uart_rx  
	#(	parameter [23:0] baud_rate = 24'd4000000, 
		parameter [27:0]clock_freq = 28'd100000000 
	)
	(	uart_clock, uart_reset, uart_d_in, 
		uart_d_out, uart_valid 				
	);
	
	input  logic		uart_clock;
	input  logic		uart_reset;
	input  logic		uart_d_in;
	output logic[7:0] 	uart_d_out;
	output logic		uart_valid;
	
	// localparam [19:0]	pulse_duration			=	clock_freq / baud_rate /2; // Divide by two to get the 52us delay, or total time
	localparam [23:0]	pulse_duration			=	clock_freq / baud_rate;	// Delay for each bit TX, No need to divide by 2.
	localparam [23:0]	half_pulse_duration		=	pulse_duration / 2; // Delay of pulse is half of the frequency
	localparam [3:0]	start_data_stop_width	=	4'd10;

	logic [23:0] clk_count;
	logic [23:0] clk_count_half;
	logic [3:0]  total_count;
	
	logic [start_data_stop_width-1:0] 	data_buffer;
	logic [1:0] 						edge_detect_reg;
	
	typedef enum logic [1:0] {Init, Start_Read, Read_Data, Finish} state_machine;
	state_machine state;
	
	always_ff @(posedge uart_clock, negedge uart_reset)	begin
		if(!uart_reset) begin
			state				<=	Init;
			data_buffer 		<=	10'b0;
			edge_detect_reg 	<=	2'b0;
			clk_count_half		<=	24'b0;
			clk_count			<=	24'b0;
			total_count			<=	4'b0;
			uart_valid			<=	1'b0;
			uart_d_out			<=	8'b0;
			
		end
		else begin
			case(state)
				Init		:	begin
									clk_count_half	<=	24'b0;
									clk_count		<=	24'b0;
									edge_detect_reg[0] <= ~uart_d_in;
									edge_detect_reg[1] <= ~edge_detect_reg[0];
									if ((edge_detect_reg[0] & edge_detect_reg[1]) == 1) begin
										state <=	Start_Read;
									end
									else begin
										state <=	Init;
									end
								end
								
				Start_Read	:	begin
									uart_valid <= 1'b0;
									if (clk_count_half == half_pulse_duration-1'b1) begin
										clk_count_half <= 24'b0;
										state <= Read_Data;
									end
									
									else begin
										clk_count_half <= clk_count_half  + 1'b1;
										clk_count <= clk_count + 1'b1;
										state <= Start_Read;
									end
								end
				
				Read_Data	:	begin	
									if (total_count == start_data_stop_width-1'b1) begin
										total_count <= 4'b0;
										state <= Finish;
									end
									else if (clk_count == pulse_duration-1'b1) begin
										clk_count <= 24'b0;
										total_count	<= total_count + 1'b1;
										data_buffer <= {uart_d_in, data_buffer[9:1]}; 
										state <= Start_Read;
									end
									else begin
										clk_count <= clk_count+ 1'b1;
										state <= Read_Data;
									end
								end
							
				Finish		:	begin
									uart_valid <= 1'b1;
									uart_d_out <= data_buffer[8:1];
									if ((edge_detect_reg[0] & edge_detect_reg[1]) == 1)
										state <= Start_Read;
									else
										state <= Init;
								end
				
				default		:	state <= Init;
			endcase
		end
	end
	
endmodule

