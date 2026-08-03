# UA-08 register specification

The supplied transaction-level DUT model exposes a 32-bit, little-endian bus
with byte addressing.

| Byte offset | Name | Access | Reset | Fields |
|---:|---|---|---:|---|
| `0x0` | `control` | RW | `0x00000000` | `enable[0]`, `mode[2:1]` |

Writes to `control` replace its 32-bit stored value. Reads return the stored
value. Any other address completes with a not-OK status.
