package ua10_pkg;
    import uvm_pkg::*;
    import ua10_support_pkg::*;
    `include "uvm_macros.svh"

    class ua10_memory_check_seq extends uvm_reg_sequence;
    `uvm_object_utils(ua10_memory_check_seq)
    ua10_reg_block model   ;
    int unsigned   verified;

    function new(string name = "ua10_memory_check_seq");
        super.new(name);
    endfunction

    virtual task body();
        // TODO: Through model.scratch and model.default_map, write the two
        // distinct specified patterns to logical indices 0 and 1, read
        // both back, check every status and value independently, and
        // increment verified only for successful readback comparisons.
        uvm_status_e s0;
        uvm_status_e s1;
        logic[31:0] r0;
        logic[31:0] r1;
        model.scratch.write(s0, 0, 32'hD00D_0001, UVM_FRONTDOOR, model.default_map, this);
        model.scratch.write(s1, 1, 32'hC0DE_0002, UVM_FRONTDOOR, model.default_map, this);

        if(s0 != UVM_IS_OK || s1 != UVM_IS_OK)
            `uvm_error("UA10_STATUS", "failed write")


        model.scratch.read(s0, 0, r0, UVM_FRONTDOOR, model.default_map, this);
        model.scratch.read(s1, 1, r1, UVM_FRONTDOOR, model.default_map, this);

        if(s0 != UVM_IS_OK || s1 != UVM_IS_OK)
            `uvm_error("UA10_STATUS", "failed read")
        else begin
            if(r0 != 32'hD00D_0001)
                `uvm_error("UA10_DATA", "failed read 0 comparison")
            else 
                verified++;
            if(r1 != 32'hC0DE_0002)
                `uvm_error("UA10_DATA", "failed read 1 comparison")
            else 
                verified++;
        end
    endtask
    endclass

        class ua10_test extends uvm_test;
            `uvm_component_utils(ua10_test)
            ua10_env              env;
            ua10_memory_check_seq seq;

            function new(string name, uvm_component parent);
                super.new(name, parent);
            endfunction

            function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                env = ua10_env::type_id::create("env", this);
            endfunction

            virtual function ua10_memory_check_seq create_memory_sequence();
                return ua10_memory_check_seq::type_id::create("seq");
            endfunction

            task run_phase(uvm_phase phase);
                phase.raise_objection(this);
                if (env == null)
                    `uvm_fatal("UA10_MODEL", "environment was not built")
                if (env.model == null)
                    `uvm_fatal("UA10_MODEL", "register block was not built")
                if (env.model.scratch == null)
                    `uvm_fatal("UA10_MODEL", "scratch memory was not built")
                if (env.model.default_map == null)
                    `uvm_fatal("UA10_MODEL", "default map was not built")

                seq = create_memory_sequence();
                if (seq == null)
                    `uvm_fatal("UA10_SEQ", "memory-check sequence was not created")
                seq.model = env.model;
                seq.start(null);

                if ((env.driver.storage[0] != 32'hD00D_0001) ||
                    (env.driver.storage[1] != 32'hC0DE_0002) ||
                    (seq.verified != 2) ||
                    (env.driver.completed != 4) ||
                    (env.driver.writes_by_index[0] != 1) ||
                    (env.driver.writes_by_index[1] != 1) ||
                    (env.driver.reads_by_index[0] != 1) ||
                    (env.driver.reads_by_index[1] != 1))
                `uvm_fatal("UA10_RESULT", $sformatf(
                        "mem0=0x%0h mem1=0x%0h verified=%0d completed=%0d",
                        env.driver.storage[0], env.driver.storage[1],
                        seq.verified, env.driver.completed))

                $display("UA10_TRACE mem0=0x%0h mem1=0x%0h verified=%0d completed=%0d",
                    env.driver.storage[0], env.driver.storage[1],
                    seq.verified, env.driver.completed);
                $display("TEST_RESULT: PASS");
                phase.drop_objection(this);
            endtask
        endclass
    endpackage
