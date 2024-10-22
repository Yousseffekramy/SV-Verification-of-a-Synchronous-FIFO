import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;
import FIFO_shared_pkg::*;

module FIFO_monitor (FIFO_interface.MONITOR FIFO_if);

    /* Create object of each class of the 3 classes */
    FIFO_transaction FIFO_tr;
    FIFO_scoreboard  FIFO_sb;
    FIFO_coverage    FIFO_cov;


    initial begin
        FIFO_tr    = new();
        FIFO_sb    = new();
        FIFO_cov   = new();

        forever begin : FOREVER
            @(negedge FIFO_if.clk);
            connect_tr_class_to_if();

            fork
                begin : TRANSACTION
                    /* Thread 1: Sample data from the transaction class */
                    FIFO_cov.sample_data(FIFO_tr);
                end

                begin
                    /* Thread 2: Check data from DUT and GM */
                    FIFO_sb.check_data(FIFO_tr);
                end
            join


            if(test_finished)begin
                $display("Test finished : Correct: %0d, Errors: %0d",correct_count,error_count);
                $display(" =================== End Simulation =================== ");
                $stop;
            end
        end
    end
    
    /* Function Description: 
            Connect the variables and signals of the transaction in 
            the interface passed to DUT */
    function void connect_tr_class_to_if();
    
        /* -------- Sample Input Data -------- */
        FIFO_tr.data_in     = FIFO_if.data_in; 
        FIFO_tr.rst_n       = FIFO_if.rst_n;
        FIFO_tr.wr_en       = FIFO_if.wr_en;
        FIFO_tr.rd_en       = FIFO_if.rd_en;
        /* -------- Sample Output Data -------- */
        FIFO_tr.data_out    = FIFO_if.data_out;
        FIFO_tr.wr_ack      = FIFO_if.wr_ack;
        FIFO_tr.overflow    = FIFO_if.overflow;
        FIFO_tr.underflow   = FIFO_if.underflow;
        FIFO_tr.full        = FIFO_if.full;
        FIFO_tr.almostfull  = FIFO_if.almostfull;
        FIFO_tr.empty       = FIFO_if.empty;
        FIFO_tr.almostempty = FIFO_if.almostempty;
    endfunction

endmodule