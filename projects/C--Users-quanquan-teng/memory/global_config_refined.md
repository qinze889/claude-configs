---
name: global-config-refined
description: 全局 CLAUDE.md 重构：精简索引 + 独立文件存放具体内容，技能/环境配置全局化
metadata: 
  node_type: memory
  type: project
  originSessionId: 0473e8a8-d6ec-4695-80b6-c8a32deca16f
---

全局 CLAUDE.md 重构结果：
- `~/.claude/CLAUDE.md` → 精简为导航索引
- `~/.claude/sop.md` → 通用执行规范详情
- `~/.claude/env.md` → 环境配置（PyMuPDF/编码/API）
- `~/.claude/flow-precipitation.md` → 流程沉淀系统详情
- `~/.claude/skills/README.md` → 已安装技能清单
- `~/CLAUDE.md` → 只保留角色、工作场景、路径约定

**Why:** 原来全局 CLAUDE.md 120 行堆积全部内容，找东西不方便。拆成索引+独立文件，按路径导航。

**How to apply:** 需要找什么配置先去 `~/.claude/CLAUDE.md` 看索引，再按路径去对应文件。
