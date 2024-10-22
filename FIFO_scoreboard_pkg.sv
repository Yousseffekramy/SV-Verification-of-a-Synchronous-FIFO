package FIFO_scoreboard_pkg;
    import FIFO_transaction_pkg::*; 
    import FIFO_shared_pkg::*;

    class FIFO_scoreboard;
        /* --------------------------- Outputs ---------------------- */
        logic [FIFO_WIDTH-1:0] data_out_ref;
        logic wr_ack_ref, overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;
        
        /* ------------------------ Golden Model -------------------- */
        bit[FIFO_WIDTH-1:0] GM_model[$];
        int count_sb;

        /* Function Description: 
                Reference_model behaves as the required of the Design 
                to check its functionality */
        function void reference_model(input FIFO_transaction FIFO_DUT);
            fork
                /* First Thread: Write Operation Logic */
                begin  

                    if (!FIFO_DUT.rst_n) begin
                        wr_ack_ref <= 0;
                        overflow_ref <= 0;
                        GM_model.delete();	
                    end
                    else if (FIFO_DUT.wr_en && count_sb < FIFO_DEPTH) begin  
                            GM_model.push_back(FIFO_DUT.data_in) ;
                            wr_ack_ref <= 1;
                            overflow_ref <= 0; 
                        end
                        else begin 
                            wr_ack_ref <= 0; 
                            if ((count_sb == FIFO_DEPTH) && FIFO_DUT.wr_en)
                                overflow_ref <= 1;
                            else
                                overflow_ref <= 0;
                        end

                end  

                /* Second Thread: Read Operation Logic */
                begin   

                    if(!FIFO_DUT.rst_n) begin
                        underflow_ref <= 0;
                    end
                    else if ( FIFO_DUT.rd_en && count_sb != 0 ) begin   
                            data_out_ref <= GM_model.pop_front();
                            underflow_ref <= 0;  
                        end
                        else begin
                            if((count_sb == 0)&& FIFO_DUT.rd_en)
                                underflow_ref <= 1 ;
                            else
                                underflow_ref <= 0 ;
                        end                

                end  

                /* Update the count according to the other flags */     
                begin
                    if(!FIFO_DUT.rst_n) begin
                        count_sb <= 0;
                    end
                    else if	( ({FIFO_DUT.wr_en, FIFO_DUT.rd_en} == 2'b10) && count_sb != FIFO_DEPTH) 
                        count_sb <= count_sb + 1;
                    else if ( ({FIFO_DUT.wr_en, FIFO_DUT.rd_en} == 2'b01) && count_sb != 0)
                        count_sb <= count_sb - 1;
                    else if ( ({FIFO_DUT.wr_en, FIFO_DUT.rd_en} == 2'b11) && count_sb == FIFO_DEPTH)
                        count_sb <= count_sb - 1;
                    else if ( ({FIFO_DUT.wr_en, FIFO_DUT.rd_en} == 2'b11) && count_sb == 0)
                        count_sb <= count_sb + 1;
                    
                end

            join /* End of Fork Join */


            /* Update the flags */
            full_ref = (count_sb == FIFO_DEPTH)? 1 : 0;     
            empty_ref = (count_sb == 0)? 1 : 0;
            almostfull_ref = (count_sb == FIFO_DEPTH-1)? 1 : 0;         
            almostempty_ref = (count_sb == 1)? 1 : 0;

        endfunction

        /* Function Description: 
                new() Constructor to set the initial values for each signal */
        function new();
            this.data_out_ref    = 0;
            this.full_ref        = 0;
            this.empty_ref       = 1;
            this.almostfull_ref  = 0;
            this.almostempty_ref = 0;
            this.wr_ack_ref      = 0;
            this.overflow_ref    = 0;
            this.underflow_ref   = 0;
        endfunction //new()


        /* Function Description: 
                check the passed object from the DUT with that produced
                by the function of refernce model and update error and 
                passed counters */
        function void check_data (input FIFO_transaction FIFO_check_data);
            reference_model(FIFO_check_data);

            if(data_out_ref != FIFO_check_data.data_out) begin
                error_count++;
                $display("%0t ERROR in data_out   : EXPECTED = %0d GOT = %0d", $time,
                                            data_out_ref, FIFO_check_data.data_out);
            end else if (wr_ack_ref != FIFO_check_data.wr_ack) begin
                error_count++;
                $display("%0t ERROR in wr_ack     : EXPECTED = %0d GOT = %0d",  $time,
                                            wr_ack_ref, FIFO_check_data.wr_ack);
            end else if (overflow_ref != FIFO_check_data.overflow) begin
                error_count++;
                $display("%0t ERROR in overflow   : EXPECTED = %0d GOT = %0d",  $time,
                                            overflow_ref, FIFO_check_data.overflow);
            end else if (full_ref != FIFO_check_data.full) begin
                error_count++;
                $display("%0t ERROR in full       : EXPECTED = %0d GOT = %0d",  $time,
                                            full_ref, FIFO_check_data.full);
            end else if (empty_ref != FIFO_check_data.empty) begin
                error_count++;
                $display("%0t ERROR in empty      : EXPECTED = %0d GOT = %0d",  $time,
                                            empty_ref, FIFO_check_data.empty);
            end else if (almostfull_ref != FIFO_check_data.almostfull) begin
                error_count++;
                $display("%0t ERROR in almostfull : EXPECTED = %0d GOT = %0d",  $time,
                                            almostfull_ref, FIFO_check_data.almostfull);
            end else if (almostempty_ref != FIFO_check_data.almostempty) begin
                error_count++;
                $display("%0t ERROR in almostfull : EXPECTED = %0d GOT = %0d",  $time,
                                            almostempty_ref, FIFO_check_data.almostempty);
            end else if (underflow_ref != FIFO_check_data.underflow) begin
                error_count++;
                $display("%0t ERROR in underflow  : EXPECTED = %0d GOT = %0d",  $time,
                                            underflow_ref, FIFO_check_data.underflow);                
            end else begin
                correct_count++;
            end
        endfunction
    endclass //FIFO_scoreboard
endpackage