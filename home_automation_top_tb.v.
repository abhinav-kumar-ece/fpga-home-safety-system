`timescale 1ns / 1ps
// =============================================================
// Testbench for FPGA Based Home Safety and Automation System
// =============================================================

module home_automation_top_tb;

    reg clk;
    reg gas_detect;
    reg fire_detect;
    reg water_sensor;
    reg mq135_d0;
    reg [15:0] sw;
    reg [3:0] btn;

    wire led_gas;
    wire led_fire;
    wire led_water_low;
    wire led_water_high;
    wire door_led;
    wire led_air;
    wire combined_buzzer;
    wire motor;
    wire servo0;

    // DUT
    home_automation_top uut (
        .clk(clk),
        .gas_detect(gas_detect),
        .fire_detect(fire_detect),
        .water_sensor(water_sensor),
        .mq135_d0(mq135_d0),
        .sw(sw),
        .btn(btn),
        .led_gas(led_gas),
        .led_fire(led_fire),
        .led_water_low(led_water_low),
        .led_water_high(led_water_high),
        .door_led(door_led),
        .led_air(led_air),
        .combined_buzzer(combined_buzzer)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        gas_detect = 0;
        fire_detect = 0;
        water_sensor = 0;
        mq135_d0 = 0;
        sw = 0;
        btn = 0;
        #200;

        // ======= door -> lock -> unlock =======
        btn[0] = 1;
        #50;
        btn[0] = 0;
        #100;

        // SET PASSWORD = 25
        sw[7:0] = 8'd25;
        btn[1] = 1;
        #20;
        btn[1] = 0;
        #200;

        // CORRECT PASSWORD CHECK
        #20;
        btn[2] = 0;
        #300;

        // WRONG PASSWORD CHECK
        sw[15:8] = 8'd10;
        btn[2] = 1;
        #20;
        #300;
    end

endmodule
