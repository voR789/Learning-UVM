# DUT boundary

UI-08 isolates transaction-level analysis wiring, so no RTL DUT is included.
The `ui08_monitor` acts as a deterministic source of already-reconstructed
observations. Pin-level sampling and virtual interfaces arrive in later
modules.
