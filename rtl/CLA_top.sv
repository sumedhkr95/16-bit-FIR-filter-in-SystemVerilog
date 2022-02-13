module CLA_top #(parameter size=16) //size needs to be multiple of 4
(
input clk,
input reset,

input logic [size-1:0] a,
output logic [size-1+2:0] s //final sum will have 2 extra bits due to carry coming from previous stages 
);

logic [size-1:0] lvl_1, lvl_2, lvl_3, lvl_4; //same size as data_in
logic [size-1:0] lvl_1_2_sum, lvl_3_4_sum; //same size as data_in
logic [(size/4):0] lvl_1_2_cin, lvl_3_4_cin; //5 bits as we have 4x 4-bit stages 
logic [size-1+4:0] lvl_1_2_sum_cin, lvl_3_4_sum_cin; //expand 4-tap adder inputs to 20-bit to handle overflow
logic [(size/4)+1:0] lvl_1_4_cin; //6 bits as we have 5x 4-bit stages
logic [size-1+4:0] final_sum_loc; //expand 4-tap adder output to 20-bit to handle overflow

/*
Adder loop
*/
assign lvl_1_2_cin[0] = 1'b0; //set initial carry input to zero
assign lvl_3_4_cin[0] = 1'b0; //set initial carry input to zero
genvar i;
generate //{
	for (i=0; i<(size/4); i++)
	begin : adder_generating_logic_2_taps_each //{
		
		FullAdder_4bit fa_4bit_1_2
		( //{
			.a_in (lvl_1[(4*i)+3:(i*4)]),
			.b_in (lvl_2[(4*i)+3:(i*4)]),
			.c_in (lvl_1_2_cin[i]),
			.sum  (lvl_1_2_sum[(4*i)+3:(i*4)]),
			.c_out_4bit_stage (lvl_1_2_cin[i+1]) 
		); //}
		
		FullAdder_4bit fa_4bit_3_4
		( //{
			.a_in (lvl_3[(4*i)+3:(i*4)]),
			.b_in (lvl_4[(4*i)+3:(i*4)]),
			.c_in (lvl_3_4_cin[i]),
			.sum  (lvl_3_4_sum[(4*i)+3:(i*4)]),
			.c_out_4bit_stage (lvl_3_4_cin[i+1]) 
		); //}
			
	end //}
endgenerate //}

assign lvl_1_2_sum_cin = {3'b0, lvl_1_2_cin[size/4], lvl_1_2_sum}; 
assign lvl_3_4_sum_cin = {3'b0, lvl_3_4_cin[size/4], lvl_3_4_sum}; 
assign lvl_1_4_cin[0] = 1'b0; 
generate //{
	for (i=0; i<(size/4)+1; i++) 
	begin : adder_generating_logic_4taps //{
		
		FullAdder_4bit fa_4bit_1_4
		( //{
			.a_in (lvl_1_2_sum_cin[(4*i)+3:(i*4)]),
			.b_in (lvl_3_4_sum_cin[(4*i)+3:(i*4)]),
			.c_in (lvl_1_4_cin[i]),
			.sum  (final_sum_loc[(4*i)+3:(i*4)]),
			.c_out_4bit_stage (lvl_1_4_cin[i+1]) 
		); //}
		
	end //}
endgenerate //}

/*
Delay stages for data input, adder inputs and final sum 
*/
always_ff @ (posedge clk)
begin //{
	if (reset)
	begin //{
		lvl_1 <= 'h0;
		lvl_2 <= 'h0;
		lvl_3 <= 'h0;
		lvl_4 <= 'h0;
		s <= 'h0;
	end //}
	else
	begin //{
		lvl_1 <= a;
		lvl_2 <= lvl_1;
		lvl_3 <= lvl_2;
		lvl_4 <= lvl_3;
		s <= final_sum_loc[size-1+2:0]; 
	end //}
end //}

endmodule
