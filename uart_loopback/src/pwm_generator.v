// File: pwm_generator.v
// This is a new file added to the project

module pwm_generator #(
    parameter CLOCK_FREQ = 27_000_000  // 27MHz clock frequency
) (
    input clk,                // Input clock
    output reg [3:0] pwm_out  // 4-bit output for PWM signals
);

    // Parameters for each PWM channel
    localparam [31:0] FREQ_1 = 1_000;     // 1kHz
    localparam [31:0] FREQ_2 = 10_000;    // 10kHz
    localparam [31:0] FREQ_3 = 100_000;   // 100kHz
    localparam [31:0] FREQ_4 = 200_000;   // 200kHz
    
    localparam [7:0] DUTY_1 = 10;  // 10% duty cycle
    localparam [7:0] DUTY_2 = 20;  // 20% duty cycle
    localparam [7:0] DUTY_3 = 30;  // 30% duty cycle
    localparam [7:0] DUTY_4 = 40;  // 40% duty cycle

    // Calculate counter max values for each frequency
    localparam [31:0] COUNT_MAX_1 = CLOCK_FREQ / FREQ_1;
    localparam [31:0] COUNT_MAX_2 = CLOCK_FREQ / FREQ_2;
    localparam [31:0] COUNT_MAX_3 = CLOCK_FREQ / FREQ_3;
    localparam [31:0] COUNT_MAX_4 = CLOCK_FREQ / FREQ_4;

    // Calculate duty cycle thresholds
    localparam [31:0] THRESH_1 = COUNT_MAX_1 * DUTY_1 / 100;
    localparam [31:0] THRESH_2 = COUNT_MAX_2 * DUTY_2 / 100;
    localparam [31:0] THRESH_3 = COUNT_MAX_3 * DUTY_3 / 100;
    localparam [31:0] THRESH_4 = COUNT_MAX_4 * DUTY_4 / 100;

    // Counters for each PWM channel
    reg [31:0] count_1 = 0;
    reg [31:0] count_2 = 0;
    reg [31:0] count_3 = 0;
    reg [31:0] count_4 = 0;

    always @(posedge clk) begin
        // PWM 1: 1kHz, 10% duty cycle
        if (count_1 < COUNT_MAX_1 - 1) 
            count_1 <= count_1 + 1;
        else 
            count_1 <= 0;
        pwm_out[0] <= (count_1 < THRESH_1) ? 1'b1 : 1'b0;

        // PWM 2: 10kHz, 20% duty cycle
        if (count_2 < COUNT_MAX_2 - 1) 
            count_2 <= count_2 + 1;
        else 
            count_2 <= 0;
        pwm_out[1] <= (count_2 < THRESH_2) ? 1'b1 : 1'b0;

        // PWM 3: 100kHz, 30% duty cycle
        if (count_3 < COUNT_MAX_3 - 1) 
            count_3 <= count_3 + 1;
        else 
            count_3 <= 0;
        pwm_out[2] <= (count_3 < THRESH_3) ? 1'b1 : 1'b0;

        // PWM 4: 200kHz, 40% duty cycle
        if (count_4 < COUNT_MAX_4 - 1) 
            count_4 <= count_4 + 1;
        else 
            count_4 <= 0;
        pwm_out[3] <= (count_4 < THRESH_4) ? 1'b1 : 1'b0;
    end

endmodule