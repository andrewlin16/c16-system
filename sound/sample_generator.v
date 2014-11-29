module sample_generator(clk, sw, key, sample);
	input clk;
	input [9:0] sw;
	input [3:0] key;
	output [23:0] sample;

	// sound generation settings
	reg [15:0] period;
	reg [7:0] volume;

	// internal sound generation regs
	reg [23:0] counter;
	reg flag;
	reg [23:0] sample;

	initial begin
		period <= 14205;	// 16'h377D
		volume <= 255;		// 8'hFF

		counter <= 1;
		flag <= 0;
		sample <= 24'h00FFFF;
	end

	always @(posedge clk) begin
		if (!key[1]) begin
			period[15:8] <= sw[7:0];
		end else if (!key[0]) begin
			period[7:0] <= sw[7:0];
		end else if (!key[2]) begin
			volume <= sw[7:0];
		end

		if (counter == 1) begin
			counter <= period;
			flag <= !flag;
		end else begin
			counter <= counter - 1;
		end

		sample <= (flag ? {8'hFF, ~volume, 8'hFF} : {8'h00, volume, 8'h00});
	end
endmodule
