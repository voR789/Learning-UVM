# UA-10 memory contract

The transaction-level implementation exposes four independent 32-bit
read/write memory locations on a little-endian, byte-addressed bus.

| Logical index | Byte address | Reset value |
|---:|---:|---:|
| 0 | `0x10` | `0x00000000` |
| 1 | `0x14` | `0x00000000` |
| 2 | `0x18` | `0x00000000` |
| 3 | `0x1C` | `0x00000000` |

A valid write replaces the selected location. A valid read returns the
selected location. Misaligned or out-of-range addresses return
`UVM_NOT_OK`.
