// UART Transmitter Module
module uart_tx #(
    parameter DELAY_FRAMES = 234 // 27,000,000 (27Mhz) / 115200 Baud rate  
) (
    input clk,
    input [7:0] txData,
    input txDataValid,
    output reg txBusy,
    output reg uart_tx
);
    reg [3:0] txState = 0;
    reg [24:0] txCounter = 0;
    reg [2:0] txBitNumber = 0;
    localparam TX_STATE_IDLE = 0;
    localparam TX_STATE_START_BIT = 1;
    localparam TX_STATE_WRITE = 2;
    localparam TX_STATE_STOP_BIT = 3;
        
    always @(posedge clk) begin
        case (txState)
            TX_STATE_IDLE: begin
                uart_tx <= 1;
                txBusy <= 0;
                if (txDataValid) begin
                    txState <= TX_STATE_START_BIT;
                    txCounter <= 0;
                    txBusy <= 1;
                end
            end
            TX_STATE_START_BIT: begin
                uart_tx <= 0;
                if (txCounter == DELAY_FRAMES - 1) begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= 0;
                    txCounter <= 0;
                end else
                    txCounter <= txCounter + 1;
            end
            TX_STATE_WRITE: begin
                uart_tx <= txData[txBitNumber];
                if (txCounter == DELAY_FRAMES - 1) begin
                    if (txBitNumber == 3'b111) begin
                        txState <= TX_STATE_STOP_BIT;
                    end else begin
                        txState <= TX_STATE_WRITE;
                        txBitNumber <= txBitNumber + 1;
                    end
                    txCounter <= 0;
                end else
                    txCounter <= txCounter + 1;
            end        
            TX_STATE_STOP_BIT: begin
                uart_tx <= 1;
                if (txCounter == DELAY_FRAMES - 1) begin
                    txState <= TX_STATE_IDLE;
                end else
                    txCounter <= txCounter + 1; 
            end
        endcase
    end
endmodule