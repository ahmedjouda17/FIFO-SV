module FIFO_tb(FIFO_interface.TEST F_if);
import FIFO_transaction::*;
import shared_pkg::*;
FIFO_transaction F_txn;

// Stimulus Generation
initial begin
   F_txn = new();
   assert_reset();

   repeat(20000) begin
      @(negedge F_if.clk);
      ->drv_done;  // go event 
      #0;
     assert(F_txn.randomize());
     F_if.rst_n = F_txn.rst_n;
     F_if.data_in = F_txn.data_in;
     F_if.wr_en = F_txn.wr_en;
     F_if.rd_en = F_txn.rd_en;
   end

   test_finished = 1;

end

task assert_reset;
   //assert reset
    F_if.rst_n = 0;
    F_if.wr_en   = 0;
    F_if.rd_en   = 0;
    F_if.data_in = 0;
   #20;
   //desert reset
   F_if.rst_n = 1;
endtask
    
endmodule