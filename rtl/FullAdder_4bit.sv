module FullAdder_4bit 
(
	input [3:0] a_in,
	input [3:0] b_in,
	input c_in,
	output [3:0] sum,
	output c_out_4bit_stage
);

	wire temp;
	assign {temp,sum} = a_in + b_in + {3'b0,c_in};
	
	wire [3:0] gen, prop; 
	
	assign prop = a_in ^ b_in;
	assign gen = a_in & b_in; 
	assign c_out_4bit_stage = (gen[3] | 
							  (prop[3] & gen[2]) | 
							  (prop[3] & prop[2] & gen[1]) | 
							  (prop[3] & prop[2] & prop[1] & gen[0]) | 
							  (prop[3] & prop[2] & prop[1] & prop[0] & c_in));	

endmodule
