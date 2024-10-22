import FIFO_transaction_pkg::*;
import FIFO_shared_pkg::*;

module FIFO_tb (FIFO_interface.TEST FIFO_if);
    /* --------------------- Class Handler ----------------------- */
    FIFO_transaction FIFO_trans;

    /* ------------------ Stimulus Generation -------------------- */
    initial begin
        $display(" =================== Start Simulation =================== ");
        FIFO_trans = new();   
        assert_reset();
        @(negedge FIFO_if.clk);
        deassert_reset();
        @(negedge FIFO_if.clk);
        
        
        /* ---------------- Inputs Randomization ----------------- */
        repeat(15000)begin
            assert(FIFO_trans.randomize());
            connect_class_to_if();
            @(negedge FIFO_if.clk);
        end
        
        
        
        test_finished = 1;
        #5;    
        
    end

    /*-----Assign data of transaction class to interface----------*/
    task connect_class_to_if();
        FIFO_if.data_in     = FIFO_trans.data_in; 
        FIFO_if.rst_n       = FIFO_trans.rst_n;
        FIFO_if.wr_en       = FIFO_trans.wr_en;
        FIFO_if.rd_en       = FIFO_trans.rd_en;
    endtask 
    
    /*----Assign output data of interface to transaction class----*/
    task connect_outputs();
        FIFO_trans.data_out    = FIFO_if.data_out;
        FIFO_trans.wr_ack      = FIFO_if.wr_ack;
        FIFO_trans.overflow    = FIFO_if.overflow;
        FIFO_trans.full        = FIFO_if.full;
        FIFO_trans.empty       = FIFO_if.empty;
        FIFO_trans.almostempty = FIFO_if.almostempty;
        FIFO_trans.almostfull  = FIFO_if.almostfull;
        FIFO_trans.underflow   = FIFO_if.underflow;
    endtask 

    /* -------------------- Reset the Inputs -------------------- */
    task assert_reset();
        FIFO_trans.data_in     = 0; 
        FIFO_trans.rst_n       = 0;
        FIFO_trans.wr_en       = 0;
        FIFO_trans.rd_en       = 0;
        connect_class_to_if();
    endtask 

    /* ------------------- Deassert the Inputs ------------------- */
    task deassert_reset();
        FIFO_trans.data_in     = 0; 
        FIFO_trans.rst_n       = 1;
        FIFO_trans.wr_en       = 0;
        FIFO_trans.rd_en       = 0;
        connect_class_to_if();
    endtask 
endmodule