// UART Loopback Module
// module uart_loop_back (
// File: top.v
// This file has been updated to include the new PWM generator

module top (
    input clk,
    input uart_rx,
    output uart_tx,
    output reg [5:0] led,
    output [3:0] pwm_out  // New: 4-bit output for PWM signals
);
    wire [7:0] rxData;
    wire rxDataValid;
    reg [7:0] txData;
    reg txDataValid;
    wire txBusy;

    // UART receiver instance
    uart_rx #(
        .DELAY_FRAMES(234)
    ) uart_rx_inst (
        .clk(clk),
        .uart_rx(uart_rx),
        .rxData(rxData),
        .rxDataValid(rxDataValid)
    );

    // UART transmitter instance
    uart_tx #(
        .DELAY_FRAMES(234)
    ) uart_tx_inst (
        .clk(clk),
        .txData(txData),
        .txDataValid(txDataValid),
        .txBusy(txBusy),
        .uart_tx(uart_tx)
    );

    // New: PWM generator instance
    pwm_generator pwm_gen (
        .clk(clk),
        .pwm_out(pwm_out)
    );

    // UART loopback logic
    reg [7:0] buffer [0:255];
    reg [7:0] writePtr = 0;
    reg [7:0] readPtr = 0;
    reg sending = 0;

    always @(posedge clk) begin
        if (rxDataValid) begin
            buffer[writePtr] <= rxData;
            writePtr <= writePtr + 1;
        end

        if (!sending && writePtr != readPtr) begin
            sending <= 1;
            txData <= buffer[readPtr];
            txDataValid <= 1;
        end else if (sending) begin
            if (!txBusy) begin
                readPtr <= readPtr + 1;
                if (readPtr + 1 != writePtr) begin
                    txData <= buffer[readPtr + 1];
                    txDataValid <= 1;
                end else begin
                    sending <= 0;
                    txDataValid <= 0;
                end
            end else begin
                txDataValid <= 0;
            end
        end else begin
            txDataValid <= 0;
        end
    end

    // LED control logic
    always @(posedge clk) begin
        if (rxDataValid) 
            led <= ~rxData[5:0];
    end
endmodule