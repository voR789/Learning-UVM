package ua07_support_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ua07_item extends uvm_sequence_item;
        `uvm_object_utils(ua07_item)
        rand bit [7:0] token;
        bit [8:0] result;
        function new(string name = "ua07_item");
            super.new(name);
        endfunction
    endclass

    class ua07_sequencer extends uvm_sequencer #(ua07_item);
        `uvm_component_utils(ua07_sequencer)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
    endclass

    class ua07_driver extends uvm_driver #(ua07_item);
        `uvm_component_utils(ua07_driver)
        int unsigned driven;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        task run_phase(uvm_phase phase);
            ua07_item req;
            ua07_item rsp;
            forever begin
                seq_item_port.get_next_item(req);
                #1ns;
                rsp = ua07_item::type_id::create("rsp");
                rsp.set_id_info(req);
                rsp.token = req.token;
                rsp.result = {1'b0, req.token} + 1;
                driven++;
                seq_item_port.item_done(rsp);
            end
        endtask
    endclass

    class ua07_env extends uvm_env;
        `uvm_component_utils(ua07_env)
        ua07_sequencer sequencer;
        ua07_driver driver;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = ua07_sequencer::type_id::create("sequencer", this);
            driver = ua07_driver::type_id::create("driver", this);
        endfunction
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class ua07_scenario extends uvm_sequence #(ua07_item);
        `uvm_object_utils(ua07_scenario)
        int unsigned item_count;
        int unsigned verified;
        bit random_tokens;
        function new(string name = "ua07_scenario");
            super.new(name);
        endfunction
        task body();
            ua07_item req;
            ua07_item rsp;
            for (int unsigned i = 0; i < item_count; i++) begin
                req = ua07_item::type_id::create($sformatf("req_%0d", i));
                start_item(req);
                if (random_tokens) begin
                    if (!req.randomize())
                        `uvm_fatal("UA07_RANDOMIZE", "item randomization failed")
                end else begin
                    req.token = 8'h20 + i;
                end
                finish_item(req);
                get_response(rsp);
                if ((rsp.token != req.token) ||
                    (rsp.result != ({1'b0, req.token} + 1)))
                    `uvm_fatal("UA07_RESPONSE", "response did not match the request")
                verified++;
            end
        endtask
    endclass

    class ua07_smoke_scenario extends ua07_scenario;
        `uvm_object_utils(ua07_smoke_scenario)
        function new(string name = "ua07_smoke_scenario");
            super.new(name);
            item_count = 2;
            random_tokens = 0;
        endfunction
    endclass

    class ua07_stress_scenario extends ua07_scenario;
        `uvm_object_utils(ua07_stress_scenario)
        function new(string name = "ua07_stress_scenario");
            super.new(name);
            item_count = 6;
            random_tokens = 1;
        endfunction
    endclass
endpackage
