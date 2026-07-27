---
tags: [index, reference, meta]
status: done
phase: 3
date: 2026-07-27
---

# PEDA Tag Index

> 所有标签及其含义的索引。用于 Obsidian Dataview 查询和笔记导航。

---

## 内容分类

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#overview` | 项目概览和导航 | PEDA Overview, PEDA 研究动机, PEDA 中文路线图 |
| `#architecture` | 系统架构文档 | PEDA 完整架构详解, Drive System, Learning Module, World Model |
| `#reference` | 参考资料和索引 | PEDA Reference Index, PEDA 术语表, PEDA 实验方法论 |
| `#methodology` | 方法和统计标准 | PEDA 实验方法论 |
| `#rules` | 开发规则和 WATCHDOG | PEDA 开发规则 |
| `#workflow` | 工作流程相关 | PEDA 开发规则 |
| `#glossary` | 术语定义 | PEDA 术语表 |
| `#theory` | 理论基础 | PEDA 研究动机, PEDA 术语表 |

---

## 实验相关

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#experiment` | 实验报告/数据 | Phase 1, 1.5, 2 详细报告; Phase 2 Held-Out; Phase 3 Sandbox N=5/N=20 |
| `#report` | 完整实验报告 | Phase 1, 1.5, 2 详细报告 |
| `#phase1` | Phase 1 相关 | Phase 1 详细报告 |
| `#phase1_5` | Phase 1.5 相关 | Phase 1.5 详细报告 |
| `#phase2` | Phase 2 相关 | Phase 2 详细报告, Data Quality over Quantity |
| `#phase3` | Phase 3 相关 | Phase 3 Sandbox N=5/N=20 |
| `#pilot` | 探索性实验 (N<10) | Phase 3 Sandbox N=5 |
| `#confirmatory` | 验证性实验 (N>=10) | Phase 3 Sandbox N=20 |
| `#heldout` | Held-out 评估 | Phase 2 Sandbox - Held-Out |
| `#sandbox` | Sandbox 环境实验 | Phase 3 Sandbox N=5/N=20 |
| `#evaluation` | 模型评估 | Phase 2 Sandbox - Held-Out |

---

## 决策相关

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#decision` | 架构/策略决策 | WM as Pattern Matcher, Phase Restructure v2.0, Data Quality over Quantity |
| `#planning` | 项目规划 | Phase Restructure v2.0 |
| `#restructuring` | 阶段重组 | Phase Restructure v2.0 |
| `#data` | 数据策略 | Data Quality over Quantity |
| `#analysis` | 深度分析 | WM as Pattern Matcher |

---

## 架构模块

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#drive-system` | Drive System 模块 | PEDA Architecture - Drive System |
| `#learning-module` | Learning Module 模块 | PEDA Architecture - Learning Module |
| `#world-model` | World Model 模块 | PEDA Architecture - World Model |
| `#code` | 包含源代码片段 | PEDA Architecture - Drive System, Learning Module, World Model |
| `#detailed` | 详细技术文档 | PEDA 完整架构详解 |

---

## 基础设施

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#infrastructure` | 实验基础设施 | AWS GPU 使用指南 |
| `#gpu` | GPU 相关 | AWS GPU 使用指南 |
| `#aws` | AWS 云服务 | AWS GPU 使用指南 |
| `#guide` | 操作指南 | AWS GPU 使用指南 |

---

## 索引和元数据

| 标签 | 含义 | 适用笔记 |
|------|------|---------|
| `#index` | 文件/标签索引 | PEDA Reference Index, PEDA Tag Index |
| `#files` | 文件索引 | PEDA Reference Index |
| `#dashboard` | 项目仪表盘 | PEDA Dashboard |
| `#meta` | 元数据笔记 | PEDA Tag Index |
| `#statistics` | 统计方法 | PEDA 实验方法论 |

---

## 状态标签

| 标签 | 含义 |
|------|------|
| `#status/done` | 已完成 |
| `#status/running` | 进行中 |
| `#status/planned` | 计划中 |
| `#status/completed` | 实验已完成（含负结果） |

---

## 常用 Dataview 查询

```dataview
TABLE
  file.tags as "Tags",
  status as "Status",
  phase as "Phase"
FROM "PEDA"
SORT phase ASC
```

---

## 相关笔记

- [[PEDA Dashboard]] — 项目总览仪表盘
- [[PEDA Reference Index]] — 文件索引
- [[PEDA 术语表]] — 概念定义
