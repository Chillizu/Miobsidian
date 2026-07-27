---
tags: [experiment, phase2, heldout, evaluation]
status: completed
phase: 2
n_samples: 35
success_rate_peda: 0.80
success_rate_pragmatic: 1.0
verdict: "WM does NOT generalize v1->v2"
date: 2026-07-27
---
# Phase 2 Sandbox — Held-Out Evaluation

> **WM does NOT generalize v1→v2 sandbox. L1 drops from 1.000 to 0.800.**

## Test Setup

- Adapter: e2 (best: L1=1.000 on v1 sandbox — 4 directories)
- Test: v2 sandbox OOD directories: `logs/`, `projects/`, `README.txt`
- 35 held-out (state, action) pairs

## Results

| Level | Target | Held-Out | Pass? |
|-------|--------|----------|-------|
| L1 (exit code) | >= 0.90 | **0.800** | FAIL |
| L2 (filesystem delta) | >= 0.70 | **0.686** | FAIL |
| L3 (output summary) | >= 0.50 | **0.229** | FAIL |

## Multi-Baseline on v2

| Baseline | read_hello | read_note |
|----------|-----------|-----------|
| PEDA | 80% success | 0% — dead in water |
| Pragmatic | 100% success | 0% — 80% revisit rate |
| Random | 100% success | 0% |

**All baselines fail `read_note` on v2 sandbox.** The e2 adapter's v1 success claims don't transfer.
> [!warning] All baselines fail on v2
> Phase 2's "PASS" metrics (L1=1.000, 20/20 multi-task) are **v1 sandbox artifacts**. The v2 sandbox is the real test environment, and WM performance there is significantly below thresholds. This is not a bug — it's a genuine finding about WM generalization.
>

## Implication

Phase 2's "PASS" metrics (L1=1.000, 20/20 multi-task) are **v1 sandbox artifacts**. The v2 sandbox is the real test environment, and WM performance there is significantly below thresholds. This is not a bug — it's a genuine finding about WM generalization.


## Data File Reference

| File | Lines/Size | Contents |
|------|-----------|----------|
| `results/phase2_remaining/heldout_test_set.jsonl` | 35 lines, 10.1KB | 35 held-out test pairs (v2 sandbox OOD) |
| `results/phase2_remaining/l1l2l3_heldout.json` | — | L1=0.800, L2=0.686, L3=0.229 |
| `results/phase2_remaining/multi_baseline_results.json` | — | PEDA/Pragmatic/Random on read_hello & read_note |
| `results/phase2_remaining/peda_read_hello.jsonl` | 5 lines | PEDA read_hello per-episode |
| `results/phase2_remaining/prag_read_hello.jsonl` | 5 lines | Pragmatic read_hello per-episode |
| `results/phase2_remaining/random_read_hello.jsonl` | 5 lines | Random read_hello per-episode |
| `results/phase2_remaining/peda_read_note.jsonl` | 5 lines | PEDA read_note per-episode |

## Adapter Version Comparison: e2 on v1 vs v2

| Metric | e2 on v1 | e2 on v2 (held-out) | Δ |
|--------|---------|---------------------|---|
| L1 (exit code) | 1.000 | 0.800 | -0.200 ❌ |
| L2 (filesystem delta) | — | 0.686 | N/A |
| L3 (output summary) | — | 0.229 | N/A |
| read_hello success | 100% | 80% (PEDA) | -20% |

**Key finding**: The e2 adapter that achieved L1=1.000 on sandbox v1 drops to L1=0.800 on v2. The "perfect" Phase 2 metrics were v1 sandbox artifacts — the real generalization challenge is v2.

## Multi-Baseline Data Summary（v2 sandbox）

Data from `results/phase2_remaining/multi_baseline_results.json`:

| Baseline | read_hello success | read_hello mean steps | read_note success | read_note revisit |
|----------|-------------------|---------------------|------------------|------------------|
| **PEDA** | **80%** (4/5) | 2.8 | **0%** (0/5) | 0.0 |
| **Pragmatic** | **100%** (5/5) | 1.0 | **0%** (0/5) | 0.8 |
| **Random** | **100%** (5/5) | 3.0 | **0%** (0/5) | 0.0 |

### Observations

1. **read_hello**: Pragmatic > PEDA > Random in efficiency. PEDA 80% vs Pragmatic 100% — Pragmatic still wins on simple tasks.
2. **read_note**: ALL baselines 0%. The e2 adapter cannot handle this task in v2 sandbox regardless of exploration strategy.
3. **Pragmatic revisit on read_note**: 80% revisit rate — gets stuck in dead loop. PEDA 0% revisit but still 0% success (explores more but can't find the solution).
4. **Random 100% on read_hello**: The task is trivially solvable by chance (1/5 success rate per step), confirming the environment is not inherently blocking.

## 35 Held-Out Test Pairs

`results/phase2_remaining/heldout_test_set.jsonl`（10.1KB, 35 lines）包含 35 个 OOD (state, action) 对，覆盖 v2 sandbox 所有 7 个目录的探索路径：

- `/sandbox` root commands: `cat README.txt`, `head -n 1 README.txt`, `wc -l README.txt`, `find . -name '*.log'`, `grep -r ERROR .`
- `/sandbox/logs` commands: `cat access.log`, `cat error.log`, `head -n 2 access.log`, `wc -l access.log`, `grep ERROR error.log`, `grep -c ERROR error.log`, `tail -n 1 access.log`
- `/sandbox/projects` traversal: `cd app`, `ls`, `cat main.py`, `cat test.py`, `cd lib`, `cat utils.py`
- `/sandbox/tmp`, `/sandbox/docs`, `/sandbox/data`: various commands

These 35 pairs are the **held-out test set** for measuring WM generalization from v1→v2.

## Cross-References

- [[Phase 3 Sandbox N=5]] — Sandbox N=5 pilot with same v2 adapter
- [[Phase 2 详细报告]] — Full Phase 2 analysis
- [[PEDA Architecture - World Model]] — WM architecture & generalization
- [[WM as Pattern Matcher]] — Design decision on WM role
- `results/phase2_remaining/report.json` — Phase 2 Slice C report
- `results/phase2_remaining/multi_baseline_results.json` — Full multi-baseline data

