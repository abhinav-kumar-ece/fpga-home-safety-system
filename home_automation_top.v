// =============================================================
// FPGA Based Home Safety and Automation System
// Top-level module and sub-modules
// Target Device: Xilinx Spartan-7 (XC7S50-CSGA324)
// Tool: Xilinx Vivado
// =============================================================

module home_automation_top (
    input clk,
    // Sensors
    input gas_detect,
    input fire_detect,
    input water_sensor,
    input mq135_d0,
    inout dht11,
    // Inputs
    input [15:0] sw,
    input [3:0] btn,
    // Outputs
    output led_gas,
    output led_fire,
    output led_water_low,
    output led_water_high,
    output door_led,
    output led_air,
    output led_L,
    output led_N,
    output led_H,
    output combined_buzzer,
    output motor,
    output servo0,
    // Display
    output [7:0] D0_SEG,
    output [7:0] D1_SEG,
    output [3:0] D0_AN,
    output [3:0] D1_AN
);

    //////////////// ALERT LOGIC ////////////////
    wire gas_alert   = (~gas_detect)  & ~weather_mode;
    wire fire_alert  = (~fire_detect) & ~weather_mode;
    wire water_alert = (water_sensor) & ~weather_mode;
    wire air_alert   = (~mq135_d0)    & ~weather_mode;

endmodule


// =============================================================
// Gas Leak Detection & Alert Module
// =============================================================
module gas_leak_system (
    input clk,
    input gas_detect,
    output reg led,
    output reg buzzer,
    output reg [7:0] D0_SEG,
    output reg [7:0] D1_SEG,
    output reg [3:0] D0_AN,
    output reg [3:0] D1_AN
);
    always @(*) begin
        if (gas_leak) begin
            led = 1;
            buzzer = 0;
            case(digit)
                3'd0: begin D0_AN = 4'b0111; D0_SEG = 8'b10000010; end
                3'd1: begin D0_AN = 4'b1011; D0_SEG = 8'b10001000; end
                3'd2: begin D0_AN = 4'b1101; D0_SEG = 8'b10010010; end
            endcase
        end
    end
endmodule


// =============================================================
// Flame Detection & Fire Alarm Module
// =============================================================
module fire_alarm_top (
    input wire clk,
    input wire fire_detect,
    output reg fire_led,
    output reg buzzer,
    output reg [7:0] D0_SEG,
    output reg [7:0] D1_SEG,
    output reg [3:0] D0_AN,
    output reg [3:0] D1_AN
);
    always @(posedge clk) begin
        if (fire_detect == 1'b0) begin
            // Fire detected
            fire_led <= 1'b1;
            buzzer   <= 1'b0;
        end
    end

    always @(*) begin
        if (fire_led) begin
            case(digit)
                3'd0: begin D0_AN = 4'b0111; D0_SEG = 8'b10001110; end
                3'd1: begin D0_AN = 4'b1011; D0_SEG = 8'b11001111; end
                3'd2: begin D0_AN = 4'b1101; D0_SEG = 8'b10001000; end
                3'd3: begin D0_AN = 4'b1110; D0_SEG = 8'b10000110; end
            endcase
        end
    end
endmodule


// =============================================================
// Water Level Detection & Motor Control Module
// =============================================================
module water_level_display (
    input clk,
    input water_sensor,
    output reg motor,
    output reg buzzer,
    output reg led_low,
    output reg led_high,
    output reg [7:0] D0_SEG,
    output reg [7:0] D1_SEG,
    output reg [3:0] D0_AN,
    output reg [3:0] D1_AN
);
    always @(posedge clk) begin
        if (water_sensor) begin
            motor    <= 0;
            buzzer   <= 0;
            led_high <= 1;
            led_low  <= 0;
        end else begin
            motor    <= 1;
            buzzer   <= 1;
            led_low  <= 1;
            led_high <= 0;
        end
    end

    always @(*) begin
        case(digit)
            3'd0: begin D0_AN = 4'b0111; D0_SEG = 8'b10001000; end
            3'd1: begin D0_AN = 4'b1011; D0_SEG = 8'b01000000; end
            3'd2: begin D0_AN = 4'b1101; D0_SEG = 8'b11000001; end
            3'd3: begin D0_AN = 4'b1110; D0_SEG = 8'b10001000; end
            3'd4: begin D1_AN = 4'b0111; D1_SEG = 8'b10001001; end
            3'd5: begin D1_AN = 4'b1011; D1_SEG = 8'b11001111; end
            3'd6: begin D1_AN = 4'b1101; D1_SEG = 8'b10000010; end
            3'd7: begin D1_AN = 4'b1110; D1_SEG = 8'b10001001; end
        endcase
    end
endmodule


// =============================================================
// Password Based Smart Door Lock Module
// =============================================================
module door_lock_top (
    input clk,
    input [15:0] sw,
    input [2:0] btn,
    output reg led,
    output reg servo0,
    output reg [7:0] D0_SEG,
    output reg [7:0] D1_SEG,
    output reg [3:0] D0_AN,
    output reg [3:0] D1_AN
);
    always @(*) begin
        if (door_open) begin
            case(digit)
                3'd0: begin D0_AN = 4'b0111; D0_SEG = 8'b11000000; end
                3'd1: begin D0_AN = 4'b1011; D0_SEG = 8'b11000000; end
                3'd2: begin D0_AN = 4'b1101; D0_SEG = 8'b11000000; end
                3'd3: begin D0_AN = 4'b1110; D0_SEG = 8'b10001000; end
                3'd4: begin D1_AN = 4'b0111; D1_SEG = 8'b11000000; end
                3'd5: begin D1_AN = 4'b1011; D1_SEG = 8'b10001100; end
                3'd6: begin D1_AN = 4'b1101; D1_SEG = 8'b10000110; end
                3'd7: begin D1_AN = 4'b1110; D1_SEG = 8'b10001000; end
            endcase
        end
    end
endmodule


// =============================================================
// Air Quality Detection Module
// =============================================================
module air_quality_checker (
    input clk,
    input reset,
    input mq135_d0,
    output reg led_air,
    output reg air_buzzer
);
    always @(posedge clk) begin
        D0_AN = 4'b1111;
        D1_AN = 4'b1111;
        D0_SEG = 8'b11111111;
        D1_SEG = 8'b11111111;
        led_air = 0;
        air_buzzer = 1;
        // BAD AIR DETECTED WHEN SENSOR = 1
        if (~mq135_d0) begin
            led_air = 1;
            air_buzzer = 0;
        end
    end
endmodule


// =============================================================
// Weather (Temperature & Humidity) Top Module
// =============================================================
module weather_top (
    input clk,
    input btn0, // reset
    input btn1, // toggle temp/hum
    inout dht11,
    output [7:0] D0_SEG,
    output [3:0] D0_AN,
    output led_L,
    output led_N,
    output led_H
);
    seven_seg_display display_unit (
        .clk(clk),
        .btn_toggle(btn1),
        .temp(temperature),
        .hum(humidity),
        .seg(D0_SEG),
        .an(D0_AN),
        .led_L(led_L),
        .led_N(led_N),
        .led_H(led_H)
    );
endmodule


// =============================================================
// DHT11 Temperature & Humidity Sensor Controller
// =============================================================
module dht11_controller (
    input clk,
    input rst,
    input enable,
    inout dht,
    output reg [39:0] data,
    output reg done
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            timer <= 0;
            bit_count <= 0;
            data <= 0;
        end else if (us_tick) begin
            // timing state machine
        end
    end
endmodule


// =============================================================
// Seven Segment Display Driver (Temperature / Humidity)
// =============================================================
module seven_seg_display (
    input clk,
    input btn_toggle,
    input enable,
    input [7:0] temp,
    input [7:0] hum,
    output reg [7:0] seg,
    output reg [3:0] an,
    output reg led_L,
    output reg led_N,
    output reg led_H
);
    always @(*) begin
        led_L = 0;
        led_N = 0;
        led_H = 0;
        symbol = 7'b1111111;
        if (enable) begin
            if (temp < 20) begin
                symbol = 7'b1000111; led_L = 1;
            end
            else if (temp <= 30) begin
                symbol = 7'b0101011; led_N = 1;
            end
            else begin
                symbol = 7'b0001001; led_H = 1;
            end
        end
    end
endmodule
