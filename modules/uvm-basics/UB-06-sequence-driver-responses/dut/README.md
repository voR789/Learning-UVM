# No RTL DUT

UB-06 isolates the UVM request/response protocol. The driver acts as a small
transaction-level service so timing at DUT pins does not obscure the new
sequence/sequencer behavior.
