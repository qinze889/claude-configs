# Git 上传规范

## 上传流程

```bash
cd ~/.claude

# 1. 查看变更
git status

# 2. 暂存所有（或指定文件）
git add <文件>

# 3. 写 commit 信息
#    格式：<type>: <简短描述>
#    类型：feat / fix / refactor / docs / chore
git commit -m "feat: xxx"

# 4. 推送到 GitHub
git push
```

## 典型场景

| 场景 | 操作 |
|------|------|
| 修改了配置文档 | `git add sop.md env.md` → commit → push |
| 新增了技能 | `git add skills/新技能/` → commit → push |
| 沉淀了新流程 | `git add flow-records/` → commit → push |
| 收束对话（highlights） | `git add session-highlights/` → commit → push |

## 注意事项

- **不上传**：对话历史、缓存、会话运行时（已在 `.gitignore` 排除）
- **commit 粒度**：相关改动放一个 commit，不相关的分开
- **推送前**：`git status` 确认没有意外文件被暂存
