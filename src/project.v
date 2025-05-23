/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_uwasic_onboarding_samuel_zhang (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path //dataout
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset //active low
);

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = out[7:0];
  assign uio_out = out[15:8];
  assign uio_oe  = 0;

  //for connecting SPI Peripherial to PWM
     wire [7:0] en_reg_out_7_0;
     wire [7:0] en_reg_out_15_8;
     wire [7:0] en_reg_pwm_7_0;
     wire [7:0] en_reg_pwm_15_8;
     wire [7:0] pwm_duty_cycle;
  //other outputs
     wire [15:0] out;

/*
    input nCS, 
    input SCLK, 
    input COPI,

    //sysclk input
    input clk,
    input rst_n,        //active LOW

    //outputs
    output wire [7:0] en_reg_out_7_0,
    output wire [7:0] en_reg_out_15_8,
    output wire [7:0] en_reg_pwm_7_0,
    output wire [7:0] en_reg_pwm_15_8,
    output wire [7:0] pwm_duty_cycle
*/
  spi_peripheral spiPeriObj(
    .nCS(ui_in[2]),
    .COPI(ui_in[1]),
    .SCLK(ui_in[0]),

    .clk(clk),
    .rst_n(rst_n),
    .en_reg_out_7_0(en_reg_out_7_0),
    .en_reg_out_15_8(en_reg_out_15_8),
    .en_reg_pwm_7_0(en_reg_pwm_7_0),
    .en_reg_pwm_15_8(en_reg_pwm_15_8),
    .pwm_duty_cycle(pwm_duty_cycle)
  );

  pwm_peripheral pwmObj(
    .clk(clk),
    .rst_n(rst_n),

    .en_reg_out_7_0(en_reg_out_7_0),
    .en_reg_out_15_8(en_reg_out_15_8),
    .en_reg_pwm_7_0(en_reg_pwm_7_0),
    .en_reg_pwm_15_8(en_reg_pwm_15_8),
    .pwm_duty_cycle(pwm_duty_cycle),

    .out(out)
  );

  

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:3], uio_oe, uio_in, 1'b0};

endmodule
