`default_nettype none

module spi_peripheral #(parameter SYNC = 2)(
    //SPI inputs
    input wire nCS, 
    input wire SCLK, 
    input wire COPI,

    //sysclk input
    input wire clk,
    input wire rst_n,        //active LOW

    //outputs
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

//internal regs
reg [3:0] sCLKcnt;
reg [15:0] data;
reg [6:0] addr;
reg [7:0] val;

reg [SYNC-1:0] sync_nCS;
reg [SYNC-1:0] sync_SCLK; 
reg [SYNC-1:0] sync_COPI;

//SPI DATA IS [R/W][ADDR 7 bit][DATA 8 bit]
//note the ADDR is by default 0x00-0x04

//Sync it using 2 bit shift registers
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        sync_nCS <= 2'b00;
        sync_SCLK <= 2'b00;
        sync_COPI <= 2'b00;
    end else begin
        sync_nCS <= {sync_nCS[SYNC-1:1], nCS};            //2'b10 is negedge
        sync_SCLK <= {sync_SCLK[SYNC-1:1], SCLK};         //note, 2'b00 is lo, 2'b01 is posedge, 2'b11 is high, 2'b10 is negedge
        sync_COPI <= {sync_COPI[SYNC-1:1], COPI};
    end
end

//take in SPI data
always @(posedge clk or negedge rst_n) begin
    if (rst_n) begin
        sCLKcnt <= 4'b0000;
        addr <= 7'b0000000;
        val <= 8'b00000000;
        data <= 0;
    end
    else begin
        if (sync_nCS == 2'b10) begin
            sCLKcnt <= 4'b0000;
        end
        else if (sync_nCS == 2'b00 && sync_SCLK == 2'b01) begin
            if (sCLKcnt != 4'b1111) begin
                data[sCLKcnt] <= sync_COPI[SYNC-1];
                sCLKcnt <= sCLKcnt + 1;
            end else begin
                addr <= data[7:1];
                val <= data[15:8];
            end
        end

    end
end

//Send it to PWM Peripheral
always@(posedge clk) begin
    case (addr) 
        7'b0000000: en_reg_out_7_0 <= val;
        7'b0000001: en_reg_out_15_8 <= val;
        7'b0000010: en_reg_pwm_7_0 <= val;
        7'b0000011: en_reg_pwm_15_8 <= val;
        7'b0000100: pwm_duty_cycle <= val;
        default: ;
         //if address isnt one of them, just dont assign anything
    endcase
end

/*
assign en_reg_out_7_0 = (addr == 7'b0000000) ? val : 8'b00000000;
assign en_reg_out_15_8 = (addr == 7'b0000001) ? val : 8'b00000000;
assign en_reg_pwm_7_0 = (addr == 7'b0000010) ? val : 8'b00000000;
assign en_reg_pwm_15_8 = (addr == 7'b0000011) ? val : 8'b00000000;
assign pwm_duty_cycle = (addr == 7'b0000100) ? val : 8'b00000000;
*/
endmodule