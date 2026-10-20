module FIFO_monitor(FIFO_interface.MONITOR F_if);

import FIFO_transaction::*;
import FIFO_coverage::*;
import FIFO_scoreboard::*;
import shared_pkg::*;

// handls
FIFO_transaction F_txn;
FIFO_coverage    F_cvg;
FIFO_scoreboard  F_sb;

initial begin

    // objects 
    F_txn = new();
    F_cvg = new();
    F_sb  = new();

    forever begin
    @(drv_done); // event 

    // inputs
    F_txn.rst_n   = F_if.rst_n;
    F_txn.wr_en   = F_if.wr_en;
    F_txn.rd_en   = F_if.rd_en;
    F_txn.data_in = F_if.data_in;

    // outputs
    F_txn.data_out    = F_if.data_out;
    F_txn.wr_ack      = F_if.wr_ack;
    F_txn.overflow    = F_if.overflow;
    F_txn.full        = F_if.full;
    F_txn.empty       = F_if.empty;
    F_txn.almostfull  = F_if.almostfull;
    F_txn.almostempty = F_if.almostempty;
    F_txn.underflow   = F_if.underflow;

    fork 
    // send coverage 
    F_cvg.sample_data(F_txn);
    // send scoreboard
    F_sb.check_data(F_txn);
    join 
    
   
end
end

initial begin
    wait(test_finished);

    $display("=====================================");
    $display("Simulation Finished");
    $display("Correct Count = %0d", correct_count);
    $display("Error Count   = %0d", error_count);
    $display("=====================================");

    $finish;
end
endmodule