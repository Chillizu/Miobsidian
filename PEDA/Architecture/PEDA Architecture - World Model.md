---
tags: [architecture, world-model, code]
status: done
phase: 2
date: 2026-07-27
---
# PEDA Architecture — World Model

## Core Role
WM 是 PEDA 的核心引擎——预测 action 执行后环境会变成什么样。预测错了 → epistemic error → 驱动力。

## Three-Level Prediction

| Level | 预测什么 | 目标 | 当前 (v2_full) |
|-------|---------|------|---------------|
| L1 | exit code (0=success, 1=error, 2=task-done) | >= 0.90 | **0.70-0.80** |
| L2 | filesystem delta (哪些文件变了) | >= 0.70 | 0.74 |
| L3 | output summary (语义匹配) | >= 0.50 | 0.90 |

## Technical Stack
- Base: **Qwen2.5-0.5B-Instruct** (frozen)
- Adaptation: **LoRA** (rank=8, alpha=16)
- Training: 65-200 transitions, 3 epochs, batch_size=4
- Inference: CPU ~3s/call (cold start ~176s), GPU ~18s/step (Docker overhead)

## Key Limitation
0.5B + LoRA on 65 transitions = **模式匹配器**，不是推理器。只会记 (state, action) → result 查表，遇到新目录布局就废（held-out L1=0.80）。

## Ensemble Uncertainty
Epistemic error 通过多个 checkpoint 的 ensemble 方差计算。当前用单一 adapter（fast mode），ensemble 未启用。


## Held-Out 实测（e2 adapter × v2 沙箱）

来自 `results/phase2_remaining/l1l2l3_heldout.json`（35 个 OOD 样本）：

| Level | 目标 | Held-Out | 通过？ |
|-------|------|----------|--------|
| L1 | >= 0.90 | **0.800** | FAIL |
| L2 | >= 0.70 | **0.686** | FAIL |
| L3 | >= 0.50 | **0.229** | FAIL |

测试集为 v2 沙箱中 e2 未见过的新目录：`logs/`、`projects/`、`README.txt`。WM 不泛化到新目录布局。见 [[Phase 2 Sandbox - Held-Out]]。

## v2 全量 Adapter

`checkpoints/phase2/sandbox_adapter_v2_full/` 在 **65 条系统性过渡** 上训练（`results/phase2_v2_full.jsonl`，66 行 JSONL 含 task/action/records 字段），覆盖 v2 沙箱 7 目录、14 文件的完整手动遍历。held-out L1=0.70-0.80，用于 Phase 3 N=5/N=20 实验 [[Phase 3 Sandbox N=5]]。

## 训练细节

| Adapter | 数据量 | 来源 | Loss 曲线 | Notes |
|---------|--------|------|-----------|-------|
| e1 | 200 transitions | 5 tasks × 20 steps random + 5 tasks × 20 steps heuristic | 0.4424→0.0291→0.0030→0.0001 | 3 epochs, batch 4 |
| e2 | 200 curated | 同上 + exit_code=2 任务完成标记（6 条） | epoch1: 0.5902→0.0249（batch 40/50） | 关键：含 task-completion 信号 |
| sandbox_v2_full | **65 条** | 手动遍历 v2 沙箱（系统性） | — | Phase 3 用，单一 adapter |

数据来源：`PEDA_WORKING_LOG.md:208`（e1 3 epochs 完整 loss），`:425-427`（e2 训练中断恢复），`results/phase2_v2_full.jsonl:1-66`（v2_full 数据）。

## LoRA 配置代码

来自 `src/phase1/world_model.py:38-42,69-76`：

```python
def __init__(
    self,
    ...
    lora_r: int = 16,        # 默认 rank=16（实际训练覆盖为 rank=8）
    lora_alpha: int = 32,    # 默认 alpha=32（实际训练覆盖为 alpha=16）
    lora_dropout: float = 0.05,
):
    self._lora_config = LoraConfig(
        r=lora_r,
        lora_alpha=lora_alpha,
        target_modules="all-linear",
        lora_dropout=lora_dropout,
        bias="none",
        task_type="CAUSAL_LM",
    )
```

实际 Phase 2 训练覆盖默认值：`rank=8, alpha=16`（来自 `PEDA_WORKING_LOG.md:16-18` 的训练命令参数）。

## Cross-References

- [[PEDA 完整架构详解]] — 全 7 模块架构参考，含数据流图
- [[WM as Pattern Matcher]] — 0.5B + 65 transitions = 查表器，不是推理器
- [[Phase 2 Sandbox - Held-Out]] — held-out 实验详情
- [[Phase 3 Sandbox N=5]] — N=5 方向性实验
- [[Data Quality over Quantity]] — 200 curated > 10k random
- [[PEDA 实验方法论]] — 评价协议
