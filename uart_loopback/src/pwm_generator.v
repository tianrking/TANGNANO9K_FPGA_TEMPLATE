module pwm_generator (
    input clk,
    output reg [3:0] pwm_out
);

    localparam TARGET_FREQ = 100_000;  // PWM frequency of 100 kHz
    localparam CLOCK_FREQ = 27_000_000;
    localparam COUNT_MAX = CLOCK_FREQ / TARGET_FREQ - 1;
    
    reg [7:0] count = 0;  // Adjusted size for 100 kHz PWM
    reg [6:0] duty_cycle [0:3];
    reg [14:0] slow_counter = 0;  // Adjusted size for 1 kHz update rate

    wire [7:0] thresh_1 = (COUNT_MAX * duty_cycle[0]) / 100;
    wire [7:0] thresh_2 = (COUNT_MAX * duty_cycle[1]) / 100;
    wire [7:0] thresh_3 = (COUNT_MAX * duty_cycle[2]) / 100;
    wire [7:0] thresh_4 = (COUNT_MAX * duty_cycle[3]) / 100;
           
    initial begin
        duty_cycle[0] = 0;
        duty_cycle[1] = 25;
        duty_cycle[2] = 50;
        duty_cycle[3] = 75;
    end

    always @(posedge clk) begin
        if (count < COUNT_MAX)
            count <= count + 1;
        else
            count <= 0;
        
        pwm_out[0] <= (count < thresh_1);
        pwm_out[1] <= (count < thresh_2);
        pwm_out[2] <= (count < thresh_3);
        pwm_out[3] <= (count < thresh_4);

        slow_counter <= slow_counter + 1;
        if (slow_counter == 27_000 - 1) begin  // Update duty cycle at 1 kHz
            duty_cycle[0] <= (duty_cycle[0] + 1) % 101;
            duty_cycle[1] <= (duty_cycle[1] + 2) % 101;
            duty_cycle[2] <= (duty_cycle[2] + 3) % 101;
            duty_cycle[3] <= (duty_cycle[3] + 4) % 101;
            slow_counter <= 0;
        end
    end
endmodule