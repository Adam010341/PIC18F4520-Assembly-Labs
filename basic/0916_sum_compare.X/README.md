# Basic · 0916 — Sum & Compare

Add two pairs of numbers, compare the two sums, and report the outcome as a status code.

| | |
|---|---|
| **Source** | [`basic.asm`](basic.asm) |
| **Techniques** | file-register addressing · `ADDWF` · compare-and-skip (`CPFSEQ`, `CPFSGT`) · three-way branch |
| **Cost** | 25 instruction cycles (reset → halt loop), simulator |

## What it does

```
A1 = x1 + x2        x1 = 0x07, x2 = 0x09
A2 = y1 + y2        y1 = 0x16, y2 = 0x09
```

The PIC18 has no "compare and branch" instruction, so the comparison is built from two skip instructions: `CPFSEQ` (skip if equal) followed by `CPFSGT` (skip if greater). Together they split the outcome three ways.

| File register | Meaning |
|---|---|
| `0x00` / `0x01` | `x1` / `x2` |
| `0x02` / `0x03` | `y1` / `y2` |
| `0x10` | `A1 = x1 + x2` |
| `0x11` | `A2 = y1 + y2` |
| `0x20` | **result code** |

| `0x20` | Meaning |
|---|---|
| `0x11` | `A1 > A2` |
| `0x22` | `A1 == A2` |
| `0x33` | `A1 < A2` |

## Expected result (simulator)

With the values above: `0x10 = 0x10`, `0x11 = 0x1F`, so `A1 < A2` and **`0x20 = 0x33`**.

## Run it

Open this folder in MPLAB X (**File ▸ Open Project**), run in the simulator, pause, and inspect **Window ▸ Target Memory Views ▸ File Registers**. See the [top-level README](../../README.md#getting-started) for details.
