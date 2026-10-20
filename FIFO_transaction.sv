package FIFO_transaction;
parameter FIFO_WIDTH = 16;
class FIFO_transaction;

// signals 
bit clk;
rand logic [FIFO_WIDTH-1:0] data_in;
rand logic rst_n, wr_en, rd_en;
logic  [FIFO_WIDTH-1:0] data_out;
logic  wr_ack, overflow;
logic  full, empty, almostfull, almostempty, underflow;
integer RD_EN_ON_DIST;
integer WR_EN_ON_DIST;

// constructor 
function new(integer RD_EN_ON_DIST = 30 ,integer WR_EN_ON_DIST= 70);
this.WR_EN_ON_DIST =WR_EN_ON_DIST;
this.RD_EN_ON_DIST = RD_EN_ON_DIST;
    
endfunction

// consructor 
constraint reset_c {rst_n dist {1:=95 , 0 :=5};}
constraint write_c {wr_en dist {1:=WR_EN_ON_DIST , 0:=100 - WR_EN_ON_DIST};}
constraint read_c {rd_en dist  {1:=RD_EN_ON_DIST , 0:=100 - RD_EN_ON_DIST};}

endclass
    
endpackage