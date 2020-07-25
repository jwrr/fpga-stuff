module waves();
    initial begin
        if ($test$plusargs ("WAVES_ON")) begin
            $dumpfile(`VCD_OUT);
            $dumpvars();
        end
    end
endmodule

