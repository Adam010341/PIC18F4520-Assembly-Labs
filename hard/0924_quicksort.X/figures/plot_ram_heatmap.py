#!/usr/bin/env python3
"""Before/after heatmap of the quicksort array (data RAM 0x100-0x1FF).

Usage, from the lab folder (hard/0924_quicksort.X):

    make CONF=default build
    mdb.sh figures/sim.mdb > sim.log            # MPLAB X command-line simulator
    python3 figures/plot_ram_heatmap.py sim.log  # refresh the dumps, then plot

Without an argument the script plots the dumps already in figures/
(ram_before.txt, ram_after.txt). Either way it first checks that
  * the "before" array equals the test vector in hard_924.asm, and
  * the "after" array is sorted ascending and is a permutation of "before",
and refuses to draw the figure if either check fails.
"""
import re
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.colors import LinearSegmentedColormap

HERE = Path(__file__).resolve().parent
ASM = HERE.parent / "hard_924.asm"
BEFORE = HERE / "ram_before.txt"
AFTER = HERE / "ram_after.txt"
PNG = HERE / "ram_heatmap.png"
BASE = 0x100

# Sequential single-hue ramp (light -> dark blue) and chart chrome.
BLUES = ["#cde2fb", "#b7d3f6", "#9ec5f4", "#86b6ef", "#6da7ec", "#5598e7", "#3987e5",
         "#2a78d6", "#256abf", "#1c5cab", "#184f95", "#104281", "#0d366b"]
SURFACE, INK, INK2, NEUTRAL = "#fcfcfb", "#0b0b0b", "#52514e", "#e4e3df"


def split_mdb_log(log_path):
    """Pull the two stopwatch readings and the two 256-byte dumps out of an MDB log."""
    lines = Path(log_path).read_text().splitlines()
    cycles = [int(m.group(1)) for l in lines
              if (m := re.match(r"Stopwatch cycle count = (\d+)", l))]
    dumps = []
    for i, l in enumerate(lines):
        if l.strip() == "x /r/256/x/b 0x100":
            rows = [r.split() for r in lines[i + 1:i + 17]]
            dumps.append([int(t, 16) for r in rows for t in r])
    if len(cycles) != 2 or len(dumps) != 2 or any(len(d) != 256 for d in dumps):
        sys.exit(f"{log_path}: expected 2 stopwatch readings and 2 dumps of 256 bytes")
    return cycles, dumps


def write_dump(path, data, header):
    rows = ["   ".join(f"{b:02x}" for b in data[r * 16:(r + 1) * 16]) for r in range(16)]
    path.write_text("".join(f"# {h}\n" for h in header) + "\n".join(rows) + "\n")


def read_dump(path):
    data, cycles = [], None
    for line in path.read_text().splitlines():
        if line.startswith("#"):
            if m := re.match(r"# cycles: (\d+)", line):
                cycles = int(m.group(1))
            continue
        data += [int(t, 16) for t in line.split()]
    assert len(data) == 256, f"{path}: {len(data)} bytes, expected 256"
    return data, cycles


def test_vector():
    """Length word and data bytes of the TESTCASE block in hard_924.asm."""
    src = ASM.read_text(encoding="latin-1")
    length = int(re.search(r"^DW\s+0x([0-9a-fA-F]+)", src, re.M).group(1), 16)
    body = [int(t, 16) for l in re.findall(r"^DB\s+(.*)$", src, re.M)
            for t in re.findall(r"0x([0-9a-fA-F]{2})", l)]
    assert len(body) == length, f"asm: length word {length}, {len(body)} data bytes"
    return body


def main():
    if len(sys.argv) > 1:
        (c_load, c_sort), (before, after) = split_mdb_log(sys.argv[1])
        common = "hard/0924_quicksort.X, data RAM 0x100-0x1FF, 16 bytes per row"
        write_dump(BEFORE, before, [
            common,
            "MDB simulator, halted at 0x0020 (MAIN): data loader done, sort not started",
            f"cycles: {c_load} (reset -> MAIN)"])
        write_dump(AFTER, after, [
            common,
            "MDB simulator, halted at 0x00CE (terminate loop): sort finished",
            f"cycles: {c_sort} (MAIN -> terminate); {c_load + c_sort} from reset"])

    before, c_load = read_dump(BEFORE)
    after, c_sort = read_dump(AFTER)
    vec = test_vector()
    n = len(vec)

    # Checks: loader output == test vector; result sorted and a permutation.
    assert before[:n] == vec, "before != test vector in hard_924.asm"
    assert after[:n] == sorted(before[:n]), "after != sorted(before)"
    assert all(a <= b for a, b in zip(after[:n], after[1:n])), "after not ascending"
    print(f"{n} bytes at 0x{BASE:03X}-0x{BASE + n - 1:03X}: before == asm test vector, "
          f"after == sorted(before), ascending {after[0]:02X}..{after[n - 1]:02X}")
    print(f"cycles: loader {c_load}, sort {c_sort}, total {c_load + c_sort}")

    plt.rcParams.update({"font.family": "DejaVu Sans", "text.color": INK,
                         "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2})
    cmap = LinearSegmentedColormap.from_list("blues", BLUES)
    fig, axes = plt.subplots(1, 2, figsize=(11.6, 6.6), facecolor=SURFACE)
    fig.subplots_adjust(left=0.07, right=0.89, top=0.765, bottom=0.10, wspace=0.22)
    panels = [
        (before, "Before: loaded by the data loader",
         f"halted at MAIN (0x0020), {c_load:,} cycles after reset"),
        (after, "After: sorted in place, ascending",
         f"halted at terminate (0x00CE), {c_sort:,} cycles later"),
    ]
    for ax, (data, title, sub) in zip(axes, panels):
        grid = np.ma.masked_array(np.array(data, float).reshape(16, 16),
                                  mask=np.arange(256).reshape(16, 16) >= n)
        ax.set_facecolor(NEUTRAL)
        mesh = ax.pcolormesh(grid, cmap=cmap, vmin=0, vmax=255,
                             edgecolors=SURFACE, linewidth=1.2)
        for k in range(n, 256):  # cells beyond the array: hatched, no value
            ax.add_patch(plt.Rectangle((k % 16, k // 16), 1, 1, facecolor=NEUTRAL,
                                       edgecolor=INK2, hatch="////", linewidth=0))
        ax.set_xlim(0, 16)
        ax.set_ylim(16, 0)  # address 0x100 at the top, like a memory view
        ax.set_aspect("equal")
        ax.set_xticks(np.arange(16) + 0.5, [f"{c:X}" for c in range(16)],
                      family="DejaVu Sans Mono", fontsize=10)
        ax.set_yticks(np.arange(16) + 0.5, [f"0x{BASE + 16 * r:03X}" for r in range(16)],
                      family="DejaVu Sans Mono", fontsize=10)
        ax.tick_params(length=0, pad=4)
        ax.xaxis.set_ticks_position("top")
        for s in ax.spines.values():
            s.set_visible(False)
        ax.set_title(f"{title}\n", fontsize=12, fontweight="bold", color=INK, pad=26)
        ax.text(0.5, 1.085, sub, transform=ax.transAxes, ha="center", fontsize=10,
                color=INK2)

    fig.canvas.draw()  # resolve the equal-aspect shrink, then match the colorbar to it
    box = axes[1].get_position()
    cax = fig.add_axes([0.915, box.y0, 0.016, box.height])
    cb = fig.colorbar(mesh, cax=cax, ticks=[0x00, 0x40, 0x80, 0xC0, 0xFF])
    cb.ax.set_yticklabels(["0x00", "0x40", "0x80", "0xC0", "0xFF"],
                          family="DejaVu Sans Mono", fontsize=10)
    cb.set_label("byte value (unsigned)", fontsize=10)
    cb.outline.set_visible(False)
    cb.ax.tick_params(length=0)

    fig.suptitle(f"PIC18F4520 quicksort: data RAM 0x{BASE:03X}–0x{BASE + n - 1:03X} "
                 f"before and after the sort ({n} bytes)",
                 x=0.07, ha="left", y=0.972, fontsize=14, fontweight="bold")
    fig.text(0.07, 0.915,
             f"MPLAB X simulator (MDB) memory dumps · result checked against Python "
             f"sorted() · sort: {c_sort:,} instruction cycles",
             fontsize=10, color=INK2)
    fig.text(0.07, 0.035,
             f"Each row is 16 consecutive bytes; the column is the address's low hex digit "
             f"(row 0x130, column 5 = 0x135). Hatched cell 0x{BASE + n:03X} is outside "
             f"the {n}-byte array.",
             fontsize=9, color=INK2)
    fig.savefig(PNG, dpi=150, facecolor=SURFACE)
    print(f"wrote {PNG.relative_to(HERE.parent)}")


if __name__ == "__main__":
    main()
