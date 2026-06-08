# 流程沉淀系统

记录跑通的工作流，自动分到通用或项目特有。

## 沉淀（创建）

- 跟我说"沉淀这个流程" → 我根据上下文创建记录
- 终端运行 `!precipitate` → 交互式创建

类型判断：
- **universal** → 通用流程，入 `flow-records/universal/` + 全局 CLAUDE.md + 生成 skill 骨架
- **project-specific** → 项目特有，入 `flow-records/project-specific/` + 项目 CLAUDE.md

## 进化（更新）

- 跟我说"进化这个流程" → 我读记录、补充变化
- 终端运行 `!evolve` → 交互式选操作：
  - 标记状态：draft → stable → deprecated
  - 类型升级：project-specific → universal（+ 创建 skill）
  - 版本日志：自动 version + changelog
  - 查看/编辑记录

## 目录结构

```
~/.claude/flow-records/
├── _index.md                 # 索引
├── _template.md              # 记录模板
├── _templates/docs/          # PRD/DESIGN/TASKS 模板
│   ├── PRD.md
│   ├── DESIGN.md
│   └── TASKS.md
├── universal/                # 通用流程记录
└── project-specific/         # 项目特有流程记录
```

## 踩坑笔记

- 脚本的 sed 占位符必须与 `_index.md` 完全一致
- Git Bash 下 sed `\\n` 可能变字面字符串，YAML 编辑用 awk
- skill 骨架只生成不注册，需手动 `npx skills` 注册
- 脚本依赖 bash + sed + awk，Windows 需 Git Bash
- `evolve` 类型升级不会自动删旧索引条目
