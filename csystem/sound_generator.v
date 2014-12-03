module sound_generator(clk, sample);
	input clk;
	output [23:0] sample;

	// sound channel parameters
	reg [15:0] period[0:3];
	reg [4:0] volume[0:3];
	reg [2:0] width[0:3];

	wire [23:0] ch_sample[0:3];

	integer ch;

	sound_channel ch0(clk, period[0], volume[0], width[0], ch_sample[0]);
	sound_channel ch1(clk, period[1], volume[1], width[1], ch_sample[1]);
	sound_channel ch2(clk, period[2], volume[2], width[2], ch_sample[2]);
	sound_channel ch3(clk, period[3], volume[3], width[3], ch_sample[3]);

	assign sample = ch_sample[0] + ch_sample[1] + ch_sample[2] + ch_sample[3];

	initial begin
		for (ch = 0; ch < 4; ch = ch + 1) begin
			period[ch] <= 14205;	// 16'h377D
			volume[ch] <= 0;
			width[ch] <= 3;
		end
	end
endmodule
