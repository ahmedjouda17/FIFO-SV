////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_interface.DUT F_if);

 
localparam max_fifo_addr = $clog2(F_if.FIFO_DEPTH);

reg [F_if.FIFO_WIDTH-1:0] mem [F_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		wr_ptr <= 0;
	end
	else if (F_if.wr_en && count < F_if.FIFO_DEPTH) begin
		mem[wr_ptr] <= F_if.data_in;
		F_if.wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
	end
	else begin 
		F_if.wr_ack <= 0; 
		if (F_if.full & F_if.wr_en)
			F_if.overflow <= 1;
		else
			F_if.overflow <= 0;
	end
end

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		rd_ptr <= 0;
		F_if.data_out <= '0;   // bug 1 : reset data out to zero
	end
	else if (F_if.rd_en && count != 0) begin
		F_if.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge F_if.clk or negedge F_if.rst_n) begin
	if (!F_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({F_if.wr_en, F_if.rd_en} == 2'b10) && !F_if.full) 
			count <= count + 1;
		else if ( ({F_if.wr_en, F_if.rd_en} == 2'b01) && !F_if.empty)
			count <= count - 1;
			else if ( {F_if.wr_en, F_if.rd_en} == 2'b11) begin      // bug 2: {when write en and read en} = 2'b11
			if (F_if.empty)
				count <= count + 1;   
			else if (F_if.full)
				count <= count - 1;
			end
	end
end

assign F_if.full = (count == F_if.FIFO_DEPTH)? 1 : 0;
assign F_if.empty = (count == 0)? 1 : 0;
assign F_if.underflow = (F_if.empty && F_if.rd_en)? 1 : 0; 
assign F_if.almostfull = (count == F_if.FIFO_DEPTH-2)? 1 : 0; 
assign F_if.almostempty = (count == 1)? 1 : 0;


//======================= ASSERTIONS =======================
`ifdef SIM

// a.Reset Behavior  
property p_reset;
	@(posedge F_if.clk) !F_if.rst_n |=> (!wr_ptr && !rd_ptr && !count);
endproperty
assert property (p_reset);
cover  property (p_reset);

// b.Write Acknowledge (wr_ack)
property p_wr_ack;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(F_if.wr_en && !F_if.full) |=> F_if.wr_ack;
endproperty
assert property (p_wr_ack);
cover  property (p_wr_ack); 

// c.Overflow Detection
property p_overflow;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(F_if.wr_en && F_if.full) |=> F_if.overflow;
endproperty
assert property (p_overflow);
cover  property (p_overflow); 

// d.Underflow Detection
property p_underflow;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(F_if.rd_en && F_if.empty) |-> F_if.underflow;
endproperty
assert property (p_underflow);
cover  property (p_underflow); 

// e.Empty Flag Assertion
property p_empty;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(!count ) |-> F_if.empty;
endproperty
assert property (p_empty);
cover  property (p_empty); 

// f.Full Flag Assertion
property p_full;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(count == F_if.FIFO_DEPTH ) |-> F_if.full;
endproperty
assert property (p_full);
cover  property (p_full); 

// g.Almost Full Condition
property p_almostfull;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(count == F_if.FIFO_DEPTH - 2 ) |-> F_if.almostfull;
endproperty
assert property (p_almostfull);
cover  property (p_almostfull); 

// h.Almost Empty Condition
property p_almostempty;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(count == 1'b1 ) |-> F_if.almostempty;
endproperty
assert property (p_almostempty);
cover  property (p_almostempty); 

// i.Pointer Wraparound
// 1. write pointer 
property p_wraparound_wr_ptr;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(wr_ptr == F_if.FIFO_DEPTH - 1'b1  ) && F_if.wr_en && !F_if.full |=> (wr_ptr == 0);
endproperty
assert property (p_wraparound_wr_ptr);
cover  property (p_wraparound_wr_ptr); 

// 2.read pointer 
property p_wraparound_rd_ptr;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(rd_ptr == F_if.FIFO_DEPTH - 1'b1  ) && F_if.rd_en && !F_if.empty |=> (rd_ptr == 0);
endproperty
assert property (p_wraparound_rd_ptr);
cover  property (p_wraparound_rd_ptr); 

// j. Pointer threshold
// 1. write pointer 
property p_threshold_wr_ptr;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(wr_ptr <= F_if.FIFO_DEPTH - 1'b1);
endproperty
assert property (p_threshold_wr_ptr);
cover  property (p_threshold_wr_ptr);

// 2.read pointer 
property p_threshold_rd_ptr;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(rd_ptr <= F_if.FIFO_DEPTH - 1'b1);
endproperty
assert property (p_threshold_rd_ptr);
cover  property (p_threshold_rd_ptr);

// 3.count  
property p_threshold_count;
	@(posedge F_if.clk) disable iff (!F_if.rst_n)
	(count <= F_if.FIFO_DEPTH);
endproperty
assert property (p_threshold_count);
cover  property (p_threshold_count);

// 7. ensuring that asynchronous reset is working as expected
// v. Asynchronous Reset 
always_comb begin
    if (!F_if.rst_n) begin
         assert final (wr_ptr == 0);
         assert final (rd_ptr == 0);
         assert final (count == 0);
         cover (wr_ptr == 0 && rd_ptr == 0 && count == 0);
    end
end
`endif

endmodule