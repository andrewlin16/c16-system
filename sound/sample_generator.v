module sample_generator(clk, sample);
	input clk;
	output [23:0] sample;

	reg [23:0] counter;
	reg flag;
	reg [23:0] sample;

	initial begin
		counter <= 1;
		flag <= 0;
		sample <= 24'h00FFFF;
	end

	always @(posedge clk) begin
		if (counter == 14205) begin
			counter <= 1;
			flag <= !flag;
		end else begin
			counter <= counter + 1;
		end

		sample <= (flag ? 24'hFF0000 : 24'h00FFFF);
	end
endmodule
