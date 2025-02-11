/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_multiplier (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  // i4bit_mul uut (
	// .a(ui_in[3:0]),
	// .b(ui_in[7:4]),
	// .s(uo_out[7:0])
	// );
	
	i8bit_mul uut
	(
		.mul_ip_A(ui_in[7:0]),
		.mul_ip_B(uio_in[7:0]),
		.prod_low(uo_out[7:0]),
		.prod_high(uio_out[7:0])
	);
	
  // assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule
