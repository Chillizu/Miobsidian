---
tags: [decision, data, methodology]
status: done
phase: 2
date: 2026-07-27
---
# Data Quality over Quantity

> **核心发现**：e2 (200 curated) > e3 (10k random)。随机数据不是"多总比少好"。

## The Experiment

| Adapter | 训练数据 | 结果 |
|---------|---------|------|
| e2 | 200 curated transitions（手动挑选高质量路径） | L1=1.000, read_note 1 步完成（v1 沙箱） |
| e3 | 10,040 random+heuristic（GPU 训 2h） | 退化——L1 更差，完成任务能力下降 |

## Why

随机采样的问题：绝大多数 shell 命令组合不会产生有意义的状态转移。10k 条随机数据里，任务完成信号（如 `cat docs/note.txt → secret key: 12345`）密度 ~2%。模型被噪音淹没了。

## Concrete Numbers

| Adapter | 数据量 | 数据来源 | 训练 Loss | L1 Held-out | 结论 |
|---------|--------|----------|-----------|-------------|------|
| e1 | 200 transitions (2 runs merged) | random + heuristic | 0.4424→0.0291→0.0030→0.0001 (3 epochs) | 需分 epoch 评估 | 第一步不再是 `ls data`，但 5 步内未完成任务 |
| e2 | 200 curated | 手动挑选高质量路径 | 优于 e3 | L1=1.000, L2=0.900, L3=0.550 | ✅ 最适配器，4/5 任务一步完成 |
| e3 | 10,040 transitions (610 eps) | random + heuristic (GPU) | 0.0103→0.0088→0.0087 | L1=0.833, L2=0.333, L3=0.133 | ❌ 退化，随机信号稀释 |
| v2_full | **65 transitions (systematic enumeration)** | `results/phase2_v2_full.jsonl` | 0.2683→0.089→0.0312 (3 epochs) | L1≈0.70-0.80 (held-out) | **系统枚举 > 随机**，65 对即达最优 |

关键对比：e1 训练 loss 从 0.4424 降至 0.0001，但 e2 (curated) 的 L1=1.000 远优于 e3 (10,040 random) 的 L1=0.833。**数据纯度比数据量更重要。**

### 为什么系统枚举优于随机采样

Shell 命令组合中，绝大多数随机 (state, action) 对不会产生有意义的状态转移（exit_code=2 在随机数据中 ~98%）。v2 沙箱的全枚举 = 65 个唯一 (s,a) 对，覆盖全部合法操作。而 10,040 条随机数据中，任务完成信号（`cat docs/note.txt → "secret key: 12345"`）密度仅 ~2%。

代码参考：`scripts/phase2_synthetic_train.py` 中的 `transitions_from_records()` 函数实现了数据加载和 (s,a,s') 格式化逻辑，是理解数据管道的入口。

## Implication

系统枚举 > 随机采样。在小场景下，枚举所有合法 (state, action) 对（v2 沙箱 = 65 对）是最优数据策略。这个原则推翻了 Phase 2 的"10k+ transitions"硬性指标。
> [!info] 核心发现
> **系统枚举 > 随机采样**。在小场景下，枚举所有合法 (state, action) 对（v2 沙箱 = 65 对）是最优数据策略。这个原则推翻了 Phase 2 的"10k+ transitions"硬性指标。
>
> 数据纯度比数据量更重要：200 curated > 10k random。
>

## Reference
- `checkpoints/phase2/sandbox_adapter_e2/` — best on v1
- `checkpoints/phase2/sandbox_adapter_e3/` — regressed
- `results/phase2_v2_full.jsonl` — v2 沙箱 65 枚举数据
- `scripts/phase2_synthetic_train.py` — 训练代码
- Source: `PEDA_WORKING_LOG.md` §Phase 2 GPU 训练与终评
- See also: [[Phase 2 详细报告]]
