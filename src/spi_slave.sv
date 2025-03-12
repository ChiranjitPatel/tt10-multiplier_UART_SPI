// `timescale 1ns/1ps

module spi_slave (
    clk,           
    reset,
	spi_start,
	// miso_reg_data,
    mosi, 	
    cs_bar,       
    sclk,
	miso,	
    // mosi_reg_data,
    rx_valid,
	tx_done
);

	// I/o
	input	logic clk;           				// Internal clock
	input	logic reset;		
	input 	logic spi_start;       				// rx_start spi transfer
	// input 	logic [15:0] miso_reg_data; 		// 16-bit register mosi_reg_data write into slave
	input	logic mosi;        					// master In, Slave Out (Data from the ADC)
	input	logic cs_bar;       				// chip select, active low (to the ADC)
	input	logic sclk;         				// spi clock - 10 MHz
	output 	logic miso;         				// spi mosi_reg_data out - ADC mosi_reg_data in
	// output	logic [15:0] mosi_reg_data;  		// mosi_reg_data 
	output	logic rx_valid;         			// mosi_reg_data rx valid signal
	output 	logic tx_done;         				// spi tx completed flag
	

    // Param
    // localparam integer WAIT_BITS = $clog2(2**6);
    localparam integer DATA_WIDTH = 16; 							// 32-bit SPI frame
    localparam integer DATA_WIDTH_BITS = $clog2(DATA_WIDTH); 		// 32-bit SPI frame
	
	// Reg
    logic [DATA_WIDTH-1:0] rx_shift_reg;
    logic [DATA_WIDTH-1:0] tx_shift_reg;
    logic [DATA_WIDTH_BITS:0] rx_bit_cnt; 							// 6-bit to count 32 bits
    logic [DATA_WIDTH_BITS:0] tx_bit_cnt; 							// 6-bit to count 32 bits
    logic sclk_drive_edge;
    logic rx_state_flag;
    logic tx_state_flag;
	
	// State
    typedef enum logic [1:0] {IDLE, TRANSFER, FINISH, WAIT_NEXT} state_t;
    state_t state;

	// State Machine
    always_ff @(posedge clk or negedge reset) begin
        if (~reset) begin
            rx_bit_cnt <= 0;
            tx_bit_cnt <= 0;
            rx_shift_reg <= 0;
            tx_shift_reg <= 0;
            rx_valid <= 0;
			tx_done <= 0;
			rx_state_flag <= 0;
			tx_state_flag <= 0;
			// mosi_reg_data <= 0;
			miso <= 0;
			sclk_drive_edge <= sclk;
			state <= IDLE;
        end
		
		else begin
			case (state)
				IDLE: 		begin
								if (spi_start & cs_bar) begin		
									rx_bit_cnt <= 0;
									tx_bit_cnt <= 0;
									rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], mosi};
									tx_shift_reg <= rx_shift_reg;
									rx_valid <= 0;
									tx_done <= 0;
									rx_state_flag <= 0;
									tx_state_flag <= 0;
									sclk_drive_edge <= sclk;
									state <= TRANSFER;
								end
								else begin
									state <= IDLE;
								end
							end

				TRANSFER: 	begin		
								rx_valid <= 0;
								tx_done <= 0;
								
								sclk_drive_edge <= sclk;
								if (~sclk_drive_edge & sclk) begin
									if (tx_bit_cnt == DATA_WIDTH) begin
										tx_bit_cnt <= 0;
										tx_state_flag <= 1;
									end 
									else begin
										tx_bit_cnt <= tx_bit_cnt + 1;
										// tx_shift_reg <= miso_reg_data;
										miso <= tx_shift_reg[(DATA_WIDTH - 1) - tx_bit_cnt]; // Load out miso_reg_data Tx
										tx_state_flag <= 0;					
									end
								end
					
								else if (sclk_drive_edge & ~sclk) begin
									if (rx_bit_cnt == DATA_WIDTH) begin
										rx_bit_cnt <= 0;
										rx_state_flag <= 1;
									end
									else begin
										rx_bit_cnt <= rx_bit_cnt + 1;
										rx_shift_reg <= {rx_shift_reg[DATA_WIDTH-2:0], mosi}; // Shift in mosi_reg_data Rx
										rx_state_flag <= 0;
									end
								end
								
								if (rx_state_flag | tx_state_flag) begin
									miso <= 0;
									rx_state_flag <= 0;
									tx_state_flag <= 0;
									rx_valid <= 1;
									tx_done <= 1;
									state <= FINISH;
								end
								else begin
									state <= TRANSFER;
								end	
							end

				FINISH: 	begin
								// mosi_reg_data <= rx_shift_reg[DATA_WIDTH-1:0];
								tx_shift_reg <= 0;
								state <= WAIT_NEXT;
							end				

				default: 	state <= IDLE;
			endcase
		end
    end
endmodule
