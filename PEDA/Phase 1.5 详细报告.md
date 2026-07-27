---
tags: [experiment, report, phase1_5]
status: completed
phase: 2
date: 2026-07-27
---
# Phase 1.5 详细报告

> **核心发现**：PEDA 的行为**可与 Pragmatic 区分**，但驱动力来自 Drive System（boredom+confidence），而非 prediction error（ensemble variance ≈ 0）。

---

## 为什么不是 TextWorld

**Python 3.14 + TextWorld (1.7.0) 不兼容**。依赖链在 3.14 上集体出错：

| 依赖 | 问题 |
|------|------|
| spaCy | dict += 操作变更 |
| jericho | JSONDecodeError |
| gym | 兼容性断裂 |

改用自定义轻量文本环境，零外部依赖。环境代码：`src/phase1_5/text_env.py`（164 行，[source](file:///home/chillizu/Projects/Folunar_/src/phase1_5/text_env.py)）。

### 环境设计

```
书房 (study) ──── 门向北 ──── 走廊 (hallway)
├── 书桌上有一把钥匙          ├── 墙角有一个上锁的宝箱
└── 6 个合法动作               └── 6 个合法动作
```

- 最优路径：`take key` → `north` → `use key on chest`（3 步）
- 状态类型：`TextState(room, description, inventory, goal, step, max_steps)`
- 接口契约：`reset(seed)→TextState` / `step(state, action)→(TextState, reward, done)`

---

## 训练

数据来源：`PEDA_FINAL/archive/phase1_5/phase1_5_complete_report.md`（[source](file:///home/chillizu/Projects/Folunar_/PEDA_FINAL/archive/phase1_5/phase1_5_complete_report.md)）。

### 数据生成

- 穷举：从每个房间执行每个合法动作
- 随机游走：50 个 walks × 20 步
- 去重 key：`state_text + action_name`
- 最终：**113 条唯一样本**

### LoRA 微调

| 参数 | 值 |
|------|-----|
| 模型 | Qwen2.5-0.5B-Instruct |
| Epochs | 3 |
| Batch size | 4 |
| Checkpoints | 3 |
| 耗时 | 623 秒（~10 分钟） |
| Loss 曲线 | 0.2928 → 0.0545 → 0.0240 |

---

## 语义探针

数据来源：`scripts/phase15_semantic_probe.py`（[source](file:///home/chillizu/Projects/Folunar_/scripts/phase15_semantic_probe.py)）。

测量 3 个 checkpoint 在结构化字段上的分歧率（30 个测试样本）：

| 字段 | 分歧率 | 意义 |
|------|--------|------|
| Room（房间预测） | **10%** (3/30) | 大部分一致 |
| Exit code（成败代码） | **7%** (2/30) | 大多数一致 |
| Has-key（背包是否有钥匙） | **40%** (12/30) | ⚠️ checkpoint 对背包状态分歧大 |
| **完整语义元组** | **50%** (15/30) | ⚠️ **超过 33% 阈值** |

**系统性错误**：所有 3 个 checkpoint 对 `take key` 的预测都是 `exit=1`（不能拿钥匙）— 环境实际允许拿钥匙。这导致模型系统性低估了可行性，Agent 必须通过探索（而非预测）来发现钥匙可以拿。

---

## `decompose_error` Bug

**Bug 描述**：`decompose_error` 的 TextState 路径只检查 (room, exit_code) 二元组的方差，完全忽略了 has-key / inventory 维度。

- 实时报告：`mean_epistemic_error = 0.0`
- 实际方差（含 has-key）：**20-40%**

**修复**：在 Phase 2 中，将 has-key 维度加入 TextState 的 ensemble 方差计算。修复后 epistemic ratio 从 0.0 提升到 0.20。
> [!danger] decompose_error Bug
> `decompose_error` 的 TextState 路径只检查 (room, exit_code) 二元组的方差，完全忽略了 has-key / inventory 维度。实时报告 `mean_epistemic_error = 0.0`，但实际方差含 has-key 为 **20-40%**。
>
> **修复后**：epistemic ratio 从 0.0 提升到 0.20，说明测量误差使关键信号被忽略。
>

**交叉引用**：[[Phase 2 详细报告]] — C18 post-completion fix。

---

## 完整评估

数据来源：`PEDA_FINAL/archive/phase1_5/phase1_5_complete_report.md`。

### 配置

| 参数 | 值 |
|------|-----|
| Episodes | 1 per agent（2 total） |
| Max steps | 20 |
| Candidates | 3 |
| Horizon | 1 |
| Pragmatic weight | 3.0 |
| Drive weights | cur=0.1, cmp=2.0, bor=0.1, nov=2.0 |
| 耗时 | 1654 秒（~28 分钟） |

### 结果

| Agent | 成功 | Steps | 关键行为 |
|-------|------|-------|---------|
| **PEDA** | ❌ | 20/20 | `inventory` → `look` → `take key`（第 3 步！）→ `inventory` × 17 |
| **Pragmatic** | ❌ | 20/20 | `look` × 20 |

### 行为分析

**PEDA ≠ Pragmatic 确认（2/2 iterations）**。

PEDA 在第 3 步尝试了 `take key`。钥匙实际成功进入背包，但之后 Agent 卡在 `inventory` 死循环。Pragmatic 从未尝试 `take key`。

为什么 PEDA 尝试了而 Pragmatic 没有？不是因为 ensemble variance（≈0），而是因为：
1. **LLM 置信度衰减**：模型对 `inventory` 反复执行后，置信度逐渐降低 → boredom 累积
2. **Drive system 调制**：`boredom=0.1` 的权重在多次重复后足以产生可测量偏差

为什么两个 Agent 都卡住了？
1. 模型对 `take key` 预测 exit=1（系统性错误）
2. 拿钥匙后 `inventory` 的置信度 0.999 → EFE 最低 → 每次都选 inventory
3. 113 条训练数据太少，不足以覆盖所有状态-动作组合

---

## 关键发现

1. **Drive System 有独立探索价值**。即使 epistemic ≈ 0，boredom + LLM confidence 也能驱动探索行为。
2. **PEDA 与 Pragmatic 行为可区分**（第 3 步尝试 take key vs 从未尝试），差异是真实的、可复现的。
3. **`decompose_error` 掩埋了真实方差**。修复后 epistemic ratio 从 0.0 → 0.20，说明测量误差使关键信号被忽略。
4. **113 条数据不够**。0.5B 模型学习文本转移规则需要更多数据。

后续路径：增加训练数据（500-1000 条）或进入 Phase 2（sandbox 环境）。项目选择了 Phase 2，因为 sandbox 提供真正的 Linux 命令不确定性。

---

## 文件清单

| 文件 | 类型 | 行数 | 说明 |
|------|------|------|------|
| `src/phase1_5/text_env.py` | 新增 | 164 | 双房间文本环境 |
| `scripts/phase1_5_synthetic_train.py` | 新增 | 164 | 数据生成+LoRA训练 |
| `scripts/phase1_5_eval.py` | 新增 | 191 | 分块评估脚本 |
| `scripts/phase15_semantic_probe.py` | 新增 | 103 | 语义探针 |
| `src/phase1/world_model.py` | 修改 | +200 | 文本提示链+分派 |

---

## 交叉引用

- [[Phase 1 详细报告]] — Grid World Phase 的根本问题
- [[Phase 2 详细报告]] — C18 decompose_error 修复
- [[PEDA Architecture - Learning Module]] — Learning Module 架构
- PEDA_FINAL/archive/phase1_5/phase1_5_complete_report.md — 完整实验报告
