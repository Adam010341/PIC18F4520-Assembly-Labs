# PIC18F4520 Assembly Labs

![PIC18](https://img.shields.io/badge/MCU-PIC18F4520-EE2223)
![Assembly](https://img.shields.io/badge/language-PIC18%20assembly%20%28MPASM%29-6E4C13)
![MPLAB X](https://img.shields.io/badge/simulator-MPLAB%20X%20v5.20-555)

[English](README.md) · **繁體中文**

六個 PIC18F4520 組合語言(MPASM)lab,從簡單的暫存器運算到使用軟體堆疊的原地快速排序。每個都是 MPLAB X 專案,在模擬器中執行,不需要開發板。

| | |
|---|---|
| 目標 MCU | PIC18F4520(8 位元、32 KB flash、1.5 KB RAM) |
| 工具鏈 | MPLAB X IDE v5.20 · MPASM 5.84 · `PIC18Fxxxx_DFP` 1.0.9 |

## Lab 一覽

每個 lab 資料夾有原始碼、README(題目、記憶體配置、預期結果)與 MPLAB X 專案檔。名稱 `MMDD_<主題>` 是實驗當天的月/日(2026 年 9 月)。

| 難度 | Lab | 做什麼 | 關鍵技巧 | 結果 · 成本 |
|---|---|---|---|---|
| Basic | [0916 · Sum & Compare](basic/0916_sum_compare.X) | 兩組數字各自相加,比較兩個和並寫入狀態碼 | `ADDWF`、比較後跳過(`CPFSEQ`/`CPFSGT`)組成三向分支 | `0x20 = 0x33` · 25 cycles |
| Basic | [0924 · Parity-Dependent Recurrence](basic/0924_parity_recurrence.X) | 由 3 項種子延伸成 6 項,規則取決於前一項是奇數或偶數 | 分頁 RAM(`MOVLB`)、`FSR0`/`FSR1` 間接定址、`BTFSC`、`DCFSNZ` | `64 50 29 27 02 52` · 55 cycles |
| Advanced | [0916 · Bit-Palindrome Check](advanced/0916_bit_palindrome.X) | 用旋轉指令反轉一個 byte 的 bit,判斷是否與原值相同 | `BTFSS`、`RLNCF`/`RRNCF`、計數迴圈 | `0x10 = 0x0D`,旗標 `0x00` · 111 cycles |
| Advanced | [0924 · Merge Two Sorted Sequences](advanced/0924_merge_sorted.X) | 把兩個遞增序列(6 + 5 bytes)合併成一個遞減序列 | 同時使用三個 FSR、`POSTINC`、`MOVFF`、雙指標合併 | `FD B4 95 … 10 0F` · 288 cycles |
| Hard | [0916 · Longest Run of 1s](hard/0916_longest_ones_run.X) | 找出一個 byte 中最長的連續 `1` | 逐 bit 掃描、維護最大值、巢狀分支 | `0xFF → 8` · 117 cycles |
| Hard | [0924 · In-Place Quicksort](hard/0924_quicksort.X) | 原地排序 255 bytes,以 RAM 中的顯式堆疊取代遞迴 | `FSR2` 軟體堆疊、16 位元指標進位、三個 FSR | 遞增排序完成 · 31,495 cycles |

*Cost = 在 MPLAB X 模擬器中,從 reset 執行到最後停止迴圈的指令週期數,以 repo 中預設的輸入計算。*

## 快速排序

[hard/0924](hard/0924_quicksort.X) 不用遞迴。PIC18 的硬體 call stack 只有 31 層,而且只存返回位址。所以我在資料 RAM 裡自己維護待處理子區間的堆疊,用 `FSR2` 存取;`FSR0` 和 `FSR1` 從陣列兩端掃描。

```
資料 RAM
0x000        陣列長度(0xFF)
0x001–0x004  pivot 值 · 左界 · 右界 · pivot 位置
0x100–0x1FE  陣列本體,原地排序
0x300 …      (left, right) 軟體堆疊   ← FSR2
```

少於兩個元素的子區間不會被推入堆疊。255 bytes 在 31,495 個週期(資料載入 1,796、排序 29,699)內排完,整個程式只佔 210 bytes flash。傾印出的 RAM 已與 Python `sorted()` 對原輸入的結果逐 byte 比對。

![排序前後的資料 RAM 0x100–0x1FE 熱圖](hard/0924_quicksort.X/figures/ram_heatmap.png)

*資料 RAM,每格一個 byte(顏色越深值越大),由 MDB 模擬器在資料載入結束後(左)與 29,699 個週期後的停止迴圈(右)傾印。傾印檔、MDB 腳本與繪圖腳本在 [`hard/0924_quicksort.X/figures/`](hard/0924_quicksort.X/figures)。*

## 建置與執行

需要 MPLAB X IDE(以 Linux 上的 v5.20 開發)與 MPASM。不需要燒錄器或開發板。

1. `git clone https://github.com/Adam010341/PIC18F4520-Assembly-Labs.git`
2. 在 MPLAB X 選 File ▸ Open Project…,選一個 lab 資料夾(例如 `hard/0924_quicksort.X`)。
3. 檢查 Project Properties:裝置 `PIC18F4520`、工具 `Simulator`、工具鏈 `MPASM`。
4. Debug Main Project。每個程式都停在 `GOTO terminate` 迴圈,在那裡暫停。
5. 開啟 Window ▸ Target Memory Views ▸ File Registers,查看該 lab README 列出的位址。

除了 `hard/0924_quicksort.X/hard_924.asm`,所有原始碼都設定 `CONFIG OSC = INTIO67` 與 `CONFIG WDT = OFF`。quicksort 原始碼沒有 `CONFIG` 行,使用晶片預設的組態位元。

## 結構

```
.
├── basic/
│   ├── 0916_sum_compare.X/
│   └── 0924_parity_recurrence.X/
├── advanced/
│   ├── 0916_bit_palindrome.X/        # + earlier_attempt/(第一版)
│   └── 0924_merge_sorted.X/
├── hard/
│   ├── 0916_longest_ones_run.X/
│   └── 0924_quicksort.X/             # + figures/(RAM 熱圖、MDB 傾印、繪圖腳本)
├── README.md
└── README.zh-TW.md
```

每個 `*.X` 資料夾包含 `.asm` 原始碼、該 lab 的 `README.md`、`Makefile` 與 `nbproject/`。

## 驗證方式

每個 lab 都透過其 Makefile 以 MPASM 組譯,並在 MPLAB 的命令列模擬器(MDB)中執行;在停止迴圈處傾印資料 RAM,與手算或 Python 算出的值比對。另外測試了邊界輸入(bit-palindrome:`0x99`;longest run:`0x76`、`0xDD`)。
