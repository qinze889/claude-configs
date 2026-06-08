---
name: "任务执行-SOP规范"
type: universal
project: ""
created: 2026-06-08
updated: 2026-06-08
tags: [sop, workflow, standard]
status: draft
version: 6
changelog:
  - date: 2026-06-08
    change: v6: 审查修复：空代码块、编号断档、分支逻辑细化、cleanup 纳入报告、全局/项目文件精简去重
  - date: 2026-06-08
    change: v5: 阶段一去掉"探索上下文"（与 SOP 前置读取重复）
  - date: 2026-06-08
    change: v4: 重构备份/清理为两条独立规则，备份在修改前，清理在方案废弃或收尾
  - date: 2026-06-08
    change: v3: 增加 docs 模板引用、_task/ 家目录限制、Claude 审核职责
  - date: 2026-06-08
    change: v2: 增加工作目录隔离规则（_task/）
  - date: 2026-06-08
    change: 初版创建
---

## 摘要

所有项目通用的执行规范：前置读取三文档 → 执行 → 同步更新，确保每次任务有上下文、有记录、不偏航。

## 触发条件

每次开始新任务、每个任务节点完成后。

## 输入

- 项目根目录下的 `docs/` 文件夹
- 三个文档：PRD.md（需求）、DESIGN.md（方案）、TASKS.md（进度）

## 执行步骤

1. **创建工作目录**：在项目根目录创建 `_task/`，所有生成文件放此处
   - ⚠️ 若当前在 `~` 家目录下，不要创建 `_task/`
2. **前置读取**：按顺序读 `docs/PRD.md`、`docs/DESIGN.md`、`docs/TASKS.md`
   - 若某文件不存在，先与你沟通了解任务背景和目标，由我生成初始内容，你确认后再继续
   - 读完向用户简要报告当前项目状态
3. **Claude 审核**：用户的设计决策和需求判断，我要主动审查疏漏
4. **执行任务**（在 `_task/` 内操作）
5. **修改文档前先备份**：改 `docs/` 下任何文件前，执行 `cleanup --backup-only`
6. **同步更新**：完成后更新 `docs/TASKS.md` 状态，若改技术方案则同步更新 `docs/DESIGN.md`
7. **方案废弃时清理**：如果当前方案跑不通要换方向，执行 `cleanup` 删除 `_task/` 临时产物
8. **任务收尾清理**：最终执行 `cleanup` 删除 `_task/`、清旧备份、删垃圾文件

## 预期产出

- 每个任务节点都有状态追踪
- 技术方案变更可追溯
- 需求范围始终明确

## 禁止行为

- 未读取上述文档直接编码
- 推荐或实现 DESIGN.md 中"已否决方案"里的任何方案
- 静默重构已有方案而不记录原因
- 对不明确的需求自行假设，必须先提问

## 验证方法

- 每次开始任务前检查是否已读取三个文件
- 每次完成任务后检查 TASKS.md 是否更新
- 有方案变更检查 DESIGN.md 是否同步更新

## 关联

- 全局 SOP 文档：`~/.claude/sop.md`
- 全局环境配置：`~/.claude/env.md`
- 全局技能清单：`~/.claude/skills/README.md`
- 全局 CLAUDE.md 索引：`~/.claude/CLAUDE.md`
- 项目文档：项目目录 `docs/` 下的 PRD.md / DESIGN.md / TASKS.md
- 流程沉淀系统：`~/.claude/flow-precipitation.md`
