# APB-style arithmetic peripheral specification

## Interface timing

- `pclk` is the only clock.
- `presetn` is active-low synchronous reset.
- A transfer has one setup cycle (`psel=1`, `penable=0`) followed by one access
  cycle (`psel=1`, `penable=1`).
- The transfer completes on an access-cycle rising edge when `pready=1`.
- `prdata` and `pslverr` are sampled for that completed transfer.
- This DUT keeps `pready=1`; the verification agent must still use the
  completion condition rather than assuming every selected cycle is complete.

## Register contract

All registers are 32 bits on a four-byte little-endian map.

### `CTRL` at `0x00`

- bit 0: `enable`, read/write;
- all other bits read as zero;
- reset value: zero.

### `GAIN` at `0x04`

- bits 7:0: unsigned gain, read/write;
- all other bits read as zero;
- reset value: one.

### `DATA` at `0x08`

- bits 7:0: unsigned command input, write-only;
- a write while `enable=0` or while busy returns `pslverr=1`;
- an accepted write starts one result operation.

### `STATUS` at `0x0C`

- bit 0: `busy`;
- bit 1: `done`;
- bit 2: `overflow`;
- read-only;
- `done` and `overflow` describe the most recently completed command;
- accepting a new command clears `done` and `overflow`.

### `RESULT` at `0x10`

- bits 7:0: result, read-only;
- after completion, result equals `min(DATA * GAIN, 255)`;
- `overflow=1` exactly when the mathematical product exceeds 255.

## Error behavior

`pslverr=1` for:

- an unmapped address;
- a read of `DATA`;
- a write to `STATUS` or `RESULT`;
- a `DATA` write while disabled or busy.

An errored transfer must not change architectural state.
