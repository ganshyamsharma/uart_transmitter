module uart_tx #(parameter clk_per_bit = 10417) // equals to clk divided by baud rate 100mhz/9.6khz
(
	input i_clk, i_tx_start,
	input [7:0] i_tx_byte,
	output o_tx_busy, o_tx_done, 
	output reg o_tx_serial_data 
);
	reg [7:0] r_byte_data;
	reg [2:0] r_state = 0, r_next_state;
	reg [$clog2(10417)-1 : 0] r_clk_count;
	reg [2:0] r_bit_index;
	
	parameter s_idle = 0;
	parameter s_tx_start_bit = 1;
	parameter s_tx_data = 2;
	parameter s_tx_stop_bit = 3;
	parameter s_final = 4;
	
	always @(*) begin
		case(r_state)
			s_idle:
				begin
					r_next_state = i_tx_start ? s_tx_start_bit : s_idle;
				end
			s_tx_start_bit:
				begin
					r_next_state = (r_clk_count == clk_per_bit) ? s_tx_data : s_tx_start_bit;
				end
			s_tx_data:
				begin
					r_next_state = (r_bit_index == 7) ? s_tx_stop_bit : s_tx_data;
				end
			s_tx_stop_bit:
				begin
					r_next_state = (r_clk_count == clk_per_bit) ? s_final : s_tx_stop_bit;
				end
			default: 
				begin
					r_next_state = s_idle;
				end
		endcase
	end
	
	always @(posedge clk) begin
		r_state <= r_next_state;
		case(r_state)
			
	end
	
	assign o_tx_busy = (r_state == s_tx_start_bit) | (r_state == s_tx_data) | (r_state == s_tx_stop_bit) | (r_state == s_final);
	assign o_tx_done = (r_state == s_final);
endmodule