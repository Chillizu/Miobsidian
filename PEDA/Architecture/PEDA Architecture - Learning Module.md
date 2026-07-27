---
tags: [architecture, learning-module, code]
status: done
phase: 2
date: 2026-07-27
---
# PEDA Architecture — Learning Module

## Role
批量化地从经验中学习。**间歇式训练**——收集一批 transitions 后统一做一次 LoRA fine-tune，然后清空 buffer。

## Why Intermittent?

连续在线学习会导致**灾难性遗忘**（Folunar_ 的教训）。Per-step SGD 让模型只记住最近的几个样本，忘了之前的。

## Workflow

```
1. store_experience(Experience(state, action, next_state, error))
   └─ buffer 累积 transitions
2. should_update() → buffer >= update_interval (default 500, test mode 50)?
3. sample_prioritized(batch_size=64) → 经验回放
4. lora_finetune(data, epochs=1) → 增量更新 LoRA adapter
5. save_checkpoint() → 保存新 ensemble checkpoint
6. buffer.clear() → 清空，等待下一批
7. saturation_detect() → 学习是否到平台期
```


## SandboxLearningModule.update() 代码

来自 `src/phase2/run.py:13-60`，Phase 2 的 SandboxState 适配子类：

```python
class SandboxLearningModule(LearningModule):
    """LearningModule adapted for SandboxState (container sandbox)."""

    def update(self) -> None:
        if not self.should_update():
            return
        samples = self.buffer.sample_prioritized(batch_size=64)
        data = []
        for exp in samples:
            if hasattr(exp.state, "container_id"):
                # SandboxState path: serialize to JSON
                state_text = exp.state.to_json()
                action_name = exp.action if isinstance(exp.action, str) else exp.action.name
                next_state_text = exp.next_state.to_json()
            else:
                # GridState path (original Phase 1 behaviour)
                state_text = Perception.render(exp.state)
                action_name = exp.action.name
                next_state_text = str(exp.next_state.agent)
            data.append({
                "state_text": state_text,
                "action_name": action_name,
                "next_state_text": next_state_text,
                "exit_code": exp.exit_code,
                "summary": exp.summary,
            })
        self.world_model.lora_finetune(data, epochs=1, learning_rate=2e-4, batch_size=4)
        self.step_count += 1
        self.error_computer.save_checkpoint(self.step_count)
        self.buffer.clear()
        if self.saturation_detector.is_saturated():
            print("[SandboxLearningModule] Saturation detected; novelty boost applied next step.")
```

## SaturationDetector 代码

来自 `src/phase1/world_model.py:859-882`：

```python
class SaturationDetector:
    """Detect learning saturation from a recent window of total error."""

    def __init__(self, window_size: int = 100):
        self.window_size = window_size
        self.errors: deque[float] = deque(maxlen=window_size)

    def add(self, total_error: float) -> None:
        self.errors.append(total_error)

    def is_saturated(self) -> bool:
        if len(self.errors) < self.window_size:
            return False
        half = self.window_size // 2
        old_mean = sum(list(self.errors)[:half]) / half
        new_mean = sum(list(self.errors)[half:]) / half
        if old_mean <= 0:
            return False
        decline = (old_mean - new_mean) / old_mean
        return decline < 0.15

    @property
    def novelty_boost(self) -> float:
        return 0.5 if self.is_saturated() else 0.0
```

饱和检测逻辑：比较窗口前一半和后一半的平均 total_error。若相对下降 < 15% → 判断为饱和。饱和时 `novelty_boost` 返回 0.5，作为额外探索奖励。

## 优先级采样

来自 `src/phase1/world_model.py:901-917`。默认以 `epistemic_error` 为采样权重：

```python
def priority_fn(exp: Experience) -> float:
    return exp.error.epistemic_error
```

确保高 epistemic uncertainty 的 experience 被更频繁地回放。

## 当前缓存参数

| 参数 | LearningModule（Phase 1） | SandboxLearningModule（Phase 2） |
|------|------------------------|----------------------------------|
| `buffer_size` | 1000 | 1000 |
| `update_interval` | 500 | 500（测试模式 50） |
| `batch_size`（采样） | 64 | 64 |
| `batch_size`（训练） | 4 | 4 |
| `epochs` | 1 | 1 |
| `learning_rate` | 2e-4 | 2e-4 |

实际 `SandboxLearningModule` 通过 `super().__init__(world_model, error_computer, buffer_size=100, update_interval=50)` 可覆盖默认值（`run.py:19`）。

## 状态

- **Phase 3 中未启用**：LLM 模式需要 GPU，当前 CPU-only 环境下 `lora_finetune()` 超时（10,040 transitions 训练 30 分钟仍未完成）
- **e2 训练证明可行**：200 transitions 在 CPU 上约 7-8 分钟完成 3 epochs
- **Phase 4 核心目标**：在 GPU 上关闭自训练循环

## Cross-References

- [[PEDA 完整架构详解]] — 全 7 模块架构参考
- [[Phase 2 详细报告]] — Phase 2 训练与评估
- [[Data Quality over Quantity]] — 200 curated > 10k random
- [[Phase 4 - Self-Training Loop]]（待创建）— 闭环自训练
