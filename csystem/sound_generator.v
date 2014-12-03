module sound_generator(clk, resetn, wen, ch_sel, ch_param, ch_val, sample);
	input clk;
	input resetn;

	input wen;
	input [1:0] ch_sel;
	input [1:0] ch_param;
	input [15:0] ch_val;

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
			volume[ch] <= 4;
			width[ch] <= 3;
		end
	end

	always @(posedge clk) begin
		if (!resetn) begin
			for (ch = 0; ch < 4; ch = ch + 1) begin
				period[ch] <= 16'hFFFF;
				volume[ch] <= 0;
				width[ch] <= 0;
			end
		end else if (wen) begin
			case (ch_param)
				0: period[ch_sel] <= ch_val;
				1: volume[ch_sel] <= ch_val[4:0];
				2: width[ch_sel] <= ch_val[2:0];
			endcase
		end
	end
endmodule
