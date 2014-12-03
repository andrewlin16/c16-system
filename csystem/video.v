module video(clk, resetn, hdmi_clk, hdmi_d, hdmi_de, hdmi_hs, hdmi_vs);
	input clk;
	input resetn;

	output hdmi_clk;
	output [23:0] hdmi_d;
	output hdmi_de;
	output hdmi_hs;
	output hdmi_vs;

	// HDMI module in/out
	reg vid_clk;

	wire [11:0] x;
	wire [11:0] y;

	reg [7:0] r;
	reg [7:0] g;
	reg [7:0] b;

	// internal picture regs
	reg [11:0] paldef[0:15];
	reg [63:0] tiledef[0:63];
	reg [7:0] palmap[0:1199];
	reg [5:0] tilemap[0:1199];

	integer my, mx, m, t;
	integer py, px, pp, p;
	integer c;

	integer i;

//=======================================================
//  Structural coding
//=======================================================

	// video clock divider
	initial begin
		vid_clk <= 0;
	end

	always @(posedge clk) begin
		vid_clk <= !vid_clk;
	end

	// picture output
	initial begin
		for (i = 0; i < 16; i = i + 1) begin
			paldef[i] <= i;
		end

		for (i = 0; i < 64; i = i + 1) begin
			tiledef[i] <= i;
		end

		for (i = 0; i < 1200; i = i + 1) begin
			palmap[i] <= i;
			tilemap[i] <= i;
		end
	end

	always @(*) begin
		my = y >> 3;
		mx = x >> 3;
		m = my * 40 + mx;
		t = tilemap[m];

		py = y & 11'b00000000111;
		px = x & 11'b00000000111;
		pp = tiledef[t][py << 3 | px];
		p = (pp ? palmap[m][7:4] : palmap[m][3:0]);

		c = paldef[p];
		r = {c[11:8], 4'b0000};
		g = {c[7:4], 4'b0000};
		b = {c[3:0], 4'b0000};
	end

	always @(posedge clk) begin
		if (!resetn) begin
			for (i = 0; i < 16; i = i + 1) begin
				paldef[i] <= 0;
			end

			for (i = 0; i < 64; i = i + 1) begin
				tiledef[i] <= 0;
			end

			for (i = 0; i < 1200; i = i + 1) begin
				palmap[i] <= 0;
				tilemap[i] <= 0;
			end
		end
	end

	// hdmi
	hdmi hdmiout(vid_clk, resetn, x, y, r, g, b, hdmi_clk, hdmi_d, hdmi_de, hdmi_hs, 0, hdmi_vs);
endmodule
