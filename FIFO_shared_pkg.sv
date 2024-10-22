package FIFO_shared_pkg;
    /* Integers to follow the count of the errors 
        and passed tests in TB */
    int error_count   = 0;
    int correct_count = 0;

    /* Signal that raises a flag when the test is 
       finished */
    bit test_finished = 0;
    
endpackage  