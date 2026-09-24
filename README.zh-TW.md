# PIC18F4520 Assembly Labs

![PIC18](https://img.shields.io/badge/MCU-PIC18F4520-EE2223)
![Assembly](https://img.shields.io/badge/language-PIC18%20assembly%20%28MPASM%29-6E4C13)
![MPLAB X](https://img.shields.io/badge/simulator-MPLAB%20X%20v5.20-555)

[English](README.md) · **繁體中文**

以 **PIC18F4520** 8 位元微控制器的組合語言完成的六個實驗,依難度分成三級:從暫存器運算,到使用軟體堆疊(software stack)的**原地迭代式快速排序(in-place iterative quicksort)**。每個 lab 都是可直接開啟的 **MPLAB X** 專案,完全在 MPLAB 模擬器中執行(不需要開發板),並且都驗證並記錄了執行結果。

| | |
|---|---|
| **目標 MCU** | PIC18F4520(8 位元、32 KB flash、1.5 KB RAM) |
| **語言** | PIC18 組合語言(MPASM) |
| **工具鏈** | MPLAB X IDE v5.20 · MPASM 5.84 · `PIC18Fxxxx_DFP` 1.0.9 |
| **執行環境** | MPLAB X 模擬器 — 不需要任何硬體 |

## Lab 一覽

每個 lab 有獨立的資料夾,內含原始碼、README(題目、記憶體配置、預期結果)以及 MPLAB X 專案檔。Lab 依實驗當天的月/日命名為 `MMDD_<主題>`(2026 年 9 月)。

| 難度 | Lab | 做什麼 | 關鍵技巧 | 結果 · 成本 |
|---|---|---|---|---|
| **Basic** | [0916 · Sum & Compare](basic/0916_sum_compare.X) | 兩組數字各自相加,比較兩個和並寫入狀態碼 | `ADDWF`、比較後跳過(`CPFSEQ`/`CPFSGT`)組成三向分支 | `0x20 = 0x33` · 25 cycles |
| **Basic** | [0924 · Parity-Dependent Recurrence](basic/0924_parity_recurrence.X) | 由 3 項種子延伸成 6 項,規則取決於前一項是奇數或偶數 | 分頁 RAM(`MOVLB`)、`FSR0`/`FSR1` 間接定址、`BTFSC`、`DCFSNZ` | `64 50 29 27 02 52` · 55 cycles |
| **Advanced** | [0916 · Bit-Palindrome Check](advanced/0916_bit_palindrome.X) | 用旋轉指令反轉一個 byte 的 bit,判斷是否與原值相同 | `BTFSS`、`RLNCF`/`RRNCF`、計數迴圈 | `0x10 = 0x0D`,旗標 `0x00` · 111 cycles |
| **Advanced** | [0924 · Merge Two Sorted Sequences](advanced/0924_merge_sorted.X) | 把兩個遞增序列(6 + 5 bytes)合併成一個遞減序列 | 同時使用三個 FSR、`POSTINC`、`MOVFF`、雙指標合併 | `FD B4 95 … 10 0F` · 288 cycles |
| **Hard** | [0916 · Longest Run of 1s](hard/0916_longest_ones_run.X) | 找出一個 byte 中最長的連續 `1` | 逐 bit 掃描、維護最大值、巢狀分支 | `0xFF → 8` · 117 cycles |
| **Hard** | [0924 · In-Place Quicksort](hard/0924_quicksort.X) | 原地排序 255 bytes,以 RAM 中的顯式堆疊取代遞迴 | `FSR2` 軟體堆疊、16 位元指標進位、三個 FSR | 遞增排序完成 · 31,495 cycles |

*Cost = 在 MPLAB X 模擬器中,從 reset 執行到最後的停止迴圈所需的指令週期數,以 repo 中預設的輸入計算。*

## 亮點:8 位元核心上的迭代式快速排序

[hard/0924](hard/0924_quicksort.X) 是整個 repo 的重心。這個程式不使用遞迴(PIC18 的硬體 call stack 只有 31 層,而且只存返回位址、無法放區域變數),而是在資料 RAM 中維護一個**待處理子區間的堆疊**,以 `FSR2` 操作;同時用 `FSR0` 與 `FSR1` 從陣列兩端向中間掃描:

```
資料 RAM
0x000        陣列長度(0xFF)
0x001–0x004  pivot 值 · 左界 · 右界 · pivot 位置
0x100–0x1FE  陣列本體 — 原地排序
0x300 …      (left, right) 軟體堆疊   ← FSR2
```

少於兩個元素的子區間不會被推入堆疊。結果:255 bytes 在 **31,495 個週期**(資料載入程式 1,796、排序本身 29,699)內排序完成,整個程式(排序常式加載入程式)只佔 **210 bytes flash**。傾印出的 RAM 內容已與 Python `sorted()` 對原輸入的結果逐 byte 比對,完全一致。

![排序前後的資料 RAM 0x100–0x1FE 熱圖](hard/0924_quicksort.X/figures/ram_heatmap.png)

*資料 RAM 中的陣列,每格一個 byte(顏色越深值越大),由 MDB 模擬器分別在資料載入程式剛結束時(左)與 29,699 個週期後到達停止迴圈時(右)傾印:255 個 byte 全部變成遞增排列,`06` … `FF`。原始傾印、MDB 腳本與繪圖腳本:[`hard/0924_quicksort.X/figures/`](hard/0924_quicksort.X/figures)。*

## 這些 lab 展現的能力

- **PIC18 記憶體模型** — access bank 與 banked 存取(`MOVLB` / BSR)、file register 定址、跨多個 RAM bank(`0x0xx`–`0x3xx`)操作。
- **間接定址** — `FSR0`/`FSR1`/`FSR2` 搭配 `INDF`、`POSTINC`、`PREINC`、`POSTDEC`;在同一個常式中同時使用三個指標。
- **沒有「比較後分支」指令的流程控制** — 以跳過指令(`CPFSEQ`、`CPFSGT`、`CPFSLT`、`BTFSS`、`BTFSC`、`DCFSNZ`)組出比較、迴圈與三向判斷。
- **位元操作** — 不經 carry 的旋轉、位元測試、位元反轉。
- **資源極度受限下的演算法** — 雙指標合併、逐 bit 的連續長度掃描,以及手動管理堆疊的快速排序,每個程式最多只佔 210 bytes flash。
- **驗證習慣** — 每個結果都實際執行(模擬器 / MDB)並與獨立計算的結果交叉比對,而不是只靠閱讀程式碼。

## 開始使用

**需求:** MPLAB X IDE(以 Linux 上的 v5.20 開發)與 MPASM 工具鏈。不需要燒錄器或開發板。

1. 複製 repository:
   ```bash
   git clone https://github.com/Adam010341/PIC18F4520-Assembly-Labs.git
   ```
2. 在 MPLAB X 選擇 **File ▸ Open Project…**,選取任一 lab 資料夾(例如 `hard/0924_quicksort.X`)。第一次開啟時 MPLAB X 會自動重新產生與機器相關的建置檔。
3. 檢查 **Project Properties**:裝置 `PIC18F4520`、工具 `Simulator`、工具鏈 `MPASM`。
4. 執行專案(**Debug Main Project**)。每個程式都結束在 `GOTO terminate` 迴圈 — 在那裡暫停即可。
5. 開啟 **Window ▸ Target Memory Views ▸ File Registers**,查看該 lab README 列出的位址。

除了 `hard/0924_quicksort.X/hard_924.asm`,所有原始碼開頭都使用相同的組態:`CONFIG OSC = INTIO67`(內部振盪器)與 `CONFIG WDT = OFF`(關閉看門狗)。quicksort 原始碼沒有 `CONFIG` 行，因此使用晶片預設的組態位元。

## Repository 結構

```
.
├── basic/
│   ├── 0916_sum_compare.X/
│   └── 0924_parity_recurrence.X/
├── advanced/
│   ├── 0916_bit_palindrome.X/        # + earlier_attempt/(第一版,供對照)
│   └── 0924_merge_sorted.X/
├── hard/
│   ├── 0916_longest_ones_run.X/
│   └── 0924_quicksort.X/             # + figures/(RAM 熱圖、MDB 傾印、繪圖腳本)
├── README.md
└── README.zh-TW.md
```

每個 `*.X` 資料夾都是完整的 MPLAB X 專案:`.asm` 原始碼、該 lab 的 `README.md`、頂層 `Makefile` 與 `nbproject/` 設定。建置輸出(`build/`、`dist/`、`debug/`)與機器相關檔案(`nbproject/private/`、`Makefile-local-*.mk`)已由 `.gitignore` 排除。

## 新增 lab 的流程

1. 在 MPLAB X 建立 lab(`PIC18F4520`、Simulator、MPASM)並確認能正常運作。
2. 將專案資料夾複製到 `<難度>/<MMDD>_<簡短主題>.X/`,難度為 `basic`、`advanced` 或 `hard`;MPLAB 專案名稱需與資料夾名稱一致。
3. 在模擬器中執行,記錄最終的暫存器 / RAM 內容與週期數。
4. 撰寫該 lab 的 `README.md`,章節與既有的相同(題目 · 記憶體配置 · 運作方式 · 預期結果 · 執行方式)。
5. 在上方表格新增一列(同時更新 [README.md](README.md))。

## 驗證方式

每個 lab 都透過其專案自己的 Makefile 以 MPASM 組譯,並在 MPLAB 的命令列模擬器(MDB)中執行;在停止迴圈處傾印資料 RAM,與手算或以 Python 算出的值比對。對演算法有邊界情況的 lab 另外測試了額外輸入(bit-palindrome:`0x99`;longest run:`0x76`、`0xDD`)。
