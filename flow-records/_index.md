# 流程沉淀目录

> 每次跑通一个流程后，在此记录。新增记录后在此加索引。

## 通用流程（跨项目）

- [任务执行-SOP规范](universal/任务执行-SOP规范.md)
- [流程沉淀系统](universal/流程沉淀系统.md)

## 项目特有流程

- [MinerU合同PDF批量OCR](project-specific/MinerU合同PDF批量OCR.md) — 港华尽调合同扫描件 MinerU API 批量 OCR 提取标题
- [通汇项目-手续清单文档批量OCR与结构化提取](project-specific/通汇项目-手续清单文档批量OCR与结构化提取.md) — 通汇光伏资产包手续清单 OCR + LLM 提取 + Excel 整理

---

### 使用方式

- **在工作流中**：直接跟我说"沉淀这个流程"
- **跑完后**：终端运行 `!precipitate`
- **目录结构**：`universal/` = 跨项目通用，`project-specific/` = 某项目独有

### 通用流程还会额外

1. 更新 `~/.claude/CLAUDE.md`（全局配置）
2. 生成 `~/.agents/skills/<name>/` 技能包（可通过 `npx skills` 管理）
