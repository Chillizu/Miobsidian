---
tags: [decision, architecture, analysis]
status: done
phase: 3
date: 2026-07-27
---
# WM as Pattern Matcher (Not Reasoner)

> **0.5B Qwen + LoRA 不做推理，只做 (s,a)→result 查表。**

## Evidence

1. **v1→v2 generalization failure**: e2 adapter L1=1.000 on v1 (4 dirs) → L1=0.800 on v2 (7 dirs). WM 没有学到"目录结构"概念，只是记住了 v1 的 layout。

2. **OOD L3 drop**: In-distribution L3=0.550 → OOD L3=0.400. 换一个目录结构，输出预测完全垮掉。

3. **read_note collapse**: v2 沙箱上 0% 完成率。`cat docs/note.txt` 在 v2 的 `/sandbox/docs/note.txt` 路径和 v1 不同 → WM 不认识。

## What This Means

- **Current WM** (0.5B + LoRA + 65 transitions): 输出取决于"见过没有"，不是"理不理解"
- **For genuine reasoning**: need 7B+ model, more data, multi-step curriculum

## Additional Evidence (Phase 3)

### Grid World Ceiling Effect (results/phase3_gpu/report.json)

Phase 3 的 Grid World 实验提供了最干净的证据：**0.5B + LoRA 在 25% 数据上就达到 g1=1.0 完美泛化。**

```
训练数据: partial_adapter_real_25_e3 (25% of 5×5 grid = ~6 cells)
PEDA goal_unknown:   10/10 (100%), μ=2.6 steps
Pragmatic goal_unknown: 10/10 (100%), μ=2.6 steps
Fisher p=1.0000, Mann-Whitney p=1.0000
```

WM 在只见过 25% 棋盘格子的情况下，对 **所有未知格子** 的 next-state 预测都达到 100% 准确。这不是"推理"——这是 0.5B 的参数容量远超 5×5 棋盘的复杂度（仅 25 个状态 × 4 动作 = 100 个可能的 (s,a) 映射），模型直接记住了所有可能的转移。

**结论**：在环境复杂度 << 模型容量的条件下，模式匹配覆盖率 = 100%，epistemic 信号 = 0。PEDA 退化为纯 greedy 导航（PEDA = Pragmatic）。

### 模型容量 vs 环境复杂度

0.5B 参数 ≈ 5亿个可学习参数；5×5 Grid World 有 100 个可能的 (s,a) 映射； Sandbox v2 有 65 个唯一的 (s,a) 对。**环境的信息量（≤ 100 个独立样本）远小于模型的表达能力（5亿参数）。**

这意味着：
- 模型不是在"学习规律"，而是在"记住训练集"——对 0.5B 来说 65 个样本就是查表
- 训练 loss 降到接近 0（e1: 0.4424→0.0001）不是因为模型"理解了"任务，而是因为训练集太小，模型完全过拟合
- 真正的泛化（如人类看到一个文件系统就能理解"cd + ls 遍历"的规则）需要 7B+ 级别的模型或专门的结构化训练

### Light JEPA 作为潜在解决方案

`PEDA_FINAL/PEDA_ENGINEERING_PLAN_v2.md` §11.2 提出了 **Light JEPA (Joint Embedding Predictive Architecture)** 作为隐藏状态层面的 epistemic 信号：

- 当前 token-space 的预测（next_token prediction）在模式匹配器下"认识就 confidence=1.0，不认识就随机猜"
- Light JEPA 在隐藏状态空间计算 ensemble 余弦距离——即使 token-space 输出相同，不同 checkpoint 的隐藏状态可能差异很大
- 这可以检测到"partial pattern match"——模型输出看似 100% 确定（token-space），但内部表示不一致（hidden-state）
- 参见 [[PEDA 完整架构详解]] 中关于 Light JEPA 的讨论

## Summary

**Current WM (0.5B + LoRA + 65 transitions)**：查表机。输出取决于"见过没有"，不是"理不理解"。

**瓶颈**：不是数据不够，是 5亿参数 / 65样本 ≈ 770万参数/样本。模型容量远超环境信息量 → 记忆而非理解。

**方向**：Light JEPA 隐藏状态 epistemic，或 7B+ 模型规模下的涌现推理能力。
> [!danger] 核心限制
> **Current WM (0.5B + LoRA + 65 transitions) = 查表机。** 输出取决于"见过没有"，不是"理不理解"。
>
> 瓶颈：5亿参数 / 65样本 ≈ 770万参数/样本。模型容量远超环境信息量 → 记忆而非理解。
>
> **方向**：Light JEPA 隐藏状态 epistemic，或 7B+ 模型规模下的涌现推理能力。
>

## Reference
- Held-out: `results/phase2_remaining/l1l2l3_heldout.json`
- OOD test: `scripts/phase2_create_ood_test.py`
