////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO_DUT (FIFO_interface.DUT FIFO_if);
 
localparam max_fifo_addr = $clog2(FIFO_if.FIFO_DEPTH);

reg [FIFO_if.FIFO_WIDTH-1:0] mem [FIFO_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		wr_ptr 			 <= 0;
		FIFO_if.overflow <= 0; /* added */
		FIFO_if.wr_ack 	 <= 0;
	end
	else if (FIFO_if.wr_en && count < FIFO_if.FIFO_DEPTH) begin
		mem[wr_ptr] <= FIFO_if.data_in;
		FIFO_if.wr_ack 	 <= 1;
		wr_ptr <= wr_ptr + 1;
		FIFO_if.overflow <= 0; /* added */
	end
	else begin 
		FIFO_if.wr_ack <= 0; 
		if (FIFO_if.full && FIFO_if.wr_en)
			FIFO_if.overflow <= 1;
		else
			FIFO_if.overflow <= 0;
	end
end

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		rd_ptr <= 0;
		FIFO_if.underflow <= 0; /* added */
	end
	else if (FIFO_if.rd_en && count != 0) begin
		FIFO_if.data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
		FIFO_if.underflow <= 0;	/* added */
	end
	else begin
		/* Sequential Raise for underflow */
		if (FIFO_if.empty && FIFO_if.rd_en) begin
			FIFO_if.underflow <= 1;
		end else begin
			FIFO_if.underflow <= 0;	
		end
	end
end

always @(posedge FIFO_if.clk or negedge FIFO_if.rst_n) begin
	if (!FIFO_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b10) && !FIFO_if.full) 
			count <= count + 1;
		else if ( ({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b01) && !FIFO_if.empty)
			count <= count - 1;
		else if (({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b11) && FIFO_if.full)      // priority for write operation
			count <= count - 1;
		else if (({FIFO_if.wr_en, FIFO_if.rd_en} == 2'b11) && FIFO_if.empty)      // priority for read operation
			count <= count + 1;
	end
end

assign FIFO_if.full = (count == FIFO_if.FIFO_DEPTH)? 1 : 0;
assign FIFO_if.empty = (count == 0)? 1 : 0;

/* assign FIFO_if.underflow = (FIFO_if.empty && FIFO_if.rd_en)? 1 : 0; Should be sequential */

/* almost full is raised when count = FIFO_DEPTH -1 not -2 */
assign FIFO_if.almostfull = (count == FIFO_if.FIFO_DEPTH-1)? 1 : 0; 

assign FIFO_if.almostempty = (count == 1)? 1 : 0;


/* ---------------------------- Assertions ---------------------------- */
`ifdef SIM
	/* ------------------------- Overflow ---------------------------- */
	property Overflow_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((FIFO_if.full) && (FIFO_if.wr_en)) |-> ##1 (FIFO_if.overflow == 1));
	endproperty

	assert property(Overflow_Condition) 
	else   $error("full = %0d, wr_en = %0d,overflow = %0d",FIFO_if.full,FIFO_if.wr_en, FIFO_if.overflow);

	cover property(Overflow_Condition);

	/* ------------------------- Underflow ---------------------------- */
	property Underflow_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((FIFO_if.empty) && (FIFO_if.rd_en)) |-> ##1 (FIFO_if.underflow == 1));
	endproperty

	assert property(Underflow_Condition) 
	else   $error("empty = %0d, rd_en = %0d, underflow = %0d",FIFO_if.empty,FIFO_if.rd_en, FIFO_if.underflow);

	cover property(Underflow_Condition);

	/* --------------------------- Full ------------------------------- */
	property Full_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((count == FIFO_if.FIFO_DEPTH)) |-> (FIFO_if.full == 1));
	endproperty

	assert property(Full_Condition) 
	else   $error("count = %0d, full = %0d", count, FIFO_if.full);

	cover property(Full_Condition);

	/* ------------------------- Almost Full --------------------------- */
	property AlmostFull_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((count == FIFO_if.FIFO_DEPTH-1)) |-> (FIFO_if.almostfull == 1));
	endproperty

	assert property(AlmostFull_Condition) 
	else   $error("count = %0d, almostfull = %0d", count, FIFO_if.almostfull);

	cover property(AlmostFull_Condition);

	/* -------------------------- Empty ------------------------------- */
	property Empty_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((count == 0)) |-> (FIFO_if.empty == 1));
	endproperty

	assert property(Empty_Condition) 
	else   $error("count = %0d, empty = %0d", count, FIFO_if.empty);

	cover property(Empty_Condition);

	/* ----------------------- AlmostEmpty ---------------------------- */
	property AlmostEmpty_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((count == 1)) |-> (FIFO_if.almostempty == 1));
	endproperty

	assert property(AlmostEmpty_Condition) 
	else   $error("count = %0d, empty = %0d", count, FIFO_if.empty);

	cover property(AlmostEmpty_Condition);

	/* ------------------------ Wr_ack flag --------------------------- */
	property WR_ack_Condition;
		@(posedge FIFO_if.clk) disable iff(!FIFO_if.rst_n) (((FIFO_if.wr_en && count < FIFO_if.FIFO_DEPTH)) |-> ##1 (FIFO_if.wr_ack == 1));
	endproperty

	assert property(WR_ack_Condition) 
	else   $error("count = %0d, wr_en = %0d, wr_ack = %0d", count,FIFO_if.wr_en, FIFO_if.wr_ack);

	cover property(WR_ack_Condition);
`endif 
endmodule

