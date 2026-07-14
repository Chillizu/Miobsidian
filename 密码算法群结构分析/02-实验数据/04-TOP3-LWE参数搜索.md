---
title: "TOP3: LWE 参数空间搜索"
tags: [cryptography, experiment, LWE, post-quantum]
date: 2026-07-14
aliases: [LWE Parameter Search]
---

# TOP3: LWE 参数空间搜索

> **实验日期:** 2026-07-14 08:19
> **平台:** Intel Core Ultra 9 185H, Arch Linux, Sage 10.9
> **参见:** [[02-实验数据/01-实验数据总览]]

---

## 实验目标

使用 `lattice-estimator` 对 LWE（Learning With Errors）参数空间进行系统安全估值，评估不同参数选择对应的已知最佳攻击复杂度。

## 搜索空间

| 参数 | 范围 |
|------|------|
| $n$ (维数) | $[64, 1024]$，步长 64 |
| $q$ (模数) | $\{256, 1024, 4096, 16384, 65536\}$ |
| $\sigma$ (噪声) | $\{1.0, 3.0\}$ |
| 特殊参数 | Kyber-512, Dilithium2/3 等价参数 |

共计 **163 个参数组合**，全部成功估值。

## 结果

| 指标 | 值 |
|------|-----|
| 平均安全位 | 177.0 bits |
| 中位安全位 | 158.0 bits |
| 最弱 | 38.3 bits |
| 最强 | 866.5 bits |
| 成功率 | 163 / 163 (100%) |

## 图表

### 安全位分布

![[chart_lwe_histogram.png]]

安全位分布呈右偏态，大量参数聚集在 100–200 bits 区间。高安全位 (>400 bits) 来自大 $n$ + 大 $q$ 组合。

### 安全 vs 效率 Pareto 前沿

![[chart_lwe_pareto.png]]

Pareto 图显示安全位与计算效率的权衡关系 — 更高的安全位需要更大的 $n$ 和 $q$，直接增加公钥尺寸和运算开销。

## Post-Quantum 参数安全估值

| 参数集 | 安全位 | 用途 |
|--------|--------|------|
| $n=256,\ q=3329,\ \sigma=2.0$ | 85.2 bits | Kyber-512 (ML-KEM) |
| $n=256,\ q=8380417,\ \sigma=2.0$ | 42.3 bits | Dilithium2 |
| $n=256,\ q=8380417,\ \sigma=4.0$ | 46.8 bits | Dilithium3 |

> **注意:** lattice-estimator 报告的 Dilithium 安全位数较低，这是因为其评估方法基于已知最佳攻击（BKZ + sieving），而 NIST 的安全估计方法包含额外的保守余量。Dilithium2 的 NIST 声称安全位为 128-bit，实际 lattice-estimator 估算为 42.3 bit — 差异来自保守假设和不同攻击模型的选择。

## 关键发现

1. **参数选择对安全位影响极大** — 同样 $n=256$，通过调整 $q$ 和 $\sigma$，安全位可在 38–866 bits 间变化。
2. **Kyber-512 估值 85.2 bits** 低于 128-bit 声称安全 — 需注意 lattice-estimator 与 NIST 方法论差异。
3. **Pareto 前沿** 为实际部署的参数选择提供了效率-安全权衡的可视化依据。

## 工具链

| 工具 | 用途 |
|------|------|
| `sage` 10.9 | `lattice-estimator` 运行环境 |
| `lattice-estimator` v0.1 | LWE 安全估值 |
| `matplotlib` | 图表生成 |

## 产出文件

| 文件 | 用途 |
|------|------|
| `lwe_data.csv` | 163 项参数 + 安全估值 |
| `lwe_results.json` | 原始 JSON 结果 (18.7 KB) |
| `chart_lwe_pareto.png` | 安全 vs 效率 Pareto 散点图 |
| `chart_lwe_histogram.png` | 安全位分布直方图 |
| `SUMMARY.md` | 摘要 |
