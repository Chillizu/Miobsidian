---
tags: [glossary, reference, theory]
status: done
phase: 1
date: 2026-07-27
---

# PEDA 术语表

> 核心概念的中文释义，用于快速查阅。按概念相关性分组，非字母排序。

---

## 理论基础

### FEP（Free Energy Principle，自由能原理）
Karl Friston 提出的统一大脑理论。核心命题：任何自组织系统（包括生物大脑）的行为都在**最小化其变分自由能**。对于 Agent 而言，这意味着同时做到两件事：(1) 最小化 surprise（让 World Model 的预测更准确），(2) 改善 World Model 本身（让未来的预测也准确）。PEDA 的哲学基础。
**参考**：[[PEDA 研究动机]] §"理论基础：Active Inference"，`research/peda_dim01_fep_theory.md`。

### EFE（Expected Free Energy，预期自由能）
Agent 在每一步对每个候选 action 计算的"行动价值"：
**G(π) = H[q(o|π)] + D_KL[q(o|π) || C(o)]**
- **Epistemic term**（信息增益项）：H[q(o|π)]——执行此 action 后预期状态分布的熵。熵越高 → 信息增益越大 → 探索价值越高。
- **Pragmatic term**（偏好实现项）：D_KL[q(o|π) || C(o)]——预期状态与偏好分布的 KL 散度。散度越小 → 越接近目标 → 任务价值越高。
- Agent 每一步选让 G(π) 最小的 action。
**参考**：[[PEDA Architecture - World Model]]，`src/phase1/drive_system.py`。

### Active Inference（主动推理）
Friston 框架的行动选择理论。核心观点：感知和行动是同一自由能最小化过程的两面。感知通过更新信念来最小化自由能；行动通过改变环境来让感知符合预期。PEDA 是这个框架在 LLM-based Agent 上的工程实现尝试。
**参考**：`PEDA_FINAL/peda_report_v11.agent.final.md` §2。

---

## 不确定性类型

### Epistemic Uncertainty（认知不确定性）
**可降低的不确定性**：因数据不足而产生的知识空白。对同一个 state 的预测，多个 checkpoint 给出不同的结果 → ensemble variance 高 → epistemic uncertainty 高。PEDA 的主要驱动信号。
**计算公式**：`epistemic = 1 - confidence`（confidence-based）或 ensemble prediction variance（ensemble-based）。
**问题**：当 WM 在所有 checkpoints 上都达成一致（"都错了但错得一样"）时 → epistemic = 0，但其实是错误共识（Phase 1.5 `take key` exit code 系统性错误）。
**参考**：[[PEDA 实验方法论]] §5 G1 信号问题。

### Aleatoric Uncertainty（随机不确定性）
**不可降低的不确定性**：环境本身的随机噪音。Phase 2 的 JSON 结构化状态表示**降低了 aleatoric noise**（`PEDA_ENGINEERING_PLAN_v2.md` §5.2），因为 token-space 预测原本需要建模语法、空格、格式等无关细节。

---

## 评测指标

### L1 / L2 / L3
World Model 预测的三个层次，复杂度递增：

| 层级 | 预测目标 | 容错 | Phase 2 目标 | 实际（v1）| 实际（v2 held-out）|
|------|---------|------|-------------|----------|------------------|
| L1 | 命令 exit code | 严格（0/1分类） | >= 0.90 | 1.000 | 0.800 |
| L2 | 文件系统变化 | 模糊（F1） | >= 0.70 | 0.900 | 0.686 |
| L3 | 输出语义摘要 | 语义（cosine） | >= 0.50 | 0.550 | 0.229 |

**参考**：`PEDA_ENGINEERING_PLAN_v2.md` §5.2，[[PEDA Architecture - World Model]]。

### SCR（Success Completion Rate，成功完成率）
Agent 在给定步数限制内（通常 10 步）完成任务的 episode 比例。Phase 3 的主要评估指标。

### FHT（First Hit Time，首次命中时间）
Agent 首次达到目标状态所需的步数。与 SCR 配合使用：SCR 衡量最终能否完成，FHT 衡量效率。
**参考**：`scripts/phase3_analysis.py`，`scripts/phase3_analysis_sandbox.py`。

---

## 核心系统组件

### Drive System（驱动系统）
四个内在驱动的动态平衡机制：

| 驱动 | 触发 | 效果 |
|------|------|------|
| Curiosity | 高 epistemic error | 偏向探索 |
| Competence | 低 aleatoric error | 偏向执行可预测动作 |
| Boredom | 连续重复同一状态 | 惩罚已探索区域 |
| Novelty | 检测到新状态 | 奖励全新状态 |

**关键发现**：在 epistemic ≈ 0 时，boredom + competence 也能产生可区分行为（PEDA ≠ Pragmatic，2/2 迭代复现）。
**参考**：[[PEDA Architecture - Drive System]]，`PHASE1_5_ITERATION2_EVALUATION.md`。

### PEDA Loop（PEDA 循环）
7 步闭合循环：**Perception → WorldModel → ErrorComputer → ActionGenerator → ActionExecutor → Environment → Perception**。LearningModule 和 DriveSystem 在侧面介入。
**参考**：[[PEDA Overview]] §Architecture，`src/phase2/run.py`。

### EFE Computation（EFE 计算方法）
两种实现方式：
- **Confidence-based**：`epistemic = 1 - confidence(WM)`，利用 LLM 自身的 logit 概率。计算快，但对 overconfidence 敏感（Phase 1.5 inventory 循环：confidence=0.999 → epistemic≈0）。
- **Ensemble-based**：多个 checkpoint 的预测方差。计算慢（需要 N 倍推理），但能捕获"共识错误"。Phase 2 实现中。
**参考**：`src/phase1/world_model.py` → `EnsembleErrorComputer`。

---

## 已知问题与模式

### Noisy TV Problem（噪音电视问题）
纯 prediction error 方法的经典失败模式：Agent 被不可预测但无信息的刺激吸引（如静态噪音电视画面）。PEDA 使用 EFE 的信息增益项（`H[q(o|π)]`）而非原始 prediction error 来规避——信息增益只关心"预计减少多少不确定性"，而不是"预测有多不准确"。
**参考**：`research/peda_dim03_intrinsic_motivation.md`。
> [!tip] EFE 天然免疫 Noisy TV
> PEDA 使用 EFE 的信息增益项（`H[q(o|π)]`）而非原始 prediction error 规避 Noisy TV——信息增益只关心"预计减少多少不确定性"。已知的随机噪声不会产生探索动机。
>

### Cold Start（冷启动问题）
WM 需要数据才能预测 → AG 需要准确 WM 才能选择有效 action → 但收集数据需要 AG 选择 action。PEDA 的 bootstrap 策略：先用 random/pragmatic policy 收集初始数据，然后交替 training 和 eval。如果初始数据质量太低，学习循环断裂（`RESEARCH_CHARTER.md` 负结果表）。
**参考**：[[PEDA 实验方法论]] §4 负结果。

### LoRA（Low-Rank Adaptation，低秩适配）
PEDA 的 World Model 微调方法。冻结基础 LLM（Qwen 2.5-0.5B），插入小规模可训练参数（rank=16）。每个 adapter 文件 <10MB，训练成本 ~1 小时 GPU。三个 adapter 构成 ensemble。
**参考**：`src/phase1/world_model.py`，`scripts/phase2_synthetic_train.py`。

### Ensemble（集成）
多个 LoRA adapter 的集合（通常是 3 个）。每个用不同的 (data_subset, seed) 训练。评估时对同一输入并行推理，用预测方差估计 epistemic uncertainty。

### Grid Search（网格搜索）
对 Drive System 四维权重进行系统扫描的协议。`results/phase1_grid_search.json` 记录了 5+10 episodes 对 4 个权重（curiosity, competence, boredom, novelty）在 {0.1, 0.5, 1.0, 2.0} 上的部分组合结果的 Pareto front。最佳权重：curiosity=1.0, competence=0.1, boredom=0.1, novelty=2.0。
**参考**：[[PEDA Architecture - Drive System]] §Grid Search 结果。

### C18 / Post-Completion Oscillation（完成后振荡）
Agent 完成任务后继续在无关状态中循环的模式。Phase 1.5 中拿了钥匙后持续 `inventory` 就是 C18 的实例。修复：`game_over` guard 在 exit_code=2 时立即终止 episode。
**参考**：[[Phase 2 详细报告]] §C18 Bug Fix，`PEDA_ENGINEERING_PLAN_v2.md` §5.6。

### Cold Start（冷启动）
WM 需要数据才能准确预测，但收集数据需要 WM 先有一定准确性的 bootstrap 困境。缓解策略：先用 random + heuristic 采集初始数据，再用这小规模数据训练初始 WM，然后逐步交替（训练→收集→训练）。
**参考**：[[PEDA 实验方法论]] §Bootstrap 策略。

### Memory vs Gradient Learning（记忆性 vs 梯度性学习）
PEDA 使用的 LoRA 梯度学习（参数更新改变行为倾向）与 Reflexion/AutoGPT 使用的符号记忆注入（自然语言摘要存储到向量数据库）的根本区别：梯度学习保证经验整合到行为模式，符号记忆依赖 LLM 的摘要质量和检索准确度。
**参考**：`PEDA_FINAL/peda_report_v11.agent.final.md` §2.6.4。
**参考**：[[PEDA Architecture - World Model]]。

---

*相关笔记：[[PEDA 研究动机]] · [[PEDA 完整架构详解]] · [[PEDA 实验方法论]] · [[PEDA 开发规则]] · [[PEDA Architecture - World Model]] · [[PEDA Architecture - Drive System]] · [[PEDA Architecture - Learning Module]]*
