# Basic · 0924 — Parity-Dependent Recurrence

Extend a 3-term seed into a 6-term sequence with a recurrence whose rule depends on whether the previous term is odd or even. The lab is an exercise in **banked RAM** and **indirect addressing** through `FSR0` / `FSR1`.

| | |
|---|---|
| **Source** | [`basic.asm`](basic.asm) |
| **Techniques** | `MOVLB` + banked access · `LFSR` · `INDF` / `PREINC` indirect addressing · `BTFSC` parity test · `DCFSNZ` loop counter |
| **Cost** | 55 instruction cycles (reset → halt loop), simulator |

## What it does

The seed `a₀ a₁ a₂ = 0x64 0x50 0x29` is written into bank 1 (`0x140`–`0x142`) with `MOVLB 1` and banked `MOVWF`. Three new terms are then generated:

```
if a[n-1] is even :  a[n] = a[n-3] + a[n-2] + a[n-1]
if a[n-1] is odd  :  a[n] = a[n-2] - a[n-1]
```

`FSR0` always points at `a[n-3]` and `FSR1` at `a[n-1]`; the new term is written through `PREINC`, after which both pointers slide forward by one. The parity test is a single `BTFSC INDF1, 0`.

| Location | Meaning |
|---|---|
| `0x01` | loop counter, preset to 4 — `DCFSNZ` falls through on the 4th decrement, so the body runs **3** times |
| `0x140` – `0x142` | seed `a₀ … a₂` |
| `0x143` – `0x145` | generated terms `a₃ … a₅` |

## Expected result (simulator)

| Address | `0x140` | `0x141` | `0x142` | `0x143` | `0x144` | `0x145` |
|---|---|---|---|---|---|---|
| Hex | `64` | `50` | `29` | `27` | `02` | `52` |
| Decimal | 100 | 80 | 41 | 39 | 2 | 82 |

Hand check: `a₂ = 41` is odd → `a₃ = 80 − 41 = 39`; `a₃` odd → `a₄ = 41 − 39 = 2`; `a₄` even → `a₅ = 41 + 39 + 2 = 82`.

## Run it

Open this folder in MPLAB X, run in the simulator, pause, and inspect the **File Registers** view at `0x140`. See the [top-level README](../../README.md#getting-started).
