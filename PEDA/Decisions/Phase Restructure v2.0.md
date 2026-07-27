---
tags: [decision, planning, restructuring]
status: done
phase: 3
date: 2026-07-27
---
# Phase Restructure — v1.1 to v2.0

> **从 4 阶段（实际混乱）重排为清晰的 7 阶段线性推进。**

## Old Structure (v1.1)

```
Phase 1 → Phase 1.5 (补充) → Phase 2a → Phase 2b → Phase 3
```

混乱点：Phase 1.5 是事后插入的文本世界验证，Phase 2a/2b 的划分仅基于数据量而非功能里程碑。

## New Structure (v2.0, 2026-07-26)

| # | Phase | 核心问题 | Status |
|---|-------|---------|--------|
| 1 | Infrastructure | Can the code run? | DONE |
| 2 | Sandbox Foundation | Is the environment ready? | DONE (infra) |
| 3 | Epistemic Validation | Does epistemic signal work? | RUNNING |
| 4 | Self-Training Loop | Can it improve itself? | NEXT |
| 5 | Sandbox Expansion | Does it scale to richer envs? | PLANNED |
| 6 | Knowledge→Application | Can it set its own goals? | PLANNED |
| 7 | Self-Modification | Can it choose what to learn? | FUTURE |

## Design Principle

每个 Phase 对应一个可验证的假设。Phase 进入下一个阶段的唯一条件是当前假设被实验验证——不是文档更新，不是代码量。


### Phase Transition Criteria (PEDA_ENGINEERING_PLAN_v2.md §3)

`PEDA_FINAL/PEDA_ENGINEERING_PLAN_v2.md` §3.1 明确定义了每个 Phase 的 transition gate：

| Transition | Gate | Criteria | Status |
|------------|------|----------|--------|
| Phase 1 → Phase 2 | G1: WM next-state accuracy > 0.90 | 1.000 (PASS) — but memorization | PASS (infrastructure) |
| Phase 2 → Phase 3 | G2-3: PEDA ≠ Pragmatic, decompose_error > 0 | PEDA 2-step vs Pragmatic 20-step (partial train); epistemic 0.0→0.20 | PASS (see §5.0) |
| Phase 3 → Phase 4 | G4-6: PEDA > Pragmatic in goal_unknown (p<0.05) | N=5 directional (p=0.177), N=20 running | NEXT |

**关键**：Phase 进入下一个阶段的唯一条件是当前 gate 被实验验证。Grid World 的 G1=1.0 被接受为 infrastructure 验证（虽然实为记忆化），导致核心假设未经检验就进入 Phase 2——这是 WATCHDOG B1/C22 要防止的模式。

### Phase 3 的实际范围

Phase 3 已从最初的"Grid World 对照实验"扩展为涵盖两个独立实验线：

| 实验 | 环境 | 适配器 | 结果 | Status |
|------|------|--------|------|--------|
| Grid World (Phase 3 GPU) | 5×5 grid | `partial_adapter_real_25_e3` (25%数据) | **天花板效应**：g1=1.0, PEDA=Pragmatic (p=1.0) | DONE — 结论：环境太简单 |
| Sandbox N=5 | v2 (7 dirs, 14 files) | `sandbox_adapter_v2_full` (65 枚举) | 方向性信号：未知区域 PEDA 6.8 步 vs Pragmatic 10.0 步 (p=0.177) | DONE — 需更大 N |
| Sandbox N=20 | v2 (7 dirs, 14 files) | `sandbox_adapter_v2_full` | 进行中 | RUNNING |

Grid World 实验是必要的负结果：它证明了 0.5B 模型在 5×5 grid 上产生**零**有用 epistemic 信号（PEDA ≈ pure greedy），迫使项目将重心转向沙箱环境。这个负结果本身是有价值的 discovery——不是实验失败，而是假设边界条件的确立。

## Key Migration

- Phase 1.5 合并入 Phase 2（文本世界是沙箱的前身）
- Phase 2a/2b 合并为 Phase 2（基础设施 + 数据管道）
- Phase 3 从"Grid World 对照实验"扩展为"任何能测 epistemic 信号的环境"（Grid World → Sandbox）
> [!info] 重组原则
> **每个 Phase 对应一个可验证的假设。** Phase 进入下一个阶段的唯一条件是当前假设被实验验证——不是文档更新，不是代码量。
>
> Grid World 的 G1=1.0 被接受为 infrastructure 验证（虽然实为记忆化），导致核心假设未经检验就进入 Phase 2——这是 WATCHDOG B1 要防止的模式。
>

## Reference
- `PEDA_FINAL/PEDA_ENGINEERING_PLAN_v2.md` §3


## Related
- [[Phase 1 详细报告]] — Grid World 天花板效应详情
- [[Phase 2 详细报告]] — Sandbox 数据质量与完整评估
- [[AWS GPU 使用指南]] — Phase 3 实验硬件手册
- [[Data Quality over Quantity]] — 数据策略决策依据
- [[WM as Pattern Matcher]] — WM 能力边界分析