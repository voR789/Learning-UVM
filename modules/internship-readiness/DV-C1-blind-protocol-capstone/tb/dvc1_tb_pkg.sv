package dvc1_tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Describe how we want our driver to interpret our requests,
  // either hold it until accepted, pulse once, or probe not-valid
  // abstract packet behavior to make things way easier
  typedef enum logic [1:0] {
    HOLD_ACCEPT,
    PULSE,
    IDLE
  } DRIVE_POLICY;

  `uvm_analysis_imp_decl(
      _cmd)  // Because we use multple imps, must declare so write() is not called by the wrong one
  `uvm_analysis_imp_decl(_rsp)
  `uvm_analysis_imp_decl(_rst)
  `uvm_analysis_imp_decl(_exp)

  `include "dvc1_transactions.sv"
  `include "dvc1_sequencers.sv"
  `include "dvc1_seqeunces.sv"
  `include "dvc1_drivers.sv"
  `include "dvc1_monitors.sv"
  `include "dvc1_agents.sv"
  `include "dvc1_analysis.sv"
  `include "dvc1_env.sv"
  `include "dvc1_tests.sv"
  
endpackage
