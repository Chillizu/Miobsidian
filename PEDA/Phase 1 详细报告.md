---
tags: [experiment, report, phase1]
status: completed
phase: 1
date: 2026-07-27
---
# Phase 1 详细报告

> **核心结论**：工程基础设施验证通过，核心假设**未能验证**。5×5 Grid World 对 Qwen2.5-0.5B 太简单，产生了 ceiling effect，PEDA 与 Pragmatic 在所有指标上无差异。

---

## 实验设计
> [!danger] 核心结论
> 工程基础设施验证通过，但核心假设**未能验证**。5×5 Grid World 对 Qwen2.5-0.5B 太简单，产生了天花板效应（ceiling effect），PEDA 与 Pragmatic 在所有指标上无差异（p=1.0）。
>
> 3/7 success criteria passed — 仅基础设施建设相关标准通过，核心假设标准全部失败。
>

### 环境

5×5 Grid World，4 动作（上下左右），25 离散状态。部分配置包含障碍物 cell。

- 状态空间：25 grid positions
- 动作空间：4（up, down, left, right）
- 目标：从随机起始位置导航到固定 goal

### 模型

- **LLM**：`Qwen/Qwen2.5-0.5B-Instruct`（5 亿参数）
- **Adapter**：LoRA fine-tune，checkpoint 每 epoch 保存
- **Adapter 路径**：`checkpoints/phase1/partial_adapter_real_25_e3`（25% 数据训练 3 epoch）

### 训练数据

20 个 drive-weight 配置 × ~24 free cells × 4 actions ≈ 1920 transitions（grid search 评估数据）。partial training 子集：

| 训练比例 | 训练 cell 数 | 训练样本 | 3-epoch loss 曲线 |
|----------|-------------|---------|------------------|
| 25% | 6/25 | 448 | 0.0308→0.0047→0.0035 |
| 10% | 2/25 | 148 | 0.0739→0.0134→0.0011 |

数据来源：`PEDA_FINAL/archive/phase1/phase1_gap_report.md`。

### Drive 权重

最终推荐配置（来自 Pareto frontier）：

```json
{
  "curiosity": 0.5, "competence": 0.5,
  "boredom": 0.5, "novelty": 0.5
}
```

注意：由于 G1=1.0，drive 权重对行为无实质影响。此推荐是 tie-breaker，非有效性证据。

---

## 正式指标（G1/G2/G3）

数据来源：`results/phase1_eval.json`（[source](file:///home/chillizu/Projects/Folunar_/results/phase1_eval.json)）。

| Gate | 指标 | 值 | 阈值 | 结果 |
|------|------|----|------|------|
| **G1** | WM next-state 准确率 | **1.0000** | > 0.90 | PASS |
| **G2** | steps vs random 比率 | **0.4337** (3.6 vs 8.3 steps) | < 0.50 | PASS |
| **G3** | 重访率 | **0.0000** | < 0.20 | PASS |
| **All** | — | 3/3 pass | — | ✅ |

G2 详细：PEDA mean steps = 3.6，random baseline = 8.3，ratio = 0.4337。random_mean_steps 来自 `results/phase1_eval.json`。

---

## Partial Training 实验

数据来源：`PEDA_FINAL/archive/phase1/phase1_gap_report.md`（[source](file:///home/chillizu/Projects/Folunar_/PEDA_FINAL/archive/phase1/phase1_gap_report.md)）。

### 25% 训练（6/25 cells）
- 训练 3 epoch 后，g1_test_set = 1.0（完美泛化到全部网格）
- ensemble 分歧率：2/28 (7%)

### 10% 训练（2/25 cells）
- 训练 3 epoch 后，g1_test_set ≈ 1.0
- ensemble 分歧率：5/28 (18%)

即使只训练 2/25 个 cell（10% 数据），0.5B 模型也能在 3 epoch 内完美泛化到全部 25 个网格。核心问题：**模型容量远超环境复杂度**。

---

## Held-Out 障碍物测试

数据来源：`results/phase1_heldout_summary.json`（[source](file:///home/chillizu/Projects/Folunar_/results/phase1_heldout_summary.json)）。

3 种障碍物布局，每种 PEDA vs Pragmatic × 5 episodes。

| 障碍物布局 | PEDA steps | Pragmatic steps | PEDA 成功 | Pragmatic 成功 |
|-----------|-----------|----------------|-----------|---------------|
| [[1,1],[3,1],[1,3],[3,3]] | 2.67 (n=3) | 3.00 (n=4) | 100% | 100% |
| [[1,2],[2,2],[3,2]] | 13.00 (n=1) | 4.67 (n=3) | 100% | 100% |
| [[2,1],[2,2],[2,3]] | 1.67 (n=3) | 1.67 (n=3) | 100% | 100% |

总体：17/30 完成（13 timeout），总体成功率 100%，总体 mean steps = 3.35。

**关键**：PEDA 和 Pragmatic 在所有布局上表现相同。epistemic error 全部为 0.0，验证了 ceiling effect。

---

## N=10 确认实验（GPU Grid World）

数据来源：`results/phase3_gpu/report.json`（[source](file:///home/chillizu/Projects/Folunar_/results/phase3_gpu/report.json)）。

在 AWS g4dn.xlarge（T4 15GB GPU）上运行，N=10 per condition × 2 conditions × 2 baselines = 40 episodes，876 秒完成。

### Goal-Known 条件

| 指标 | PEDA (n=10) | Pragmatic (n=10) |
|------|------------|-----------------|
| 成功率 | 10/10 (100%) | 10/10 (100%) |
| Mean steps | **3.3** (SD=1.35) | **3.3** (SD=1.35) |
| Median steps | 4 | 4 |
| Min-Max | 1-6 | 1-6 |
| 重访率 | 0.0 | 0.0 |

### Goal-Unknown 条件

| 指标 | PEDA (n=10) | Pragmatic (n=10) |
|------|------------|-----------------|
| 成功率 | 10/10 (100%) | 10/10 (100%) |
| Mean steps | **2.6** (SD=1.85) | **2.6** (SD=1.85) |
| Median steps | 2 | 2 |
| Min-Max | 1-6 | 1-6 |
| 重访率 | 0.0 | 0.0 |

### 统计检验

| 检验 | p-value | 显著？ |
|------|---------|--------|
| Fisher exact（goal_unknown 成功率）| **1.000** | ❌ |
| Mann-Whitney U（goal_unknown steps）| **1.000** | ❌ |
| Fisher exact（goal_known fairness）| **1.000** | ✅（fairness pass） |

### 判定

```
verdict: "CORE_HYPOTHESIS_NOT_SUPPORTED"
passed_criteria: "3/7"
```

成功标准中仅 goal_known fairness pass、peda/pragmatic goal_unknown success > 60% 通过。PEDA≠Pragmatic 的 4 个标准全部失败。

---

## Phase 1 实际验证了什么

### ✅ 验证通过
1. **工程基础设施**：LLM 加载、LoRA fine-tune、checkpoint 保存、EFE 计算、action selection、evaluation loop 全部工作
2. **代码无关键 bug**：Gate 指标通过、held-out 测试无异常崩溃
3. **WATCHDOG B7 确认**：environment-model mismatch — Grid World 对 0.5B 模型太简单，无法产生 epistemic 信号

### ❌ 未验证
1. **核心假设**：预测误差驱动探索（PEDA ≠ Pragmatic）— **在 Grid World 中不成立**
2. **OOD 泛化**：G1/G2/G3 仅在 training distribution 上测量（违反 WATCHDOG C9）
3. **行为多样性**：未测量 entropy、coverage、FactGraph 增长等探索指标

### Ceiling Effect 根因

5×5 Grid World 的状态空间（25 states × 4 actions = 100 组合）远小于 0.5B 模型的容量。即使 10% 训练数据也能在 3 epoch 内将 WM 泛化到全部网格。结果：epistemic error ≈ 0，PEDA 退化为 Pragmatic。

---

## 交叉引用

- [[Phase 1.5 详细报告]] — TextWorld 替代实验，decompose_error bug 发现
- [[Phase 2 详细报告]] — Sandbox 环境，实际 Linux 命令不确定性
- [[PEDA 研究动机]] — 原始假设
- [[Phase Restructure v2.0]] — Phase 重组决策
- PEDA_FINAL/archive/phase1/phase1_gap_report.md — Gap 分析报告
- results/phase1_eval.json — 正式评估数据
- results/phase3_gpu/report.json — GPU 确认实验
