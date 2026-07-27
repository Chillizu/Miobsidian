---
tags: [architecture, drive-system, code]
status: done
phase: 2
date: 2026-07-27
---
# PEDA Architecture — Drive System

## Role
动态平衡四维驱动权重，调制 Action Generator 的 EFE 计算。

## Four Drives

| Drive | 触发条件 | 计算公式 | 效果 |
|-------|---------|----------|------|
| **Curiosity** | 高 epistemic error | `tanh(2.0 × error.epistemic_error)` | 探索未知状态转移 |
| **Competence** | 低 aleatoric error / 适度成功率 | `flow_zone(success_rate)` 映射 [0.2, 0.8] → [0.2, 0.8] | 偏好可预测的行为 |
| **Boredom** | 重复访问相同状态 | `max(0, 0.7 - action_entropy)` 窗口 50 步 | 惩罚已探索区域 |
| **Novelty** | 长时间无新状态 | `1 - exp(-0.01 × steps_since_external)` | 直接奖励新状态 |

计算公式来自 `src/phase1/drive_system.py:59-86`（`update()` 方法）。

## update() 方法代码

来自 `src/phase1/drive_system.py:59-86`，每步从 error vector + action history 计算四个驱动项：

```python
def update(
    self,
    error,
    last_action: Action,
    has_external_input: bool,
    action_history: List[Action],
) -> DriveTerms:
    curiosity_term = math.tanh(2.0 * error.epistemic_error)
    competence_term = _flow_zone_function(self._success_rate(window=20))
    boredom_term = max(0.0, 0.7 - _action_entropy(action_history, window=50))
    if has_external_input:
        self.steps_since_external_input = 0
    elif self.steps_since_external_input > 0:
        self.steps_since_external_input += 1
    novelty_term = 1.0 - math.exp(-0.01 * self.steps_since_external_input)

    terms = DriveTerms(
        curiosity=curiosity_term,
        competence=competence_term,
        boredom=boredom_term,
        novelty=novelty_term,
    )
    self.current_terms = terms
    self.action_history.append(last_action)
    self.error_history.append(error.total_error)
    self.success_history.append(error.level1_error == 0)
    return terms
```

## apply_to_efe() 方法代码

来自 `src/phase1/drive_system.py:88-112`，将四个驱动项调制到 EFE 上：

```python
def apply_to_efe(
    self,
    base_efe: float,
    trajectory: List[PredictedState],
    action_history: List[Action],
    candidate_action: Optional[Action] = None,
) -> float:
    info_gain = sum(1.0 - p.level2_confidence for p in trajectory)
    challenge_level = sum(1.0 - p.level1_confidence for p in trajectory) / max(1, len(trajectory))
    diversity_bonus = 0.0
    if candidate_action is not None:
        recent = action_history[-10:] if len(action_history) > 10 else action_history
        if not any(_action_name(a) == _action_name(candidate_action) for a in recent):
            diversity_bonus = 0.2
    external_info_potential = 0.0

    drive_adjustment = (
        self.weights.curiosity * self.current_terms.curiosity * info_gain
        + self.weights.competence * self.current_terms.competence * challenge_level
        + self.weights.boredom * self.current_terms.boredom * diversity_bonus
        + self.weights.novelty * self.current_terms.novelty * external_info_potential
    )
    return base_efe - drive_adjustment
```

## Flow Zone Function

`_flow_zone_function()` (`drive_system.py:35-39`) 将 success_rate 线性映射到 [0.2, 0.8]：

```python
def _flow_zone_function(success_rate: float) -> float:
    t = (success_rate - 0.2) / 0.6
    t = max(0.0, min(1.0, t))
    return 0.2 + 0.6 * t
```

当 success_rate ∈ [0.2, 0.8] 时 competence_term 取中间值——对应"挑战与技能匹配"的 flow zone。

## 网格搜索结果

来自 `results/phase1_grid_search.json`（Phase 1 Grid World，stub 模式，5+10 episodes）：

| rank | curiosity | competence | boredom | novelty | score | revisit_rate |
|------|-----------|-----------|---------|---------|-------|-------------|
| 1 | **1.0** | **0.1** | **0.1** | **2.0** | 0.9796 | **0.020** |
| 2 | 2.0 | 1.0 | 0.5 | 1.0 | 0.9796 | 0.025 |
| 3 | 2.0 | 0.1 | 0.5 | 2.0 | 0.9704 | 0.050 |
| 4 | 0.5 | 0.5 | 0.5 | 0.5 | 0.9776 | 0.025 |
| 5 | 1.0 | 2.0 | 0.5 | 0.5 | 0.9764 | 0.025 |

**最佳权重**：curiosity=1.0, competence=0.1, boredom=0.1, novelty=2.0, revisit_rate=0.02（最低重复率）

## EFE 调制的完整公式

更新后的准确公式（来自 `drive_system.py:94-112` 和 `ActionGenerator.compute_efe()` `:151-222`）：

```
epistemic = Σ( (1 - level2_confidence) × epistemic_ratio × 0.9^step )
pragmatic = 0.0 if predicted exit_code=2 else 0.5
base_efe = epistemic + pragmatic × 3.0
confidence_penalty = 0.3 × (avg_conf - 0.95) if avg_conf > 0.95 else 0.0
final_efe = base_efe + confidence_penalty - drive_adjustment
```

## Key Finding（Phase 1.5）

**Drive System 在 epistemic≈0 时仍有独立价值。** Phase 1.5 TextWorld 实验：即使 WM 没有 epistemic uncertainty（环境被完美记忆），boredom + competence 也能驱散 `look` 死循环。说明驱动系统不是 epistemic 的附庸——它在 EFE 框架中独立贡献探索行为。

## Cross-References

- [[PEDA 完整架构详解]] — 全 7 模块架构参考
- [[PEDA 实验方法论]] — 网格搜索 & Pareto 协议
- [[Phase 1 Grid World]] — 天花板效应：PEDA=Pragmatic
- [[Phase 2 Sandbox - Held-Out]] — 多基线结果
