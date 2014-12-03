module video(clk, resetn, hdmi_clk, hdmi_d, hdmi_de, hdmi_hs, hdmi_vs);
	input clk;
	input resetn;

	output hdmi_clk;
	output [23:0] hdmi_d;
	output hdmi_de;
	output hdmi_hs;
	output hdmi_vs;

	// HDMI module in/out
	wire [11:0] x;
	wire [11:0] y;

	reg [7:0] r;
	reg [7:0] g;
	reg [7:0] b;

	// internal picture regs
	reg [11:0] paldef[0:15];
	reg [3:0] tiledef[0:16383];
	reg [5:0] tilemap[0:299];

	integer ty, tx, t;
	integer py, px, p;
	integer c;

	integer i;

//=======================================================
//  Structural coding
//=======================================================

	// picture output
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			paldef[i] <= i;
		end

		for (i = 0; i < 4096; i = i + 1) begin
			tiledef[i] <= i;
			tiledef[i+4096] <= i;
			tiledef[i+8192] <= i;
			tiledef[i+12288] <= i;
		end

		for (i = 0; i < 300; i = i + 1) begin
			tilemap[i] <= i;
		end
	end

	always @(*) begin
		ty = y >> 4;
		tx = x >> 4;
		t = tilemap[ty*20+tx];

		py = y & 11'b00000001111;
		px = x & 11'b00000001111;
		p = tiledef[t << 8 | py << 4 | px];

		c = paldef[p];
		r = {c[11:8], 4'b0000};
		g = {c[7:4], 4'b0000};
		b = {c[3:0], 4'b0000};
	end

	// hdmi
	hdmi hdmiout(clk, resetn, x, y, r, g, b, hdmi_clk, hdmi_d, hdmi_de, hdmi_hs, 0, hdmi_vs);
endmodule
