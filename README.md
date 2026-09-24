# PIC18F4520 Assembly Labs

![PIC18](https://img.shields.io/badge/MCU-PIC18F4520-EE2223)
![Assembly](https://img.shields.io/badge/language-PIC18%20assembly%20%28MPASM%29-6E4C13)
![MPLAB X](https://img.shields.io/badge/simulator-MPLAB%20X%20v5.20-555)

**English** · [繁體中文](README.zh-TW.md)

Hand-written assembly for the **PIC18F4520** 8-bit microcontroller — six lab exercises in three difficulty levels, from register arithmetic up to an **in-place iterative quicksort** with a software stack. Every lab is a ready-to-open **MPLAB X** project, runs entirely in the MPLAB simulator (no board needed), and has its result verified and documented.

| | |
|---|---|
| **Target MCU** | PIC18F4520 (8-bit, 32 KB flash, 1.5 KB RAM) |
| **Language** | PIC18 assembly (MPASM) |
| **Toolchain** | MPLAB X IDE v5.20 · MPASM 5.84 · `PIC18Fxxxx_DFP` 1.0.9 |
| **Runs on** | MPLAB X simulator — no hardware required |

## Labs at a glance

Each lab has its own folder with the source, a README (task, memory map, expected result), and the MPLAB X project files. Labs are named `MMDD_<topic>` after the month/day of the session (September 2026).

| Level | Lab | What it does | Key techniques | Result · cost |
|---|---|---|---|---|
| **Basic** | [0916 · Sum & Compare](basic/0916_sum_compare.X) | Adds two pairs of numbers, compares the sums, writes a status code | `ADDWF`, compare-and-skip (`CPFSEQ`/`CPFSGT`) three-way branch | `0x20 = 0x33` · 25 cycles |
| **Basic** | [0924 · Parity-Dependent Recurrence](basic/0924_parity_recurrence.X) | Grows a 3-term seed into 6 terms; the rule depends on whether the previous term is odd or even | banked RAM (`MOVLB`), `FSR0`/`FSR1` indirect addressing, `BTFSC`, `DCFSNZ` | `64 50 29 27 02 52` · 55 cycles |
| **Advanced** | [0916 · Bit-Palindrome Check](advanced/0916_bit_palindrome.X) | Reverses the bits of a byte with rotates and checks if it equals the original | `BTFSS`, `RLNCF`/`RRNCF`, counted loop | `0x10 = 0x0D`, flag `0x00` · 111 cycles |
| **Advanced** | [0924 · Merge Two Sorted Sequences](advanced/0924_merge_sorted.X) | Merges two ascending sequences (6 + 5 bytes) into one descending sequence | three FSRs at once, `POSTINC`, `MOVFF`, two-pointer merge | `FD B4 95 … 10 0F` · 288 cycles |
| **Hard** | [0916 · Longest Run of 1s](hard/0916_longest_ones_run.X) | Finds the longest run of consecutive `1` bits in a byte | bit-serial scan, running maximum, nested branches | `0xFF → 8` · 117 cycles |
| **Hard** | [0924 · In-Place Quicksort](hard/0924_quicksort.X) | Sorts 255 bytes in place, recursion replaced by an explicit stack in RAM | software stack on `FSR2`, 16-bit pointer carry, three FSRs | sorted ascending · 31,495 cycles |

*Cost = instruction cycles from reset to the final halt loop in the MPLAB X simulator, for the input checked into the repo.*

## Spotlight: iterative quicksort on an 8-bit core

The [hard/0924](hard/0924_quicksort.X) lab is the centrepiece. Rather than recursing (the PIC18 hardware call stack is only 31 levels deep and holds return addresses, not local variables), the routine keeps a **stack of pending sub-ranges in data RAM** and drives it with `FSR2`, while `FSR0` and `FSR1` scan the array from both ends:

```
Data RAM
0x000        length of the array (0xFF)
0x001–0x004  pivot value · left bound · right bound · pivot position
0x100–0x1FE  the array — sorted in place
0x300 …      software stack of (left, right) pairs   ← FSR2
```

Sub-ranges with fewer than two elements are never pushed. Result: 255 bytes sorted in **31,495 cycles** (1,796 for the data loader, 29,699 for the sort itself), with the whole program — sort routine and loader — taking just **210 bytes of flash**. The dumped RAM was checked byte-for-byte against `sorted()` of the input in Python.

![Heatmap of data RAM 0x100–0x1FE before and after the sort](hard/0924_quicksort.X/figures/ram_heatmap.png)

*The array in data RAM, one cell per byte (darker = larger), dumped from the MDB simulator right after the data loader (left) and at the halt loop 29,699 cycles later (right): all 255 bytes end up in ascending order, `06` … `FF`. Raw dumps, MDB script and plotting script: [`hard/0924_quicksort.X/figures/`](hard/0924_quicksort.X/figures).*

## What these labs demonstrate

- **PIC18 memory model** — access bank vs. banked access (`MOVLB` / BSR), file-register addressing, working across several RAM banks (`0x0xx`–`0x3xx`).
- **Indirect addressing** — `FSR0`/`FSR1`/`FSR2` with `INDF`, `POSTINC`, `PREINC`, `POSTDEC`; using all three pointers in one routine.
- **Control flow without flags-and-branches** — building comparisons, loops and three-way decisions from skip instructions (`CPFSEQ`, `CPFSGT`, `CPFSLT`, `BTFSS`, `BTFSC`, `DCFSNZ`).
- **Bit manipulation** — rotates without carry, bit tests, bit reversal.
- **Algorithms under tight constraints** — two-pointer merge, bit-serial run-length scan, and quicksort with manual stack management, each fitting in at most 210 bytes of flash.
- **Verification habits** — each result is confirmed by running the code (simulator / MDB) and cross-checking against an independent calculation, not just by reading it.

## Getting started

**Requirements:** MPLAB X IDE (developed with v5.20 on Linux) with the MPASM toolchain. No programmer or board is needed.

1. Clone the repository:
   ```bash
   git clone https://github.com/Adam010341/PIC18F4520-Assembly-Labs.git
   ```
2. In MPLAB X choose **File ▸ Open Project…** and select one lab folder (e.g. `hard/0924_quicksort.X`). MPLAB X regenerates the machine-specific build files on first open.
3. Check **Project Properties**: device `PIC18F4520`, tool `Simulator`, toolchain `MPASM`.
4. Run the project (**Debug Main Project**). Every program ends in a `GOTO terminate` loop — pause it there.
5. Open **Window ▸ Target Memory Views ▸ File Registers** and look at the addresses listed in the lab's README.

All sources start with the same configuration: `CONFIG OSC = INTIO67` (internal oscillator) and `CONFIG WDT = OFF` (watchdog disabled).

## Repository layout

```
.
├── basic/
│   ├── 0916_sum_compare.X/
│   └── 0924_parity_recurrence.X/
├── advanced/
│   ├── 0916_bit_palindrome.X/        # + earlier_attempt/ (first version, for reference)
│   └── 0924_merge_sorted.X/
├── hard/
│   ├── 0916_longest_ones_run.X/
│   └── 0924_quicksort.X/             # + figures/ (RAM heatmap, MDB dumps, plot script)
├── README.md
└── README.zh-TW.md
```

Each `*.X` folder is a complete MPLAB X project: the `.asm` source, a lab `README.md`, the top-level `Makefile` and the `nbproject/` configuration. Build output (`build/`, `dist/`, `debug/`) and machine-specific files (`nbproject/private/`, `Makefile-local-*.mk`) are git-ignored.

## Adding a new lab

1. Create the lab in MPLAB X (`PIC18F4520`, Simulator, MPASM) and get it working.
2. Copy the project folder to `<level>/<MMDD>_<short_topic>.X/` where level is `basic`, `advanced` or `hard`; keep the MPLAB project name equal to the folder name.
3. Run it in the simulator, record the final register/RAM contents and the cycle count.
4. Add a lab `README.md` with the same sections as the existing ones (task · memory map · how it works · expected result · run it).
5. Add a row to the table above (and in [README.zh-TW.md](README.zh-TW.md)).

## Verification

Each lab was assembled with MPASM through its own project Makefile and executed in MPLAB's command-line simulator (MDB); the data-RAM contents at the halt loop were dumped and compared with values computed by hand or in Python. Additional inputs were checked where the algorithm has interesting edge cases (bit-palindrome: `0x99`; longest run: `0x76`, `0xDD`).
