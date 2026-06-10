---
name: "任务执行-SOP规范"
type: universal
project: ""
created: 2026-06-08
updated: 2026-06-10
tags: [sop, workflow, standard, superpowers]
status: draft
version: 7
changelog:
  - date: 2026-06-10
    change: v7: 整合 superpowers 技能集，增加请求分类→skill 路由→验证的分流环节
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

请求分类 → 路由到对应 superpowers skill → 执行 → 验证收尾。每次任务有上下文、有流程、有记录。

## 触发条件

每次收到新请求时执行。注意：**先调 using-superpowers，再分类，再行动**，连澄清问题都要排在这之后。

## 入口：using-superpowers（每次会话/新请求第 1 步）

每次开始新任务，**第 1 步调 `using-superpowers` skill**。它提供：
- 完整的 skill 调用规则（"1% 可能就要调"）
- 红旗清单（防止我偷懒不调 skill）
- skill 优先级排序规则
- 平台适配说明

调完后再对照下表判断具体的请求类型。

## 请求分类分流表

收到请求后，先判断类型，路由到对应 skill：

| # | 请求类型 | 触发关键词/场景 | 路由（Skill + 流程） |
|---|---------|----------------|-------------------|
| 1 | 🧠 **创意/新功能** | "做个XX""想加个""新想法""设计一个" | `brainstorming` → `writing-plans` → `executing-plans` |
| 2 | 🐛 **修 Bug** | "报错""坏了""不对""异常""bug""不工作" | `systematic-debugging`（诊断后再动手） |
| 3 | 💬 **纯查询/知识** | "什么是""怎么理解""XX是什么""帮我查" | 直接回答，或 `deep-research`（需多源查证） |
| 4 | ⚡ **执行（已有方案）** | "跑一下""执行""按这个做""继续" | `executing-plans` 或直接执行 |
| 5 | 👁 **代码审查** | "审查""review""帮我看看代码""检查" | `requesting-code-review` / `code-review` skill |
| 6 | 🧪 **TDD 开发** | "实现XX"（需求明确有预期行为） | `test-driven-development`（先测试后代码） |
| 7 | 🔀 **子代理并行** | 多个独立任务可同时做，无共享状态 | `subagent-driven-development` 或 `dispatching-parallel-agents` |
| 8 | ✅ **完成验证** | "做完了""搞定了""完成了" | `verification-before-completion`（验证后再宣称完成） |
| 9 | 🎯 **分支收尾** | "合进去""提PR""收尾""可以合并了" | `finishing-a-development-branch` |
| 10 | 🔧 **配置/环境** | "装XX""配置XX""环境问题" | 直接处理，必要时调对应 domain skill |

**分流规则：**
- 流程类 skill（brainstorming / systematic-debugging）优先于实现类 skill
- 一个请求可能跨多种类型 → 按最匹配的走，执行中再调其他 skill
- "简单问题"≠"不调 skill" — 见下面红旗清单

## 执行步骤

### 阶段一：入口 -> 分类 -> Skill 路由

1. **收到请求**，先不回应、不行动、不问澄清问题
2. **第一步调 `using-superpowers` skill**（会话入口，获取技能总纲）
3. **对照分类表**判断请求类型（1-10）
4. **调对应的具体 Skill 工具**，让 skill 内容指导后续行动
   - 如果可能有 skill 适用（哪怕 1% 可能），**必须**调 Skill 工具检查
   - 多个 skill 匹配时，先调流程类，再调实现类
5. **告知用户**："按[请求类型]处理，调用了[skill名]"
6. **按 skill 的指导执行**

### 阶段二：前置上下文（适用于有项目文档的场景）

1. **创建工作目录**：在项目根目录创建 `_task/`，所有生成文件放此处
   - 若当前在 `~` 家目录下，不要创建 `_task/`
2. **前置读取**：按顺序读 `docs/PRD.md`、`docs/DESIGN.md`、`docs/TASKS.md`
   - 若某文件不存在，先与你沟通了解任务背景和目标，由我生成初始内容，你确认后再继续
   - 读完向用户简要报告当前项目状态
3. **Claude 审核**：用户的设计决策和需求判断，我要主动审查疏漏

### 阶段三：执行 + 验证

4. **执行任务**（在 `_task/` 内操作，或按 skill 指导执行）
5. **修改文档前先备份**：改 `docs/` 下任何文件前，执行 `cleanup --backup-only`
6. **同步更新**：完成后更新 `docs/TASKS.md` 状态，若改技术方案则同步更新 `docs/DESIGN.md`
7. **方案废弃时清理**：如果当前方案跑不通要换方向，执行 `cleanup` 删除 `_task/` 临时产物
8. **任务收尾清理**：最终执行 `cleanup` 删除 `_task/`、清旧备份、删垃圾文件
9. **收束时写 session highlight**：在 `~/.claude/session-highlights/YYYY-MM.md` 追加本会话关键变更（做了什么、改了什么东西、流程沉淀记录）
   - 会话收束/收尾/cleanup 前执行，确保不遗漏
   - 格式参考已有记录，一句话概括 + 清单

## 预期产出

- 每个任务按正确流程执行，不跳步骤
- 请求类型自动分流，不走错流程
- 技术方案变更可追溯
- 需求范围始终明确

## 禁止行为

- 未分类直接回应
- 未调 Skill 工具凭记忆行动
- 推荐或实现 DESIGN.md 中"已否决方案"里的任何方案
- 静默重构已有方案而不记录原因
- 对不明确的需求自行假设，必须先提问
- "简单问题不需要 skill" — 见下面红旗清单

## 红旗清单（我在偷懒不调 skill 的信号）

| 想法 | 真相 |
|------|------|
| "这只是一个简单问题" | 问题也是任务，先检查 skill |
| "我需要更多上下文" | Skill 检查在澄清问题之前 |
| "让我先看看代码" | Skill 告诉你怎么探索，先调 |
| "我先跑一下看看" | 先调 skill，再动手 |
| "我记得这个 skill 的内容" | Skill 会更新，调当前版本 |
| "这不算一个任务" | 有行动 = 有任务，调 skill |
| "这个 skill 太大材小用了" | 简单的事也会变复杂，用 skill |
| "我先做这一件事" | 在做事之前调 Skill 工具 |

## 验证方法

- 每次开始任务前检查是否已分类 + 调 skill
- 每次完成任务后检查 TASKS.md 是否更新
- 有方案变更检查 DESIGN.md 是否同步更新

## 关联

- 全局 SOP 文档：`~/.claude/sop.md`
- 全局环境配置：`~/.claude/env.md`
- 全局 CLAUDE.md 索引：`~/.claude/CLAUDE.md`
- 技能总纲：`using-superpowers` skill（会话开始时调用）
- 流程沉淀系统：`~/.claude/flow-precipitation.md`
- 项目文档：项目目录 `docs/` 下的 PRD.md / DESIGN.md / TASKS.md
