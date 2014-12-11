module c16(clk, resetn, key, sw, snd_wen, vid_wen, w_param, w_index, w_val, debug);
	input clk;
	input resetn;

	input [3:0] key;
	input [9:0] sw;

	output snd_wen;
	output vid_wen;
	output [1:0] w_param;
	output [10:0] w_index;
	output [15:0] w_val;

	output [33:0] debug;

	// state definitions
	parameter s_init = 0;
	parameter s_fetch1 = 1;
	parameter s_fetch2 = 2;
	parameter s_decode = 3;
	parameter s_xalu = 4;
	parameter s_xmul = 5;
	parameter s_xdiv = 6;
	parameter s_xld1 = 7;
	parameter s_xld2 = 8;
	parameter s_xst1 = 9;
	parameter s_xst2 = 10;
	parameter s_xcall = 11;
	parameter s_xbr = 12;
	parameter s_xsti = 13;
	parameter s_xrti = 14;
	parameter s_checkint = 15;

	// decode definitions
	`define d_op inst[15:12]
	`define d_format inst[11]
	`define d_rd inst[10:8]
	`define d_ra inst[7:5]
	`define d_rb inst[2:0]
	`define d_imm5 {(inst[4] ? 11'b11111111111 : 11'b00000000000), inst[4:0]};
	`define d_imm8 {(inst[7] ? 8'b11111111 : 8'b00000000), inst[7:0]};

	// processor regs
	reg [15:0] regs[7:0];
	reg [3:0] state;
	reg [1:0] state_wait;

	// fetch/mem
	reg [15:0] pc;
	reg [15:0] addr;
	reg [15:0] inst;
	reg re;
	reg we;
	wire [15:0] mem_out;

	// decode
	reg [3:0] op;
	reg [2:0] rd;
	reg [2:0] ra;
	reg [15:0] vd;
	reg [15:0] va;
	reg [15:0] vb;

	// internal interrupt regs
	reg [15:0] isr;
	reg [15:0] intpc;
	reg int_flag;
	reg int_trig;

	// output regs
	reg snd_wen;
	reg vid_wen;
	reg [1:0] w_param;
	reg [10:0] w_index;
	reg [15:0] w_val;
	wire [33:0] debug;

	// debug
	reg [15:0] ss_out;

	// memory
	memory mem(addr[12:0], clk, vd, re, we, mem_out);

	initial begin
		state <= s_init;
		re <= 0;
		we <= 0;
		snd_wen <= 0;
		vid_wen <= 0;
	end

	always @(posedge clk) begin
		// default values
		re <= 0;
		we <= 0;
		snd_wen <= 0;
		vid_wen <= 0;

		w_param <= 0;
		w_index <= 0;
		w_val <= 0;

		if (!resetn) begin
			state <= s_init;
		end else begin
			// state machine
			case (state)
				s_init: begin
					pc <= 0;
					regs[7] <= 0;
					regs[6] <= 0;
					regs[5] <= 0;
					regs[4] <= 0;
					regs[3] <= 0;
					regs[2] <= 0;
					regs[1] <= 0;
					regs[0] <= 0;

					state <= s_fetch1;

					isr <= 0;
					int_flag <= 0;
				end
				s_fetch1: begin
					addr <= pc;
					re <= 1;
					pc <= pc + 1;
					state <= s_fetch2;
					state_wait <= 2;
				end
				s_fetch2: begin
					inst <= mem_out;
					if (!state_wait) begin
						state <= s_decode;
					end
					state_wait <= state_wait - 1;
				end
				s_decode: begin
					op <= `d_op;
					rd <= `d_rd;
					ra <= `d_ra;

					vd <= regs[`d_rd];

					if (`d_format) begin
						if (`d_op >= 4'hA) begin	// ld, st, lea, call, brnz, brz
							va <= pc;
							vb <= `d_imm8;
						end else begin
							va <= regs[`d_ra];
							vb <= regs[`d_rb];
						end
					end else begin
						va <= regs[`d_ra];
						vb <= `d_imm5;
					end

					if (`d_op <= 4'h6 || `d_op == 4'hC) begin
						state <= s_xalu;
					end else if (`d_op == 4'h7) begin
						state <= (`d_format ? s_xsti : s_xrti);
					end else if (`d_op == 4'h8) begin
						state <= (`d_format ? s_xmul : s_xalu);
					end else if (`d_op == 4'h9) begin
						state <= (`d_format ? s_xdiv : s_xalu);
					end else if (`d_op == 4'hA) begin
						state <= s_xld1;
					end else if (`d_op == 4'hB) begin
						state <= s_xst1;
					end else if (`d_op == 4'hD) begin
						state <= s_xcall;
					end else if (`d_op == 4'hE || `d_op == 4'hF) begin
						state <= s_xbr;
					end else begin
						state <= s_checkint;
					end
				end
				s_xalu: begin
					if (rd != 7) begin
						case (op)
							4'h0: regs[rd] <= va + vb;
							4'h1: regs[rd] <= va - vb;
							4'h2: regs[rd] <= ($signed(va) < $signed(vb) ? 1 : 0);
							4'h3: regs[rd] <= (va < vb ? 1 : 0);
							4'h4: regs[rd] <= va & vb;
							4'h5: regs[rd] <= va | vb;
							4'h6: regs[rd] <= va ^ vb;
							4'h8: regs[rd] <= va << vb[3:0];
							4'h9: regs[rd] <= va >> vb[3:0];	// note: arithmetic not supported
							4'hC: regs[rd] <= va + vb;
						endcase
					end
					state <= s_checkint;
				end
				s_xmul: begin
					// unsupported
					state <= s_checkint;
				end
				s_xdiv: begin
					// unsupported
					state <= s_checkint;
				end
				s_xld1: begin
					addr <= va + vb;
					re <= ((va + vb) & 16'h8000 ? 0 : 1);
					state <= s_xld2;
					state_wait <= 2;
				end
				s_xld2: begin
					if (rd != 7) begin
						if (addr[15]) begin
							regs[rd] <= (addr[0]) ? key : sw;
						end else begin
							regs[rd] <= mem_out;
						end
					end
					if (!state_wait) begin
						state <= s_checkint;
					end
					state_wait <= state_wait - 1;
				end
				s_xst1: begin
					addr <= va + vb;
					we <= ((va + vb) & 16'h8000 ? 0 : 1);
					state <= s_xst2;
					state_wait <= 2;
				end
				s_xst2: begin
					if (addr[15]) begin
						if (addr[13]) begin
							vid_wen <= 1;
							w_param <= addr[12:11];
							w_index <= addr[10:0];
						end else begin
							snd_wen <= 1;
							w_param <= addr[1:0];
							w_index <= addr[3:2];
						end
						w_val <= vd;
					end
					if (!state_wait) begin
						state <= s_checkint;
					end
					state_wait <= state_wait - 1;
				end
				s_xcall: begin
					if (rd != 7) begin
						regs[rd] <= pc;
					end
					pc <= va + vb;
					state <= s_checkint;
				end
				s_xbr: begin
					if (vd != 0 && op == 4'hE || vd == 0 && op == 4'hF) begin
						pc <= va + vb;
					end
					state <= s_checkint;
				end
				s_xsti: begin
					isr <= vd;
					state <= s_checkint;
				end
				s_xrti: begin
					pc <= intpc;
					int_flag <= 0;
					state <= s_checkint;
				end
				s_checkint: begin
					if (isr != 0 && !int_flag && int_trig) begin
						intpc <= pc;
						pc <= isr;
						int_flag <= 1;
					end
					state <= s_fetch1;
				end
			endcase
		end
	end

	// debugging
	always @(*) begin
		if (sw[9]) begin
			ss_out <= regs[sw[8:6]];
		end else if (sw[5]) begin
			ss_out <= sw[4] ? va : vb;
		end else begin
			ss_out <= inst;
		end
	end

	assign debug = {pc[9:0], 4'h0, state, ss_out};
endmodule
