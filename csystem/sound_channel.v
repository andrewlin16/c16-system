module sound_channel(clk, period, volume, width, sample);
	input clk;
	input [15:0] period;
	input [4:0] volume;
	input [2:0] width;
	output [23:0] sample;

	// internal sound generation regs
	reg [23:0] counter;
	reg [3:0] pulse_ctr;
	reg [15:0] lfsr;
	reg flag;
	reg [23:0] sample;

	initial begin
		counter <= 1;
		pulse_ctr <= 0;
		lfsr <= 16'hFFFF;
		flag <= 0;
	end

	always @(posedge clk) begin
		if (counter >= period) begin
			counter <= 1;
			pulse_ctr <= (pulse_ctr == 7 ? 0 : pulse_ctr + 1);
			lfsr <= {lfsr[0] ^ lfsr[2] ^ lfsr[3] ^ lfsr[5], lfsr[15:1]};
		end else begin
			counter <= counter + 1;
		end
	end

	always @(*) begin
		flag <= (width[2] ? lfsr[0] : (pulse_ctr <= (width & 3'h3)));
		if (volume == 0) begin
			sample <= 0;
		end else begin
			sample <= (flag ? {8'hFF, ~volume, 11'h7FF} : {8'h00, volume, 11'h000});
		end
	end
endmodule
