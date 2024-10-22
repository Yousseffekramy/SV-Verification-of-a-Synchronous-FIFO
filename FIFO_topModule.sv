
module FIFO_top();
    /* Declare the clk and pass it to the interface */
    bit clk;

    initial begin    
        clk = 0;
        forever begin
            #10 clk = ~clk;
        end
    end

    /* Creates the FIFO interface and pass clk to it */
    FIFO_interface FIFO_if(clk);

    /* Passes the interface to the DUT,TEST,Monitor */
    FIFO_DUT DUT (FIFO_if);
    FIFO_monitor MONITOR (FIFO_if);
    FIFO_tb TEST (FIFO_if);

endmodule