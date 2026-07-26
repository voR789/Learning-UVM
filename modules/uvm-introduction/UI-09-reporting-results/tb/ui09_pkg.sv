package ui09_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ui09_reporter extends uvm_component;
        `uvm_component_utils(ui09_reporter)
        int match_count;
        int retry_count;
        int mismatch_count;
        int detail_attempts;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void evaluate(int case_id, int observed, int expected,
                               bit retry_allowed);
            // TODO 1: Always attempt one UVM_HIGH informational detail report
            // with ID UI09_DETAIL and increment detail_attempts.
            `uvm_info("UI09_DETAIL", $sformatf("Evaluating case: %d", case_id), UVM_HIGH)
            detail_attempts++;

            // TODO 2: Implement the three-way classification:
            // exact match -> increment match_count and UVM_LOW info ID UI09_MATCH
            // retry-allowed mismatch -> increment retry_count and warning ID UI09_RETRY
            // other mismatch -> increment mismatch_count and error ID UI09_MISMATCH
            // Include case_id, observed, and expected in useful diagnostics.
            if(observed == expected) begin
                `uvm_info("UI09_MATCH", "transaction matched", UVM_LOW)
                match_count++;
            end else begin
                if(retry_allowed) begin
                    `uvm_warning("UI09_RETRY", "retrying evaluation")
                    retry_count++;
                end else begin
                    `uvm_error("UI09_MISMATCH", "observed and expected values do not match")
                    mismatch_count++;
                end
            end
            
        endfunction

        task run_phase(uvm_phase phase);
            // TODO 3: Call evaluate() for all four rows in README order.
            evaluate(0, 10, 10, 0);
            evaluate(1, 14, 15, 1);
            evaluate(2, 20, 20, 0);
            evaluate(3, 25, 25, 0);
        endtask
    endclass

    class ui09_test extends uvm_test;
        `uvm_component_utils(ui09_test)
        ui09_reporter reporter;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            // TODO 4: Factory-create reporter as child "reporter".
            reporter = ui09_reporter::type_id::create("reporter", this);
        endfunction

        function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            // TODO 5: Set reporter's verbosity level to UVM_MEDIUM.
            reporter.set_report_verbosity_level(UVM_MEDIUM); // Filters out messages w/ verbosity > UVM_MEDIUM
        endfunction

        task run_phase(uvm_phase phase);
            uvm_report_server server;
            int warning_count;
            int error_count;
            int fatal_count;

            // TODO 6: Raise the phase objection.
            phase.raise_objection(this);
            // TODO 7: Allow the reporter run_phase to finish, then obtain the
            // global report server and query warning/error/fatal counts.
            #1ns;
            server = uvm_report_server::get_server();
            warning_count = server.get_severity_count(UVM_WARNING);
            error_count = server.get_severity_count(UVM_ERROR);
            fatal_count = server.get_severity_count(UVM_FATAL);
            // TODO 8: Fatal unless local counts are 3/1/0, detail_attempts is
            // 4, global counts are 1/0/0, UVM_LOW info is enabled, and
            // UVM_HIGH info is disabled for reporter.
            if( reporter.match_count != 3 || 
                reporter.retry_count != 1 ||
                reporter.mismatch_count != 0 ||
                reporter.detail_attempts != 4 ||
                warning_count != 1 ||
                error_count != 0 ||
                fatal_count != 0 ||
                !reporter.uvm_report_enabled(UVM_LOW, UVM_INFO, "UI09_MATCH") ||
                reporter.uvm_report_enabled(UVM_HIGH, UVM_INFO, "UI09_DETAIL")
            )
            `uvm_fatal("UI09_VERDICT", "end-of-test evidence did not match the required counts")            
            // TODO 9: Print exactly:
            // REPORT_TRACE: matches=3 retries=1 mismatches=0 details=4 warnings=1 errors=0 fatals=0
            // TEST_RESULT: PASS
            $display("REPORT_TRACE: matches=%0d retries=%0d mismatches=%0d details=%0d warnings=%0d errors=%0d fatals=%0d",
                     reporter.match_count,
                     reporter.retry_count,
                     reporter.mismatch_count,
                     reporter.detail_attempts,
                     warning_count,
                     error_count,
                     fatal_count);
            $display("TEST_RESULT: PASS");
            // TODO 10: Drop the phase objection.
            phase.drop_objection(this);
        endtask
    endclass
endpackage
