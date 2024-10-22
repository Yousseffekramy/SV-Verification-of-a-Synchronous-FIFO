
package  FIFO_coverage_pkg;
    import FIFO_transaction_pkg::*;
    
    class FIFO_coverage;
        /* ------------------ Transaction Class Handler ------------------ */
        FIFO_transaction F_cvg_txn;

        /* -------------------- Transaction Covergroup ------------------- */
        covergroup transaction_pkg_signals_cg;
            WRITE_cp : coverpoint F_cvg_txn.wr_en {
                bins wr_en_0 = {0};
                bins wr_en_1 = {1};
            }

            READ_cp : coverpoint F_cvg_txn.rd_en {
                bins rd_en_0 = {0};
                bins rd_en_1 = {1};
            }

            WRITE_ACK_cp : coverpoint F_cvg_txn.wr_ack {
                bins wr_ack_0 = {0};
                bins wr_ack_1 = {1};
            }

            UNDERFLOW_cp : coverpoint F_cvg_txn.underflow {
                bins underflow_0 = {0};
                bins underflow_1 = {1};
            }

            FULL_cp : coverpoint F_cvg_txn.full {
                bins full_0 = {0};
                bins full_1 = {1};
            }

            EMPTY_cp : coverpoint F_cvg_txn.empty{
                bins empty_0 = {0};
                bins empty_1 = {1};
            }

            ALMOSTFULL_cp : coverpoint F_cvg_txn.almostfull{
                bins almostfull_0 = {0};
                bins almostfull_1 = {1};
            }

            ALMOSTEMPTY_cp : coverpoint F_cvg_txn.almostempty{
                bins almostempty_0 = {0};
                bins almostempty_1 = {1};
            }

            OVERFLOW_cp : coverpoint F_cvg_txn.overflow{
                bins overflow_0 = {0};
                bins overflow_1 = {1};
                option.weight = 0;
            }

            /* CROSS COVERAGE for each WR_EN, RD_EN, each output */
            WRITE_ACK_cross  : cross WRITE_cp,READ_cp,WRITE_ACK_cp;
            UNDERFLOW_cross  : cross WRITE_cp,READ_cp,UNDERFLOW_cp;
            FULL_cross       : cross WRITE_cp,READ_cp,FULL_cp;
            EMPTY_cross      : cross WRITE_cp,READ_cp,EMPTY_cp;
            ALMOSTFULL_cross : cross WRITE_cp,READ_cp,ALMOSTFULL_cp;
            ALMOSTEMPTY_cross: cross WRITE_cp,READ_cp,ALMOSTEMPTY_cp;
            OVERFLOW_CROSS   : cross WRITE_cp,READ_cp,OVERFLOW_cp;

        endgroup

        /* ------------------ Class Constructor ------------------ */
        function new();
            F_cvg_txn = new();
            transaction_pkg_signals_cg = new();
        endfunction //new()

        /* ---------------- Sample data function ---------------- */
        function void sample_data(input FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            transaction_pkg_signals_cg.sample();
        endfunction //sample_data

    endclass //FIFO_Coverage
    
endpackage