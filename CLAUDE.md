# Global CLAUDE.md

全局配置，对所有项目生效。项目特有内容写对应目录的 `CLAUDE.md`。

## 快速导航

| 路径 | 内容 |
|------|------|
| [sop.md](sop.md) | 通用执行规范 |
| [env.md](env.md) | 环境配置（Python/OCR/API/编码约定） |
| [privacy.md](privacy.md) | 用户隐私规范（第三方API上传限制） |
| [anti-corruption.md](anti-corruption.md) | 对话防腐化机制 |
| [checkpoint.md](checkpoint.md) | 会话状态检查点 |
| [flow-precipitation.md](flow-precipitation.md) | 流程沉淀/进化系统 |
| [skills/README.md](skills/README.md) | 已安装技能清单 |
| [flow-records/_index.md](flow-records/_index.md) | 已沉淀流程索引 |

## 快捷命令

| 命令 | 作用 |
|------|------|
| `cleanup` | 清理 `_task/`、旧备份、垃圾文件 |
| `cleanup --backup-only` | 修改三文档前备份 |
| `cleanup --dry-run` | 预览可删内容 |
| `!precipitate` | 沉淀当前流程 |
| `!evolve` | 进化已有流程记录 |

## 会话行为

### 防腐化（anti-corruption）

- **主动监视对话长度**：任务接近完成 / 话题切换 / 轮数偏多时，提醒你"要不要收束？"
- **不管你听不听**：提醒一次后你决定继续——那我继续（不反复催）；你决定收束——我配合完成沉淀
