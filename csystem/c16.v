module c16(clk, resetn, key, sw, snd_wen, vid_wen, w_param, w_index, w_val, debug);
	input clk;
	input resetn;

	input [4:0] key;
	input [9:0] sw;

	output snd_wen;
	output vid_wen;
	output [1:0] w_param;
	output [10:0] w_index;
	output [15:0] w_val;

	output [33:0] debug;

	// output regs
	reg snd_wen;
	reg vid_wen;
	reg [1:0] w_param;
	reg [10:0] w_index;
	reg [15:0] w_val;
	reg [33:0] debug;

	// TODO: temporary outputs
	always @(posedge clk) begin
		snd_wen <= !key[0];
		vid_wen <= !key[1];

		w_param <= ~key[3:2];
		w_index <= 0;
		w_val <= sw;

		debug <= {sw, 4'h0, key, 16'h00};
	end
endmodule
