package access_fixture_pkg;
    import uvm_pkg::*;
    import ua09_support_pkg::*;
    import ua09_pkg::*;
    `include "uvm_macros.svh"

    class ua09_reference_test extends ua09_test;
        `uvm_component_utils(ua09_reference_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task resynchronize_from_hardware(output uvm_status_e status);
            uvm_reg_data_t observed;
            bit accepted;
            env.backdoor.read(status, observed);
            if (status == UVM_IS_OK) begin
                accepted = env.model.control.predict(observed);
                if (!accepted)
                    status = UVM_NOT_OK;
            end
        endtask

        virtual function void stage_desired(input uvm_reg_data_t value);
            env.model.control.set(value);
        endfunction

        virtual task commit_desired(output uvm_status_e status);
            env.model.control.update(status, UVM_FRONTDOOR,
                env.model.default_map);
        endtask
    endclass

    class ua09_predict_without_observation_test extends ua09_reference_test;
        `uvm_component_utils(ua09_predict_without_observation_test)
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task resynchronize_from_hardware(output uvm_status_e status);
            bit accepted;
            accepted = env.model.control.predict(env.driver.stored_control);
            if (accepted)
                status = UVM_IS_OK;
            else
                status = UVM_NOT_OK;
        endtask
    endclass
endpackage
