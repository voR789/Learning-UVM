package ua_g1_reference_pkg;
    import uvm_pkg::*;
    import ua_g1_support_pkg::*;
    import ua_g1_pkg::*;
    `include "uvm_macros.svh"

    class ua_g1_reference_monitor extends ua_g1_apb_monitor;
        `uvm_component_utils(ua_g1_reference_monitor)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            ua_g1_apb_item item;
            forever begin
                @(posedge vif.pclk);
                if (vif.presetn && vif.psel && vif.penable && vif.pready) begin
                    item = ua_g1_apb_item::type_id::create("item");
                    item.write = vif.pwrite;
                    item.addr = vif.paddr;
                    item.wdata = vif.pwdata;
                    item.rdata = vif.prdata;
                    item.error = vif.pslverr;
                    completed_ap.write(item);
                    observed++;
                end
            end
        endtask
    endclass

    class ua_g1_reference_scoreboard extends ua_g1_scoreboard;
        `uvm_component_utils(ua_g1_reference_scoreboard)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void write(ua_g1_apb_item t);
            bit expected_error;
            logic [15:0] product;

            expected_error = 0;
            case (t.addr)
                CTRL_ADDR, GAIN_ADDR: expected_error = 0;
                DATA_ADDR: expected_error = !t.write || !enable_model;
                STATUS_ADDR, RESULT_ADDR: expected_error = t.write;
                default: expected_error = 1;
            endcase

            transactions++;
            if (t.error != expected_error) begin
                mismatches++;
                `uvm_error("UAG1_RESPONSE", $sformatf(
                    "addr=0x%0h expected_error=%0b observed_error=%0b",
                    t.addr, expected_error, t.error))
            end

            if (t.error)
                return;

            case (t.addr)
                CTRL_ADDR: begin
                    if (t.write)
                        enable_model = t.wdata[0];
                    else if (t.rdata[0] != enable_model) begin
                        mismatches++;
                        `uvm_error("UAG1_MISMATCH", "CTRL readback mismatch")
                    end
                end
                GAIN_ADDR: begin
                    if (t.write)
                        gain_model = t.wdata[7:0];
                    else if (t.rdata[7:0] != gain_model) begin
                        mismatches++;
                        `uvm_error("UAG1_MISMATCH", "GAIN readback mismatch")
                    end
                end
                DATA_ADDR: begin
                    if (t.write) begin
                        product = t.wdata[7:0] * gain_model;
                        expected_overflow = (product > 16'h00FF);
                        expected_result = expected_overflow ?
                            8'hFF : product[7:0];
                        expected_valid = 1;
                    end
                end
                STATUS_ADDR: begin
                    if (!t.write && t.rdata[1] && expected_valid &&
                        (t.rdata[2] != expected_overflow)) begin
                        mismatches++;
                        `uvm_error("UAG1_MISMATCH", $sformatf(
                            "STATUS overflow expected=%0b observed=%0b",
                            expected_overflow, t.rdata[2]))
                    end
                end
                RESULT_ADDR: begin
                    if (!t.write && expected_valid) begin
                        if (t.rdata[7:0] != expected_result) begin
                            mismatches++;
                            `uvm_error("UAG1_MISMATCH", $sformatf(
                                "RESULT expected=0x%02h observed=0x%02h",
                                expected_result, t.rdata[7:0]))
                        end
                        results_checked++;
                        ->checked_event;
                    end
                end
                default: begin
                end
            endcase
        endfunction
    endclass

    class ua_g1_reference_coverage extends ua_g1_coverage;
        `uvm_component_utils(ua_g1_reference_coverage)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void write(ua_g1_apb_item t);
            sampled_addr = t.addr;
            sampled_write = t.write;
            sampled_error = t.error;
            sampled_result_class = 0;

            case (t.addr)
                CTRL_ADDR: address_mask[0] = 1;
                GAIN_ADDR: address_mask[1] = 1;
                DATA_ADDR: address_mask[2] = 1;
                STATUS_ADDR: address_mask[3] = 1;
                RESULT_ADDR: address_mask[4] = 1;
                default: begin
                end
            endcase

            if (t.write)
                saw_write = 1;
            else
                saw_read = 1;
            if (t.error)
                saw_error = 1;
            else
                saw_success = 1;

            if (!t.write && !t.error && (t.addr == RESULT_ADDR)) begin
                if (t.rdata[7:0] == 8'hFF) begin
                    sampled_result_class = 2;
                    saw_saturated_result = 1;
                end else begin
                    sampled_result_class = 1;
                    saw_normal_result = 1;
                end
            end

            apb_cg.sample();
            samples++;
        endfunction
    endclass

    class ua_g1_reference_scenario extends ua_g1_scenario_seq;
        `uvm_object_utils(ua_g1_reference_scenario)

        function new(string name = "ua_g1_reference_scenario");
            super.new(name);
        endfunction

        task poll_until_done(output uvm_reg_data_t status_value);
            uvm_status_e status_code;
            bit done_seen;
            done_seen = 0;
            repeat (8) begin
                model.status.read(status_code, status_value, UVM_FRONTDOOR,
                    model.default_map, this);
                if (status_code != UVM_IS_OK)
                    `uvm_fatal("UAG1_STATUS", "STATUS read failed")
                polls++;
                if (status_value[1])
                    done_seen = 1;
                if (done_seen)
                    break;
            end
            if (!done_seen)
                `uvm_fatal("UAG1_POLL", "STATUS.done did not assert")
        endtask

        virtual task body();
            uvm_status_e status_code;
            uvm_reg_data_t observed;

            if (model == null)
                `uvm_fatal("UAG1_MODEL", "scenario model is null")

            model.data.write(status_code, 32'h05, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code == UVM_IS_OK)
                `uvm_fatal("UAG1_REJECT", "disabled DATA write was accepted")
            rejected++;

            model.control.write(status_code, 32'h1, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code != UVM_IS_OK)
                `uvm_fatal("UAG1_STATUS", "CTRL write failed")
            model.gain.write(status_code, 32'h3, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code != UVM_IS_OK)
                `uvm_fatal("UAG1_STATUS", "GAIN=3 write failed")
            model.data.write(status_code, 32'h20, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code != UVM_IS_OK)
                `uvm_fatal("UAG1_STATUS", "normal DATA write failed")
            poll_until_done(observed);
            if (observed[2])
                `uvm_fatal("UAG1_STATUS", "normal command reported overflow")
            model.result.read(status_code, observed, UVM_FRONTDOOR,
                model.default_map, this);
            if ((status_code != UVM_IS_OK) || (observed[7:0] != 8'h60))
                `uvm_fatal("UAG1_SCENARIO", $sformatf(
                    "normal result status=%0d value=0x%0h",
                    status_code, observed))
            verified++;

            model.gain.write(status_code, 32'h4, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code != UVM_IS_OK)
                `uvm_fatal("UAG1_STATUS", "GAIN=4 write failed")
            model.data.write(status_code, 32'h80, UVM_FRONTDOOR,
                model.default_map, this);
            if (status_code != UVM_IS_OK)
                `uvm_fatal("UAG1_STATUS", "saturating DATA write failed")
            poll_until_done(observed);
            if (!observed[2])
                `uvm_fatal("UAG1_STATUS", "saturating command missed overflow")
            model.result.read(status_code, observed, UVM_FRONTDOOR,
                model.default_map, this);
            if ((status_code != UVM_IS_OK) || (observed[7:0] != 8'hFF))
                `uvm_fatal("UAG1_SCENARIO", $sformatf(
                    "saturated result status=%0d value=0x%0h",
                    status_code, observed))
            verified++;
        endtask
    endclass

    class ua_g1_reference_test extends ua_g1_test;
        `uvm_component_utils(ua_g1_reference_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            ua_g1_apb_monitor::type_id::set_type_override(
                ua_g1_reference_monitor::get_type());
            ua_g1_scoreboard::type_id::set_type_override(
                ua_g1_reference_scoreboard::get_type());
            ua_g1_coverage::type_id::set_type_override(
                ua_g1_reference_coverage::get_type());
            super.build_phase(phase);
        endfunction

        virtual function ua_g1_scenario_seq create_scenario();
            return ua_g1_reference_scenario::type_id::create("scenario");
        endfunction
    endclass

    class ua_g1_fault_test extends ua_g1_reference_test;
        `uvm_component_utils(ua_g1_fault_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass
endpackage
