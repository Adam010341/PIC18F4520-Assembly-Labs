# Advanced · 0924 — Merge Two Sorted Sequences

Merge two ascending sequences of different lengths into a single **descending** sequence, using three indirect-addressing pointers at once.

| | |
|---|---|
| **Source** | [`advanced_924.asm`](advanced_924.asm) |
| **Techniques** | three simultaneous pointers (`FSR0` / `FSR1` / `FSR2`) · `POSTINC` auto-increment · `MOVFF` memory-to-memory copy · `DCFSNZ` counters · two-pointer merge |
| **Cost** | 288 instruction cycles (reset → halt loop), simulator |

## What it does

| Location | Meaning |
|---|---|
| `0x200` | sequence **A**, 6 bytes: `0F 21 35 50 88 B4` (`FSR0`) |
| `0x210` | sequence **B**, 5 bytes: `10 28 44 95 FD` (`FSR1`) |
| `0x230` | temporary merged buffer, ascending (`FSR2`) |
| `0x220` | **answer**, descending |
| `0x01` / `0x02` | remaining elements in A / B |
| `0x03` | length counter for the final copy |

1. **Merge** — compare the heads of A and B (`CPFSGT`), copy the smaller one to the temp buffer with `MOVFF POSTINC, POSTINC2`. When one sequence runs out, the remainder of the other is copied straight across (`fillWithA` / `fillWithB`).
2. **Reverse** — walk the temp buffer from its tail back to its head, writing to `0x220` so the answer is in descending order.

## Expected result (simulator)

| Range | Contents |
|---|---|
| `0x230`–`0x23A` (temp) | `0F 10 21 28 35 44 50 88 95 B4 FD` (ascending) |
| `0x220`–`0x22A` (**answer**) | `FD B4 95 88 50 44 35 28 21 10 0F` (descending) |

## Run it

Open this folder in MPLAB X, run in the simulator, pause, and inspect the **File Registers** view at `0x220`. See the [top-level README](../../README.md#getting-started).
