# Hard · 0916 — Longest Run of 1s

Scan an 8-bit value and find the length of its longest run of consecutive `1` bits.

| | |
|---|---|
| **Source** | [`hard.asm`](hard.asm) |
| **Techniques** | bit-serial scan with `BTFSS` · rotate (`RRNCF`) · running maximum with `CPFSGT` · nested loop/branch structure |
| **Cost** | 117 instruction cycles (reset → halt loop) for input `0xFF`, simulator |

## What it does

| File register | Meaning |
|---|---|
| `0x00` | input byte (`0xFF`) |
| `0x05` | working copy, rotated right each step |
| `0x02` | length of the current run of 1s |
| `0x03` | number of bits scanned so far (loop counter, stops at 8) |
| `0x04` | constant 8 |
| `0x10` | **result** — longest run seen |

Bits are read LSB-first. While the bit is `1`, the run counter `0x02` grows. When a `0` is hit (or all 8 bits are consumed) the run is *evaluated*: if it is at least as long as the stored maximum, `0x10` is updated (`CPFSGT` skips the store when the maximum is already larger); the run counter is cleared and scanning continues until 8 bits have been processed.

## Expected result (simulator)

| Input `0x00` | Bits (MSB → LSB) | `0x10` |
|---|---|---|
| `0xFF` (checked in) | `1111 1111` | `8` |
| `0x76` (constant edited in a scratch copy) | `0111 0110` | `3` |
| `0xDD` (constant edited in a scratch copy) | `1101 1101` | `3` |

## Run it

Open this folder in MPLAB X, run in the simulator, pause, and inspect the **File Registers** view at `0x10`. To try another input, change the constant in `movlw b'11111111'` at the top of the file. See the [top-level README](../../README.md#getting-started).
