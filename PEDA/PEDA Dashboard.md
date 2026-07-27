---
tags: [dashboard, index, overview]
status: running
phase: 3
date: 2026-07-27
---

# PEDA Dashboard

> 项目状态总览 — 自动更新于 2026-07-27

---

## 统计概览

```dataviewjs
// Total notes count
let total = dv.pages('"PEDA"').length;

// Experiments completed
let experiments = dv.pages('#experiment');
let completed = experiments.where(p => p.status == "completed").length;

// Phases done
let phases = dv.pages('#experiment');
let phasesDone = dv.pages('#report').where(p => p.status == "completed").length;

dv.span("**总笔记数**: " + total + " | ");
dv.span("**实验完成**: " + completed + " | ");
dv.span("**Phase 完成**: 1, 1.5, 2, 3 ✅ | ")
dv.span("**当前 Phase**: 3 (N=20 ✅)");
```

---

## 实验总表

```dataview
TABLE
  status as "状态",
  phase as "Phase",
  n_samples as "N",
  success_rate_peda as "PEDA 成功率",
  success_rate_pragmatic as "Pragmatic 成功率",
  p_value as "p-value",
  verdict as "结论"
FROM #experiment
SORT phase ASC
```

---

## 活跃 / 阻塞项

```dataview
LIST
FROM #experiment
WHERE status = "running" OR status = "planned"
SORT phase ASC
```

---

## 待办任务

```dataview
TASK
FROM "PEDA"
WHERE !completed
```

---

## 决策索引

```dataview
TABLE
  status as "状态",
  phase as "Phase"
FROM #decision
SORT phase ASC
```

---

## 架构笔记

```dataview
TABLE
  status as "状态",
  phase as "Phase"
FROM #architecture
SORT file.name ASC
```

---

## 参考笔记

```dataview
TABLE
  status as "状态",
  phase as "Phase"
FROM #reference
SORT file.name ASC
```

---

## 快速导航

| 类别 | 笔记 |
|------|------|
| **Overview** | [[PEDA Overview]] · [[PEDA 研究动机]] · [[PEDA 中文路线图]] |
| **Architecture** | [[PEDA 完整架构详解]] · [[PEDA Architecture - Drive System]] · [[PEDA Architecture - Learning Module]] · [[PEDA Architecture - World Model]] |
| **Methodology** | [[PEDA 实验方法论]] · [[PEDA 术语表]] · [[PEDA 开发规则]] |
| **Reports** | [[Phase 1 详细报告]] · [[Phase 1.5 详细报告]] · [[Phase 2 详细报告]] |
| **Experiments** | [[Phase 2 Sandbox - Held-Out]] · [[Phase 3 Sandbox N=5]] · [[Phase 3 Sandbox N=20]] |
| **Decisions** | [[WM as Pattern Matcher]] · [[Phase Restructure v2.0]] · [[Data Quality over Quantity]] |
| **Infrastructure** | [[AWS GPU 使用指南]] · [[PEDA Reference Index]] |
| **Index** | [[PEDA Tag Index]] |
