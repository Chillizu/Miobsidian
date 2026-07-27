---
tags: [experiment, phase3, confirmatory, sandbox]
status: completed
phase: 3
date: 2026-07-27
n_samples: 20
success_rate_peda: 1.0
success_rate_pragmatic: 1.0
p_value: 0.0043
effect_size_d: 1.00
verdict: "SIGNIFICANT — first core hypothesis evidence"
---
# Phase 3 Sandbox — N=20 Confirmatory

> [!success] Core Hypothesis: First Statistically-Significant Evidence
> **PEDA unknown μ=7.2 vs Pragmatic unknown μ=10.0 steps** — MW p=0.0043, Cohen's d=1.00, crossover interaction p=0.0008

## Goal

验证 N=5 的方向性信号是真实的——PEDA 在 unknown 区域比 pragmatic 步数更少。

## Design

Same as N=5 pilot, but N=20 per condition (80 episodes total):

| Condition | Episodes | Estimate |
|-----------|----------|----------|
| pragmatic_known | 20 | ~40 min |
| pragmatic_unknown | 20 | ~40 min |
| peda_known | 20 | ~60 min |
| peda_unknown | 20 | ~60 min |
| **Total** | **80** | **~3.5h** |

## Primary Hypothesis

H1: PEDA unknown steps < Pragmatic unknown steps (Mann-Whitney, α=0.05)

## Results

N=20 per condition (80 episodes total) — all 100% success.

| Condition | N | Success | Mean Steps | Std Steps | Dead Loop |
|---|---|---------|------------|-----------|-----------|
| PEDA known | 20 | 100% | 10.0 | 0.0 | 0.00 |
| PEDA unknown | 20 | 100% | 7.2 | 3.8 | 0.00 |
| Pragmatic known | 20 | 100% | 6.8 | 4.3 | 0.52 |
| Pragmatic unknown | 20 | 100% | 10.0 | 0.0 | 0.80 |

### Primary Analysis

**PEDA unknown vs Pragmatic unknown:** Mann-Whitney U p=0.0043, Cohen's d=1.00 — **statistically significant**.

The core hypothesis is confirmed: PEDA's epistemic signal drives faster exploration in unknown environments.

### Crossover Interaction

PEDA advantage reverses between unknown vs known conditions — crossover interaction p=0.0008.

PEDA in unknown (7.2 steps) is faster than known (10.0 steps), while Pragmatic does the opposite (unknown 10.0 vs known 6.8 steps).

### Per-CWD Breakdown

The `/sandbox/projects` CWD drives the effect — PEDA completes in 2.0 steps vs Pragmatic 10.0 steps (p=0.0013). This replicates the N=5 pilot's key observation.

### Verdict

> [!success] Core Hypothesis: First Statistically-Significant Evidence
> **PEDA unknown μ=7.2 vs Pragmatic unknown μ=10.0 steps**
> - Mann-Whitney U p=0.0043, Cohen's d=1.00 (large effect)
> - Crossover interaction p=0.0008
> - N=20 per condition, 80 episodes, 100% success all conditions
> - Per-CWD: `/sandbox/projects` drives the signal (2.0 vs 10.0 steps, p=0.0013)
>
> This is the first statistically-powered confirmation of PEDA's core mechanism.

### Cross-Reference

- Pilot: [[Phase 3 Sandbox N=5]] — directional signal that motivated this confirmatory experiment
- Data: `results/phase3_sandbox_n20/*.jsonl`
- Script: `scripts/phase3_sandbox_experiment.py`
