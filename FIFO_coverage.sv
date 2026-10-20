package FIFO_coverage;
import FIFO_transaction::*;
class FIFO_coverage;

// object FIFO_transaction
FIFO_transaction F_cvg_txn;


covergroup CovCode;

// ============= COVERPOINTS INPUTS ================== 

// coverpoint write  
wr_en_cp : coverpoint F_cvg_txn.wr_en {
    bins wr_en_0 = {0};
    bins wr_en_1 = {1};
}

//  coverpoint read  
rd_en_cp : coverpoint F_cvg_txn.rd_en {
    bins rd_en_0 = {0};
    bins rd_en_1 = {1};
}

// ============= COVERPOINTS OUTPUTS ================== 

// coverpoint Write Acknowledge 
wr_ack_cp : coverpoint F_cvg_txn.wr_ack {
    bins wr_ack_0 = {0};
    bins wr_ack_1 = {1};
}

// coverpoint overflow 
overflow_cp : coverpoint F_cvg_txn.overflow {
    bins overflow_0 = {0};
    bins overflow_1 = {1};
}

// coverpoint full 
full_cp : coverpoint F_cvg_txn.full {
    bins full_0 = {0};
    bins full_1 = {1};
} 

// coverpoint empty 
empty_cp : coverpoint F_cvg_txn.empty {
    bins empty_0 = {0};
    bins empty_1 = {1};
} 

// coverpoint almostfull  
almostfull_cp : coverpoint F_cvg_txn.almostfull {
    bins almostfull_0 = {0};
    bins almostfull_1 = {1};
} 

// coverpoint almostempty  
almostempty_cp : coverpoint F_cvg_txn.almostempty {
    bins almostempty_0 = {0};
    bins almostempty_1 = {1};
} 

// coverpoint underflow  
underflow_cp : coverpoint F_cvg_txn.underflow {
    bins underflow_0 = {0};
    bins underflow_1 = {1};
} 


// =================== CROSS COVERAGE =====================

cross_1 : cross wr_en_cp , rd_en_cp , wr_ack_cp;
cross_2 : cross wr_en_cp , rd_en_cp , overflow_cp;
cross_3 : cross wr_en_cp , rd_en_cp , full_cp;
cross_4 : cross wr_en_cp , rd_en_cp , empty_cp;
cross_5 : cross wr_en_cp , rd_en_cp , almostfull_cp;
cross_6 : cross wr_en_cp , rd_en_cp , almostempty_cp;
cross_7 : cross wr_en_cp , rd_en_cp , underflow_cp{
    illegal_bins impossible = binsof (rd_en_cp) intersect {0} && binsof (underflow_cp) intersect {1};
}

endgroup

// e. Create a void function inside it named sample_data that takes one input named F_txn. This
//input is an object of class FIFO_transaction. This function will do the following
function void sample_data(FIFO_transaction F_txn);
F_cvg_txn = F_txn;
CovCode.sample();
endfunction 
function new();
CovCode = new();    
endfunction

endclass
    
endpackage