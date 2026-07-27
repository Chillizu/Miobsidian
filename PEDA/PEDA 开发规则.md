---
tags: [rules, workflow, watchdog]
status: done
phase: 2
date: 2026-07-27
---

# PEDA 开发规则

> WATCHDOG 规则系统（B1-B9 Blocker / C1-C22 Concern / N1-N3 Nit）的中文版。来源：`WATCHDOG.md`，项目根目录。所有规则由 oh-my-pi advisor 自动检查。

**核心原则**：如果任何规则与"快速推进"冲突，规则优先。PEDA 最大的风险不是推进太慢，而是重蹈 Folunar_ 的覆辙——用计划/文档/代码量冒充进展。

---

## Blocker 规则（STOP——必须阻塞）

### B1：Phase 推进必须带假设验证
**触发条件**：声明某个 Phase"完成""已实现""完工"，但对应的 go/no-go 标准未经实验验证。
**实例**：Folunar_ 在 142 个 commit 中声明了 20 个 Phase"已实现"，但从未验证核心想法是否工作。
**正确行为**：如果 go/no-go 条件不满足，停留在当前 Phase 并运行缺失的验证实验。文档记录结果（通过或失败），不是完成状态。
**参考**：`PEDA_ENGINEERING_PLAN_v2.md` §3.1 Phase transition criteria。

### B2：禁止在 stub 中注入假数据
**触发条件**：修改 stub/mock/test fixture 来注入人工随机性或不确定性，以便让测试通过或指标变好。
**实例**：修改确定性 stub 产生随机 "epistemic 信号" 来让 EFE 计算"有效"。
**正确行为**：Stub 保持确定性。如果确定性 stub 导致指标预期失败，记录为"stub 预期行为"，然后用真实模型验证。**绝不为了通过指标而修改 stub**。
**参考**：`peda_reflection_v11.md` — Problem 2 "Stub模式陷阱"。

### B3：新模块必须通过三道门
**触发条件**：添加新 Python 模块/文件时，不能证明以下至少一项：
1. 直接帮助 World Model 更准确地预测，或
2. 有已发表的论文或成熟开源项目证明该技术对类似问题有效，或
3. 已尝试用现有模块实现该功能并证明不可行。
**实例**：Folunar_ 生长到 40+ 模块，很多 <150 行，仅为"完整性"存在。PEDA 核心仅 5 个模块。
**正确行为**：创建新文件前，写一条简短理由（可在 commit message 中）说明通过哪道门。

### B4：禁止创建新计划文档代替更新（已降级为 Concern）
**原始**：创建新 `PLAN_*.md`、`ARCH_*.md` 等文件，或现有文档膨胀 50%+ 而无相应代码变更。
**2026-07-07 降级理由**：探索阶段的方向转向是正常的，新文档有时比更新旧文档更清晰。但验证/写作阶段恢复执行。
**参考**：`peda_reflection_v11.md` — Problem 4 "计划文档通货膨胀"。

### B5：样本量不足不能声称验证
**触发条件**：使用 <5 episodes/condition（或 <30 总观测）声称假设被"验证""确认""证明"。
**实例**：Phase 1 partial-training pilot：PEDA 2 步 vs Pragmatic 20 步（仅 1 episode/condition）。差异强烈但 1 episode 随机性完全足够解释。
**正确行为**：
- Pilot（探索）：1-3 episodes，方向性信号，不做统计结论
- Confirmatory（验证）：>=10 episodes/condition，预先注册假设和成功阈值
- 硬件限制时应明确声明不确定性（如"N=3，方向性信号，p-value 未计算"）
**参考**：`PHASE1_PARTIAL_EVALUATION.md` §6.2。

### B6：禁止 cherry-pick 实验条件
**触发条件**：在看到初步结果后调整实验条件，且调整方向使结果更好，而非检验预先注册的假设。或只报告有利条件子集。
**实例**：Phase 1 中 g1_test_set 过高（>0.90）所以降低 train_fraction——这个决策本身科学，但必须预注册并重新运行所有条件，不能选择性重跑。
**正确行为**：每次调整条件后重新运行 **ALL** 条件，报告所有结果（包括 null 和负结果）。

### B7：环境-模型不匹配识别并转向（已降级为 Concern）
**原始**：WM 在 50% 训练数据上达到 g1 > 0.90 后继续尝试优化而非承认环境太简单。
**实例**：Phase 1 Grid World：25% 训练数据 → g1=0.87, 10%+3 epochs → g1=1.0。Agent 用了 25%→10%→3 epochs 三轮才接受失败。
**正确行为**：如果 1-2 次尝试后 g1 > 0.90 with <50% 训练数据 → 承认环境太简单，立即转向更复杂环境。

### B8："再试一次"死亡螺旋
**触发条件**：同一方法尝试 >=3 次，参数越来越极端，仍不成功。
**实例**：Phase 1 Grid World 的 train_fraction: 0.5→0.25→0.10→0.05 螺旋。
**正确行为**：每种条件最多 2 次尝试。第 3 次需要书面证明为什么这次与前两次不同。

### B9：异常结果 1 小时内必须解释
**触发条件**：实验产生异常结果（score>0.99、100%准确率等），1 小时内无可证伪的解释。
**实例**：Phase 1 Grid Search 得分 0.996、步数 1.0——可能是目标放置或计数 bug——未经调查直接接受。
**正确行为**：1 小时内：(1) 复现结果，(2) 检查中间变量，(3) 找出 bug 或提供可证伪解释，(4) 如果无法解释——停止写代码，进入纯理论分析模式。

---

## Concern 规则（WARN——警告，持续确认）

### C2：过程指标冒充进展
**触发条件**：用"测试通过""lint 干净""写了 X 行代码"等过程指标报告进展。
**实例**：Folunar_ 的 92.2% "成功率" 是命令执行成功率，不是任务完成率。
**参考**：[[PEDA 实验方法论]] §1 区分 pilot 和 confirmatory。

### C12：死循环必须识别为根本限制
**触发条件**：Agent 连续 >=3 步选择同一 action，WM 分配 >0.99 置信度，形成自强化循环。
**实例**：Phase 1.5 full eval：PEDA 在拿到钥匙后 `inventory` 循环 17 步。模型对 `inventory` 预测置信度 0.999，boredom drive (0.1) 太弱无法打破。
**参考**：[[PEDA Architecture - Drive System]] §Drive 表格。

### C14：Drive System 未经验证时讨论独立价值无意义
**触发条件**：将 Drive System 描述为"有独立价值""理论意义"但未跑对照实验（PEDA vs heuristic baseline）。
**正确行为**：在验证前，所有 Drive System 声明必须前缀"未验证"或"工程机制，非理论贡献"。
**参考**：`GLM5_2_RESPONSE_ANALYSIS.md` Q6。

### C18：post-completion oscillation
**实例**：Phase 1.5 `game_over` 状态后 agent 继续行动。修复：加入 `game_over` guard，一旦完成任务立即终止动作选择。
**来源**：`PEDA_ENGINEERING_PLAN_v2.md` §5.6。"C18 post-completion oscillation fix (game_over guard) — High confidence"。

### C20-C22：Orchestration 规则
**内容简述**：
- C20：主 Agent 向子 Agent 分配任务必须有明确的契约（输入格式、成功标准、输出格式）
- C21：子 Agent 不能修改非其权限范围内的文件
- C22：并行子 Agent 的结果必须在合并前通过独立验证
**来源**：`WATCHDOG.md` C20-C22 规则（`PEDA_ENGINEERING_PLAN_v2.md` §1.2 提到 "C20-C22 (orchestration) — New"），以及 `AGENTS.md` 中的协作模式。

---

## Nit 规则（Minor——快速通过）

### N1：可推迟的工作
触发：当前 Phase 验证未完成时，在类型注解、docstring、README、import 排序上消耗时间。
正确行为：加 `# TODO(Phase-N)` 标记，完成验证再回来。

### N2：不使用现有解决方案
触发：从零实现已有成熟开源库的功能（vector DB → ChromaDB，缓存 → diskcache 等）。

### N3：忽略前代教训
触发：违反 Folunar_ 已验证的错误模式而不说明为什么此项目不同（添加"完整性"模块、创建新 PLAN 文档、在线无 replay buffer 训练等）。

---

*相关笔记：[[PEDA 实验方法论]] · [[PEDA 研究动机]] · [[PEDA 完整架构详解]] · [[Phase 1 详细报告]] · [[Phase 2 详细报告]]*

## 规则系统设计原理

WATCHDOG 规则的分级设计（Blocker > Concern > Nit）反映了 PEDA 项目的风险管理策略：

- **Blocker（B1-B9）**：会直接导致项目方向错误或数据造假的行为。一旦触发，advisor 必须发出阻塞信号，当前工作立即停止，直到违规被解决。
- **Concern（C1-C22）**：会分散精力或积累技术债的行为。advisor 发出警告并持续确认，但不强制停止。探索阶段容忍度更高。
- **Nit（N1-N3）**：最佳实践建议。advisor 记录但不阻塞进度。

这个分级系统确保关键错误（如 Phase 推进没有假设验证、样本量不足声称结论）被立即拦截，同时允许在探索阶段保留灵活性（如创建新文档、跳过 lint）。
> [!warning] 核心原则
> **如果任何规则与"快速推进"冲突，规则优先。** PEDA 最大的风险不是推进太慢，而是重蹈 Folunar_ 的覆辙——用计划/文档/代码量冒充进展。
>
> Blocker (B1-B9) = STOP，Concern (C1-C22) = WARN，Nit (N1-N3) = 建议。
>

## 与 Folunar_ 教训的对应

| WATCHDOG | Folunar_ 教训 | PEDA 缓解 |
|----------|--------------|----------|
| B1 | 142 commits, 20 phases "implemented", 0 validated | Go/no-go criteria per phase, scientific gate |
| B3 | 40+ modules, <150 lines each | 5 core modules, module review gate |
| B4 | ~30K words plan docs vs ~3.7K lines code | Living plan, append not create |
| B8 | Grid World 25%→10%→3 epochs spiral | Max 2 attempts per condition |
| C2 | 92.2% "success" = command exec, not task completion | Task-level metrics (SCR, FHT, L1/L2/L3) |
| C12 | PEDA inventory loop 17 steps (Phase 1.5) | ConfidencePenalty, game_over guard |

来源：`peda_reflection_v11.md`（v1.0 事后反思 + 反模式清单），`CODING_AGENT_EVALUATION.md`（第三方评审问题清单）。

## 参考

- [[PEDA 实验方法论]] — 实验设计标准，pilot vs confirmatory
- [[Phase 1 详细报告]] — B7 (环境-模型不匹配) 实例：Grid World
- [[Phase 1.5 详细报告]] — C12 (死循环) 实例：inventory 循环
- [[Phase 2 详细报告]] — C18 (post-completion oscillation) 实例与修复
- [[PEDA 研究动机]] — 项目哲学基础
