---
name: session-log
description: 会话收束记录按月拆分，位于 ~/.claude/session-log/YYYY-MM.md，每次收束追加一条
metadata: 
  node_type: memory
  type: reference
  originSessionId: 0473e8a8-d6ec-4695-80b6-c8a32deca16f
---

每次收束对话时，在 `~/.claude/session-log/YYYY-MM.md` 追加一条记录。格式：
- 标题行：日期 / 关键词1 / 关键词2
- 正文：改动清单

**Why:** 用户想自己回顾做了什么，按月存档便于翻阅。

**How to apply:** 每次收束前，确定当前月份文件，追加一条新记录。
