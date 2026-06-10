---
name: sop-superpowers-integration
description: SOP 已整合 superpowers 技能集，请求需先分类再调 Skill 再行动
metadata:
  type: feedback
---

SOP 已升级整合 `obra/superpowers` 全部 14 个 skill，核心流程改为：**入口调 using-superpowers → 请求分类 → 调对应 Skill 工具 → 按 skill 执行 → 验证收尾**。

**Why:** 用户要求建立请求分流机制，让不同类型的请求（创意/修 bug/TDD/代码审查等）自动路由到对应 superpowers skill，避免跳步骤或凭记忆行动。

**How to apply:** 每次收到请求，先调 using-superpowers，再对照分类表判断类型，再调对应 Skill 工具，最后行动。会话收束前必须写 session-highlights。关联 SOP flow record: `flow-records/universal/任务执行-SOP规范.md`。
