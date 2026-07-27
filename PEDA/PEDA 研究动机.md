---
tags: [motivation, theory, overview]
status: done
phase: 1
date: 2026-07-27
---
# PEDA 研究动机（人话版）

## 问题的起点

现在的 AI agent 有一个共同的操作系统：**用户说 → 我做。**

无论是 ChatGPT agent、Claude agent，本质上都在等用户那句"帮我做 X"。用户不说话，它就发呆。这是**遥控器**，不是**自主 agent**。

## PEDA 在试什么

把方向盘从用户手里拿走，换成一个内部信号：**预测误差。**

具体场景：

```
Agent 在 Linux 沙箱里，面前有个 docs/ 目录。
它不知道 cat docs/note.txt 会输出什么。
WM 预测："输出应该是...不知道。"
epistemic error 高 → EFE 算出来 cat docs/note.txt 的期望信息增益最大
→ Agent 主动去 cat 那个文件。
→ 看到输出是 "secret key: 12345"。
→ epistemic error 归零——学到了。
```

这个循环不需要用户说一句话。Agent 自己"想知道"→ 自己"去看"→ 自己"学会了"。PEDA 的核心假设就是：**这个好奇心机制可以替代用户指令。**

## 7 模块架构流

PEDA 包含 7 个模块的闭合循环，每一步的完整流程：

1. **Perception** — 将环境原始输出（exit code, stdout, filesystem delta）编码为 tokenized 观测向量
2. **World Model** — Qwen 0.5B + LoRA，以 (state, action) 为输入预测下一状态的三层次（exit code / 文件系统变化 / 命令输出摘要）
3. **ErrorComputer** — 将 WM 预测与实际观测比较，计算分层 L1/L2/L3 预测误差，合成误差向量
4. **Drive System** — 四维驱动（curiosity / competence / boredom / novelty）将原始误差调制为 EFE 信号
5. **ActionGenerator** — 基于 EFE 最小化选择下一个 action（在候选 action 列表中遍历，选 EFE 最小的那个）
6. **ActionExecutor** — 执行选中的 action（bash 命令或 Python 代码）
7. **Environment** — Docker sandbox 或 Grid World 接收 action 并返回新状态

LearningModule 作为旁路系统，间歇式收集 transitions 进行 LoRA 微调，不干预主循环决策。

详细架构参见 [[PEDA 完整架构详解]]。

## 和现在的 LLM agent 有什么不同

| | 传统 LLM agent | PEDA |
|---|---|---|
| 驱动力 | 用户指令 | 预测误差（epistemic uncertainty） |
| 目标 | 用户给的 task | EFE 最小化自动产生 |
| 停止条件 | 用户说够了 | 预测误差降到阈值以下 |
| "学习"的含义 | in-context learning（一次对话） | LoRA 增量训练（跨 episodes） |
| 能自己"找事做"吗 | 不能 | 理论上能 |

### PEDA vs 主流 Agent 框架

| 框架 | 驱动力 | World Model | 学习方式 | 与 PEDA 的核心差异 |
|------|--------|-------------|----------|-------------------|
| **Voyager** (MineDojo) | 自动课程（技能树） | 无显式 WM | GPT-4 代码生成 + 技能库 | 目标是技能累积，不是 epistemic 探索；无预测误差机制 |
| **Reflexion** | 任务完成 + 反思 | 无 WM | 环境反馈 → verbal 反思 → 更新记忆 | 反思是事后分析，不是实时的预测误差驱动；仍以任务为中心 |
| **ReAct** | 用户指令 | Chain-of-thought | In-context | 本质上还是"用户说就做"，没有内部驱动力 |
| **PEDA** | 预测误差 (EFE) | 0.5B + LoRA | LoRA 增量训练（跨 episode） | 唯一不需要用户指令、完全由好奇心驱动的架构 |

Voyager 和 Reflexion 都是"给一个任务，看 agent 做得有多好"。PEDA 问的是"如果没有任务，agent 会不会自己找事做？"——这是完全不同的研究问题。

## Noisy TV 问题与 EFE 的解决方案

强化学习中的 **Noisy TV Problem**（或称"嘈杂电视问题"）：当环境中存在随机不可预测的元素（如电视随机切换频道），好奇心驱动的 agent 会被吸引而无法自拔，因为那个电视永远会产生预测误差。

EFE 从数学上解决了这个问题：

```
EFE = D_KL[Q(s' | a) || Q(s')] - E_{Q(s' | a)}[log P(o' | s')]
       ^^^^^^^^^^^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
       信息增益（epistemic value）   偏好实现（pragmatic value）
```

- 第一项（信息增益）度量 Agent 对自己信念的不确定性——如果 WM 已经知道电视会输出随机噪声，再做一次也不会增加信念确定性，信息增益接近零。
- 第二项（偏好实现）度量结果是否符合 Agent 的偏好分布——噪声不符合任何偏好，这项不会驱动探索。

因此，EFE 框架天然免疫 Noisy TV：Agent 对可预测的随机噪声（已知不确定性）不会有探索动机，只对**减少模型不确定性**的动作感兴趣。

## 这个名字怎么来的

PEDA = **Predictive-Error-Driven Autonomous Agent**

- **Predictive-Error-Driven**：行动选择的驱动力来自预测误差，而不是外部奖励。
- **Autonomous**：不需要用户指令——误差产生行动，行动消除误差，循环自给自足。

## 理论基础：Active Inference（主动推理）

这不是凭空想出来的。Active Inference 是 Karl Friston（UCL 神经科学家）提出的框架，核心公式是**预期自由能（Expected Free Energy, EFE）**：

```
EFE = 信息增益（epistemic value）+ 偏好实现（pragmatic value）
```

- **信息增益**：做这个 action 我能学到多少关于环境的新东西？
- **偏好实现**：做这个 action 能让我多接近目标？

Agent 每一步选让 EFE 最小的 action。当 WM 不确定时，信息增益项大 → 选探索性 action。当接近目标时，偏好实现项大 → 选任务导向 action。

### Active Inference 的完整数学形式

Active Inference 的核心方程（基于离散时间、部分可观测马尔可夫决策过程，POMDP）：

**生成模型**（World Model 的数学本质）：
```
P(o_t, s_t, π) = P(π) ∏_t P(o_t | s_t) P(s_t | s_{t-1}, π)
```
- `o_t`：t 时刻的观测
- `s_t`：t 时刻的隐藏状态
- `π`：策略（action 序列）

**预期自由能**（Agent 在每一步最小化的目标）：
```
G(π) = ∑_τ G(π, τ)

G(π, τ) = -E_{Q(o_τ, s_τ | π)}[D_KL[Q(s_τ | o_τ, π) || Q(s_τ | π)]]   ← 信息增益
         - E_{Q(o_τ | π)}[log P(o_τ)]                                     ← 偏好实现
```

其中 `Q(o_τ, s_τ | π)` 是 Agent 在策略 π 下对未来状态和观测的变分后验估计。`P(o_τ)` 是 Agent 的偏好分布（先验期望看到哪些观测）。

**PEDA 的创新**：用 LLM (Qwen 0.5B + LoRA) 作为 World Model，用 LoRA 微调作为 learning mechanism（近似贝叶斯信念更新）。这在前沿文献里还没有完全被验证过的组合。

关键概念解释见 [[PEDA 术语表]]。

## 我们遇到的问题

### 环境太简单（天花板效应 #1）

Grid World 5×5：WM 完美记住了 25 格 → epistemic error=0 → PEDA 退化成 A* 寻路。测不出差别。

### 任务太简单（天花板效应 #2）

read_hello（`cat hello.txt`）：WM 就算不准确，pragmatic 策略多试几次也能撞对。又是天花板。

### WM 是查表机（泛化失败）

在 v1 沙箱上调好的 adapter 换到 v2 沙箱就废了。WM 没学会"目录结构"这个概念，只是背下了 v1 的 layout。

### 这些问题的共同根因

**当前配置（0.5B + LoRA + 65 transitions）处于一个尴尬的中间地带**——WM 不是"完美的"（所以有 epistemic error），但它的不确定性是噪音性的（没有结构，无法被探索有效消解）。

要打破这个僵局，要么提升 WM（更大模型、更多数据 → Phase 5），要么找恰好在"WM 能处理但 pragmatic 搞不定"的难度甜点。

> [!warning] 项目可能失败
> **研究宪章明确写了**：如果 Phase 3 证明 epistemic 信号不比随机探索好，我们就接受这个负结果。证明一个想法不成立也是科学贡献。
>
> 但如果在某个环境中确实观察到 epistemic 信号驱动了更高效的探索——即使只是一个受控实验——它将是这个研究方向的第一个统计证据。
