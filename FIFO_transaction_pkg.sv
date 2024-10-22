package FIFO_transaction_pkg;
    /* ------------------------- Parameters --------------------- */
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    class FIFO_transaction;


        /* --------------------------- Inputs ----------------------- */
        rand logic [FIFO_WIDTH-1:0] data_in;
        logic clk;
        rand logic rst_n, wr_en, rd_en;

        /* --------------------------- Outputs ---------------------- */
        logic [FIFO_WIDTH-1:0] data_out;
        logic wr_ack, overflow;
        logic full, empty, almostfull, almostempty, underflow;

        /* --------------------- Transaction Integers ---------------- */
        integer RD_EN_ON_DIST;
        integer WR_EN_ON_DIST;

        /* ============================================================ */

        /* ------------------------- Constraints ---------------------- */
        
        /* Constraint for rst_n to be deasserted */
        constraint reset_c {
            rst_n dist { 0 := 2, 1:=98};
        }
        
        /*  Constraint the write enable to be high / low according to 
        distribution of the value WR_EN_ON_DIST */
        constraint WR_EN_c {
            wr_en dist { 1 := WR_EN_ON_DIST ,
                         0 := 100 - WR_EN_ON_DIST};
        }

        /*  Constraint the write enable to be high / low according to 
        distribution of the value RD_EN_ON_DIST */
        constraint RD_EN_c {
            rd_en dist { 1 := RD_EN_ON_DIST ,
                         0 := 100 - RD_EN_ON_DIST};
        }

        /* ============================================================ */
        function new(integer RD_EN_ON_DIST_copy = 30 ,
                     integer WR_EN_ON_DIST_copy = 70 );

            RD_EN_ON_DIST = RD_EN_ON_DIST_copy;
            WR_EN_ON_DIST = WR_EN_ON_DIST_copy;

        endfunction //new()

    endclass //FIFO_transaction

endpackage