---
name: feedback-task-flow
description: 三阶段流程：调研对比→规划(等确认)→执行，三阶段均可派子agent
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7d00e18d-7602-4990-a55d-f6d8681cd375
---

**规则**：任务分三阶段执行，不可跳过阶段。

**Why:** 结合 brainstorming 技能的最佳实践和用户原始流程。先充分调研再动手，避免方向跑偏。

**How to apply:**

**阶段一（调研对比）** — ① 探索上下文 ② 查 skills.sh + 已安装技能 + GitHub 方案 ③ 逐问澄清 ④ 出 2-3 套方案对比 → 输出调研报告

**阶段二（规划设计）** — ⑤ 分块出设计逐块确认 ⑥ 写设计文档到 docs/specs/ ⑦ 自检 → ⏸ 等用户审 spec

**阶段三（执行）** — ⑧ 出执行计划拆小任务 ⑨ 派子 agent 并行执行

可用技能：brainstorming(writing-plans/executing-plans), spark, guizang-ppt-skill, pdf, xlsx, find-skills
