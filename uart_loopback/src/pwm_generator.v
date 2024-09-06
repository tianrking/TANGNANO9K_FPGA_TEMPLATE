// File: pwm_generator.v
// PWM generator with auto-changing duty cycle

module pwm_generator #(
    parameter CLOCK_FREQ = 8_000_000  // 8MHz clock frequency
) (
    input clk,                // Input clock
    output reg [3:0] pwm_out  // 4-bit output for PWM signals
);

    // PWM frequency for all channels
    localparam FREQ = 1_000;  // 1kHz
    localparam COUNT_MAX = CLOCK_FREQ / FREQ;  // 8000

    reg [12:0] count = 0;  // 13 bits for 8000
    reg [6:0] duty_cycle [0:3];  // Duty cycles for 4 channels
    reg [25:0] slow_counter = 0;  // Counter for slow duty cycle change

    // Threshold calculations
    wire [12:0] thresh_1 = (COUNT_MAX * duty_cycle[0]) / 100;
    wire [12:0] thresh_2 = (COUNT_MAX * duty_cycle[1]) / 100;
    wire [12:0] thresh_3 = (COUNT_MAX * duty_cycle[2]) / 100;
    wire [12:0] thresh_4 = (COUNT_MAX * duty_cycle[3]) / 100;

    initial begin
        duty_cycle[0] = 0;
        duty_cycle[1] = 25;
        duty_cycle[2] = 50;
        duty_cycle[3] = 75;
    end

    always @(posedge clk) begin
        // PWM generation
        if (count < COUNT_MAX - 1) 
            count <= count + 1;
        else 
            count <= 0;

        pwm_out[0] <= (count < thresh_1) ? 1'b1 : 1'b0;
        pwm_out[1] <= (count < thresh_2) ? 1'b1 : 1'b0;
        pwm_out[2] <= (count < thresh_3) ? 1'b1 : 1'b0;
        pwm_out[3] <= (count < thresh_4) ? 1'b1 : 1'b0;

        // Slow counter for duty cycle change
        slow_counter <= slow_counter + 1;

        // Change duty cycles every ~1 second
        if (slow_counter == 0) begin
            duty_cycle[0] <= (duty_cycle[0] + 1) % 101;
            duty_cycle[1] <= (duty_cycle[1] + 2) % 101;
            duty_cycle[2] <= (duty_cycle[2] + 3) % 101;
            duty_cycle[3] <= (duty_cycle[3] + 4) % 101;
        end
    end

endmodule