# 通用执行规范（SOP）

> 适用于所有项目、所有任务。违反视为无效。

## 核心原则

**先分类 → 调 Skill → 再行动。** 连澄清问题都要排在分类和 skill 调用之后。

## 请求分类分流表

收到请求后，先判断类型，路由到对应技能：

| # | 类型 | 触发词 | 流程 |
|---|------|--------|------|
| 1 | 创意/新功能 | "做个XX""想加个""新想法""设计一个" | `brainstorming` → `writing-plans` → `executing-plans` |
| 2 | 修 Bug | "报错""坏了""不对""异常""bug" | `systematic-debugging`（先诊断后动手） |
| 3 | 纯查询/知识 | "什么是""怎么理解""帮我查" | 直接回答，或 `deep-research` |
| 4 | 执行（已有方案） | "跑一下""执行""按这个做""继续" | `executing-plans` 或直接执行 |
| 5 | 代码审查 | "审查""review""帮我看看" | `requesting-code-review` / `code-review` |
| 6 | TDD 开发 | "实现XX"（需求明确） | `test-driven-development` |
| 7 | 子代理并行 | 多个独立任务 | `subagent-driven-development` |
| 8 | 完成验证 | "做完了""完成了" | `verification-before-completion` |
| 9 | 分支收尾 | "合进去""提PR""收尾" | `finishing-a-development-branch` |
| 10 | 配置/环境 | "装XX""配置XX" | 直接处理 |
| 11 | 不确定 | 模棱两可 | `using-superpowers` |

**规则：**
- 流程类 skill（brainstorming / systematic-debugging）优先于实现类
- 可能有 skill 适用（哪怕 1%）→ 必须调 Skill 工具检查
- 简单问题 ≠ 不调 skill

## 执行步骤

### 1. 入口 + 分类 + 调 Skill
1. **先调 `using-superpowers`**（会话入口，获取技能总纲）
2. 对照分类表判断类型（1-10）
3. 调对应的 Skill 工具
4. 告知用户处理方向
5. 按 skill 指导执行

### 2. 前置上下文（有 docs/ 时）
1. 项目根创建 `_task/`（在 `~` 时跳过）
2. 顺序读 `docs/PRD.md` → `docs/DESIGN.md` → `docs/TASKS.md`
3. Claude 审核用户设计决策疏漏

### 3. 执行 + 收尾
1. `_task/` 内操作（或按 skill 指导）
2. 改 docs/ 前 `cleanup --backup-only`
3. 完成后更新 TASKS.md / DESIGN.md
4. 收尾 `cleanup` 删除临时产物
5. **收束前写 session-highlights**（追加本月 MD 文件）

## 红旗清单（我偷懒的信号）

"简单问题""我先跑一下""我记得这个 skill""先做这一件事" → **STOP，先调 Skill**

## 禁止行为

- 未分类直接回应 / 未调 Skill 工具凭记忆行动
- 未读三文档直接编码 / 推荐已否决方案
- 静默重构不记录原因 / 不明确需求自行假设
