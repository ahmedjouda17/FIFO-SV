package FIFO_scoreboard;
import FIFO_transaction::*;
import shared_pkg::*;
parameter FIFO_DEPTH = 8;
class FIFO_scoreboard;

//  reference outputs

logic  [FIFO_WIDTH-1:0] data_out_ref ='0;


// QUEUE -----> SMALL FIFO TO CHECK DATA OUT 
reg [FIFO_WIDTH - 1:0] queue[$];

// reference model 
task reference_model(FIFO_transaction F_txn);
    bit was_empty, was_full;

    if (!F_txn.rst_n) begin
        queue.delete();
        data_out_ref = '0;
    end 
    else begin
        was_empty = (queue.size() == 0);
        was_full  = (queue.size() == FIFO_DEPTH);

        // write 
        if (F_txn.wr_en && !was_full)
            queue.push_back(F_txn.data_in);

        // read 
        if (F_txn.rd_en && !was_empty)
            data_out_ref = queue.pop_front();
    end
endtask

// check out 
task check_data(FIFO_transaction F_txn);

        // call task reference model 
        reference_model(F_txn);
    if (F_txn.data_out !== data_out_ref)begin
        $display("ERROR | refrence =%h , actual =%h", data_out_ref,F_txn.data_out);
        error_count++;
    end
    else begin
        $display("PASS | refrence =%h , actual =%h", data_out_ref,F_txn.data_out);
        correct_count++;   
    end
    
endtask
endclass
endpackage