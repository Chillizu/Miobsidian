---
title: "TOP1: DES 非群验证"
tags: [cryptography, experiment, DES]
date: 2026-07-14
aliases: [DES Non-Group Verification]
---

# TOP1: DES 非群验证

> **实验日期:** 2026-07-14 08:00
> **平台:** Intel Core Ultra 9 185H, Arch Linux
> **参见:** [[02-实验数据/01-实验数据总览]]

---

## 实验目标

验证 DES 复合运算是否形成群。Campbell & Wiener (1992) 证明 DES 生成的子群大小至少为 $10^{2499}$，本实验通过采样方法对"非群"结论进行实证支持。

## 方法

随机选取 20 个 DES 密钥，对固定明文（8 字节）计算所有 100,000 种两两复合 $\text{DES}_{k_1}(\text{DES}_{k_2}(m))$，检验重复性。实验分三个子实验：

| 子实验 | 方法 | 样本量 |
|--------|------|--------|
| Exp1: Birthday 采样 | 逐步扩大采样量，记录不同复合数 | 100,000 |
| Exp2: 碰撞矩阵 | 50 对密钥 × 500 个 $K_3$ 穷举碰撞 | 25,000 |
| Exp3: 分布比较 | 单密钥 vs 双密钥输出分布 Jaccard 比较 | 50,000 |

## 结果

| 指标 | 值 |
|------|-----|
| 不同复合结果 | 100,000 / 100,000 (100%) |
| 碰撞次数 | 0 |
| Jaccard 重叠度 | 0.00% |
| 采样速率 | ~47,500 samples/s |
| 总耗时 | < 0.1 min |

### Exp1 — Birthday 采样

![[exp1_distinct_growth.png]]

累积不同复合数随采样量线性增长至 100,000，未出现典型的群饱和现象（若为群，新复合数量应随采样增加而递减）。

### Exp2 — 碰撞矩阵

![[exp2_collision_heatmap.png]]

50 对密钥交叉验证，共 25,000 次 $\text{DES}^{-1}_{k_3}(\text{DES}_{k_1}(\text{DES}_{k_2}(m)))$ 碰撞搜索，均为 0 匹配。

### Exp3 — 分布比较

![[exp3_distribution.png]]

单密钥 (50,000 distinct) 与双密钥 (50,000 distinct) 输出集合 Jaccard 相似度 0.0000，分布完全不相交。

## 结论

实验结果与"DES 不是群"的文献结论 **一致**。三个独立子实验均在统计意义上排除了小群假设。

> Campbell & Wiener (1992) 严格证明 DES 复合生成的子群规模至少为 $10^{2499}$ —— 远超出任何采样实验的探测范围。本实验的零碰撞结果在此上下文中是预期的。

## 产出文件

| 文件 | 用途 |
|------|------|
| `des_nongroup.py` | 实验脚本 (9.9 KB) |
| `exp1_distinct_growth.png` | 不同复合数 vs 采样量曲线 |
| `exp2_collision_heatmap.png` | 碰撞矩阵热图 |
| `exp3_distribution.png` | 分布对比图 |
| `exp1_data.csv` | 增长数据 |
| `exp3_stats.csv` | 分布统计 |
| `SUMMARY.md` | 摘要 |
| `top1_run.log` | 运行日志 |

## 引用

- Campbell & Wiener (1992). DES is not a group.
- Kaliski (1988). DES is not a group — preliminary evidence.
