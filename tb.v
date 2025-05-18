module uart_tx_tb();

    reg i_clk_tb, i_tx_start_tb;
	reg [7:0] i_tx_byte_tb;
    wire o_tx_busy_tb, o_tx_done_tb, o_tx_serial_data_tb;
    
    uart_tx uut0(i_clk_tb, i_tx_start_tb, i_tx_byte_tb, o_tx_busy_tb, o_tx_done_tb, o_tx_serial_data_tb);
    
    always #5 i_clk_tb = ~i_clk_tb;
    initial begin
        i_clk_tb = 1'b0;
        i_tx_byte_tb = 8'd212;
        i_tx_start_tb = 1'b0;
        #100
        i_tx_start_tb = 1'b1;
        #200000
        i_tx_byte_tb = 8'd5;
    end
endmodule