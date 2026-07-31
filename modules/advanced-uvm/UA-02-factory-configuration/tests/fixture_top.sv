module fixture_top;
    import uvm_pkg::*;
    import ua02_pkg::*;
    import ua02_fixture_pkg::*;

    initial begin
        run_test();
    end

    initial begin
        #1us;
        $fatal(1, "UA-02 fixture timeout");
    end
endmodule
