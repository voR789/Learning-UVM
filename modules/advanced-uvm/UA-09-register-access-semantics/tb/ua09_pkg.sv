package ua09_pkg;
    import uvm_pkg::*;
    import ua09_support_pkg::*;
    `include "uvm_macros.svh"

    class ua09_test extends ua09_base_test;
        `uvm_component_utils(ua09_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task resynchronize_from_hardware(output uvm_status_e status);
            // TODO: Obtain the implemented control value through the supplied
            // backdoor service, then synchronize RAL from that evidence.
            uvm_reg_data_t val;
            env.backdoor.read(status, val);
            if(status == UVM_IS_OK) begin
                void'(env.model.control.predict(val));
            end
        endtask

        virtual function void stage_desired(input uvm_reg_data_t value);
            // TODO: Stage value as desired state without bus traffic.
            env.model.control.set(value);
        endfunction

        virtual task commit_desired(output uvm_status_e status);
            // TODO: Commit the staged desired value through the supplied
            // frontdoor map.
            env.model.control.update(status, UVM_FRONTDOOR, env.model.default_map);
        endtask
    endclass
endpackage
