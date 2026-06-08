---
name: flow-precipitation-system
description: How to record workflows after they work — stored in .claude/flow-records with auto-routing
metadata: 
  node_type: memory
  type: reference
  originSessionId: 2942a771-c72d-4e89-9470-ccb09c5f5c89
---

The flow precipitation system lives at `~/.claude/flow-records/`. When a workflow is confirmed working, record it there.

**Two paths:**
- **Universal** → `flow-records/universal/` + `~/.claude/CLAUDE.md` + `~/.agents/skills/<name>/` skill
- **Project-specific** → `flow-records/project-specific/` + project's CLAUDE.md

**Trigger:**
- User says "沉淀这个流程" / "记下来" → I create the record from conversation context
- User runs `!precipitate` → interactive bash script

**My behavior (from CLAUDE.md):**
- Proactively ask "要不要沉淀" when a workflow finishes
- Judge universal vs project-specific from context
- Use template from `_template.md`

See [[flow-records-index]] for current records.
