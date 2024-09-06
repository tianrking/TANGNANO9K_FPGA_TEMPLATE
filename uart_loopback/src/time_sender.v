// File: time_sender.v
// Module to send alternating 1 and 0 every 200ms

module time_sender #(
    parameter CLOCK_FREQ = 8_000_000  // 8MHz clock frequency
) (
    input wire clk,
    output reg uart_tx,
    output reg current_bit
);

    // UART parameters
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD = CLOCK_FREQ / BAUD_RATE;

    // 200ms period
    localparam SEND_PERIOD = CLOCK_FREQ / 5;  // 200ms = 1/5 second

    // States
    localparam IDLE = 2'd0;
    localparam SENDING = 2'd1;
    localparam WAIT = 2'd2;

    reg [1:0] state = IDLE;
    reg [31:0] period_counter = 0;
    reg [3:0] bit_counter = 0;
    reg [15:0] tx_timer = 0;

    initial begin
        current_bit = 1;  // Start with 1
        uart_tx = 1;      // Idle high
    end

    always @(posedge clk) begin
        // Increment period counter
        if (period_counter == SEND_PERIOD - 1) begin
            period_counter <= 0;
            current_bit <= ~current_bit;  // Toggle the bit
        end else begin
            period_counter <= period_counter + 1;
        end

        case (state)
            IDLE: begin
                uart_tx <= 1; // Idle high
                if (period_counter == 0) begin
                    state <= SENDING;
                    bit_counter <= 0;
                    tx_timer <= 0;
                end
            end

            SENDING: begin
                tx_timer <= tx_timer + 1;
                if (tx_timer == 0) begin
                    case (bit_counter)
                        0: uart_tx <= 0;  // Start bit
                        1: uart_tx <= current_bit;  // Data bit (1 or 0)
                        2, 3, 4, 5, 6, 7, 8: uart_tx <= 0;  // Padding with zeros
                        9: uart_tx <= 1;  // Stop bit
                    endcase

                    if (bit_counter == 9) begin
                        state <= WAIT;
                        bit_counter <= 0;
                    end else
                        bit_counter <= bit_counter + 1;
                end
                if (tx_timer == BIT_PERIOD - 1)
                    tx_timer <= 0;
            end

            WAIT: begin
                uart_tx <= 1; // Idle high
                if (period_counter == SEND_PERIOD/2 - 1) begin // Wait for the rest of the 200ms period
                    state <= IDLE;
                end
            end
        endcase
    end

endmodule