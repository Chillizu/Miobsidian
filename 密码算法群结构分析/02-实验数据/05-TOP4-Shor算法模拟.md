---
title: "TOP4: Shor 算法模拟"
tags: [cryptography, experiment, Shor, quantum]
date: 2026-07-14
aliases: [Shor Algorithm Simulation]
---

# TOP4: Shor 算法模拟

> **实验日期:** 2026-07-14 07:56
> **平台:** Intel Core Ultra 9 185H, Arch Linux
> **参见:** [[02-实验数据/01-实验数据总览]]

---

## 实验目标

在经典计算机上模拟 Shor 算法分解小整数，验证算法正确性，并基于复杂度外推 RSA-2048 的量子资源需求。

## 分解结果

| $N$ | 因子 | 时间 (s) |
|-----|------|----------|
| 15 | $3 \times 5$ | < 0.001 |
| 21 | $3 \times 7$ | < 0.001 |
| 33 | $3 \times 11$ | < 0.001 |
| 35 | $5 \times 7$ | < 0.001 |
| 77 | $7 \times 11$ | < 0.001 |
| 143 | $11 \times 13$ | < 0.001 |

全部 6 个合数均正确分解，验证了 Shor 算法的周期查找-因子分解等价性。

## 量子资源外推

基于 Shor (1994) 的算法复杂度 $O((\log N)^3)$ 和门分解估计，对 RSA-2048 的资源需求外推如下：

| 指标 | 估值 |
|------|------|
| 所需量子比特 | $\sim 4{,}100$ |
| 量子门数 | $\sim 10^{11}$ |
| 量子-经典交叉点 | $\sim 30$ bits |

### 交叉点分析

量子-经典交叉点（QC crossover）约在 **30 bits**：对于 $\leq 30$-bit 的合数，经典算法（GNFS / ECM）比含纠错开销的量子 Shor 更快。RSA-2048 远在此交叉点之上，量子加速显著。

## 图表

### 资源缩放曲线

![[chart_shor_scaling.png]]

量子比特和门数随合数规模指数增长，验证 Shor 算法的多项式时间复杂度。

### 分解成功率

![[chart_shor_success.png]]

所有测试整数均成功分解（成功率 100%）。

### T 门增长

![[chart_shor_tgates.png]]

T 门（容错量子计算中最昂贵的门）随问题规模的增长趋势。

### 分解时间

![[chart_shor_timing.png]]

经典模拟下分解时间随 $N$ 增长曲线 — 小整数范围内基本不变。

## 关键发现

1. **Shor 算法对小整数有效** — 6/6 全部成功分解，验证核心逻辑正确。
2. **RSA-2048 需要 ~4,100 量子比特** — 当前量子硬件（~1,000 物理量子比特）距离门操作量子计算机仍远。
3. **经典-量子交叉点在 ~30 bits** — 对小模数 RSA 经典算法仍有优势。
4. **T 门是主要瓶颈** — 在容错量子计算中 T 门占主导开销，其增长趋势与门总数一致。

> **注意:** 本实验未安装 Qiskit，因此所有模拟均在经典模式下进行，不涉及实际量子态向量演化。量子资源估计来自理论分析而非仿真。

## 产出文件

| 文件 | 用途 |
|------|------|
| `shor_simulation.py` | 模拟脚本 (13.6 KB) |
| `resource_scaling.csv` | 量子资源缩放数据 |
| `chart_shor_scaling.png` | 门/量子比特缩放曲线 |
| `chart_shor_success.png` | 成功率柱状图 |
| `chart_shor_tgates.png` | T 门需求增长 |
| `chart_shor_timing.png` | 分解时间 |
| `SUMMARY.md` | 摘要 |

## 引用

- Shor, P. W. (1994). Polynomial-time algorithms for prime factorization and discrete logarithms on a quantum computer.
- Gidney & Ekerå (2019). How to factor 2048-bit RSA integers in 8 hours using 20 million noisy qubits.
