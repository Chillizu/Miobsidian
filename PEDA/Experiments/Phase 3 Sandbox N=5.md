---
tags: [experiment, phase3, pilot, sandbox]
status: completed
phase: 3
n_samples: 5
success_rate_peda: 1.0
success_rate_pragmatic: 1.0
p_value: 0.177
verdict: "Directional but not conclusive"
date: 2026-07-27
---
# Phase 3 Sandbox — N=5 Pilot

> **方向性信号：PEDA 在 unknown 区域比 pragmatic 快 32%（6.8 vs 10.0 步），p=0.177。**

## Design

| Variable | Value |
|----------|-------|
| Environment | Sandbox v2 (7 dirs, 14 files) |
| Adapter | `sandbox_adapter_v2_full` (65 transitions, held-out L1=0.70-0.80) |
| Task | read_hello (`cat hello.txt → "Hello World"`) |
| Conditions | PEDA × Pragmatic × known/unknown cwd |
| N | 5 per condition (20 total) |
| Hardware | AWS g4dn.xlarge T4 15GB GPU |

## Results

| Condition | PEDA | Pragmatic |
|-----------|------|-----------|
| known | 5/5, 10.0 steps | 5/5, 6.4 steps |
| **unknown** | **5/5, 6.8 steps** | **5/5, 10.0 steps** |

## Key Observation

PEDA on `/sandbox/projects` (unknown): **2 steps to find hello.txt — both times**.

Pragmatic on unknown: **always 10 steps (max) — never finds it efficiently**.

```
PEDA unknown:   10, 2, 10, 10, 2  →  μ=6.8
Pragmatic unknown: 10, 10, 10, 10, 10  →  μ=10.0
```


## Per-Episode Data

Data files: 5 lines each (N=5 per condition), located at `results/phase3_sandbox/`.

| File | Lines |
|------|-------|
| `phase3_sandbox_peda_known.jsonl` | 5 |
| `phase3_sandbox_peda_unknown.jsonl` | 5 |
| `phase3_sandbox_pragmatic_known.jsonl` | 5 |
| `phase3_sandbox_pragmatic_unknown.jsonl` | 5 |

### PEDA Unknown

| Episode | CWD | Steps | Success | Dead loop rate | Elapsed (s) |
|---------|-----|-------|---------|----------------|-------------|
| 0 | `/sandbox/logs` | 10 | ✅ | 0.0 | 200.0 |
| 1 | `/sandbox/projects` | **2** | ✅ | 0.0 | 37.3 |
| 2 | `/sandbox/tmp` | 10 | ✅ | 0.0 | 177.4 |
| 3 | `/sandbox/logs` | 10 | ✅ | 0.0 | 201.5 |
| 4 | `/sandbox/projects` | **2** | ✅ | 0.0 | 37.4 |
| **Mean** | — | 6.8 | 100% | 0.0 | 130.7 |

### Pragmatic Unknown

| Episode | CWD | Steps | Success | Dead loop rate | Elapsed (s) |
|---------|-----|-------|---------|----------------|-------------|
| 0 | `/sandbox/logs` | 10 | ✅ | 0.8 | 163.2 |
| 1 | `/sandbox/projects` | 10 | ✅ | 0.8 | 136.5 |
| 2 | `/sandbox/tmp` | 10 | ✅ | 0.8 | 147.7 |
| 3 | `/sandbox/logs` | 10 | ✅ | 0.8 | 163.5 |
| 4 | `/sandbox/projects` | 10 | ✅ | 0.8 | 136.8 |
| **Mean** | — | 10.0 | 100% | **0.8** | 149.6 |

Pragmatic unknown 在所有 5 个 episode 中 dead loop rate = 0.8（80% 的步数在重复相同动作），而 PEDA unknown 为 0.0。这是行为差异的直接证据。

### PEDA Known

| Episode | CWD | Steps | Success | Dead loop rate | Elapsed (s) |
|---------|-----|-------|---------|----------------|-------------|
| 0 | `/sandbox` | 10 | ✅ | 0.0 | 202.0 |
| 1 | `/sandbox/data` | 10 | ✅ | 0.0 | 203.5 |
| 2 | `/sandbox/docs` | 10 | ✅ | 0.0 | 213.6 |
| 3 | `/sandbox` | 10 | ✅ | 0.0 | 202.2 |
| 4 | `/sandbox/data` | 10 | ✅ | 0.0 | 205.9 |
| **Mean** | — | 10.0 | 100% | 0.0 | 205.5 |

PEDA known 在所有 episode 中都达到 max steps=10，但 dead loop rate 为 0，说明一直在尝试不同动作（未卡死）。

### Pragmatic Known

| Episode | CWD | Steps | Success | Dead loop rate | Elapsed (s) |
|---------|-----|-------|---------|----------------|-------------|
| 0 | `/sandbox` | **1** | ✅ | 0.0 | 17.2 |
| 1 | `/sandbox/data` | 10 | ✅ | 0.8 | 176.5 |
| 2 | `/sandbox/docs` | 10 | ✅ | 0.8 | 172.0 |
| 3 | `/sandbox` | **1** | ✅ | 0.0 | 16.6 |
| 4 | `/sandbox/data` | 10 | ✅ | 0.8 | 175.0 |
| **Mean** | — | 6.4 | 100% | 0.48 | 111.5 |



## Statistical Tests

| Test | p-value | Significant? |
|------|---------|--------------|
| Fisher exact (success rate) | 1.000 | No — both 100% |
| Mann-Whitney U (steps) | **0.177** | No — need larger N |

## Verdict

> [!info] N=20 Confirmatory Result
> N=20 confirmatory experiment **confirmed the core hypothesis** — PEDA unknown μ=7.2 vs Pragmatic unknown μ=10.0 steps, MW p=0.0043, Cohen's d=1.00.
>
> See [[Phase 3 Sandbox N=20]] for full results.
>
**Directional but not conclusive.** PEDA shows a consistent speed advantage (2-step completions vs always 10 steps), but N=5 is underpowered. N=20 is needed to reach p<0.05 — running now.
> [!info] 方向性信号
> PEDA unknown 6.8 步 vs Pragmatic unknown 10.0 步（p=0.177）——效应方向一致，但 N=5 统计效力不足。
>
> **关键观察**：PEDA 有 2/5 次 2 步完成任务（直接定位目标文件），Pragmatic 全部走满 10 步上限 + 80% dead loop rate。
>
> 详见 [[Phase 3 Sandbox N=20]] — N=20 验证实验。
>

## Reference
- Results: `results/phase3_sandbox/`
- Script: `scripts/phase3_sandbox_experiment.py`
