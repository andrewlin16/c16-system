module sample_generator(clk, sw, key, sample);
	input clk;
	input [9:0] sw;
	input [3:0] key;
	output [23:0] sample;

	// sound generation settings
	reg [15:0] period;
	reg [4:0] volume;
	reg [2:0] width;

	// internal sound generation regs
	reg [23:0] counter;
	reg [3:0] pulse_ctr;
	reg flag;
	reg [23:0] sample;

	initial begin
		period <= 14205;	// 16'h377D
		volume <= 8;
		width <= 3;

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
			volume <= sw[4:0];
		end else if (!key[3]) begin
			width <= sw[2:0];
		end

		if (counter >= period) begin
			counter <= 1;
			pulse_ctr <= (pulse_ctr == 7 ? 0 : pulse_ctr + 1);
		end else begin
			counter <= counter + 1;
		end

		flag <= (pulse_ctr <= (width & 3'h3));
		sample <= (flag ? {8'hFF, ~volume, 11'h7FF} : {8'h00, volume, 11'h000});
	end
endmodule
