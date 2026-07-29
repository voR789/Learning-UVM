package ub06_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class ub06_item extends uvm_sequence_item;
    rand bit [7:0] operand;
    bit          [7:0] result;
    int unsigned       tag   ;

    `uvm_object_utils_begin(ub06_item)
    `uvm_field_int(operand, UVM_DEFAULT)
    `uvm_field_int(result, UVM_DEFAULT)
    `uvm_field_int(tag, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "ub06_item");
        super.new(name);
    endfunction
    endclass

        class ub06_sequencer extends uvm_sequencer #(ub06_item);
            `uvm_component_utils(ub06_sequencer)

            function new(string name, uvm_component parent);
                super.new(name, parent);
            endfunction
        endclass

        class ub06_driver extends uvm_driver #(ub06_item);
            `uvm_component_utils(ub06_driver)

            function new(string name, uvm_component parent);
                super.new(name, parent);
            endfunction

            task run_phase(uvm_phase phase);
                ub06_item req;
                ub06_item rsp;
                forever begin
                    seq_item_port.get_next_item(req);
                    // TODO: Return one identified response whose result is operand + 1.
                    rsp = ub06_item::type_id::create("rsp");
                    rsp.set_id_info(req); // Copies over internal ID info
                    rsp.result = req.operand + 1;   
                    rsp.tag = req.tag;
                    rsp.operand = req.operand;
                    seq_item_port.item_done(rsp);
                end
            endtask
        endclass

        class ub06_roundtrip_sequence extends uvm_sequence #(ub06_item);
            `uvm_object_utils(ub06_roundtrip_sequence)
            int unsigned verified_count;

            function new(string name = "ub06_roundtrip_sequence");
                super.new(name);
            endfunction

            task body();
                ub06_item req;
                ub06_item rsp;
                verified_count = 0;
                for (int unsigned i = 0; i < 3; i++) begin
                    req = ub06_item::type_id::create($sformatf("req_%0d", i));
                    start_item(req);
                    req.tag = i;
                    req.operand = 8'h20 + i;
                    finish_item(req);

                    // TODO: Receive and validate the response for this request.
                    rsp = ub06_item::type_id::create($sformatf("rsp_%0d", i));
                    get_response(rsp);
                    if(rsp.result != req.operand + 1)
                        `uvm_fatal("UB06_RESPONSE", "Result values are incorrect")
                    if(rsp.tag != req.tag)
                        `uvm_fatal("UB06_RESPONSE", "Tag value incorrect")
                    else 
                        verified_count++;
                end
            endtask
        endclass

        class ub06_test extends uvm_test;
            `uvm_component_utils(ub06_test)
            ub06_sequencer sequencer;
            ub06_driver    driver   ;

            function new(string name, uvm_component parent);
                super.new(name, parent);
            endfunction

            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                sequencer = ub06_sequencer::type_id::create("sequencer", this);
                driver = ub06_driver::type_id::create("driver", this);
            endfunction

            function void connect_phase(uvm_phase phase);
                super.connect_phase(phase);
                driver.seq_item_port.connect(sequencer.seq_item_export);
            endfunction

            task run_phase(uvm_phase phase);
                ub06_roundtrip_sequence sequence_h;

                phase.raise_objection(this);
                sequence_h = ub06_roundtrip_sequence::type_id::create("sequence_h");
                sequence_h.start(sequencer);
                if (sequence_h.verified_count != 3)
                    `uvm_fatal("UB06_COUNT", "not all three responses were verified")
                $display("RESPONSE_SUMMARY: verified=%0d", sequence_h.verified_count);
                $display("TEST_RESULT: PASS");
                phase.drop_objection(this);
            endtask
        endclass
    endpackage
