# UA-09 register contract

The transaction-level implementation exposes one 32-bit, little-endian,
byte-addressed register.

| Byte offset | Name | Access | Reset | Fields |
|---:|---|---|---:|---|
| `0x0` | `control` | RW | `0x00000000` | `enable[0]`, `mode[2:1]` |

Frontdoor reads and writes use the supplied bus path. A supplied custom
backdoor accesses the same implementation storage without creating a bus
transaction. The testbench may model an external hardware-side update to that
storage; such an update does not automatically change RAL state.
