---
tags: [reference, index, files]
status: done
phase: 3
date: 2026-07-27
---
# PEDA 参考文件索引

> 所有关键文件，按用途分类。路径相对于 `~/Projects/Folunar_/`。
> 行数统计更新于 2026-07-27。

## 核心规划文档

| 文件 | 行数 | 用途 |
|------|------|------|
| `PEDA_FINAL/PEDA_ENGINEERING_PLAN_v2.md` | 824 | 工程计划书 v2.0（5664 字，16 章 + 3 附录） |
| `PEDA_FINAL/PEDA_RESEARCH_MANUSCRIPT.md` | 697 | 研究手稿（8111 字，10 章 + 29 参考文献） |
| `PEDA_FINAL/RESEARCH_CHARTER.md` | 85 | 研究宪章：核心问题、负结果接受标准、成功定义 |
| `PEDA_FINAL/README_FOR_AGENTS.md` | 126 | Agent 快速入口和文件索引 |

## 评估报告

| 文件 | 行数 | 内容 |
|------|------|------|
| `PEDA_FINAL/archive/phase1/phase1_gap_report.md` | 71 | Phase 1 核心假设 gap 审计 |
| `PEDA_FINAL/archive/phase1_5/phase1_5_complete_report.md` | 229 | Phase 1.5 文本世界完整报告 |
| `PEDA_WORKING_LOG.md` | 1533 | 工作日志（所有实验记录） |
| `PEDA_FINAL/peda_report_v11.agent.final.md` | 2054 | v1.1 架构权威文档 |
| `PEDA_FINAL/peda_reflection_v11.md` | 188 | v1.0 事后反思 + 反模式清单 |

## 核心代码

| 文件 | 行数 | 用途 |
|------|------|------|
| `src/phase1/run.py` | — | Phase 1 完整 7 步 PEDA 循环（参考实现） |
| `src/phase1/types.py` | — | State, Action, Experience, ErrorVector 类型定义 |
| `src/phase1/world_model.py` | — | WorldModel, LearningModule, EnsembleErrorComputer |
| `src/phase1/drive_system.py` | — | HomeostaticDriveSystem 四维驱动 |
| `src/phase1/grid_env.py` | — | 5×5 Grid World 环境 |
| `src/phase2/run.py` | — | Phase 2 完整 PEDA 循环（LearningModule 集成） |
| `src/phase2/sandbox_env.py` | — | Docker sandbox v2 环境（7 目录，14 文件） |
| `scripts/phase2_collect_data.py` | — | 数据收集/多基线评估脚本 |
| `scripts/phase2_synthetic_train.py` | — | LoRA adapter 训练脚本 |

## Phase 1.5 代码

| 文件 | 行数 | 用途 |
|------|------|------|
| `src/phase1_5/text_env.py` | 194 (note: 原 164→194) | 文本世界环境（synthetic + holdout） |
| `scripts/phase1_5_synthetic_train.py` | 224 (原 164→224) | Phase 1.5 合成数据训练脚本 |
| `scripts/phase1_5_eval.py` | 192 (原 191→192) | Phase 1.5 评估脚本 |
| `scripts/phase15_semantic_probe.py` | 116 (原 103→116) | 语义探测（intermediate hidden state） |

## Phase 3 脚本

| 文件 | 行数 | 用途 |
|------|------|------|
| `scripts/phase3_experiment.py` | — | Grid World 对照实验 |
| `scripts/phase3_run_all.py` | — | 批量执行 |
| `scripts/phase3_fast.py` | — | 快速模式 |
| `scripts/phase3_analysis.py` | — | 统计分析 |
| `scripts/phase3_analysis_sandbox.py` | 239 | 沙箱版统计分析 |
| `scripts/phase3_sandbox_experiment.py` | 163 | 沙箱对照实验（GPU 用） |

## Docker 环境

| 文件 | 行数 | 用途 |
|------|------|------|
| `Dockerfile.busybox` | 6 | 沙箱 v1 基础 Docker image |
| `Dockerfile.busybox_v2` | 33 | 沙箱 v2 扩展 Docker image（7 目录，14 文件） |

## Checkpoints

| 路径 | 大小/行数 | 说明 |
|------|-----------|------|
| `checkpoints/phase2/sandbox_adapter_e2/` | 目录 | 最佳 v1 adapter（200 curated，L1=1.000 on v1） |
| `checkpoints/phase2/sandbox_adapter_v2_full/` | 目录 | v2 全量 adapter（65 transitions，L1=0.70-0.80 held-out） |
| `checkpoints/phase2/sandbox_adapter_v2_partial/` | 目录 | v2 部分 adapter（40 known transitions） |
| `checkpoints/phase1/partial_adapter_real_25_e3/` | 目录 | Phase 1 部分 adapter（Grid World 用） |

## 实验数据

### Phase 2 Remaining (`results/phase2_remaining/`)

11 文件，包含 held-out test sets 和多基线评估结果：

| 文件 | 行数 | 说明 |
|------|------|------|
| `heldout_test_set.flat.jsonl` | 35 | Held-out 测试集平铺格式 |
| `heldout_test_set.jsonl` | 35 | Held-out 测试集原始格式 |
| `l1l2l3_heldout.json` | 10 | L1/L2/L3 held-out 指标 |
| `multi_baseline_results.json` | 140 | 多基线对比结果 |
| `peda_read_hello.jsonl` | 5 | PEDA read_hello 实验数据（5 episodes） |
| `peda_read_note.jsonl` | 5 | PEDA read_note 实验数据（5 episodes） |
| `prag_read_hello.jsonl` | 5 | Pragmatic read_hello（5 episodes） |
| `prag_read_note.jsonl` | 5 | Pragmatic read_note（5 episodes） |
| `random_read_hello.jsonl` | 5 | Random read_hello（5 episodes） |
| `random_read_note.jsonl` | 5 | Random read_note（5 episodes） |
| `report.json` | 28 | Phase 2 报告元数据 |

### Phase 3 Sandbox (`results/phase3_sandbox/`)

4 文件，各 5 episodes，N=5 方向性信号：

| 文件 | 行数 (episodes) | 条件 |
|------|-----------------|------|
| `phase3_sandbox_peda_known.jsonl` | 5 | PEDA，目标已知 |
| `phase3_sandbox_peda_unknown.jsonl` | 5 | PEDA，目标未知 |
| `phase3_sandbox_pragmatic_known.jsonl` | 5 | Pragmatic，目标已知 |
| `phase3_sandbox_pragmatic_unknown.jsonl` | 5 | Pragmatic，目标未知 |

### Phase 3 Sandbox N=20 (`results/phase3_sandbox_n20/`)

进行中（N=20，置信度加权）。数据收集尚未完成。

### Phase 3 Grid World GPU (`results/phase3_gpu/`)

| 文件 | 行数 | 说明 |
|------|------|------|
| `report.json` | 95 | Grid World GPU 实验结果（N=10/condition，天花板效应） |

## 规则与配置

| 文件 | 行数 | 用途 |
|------|------|------|
| `WATCHDOG.md` | 1029 | 守护规则（B1-B9, C1-C22, N1-N3） |
| `AGENTS.md` | 155 | 项目级 Agent 协作规则 |

## AWS GPU 实例

| 参数 | 值 |
|------|-----|
| Instance ID | `i-0cbdb085a1e726bef` |
| IP | `44.211.123.115` |
| Type | g4dn.xlarge (T4 15GB) |
| Region | us-east-1 |
| SSH | EC2 Instance Connect（key 60s 过期） |
| Python | `/opt/pytorch/bin/python` (CUDA 13.2) |

## 相关工作流文档

- [[PEDA 术语表]] — 关键概念定义
- [[PEDA 完整架构详解]] — 7 模块架构详细设计
- [[PEDA 实验方法论]] — 实验设计、数据分析流程
- [[PEDA 开发规则]] — 编码规范与审查流程
- [[AWS GPU 使用指南]] — GPU 实例配置与实验流程
- [[Phase 1 详细报告]] — Grid World 完整实验报告
- [[Phase 1.5 详细报告]] — Text World 完整分析
- [[Phase 2 详细报告]] — Sandbox 完整实验报告
