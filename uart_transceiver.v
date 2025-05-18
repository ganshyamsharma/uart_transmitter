module uart_tx #(parameter clk_per_bit = 10417) // equals to clk divided by baud rate 100mhz/9.6khz
(
	input i_clk, i_tx_start,
	input [7:0] i_tx_byte,
	output o_tx_busy, o_tx_done, 
	output reg o_tx_serial_data 
);
	reg [7:0] r_byte_data;
	reg [2:0] r_state = 0, r_next_state;
	reg [$clog2(clk_per_bit)-1 : 0] r_clk_count = 0;
	reg [3:0] r_bit_index = 0;
	
	parameter s_idle = 3'd0;
	parameter s_tx_start_bit = 3'd1;
	parameter s_tx_data = 3'd2;
	parameter s_tx_stop_bit = 3'd3;
	parameter s_final = 3'd4;
	///////////////////////////////////////	State Transition Logic	/////////////////////////////////
	always @(*) begin
		case(r_state)
			s_idle:
				begin
					r_next_state = i_tx_start ? s_tx_start_bit : s_idle;
				end
			s_tx_start_bit:
				begin
					r_next_state = (r_clk_count == clk_per_bit-1) ? s_tx_data : s_tx_start_bit;
				end
			s_tx_data:
				begin
					r_next_state = (r_bit_index == 8) ? s_tx_stop_bit : s_tx_data;
				end
			s_tx_stop_bit:
				begin
					r_next_state = (r_clk_count == clk_per_bit-1) ? s_final : s_tx_stop_bit;
				end
			s_final:
				begin
					r_next_state = s_idle;
				end
			default: 
				begin
					r_next_state = s_idle;
				end
		endcase
	end
	///////////////////////////////////////	
	always @(posedge i_clk) begin
		r_state <= r_next_state;
		case(r_state)
			s_tx_start_bit:
				begin	
				    o_tx_serial_data <= 1'b0;	
				    r_byte_data <= i_tx_byte;								
					if(r_clk_count == clk_per_bit-1) begin
						r_clk_count <= 0;					
					end
					else
						r_clk_count <= r_clk_count + 1;
				end
			s_tx_data:
				begin
					if(r_bit_index < 8) begin
						if(r_clk_count == clk_per_bit-1) begin
							r_bit_index <= r_bit_index + 1;
							r_clk_count <= 0;
						end
						else begin
							r_clk_count <= r_clk_count + 1;
							o_tx_serial_data <= r_byte_data[r_bit_index];
						end
					end
					else
						r_bit_index <= 0;	
				end
			s_tx_stop_bit:
				begin
					o_tx_serial_data <= 1;
					if(r_clk_count == clk_per_bit-1)
						r_clk_count <= 0;
					else
						r_clk_count <= r_clk_count + 1;
				end
	endcase
	end
	//////////////////////////////////////	State Outputs	/////////////////////////////////////////////////
	
	assign o_tx_busy = (r_state == s_tx_start_bit) | (r_state == s_tx_data) | (r_state == s_tx_stop_bit) | (r_state == s_final);
	assign o_tx_done = (r_state == s_final);
	
endmodule