# Advanced · 0916 — Bit-Palindrome Check

Decide whether the 8-bit pattern in a register reads the same forwards and backwards (e.g. `1001 1001`) — by reversing its bits with rotate instructions and comparing against the original.

| | |
|---|---|
| **Source** | [`Advance2.asm`](Advance2.asm) (final) · [`earlier_attempt/Advance.asm`](earlier_attempt/Advance.asm) (first version, kept for reference) |
| **Techniques** | bit test (`BTFSS`) · rotate without carry (`RLNCF` / `RRNCF`) · counted loop with `CPFSEQ` · `INCF` |
| **Cost** | 111 instruction cycles (reset → halt loop) for the checked-in input, simulator |

## What it does

| File register | Meaning |
|---|---|
| `0x00` | input byte (`0xB0` = `1011 0000`) — never modified |
| `0x05` | working copy, rotated right once per iteration |
| `0x01` | iteration counter (0 → 8) |
| `0x10` | accumulator → ends up as the **bit-reversed** input |
| `0x11` | **result flag** |

For each of the 8 bits (LSB first): if the bit is set, `INCF 0x10`; then `RLNCF 0x10` (rotate the accumulator left) and `RRNCF 0x05` (expose the next input bit). Every bit ends up mirrored, offset by one position; one final `RRNCF 0x10` realigns it. Finally `CPFSEQ` compares the reversed byte with the untouched original:

| `0x11` | Meaning |
|---|---|
| `0xFF` | palindrome (reversed == original) |
| `0x00` | not a palindrome |

## Expected result (simulator)

| Input `0x00` | `0x10` (reversed) | `0x11` |
|---|---|---|
| `0xB0` `1011 0000` (checked in) | `0x0D` `0000 1101` | `0x00` |
| `0x99` `1001 1001` (constant edited in a scratch copy) | `0x99` | `0xFF` |

## Earlier attempt

[`earlier_attempt/Advance.asm`](earlier_attempt/Advance.asm) is the first version of this lab (input `0xD2`). It differs from the final version in three ways: it loops 7 times instead of 8, it rotates the original byte in place (so the final comparison is against a modified value), and it has no realigning rotate. As a result it reports "not a palindrome" even for `0x99`. It is not part of the MPLAB project and is kept only to show how the solution evolved.

## Run it

Open this folder in MPLAB X, run in the simulator, pause, and inspect the **File Registers** view at `0x10` / `0x11`. See the [top-level README](../../README.md#getting-started).
