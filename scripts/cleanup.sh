#!/usr/bin/env bash
# 垃圾自清除脚本
# 用法: cleanup [--dry-run] [--keep-task] [--backup-only]
#   --backup-only  仅备份 docs/（在任务开始时调用），不执行删除
#   无参数        任务收尾时自动清理临时产物、清除过期版本
#
# 完整流程:
#   任务开始 → cleanup --backup-only  （备份当前 docs/ 状态）
#   任务结束 → cleanup                （删 _task/、清旧备份、删垃圾）

set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DRY_RUN=false
KEEP_TASK=false
BACKUP_ONLY=false

PROJECT_ROOT="$(pwd)"
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --keep-task) KEEP_TASK=true ;;
    --backup-only) BACKUP_ONLY=true ;;
    --help|-h)
      echo "用法: cleanup [--dry-run] [--keep-task] [--backup-only]"
      echo ""
      echo "  --backup-only  仅备份 docs/（任务开始时调用），不执行删除"
      echo "  --keep-task    保留 _task/ 目录"
      echo "  --dry-run      只预览不真删"
      exit 0 ;;
  esac
done

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "❌ 目录不存在: $PROJECT_ROOT"
  exit 1
fi
cd "$PROJECT_ROOT"

DELETED_COUNT=0
BACKUP_COUNT=0

echo ""
echo "═══════════════════════════════════════"
if [ "$BACKUP_ONLY" = true ]; then
  echo "  📦 文档备份（任务开始前快照）"
else
  echo "  🧹 自清除"
fi
echo "  目录: $PROJECT_ROOT"
echo "═══════════════════════════════════════"

# ── 1. 备份 docs/ ──
backup_file() {
  local file="$1"
  [ ! -f "$file" ] && return
  local backup_dir="$PROJECT_ROOT/_backup/docs"
  local basename_file
  basename_file=$(basename "$file" .md)
  mkdir -p "$backup_dir"
  local latest_backup
  latest_backup=$(ls -t "$backup_dir/${basename_file}"_*.md 2>/dev/null | head -1)
  if [ -n "$latest_backup" ] && diff "$file" "$latest_backup" &>/dev/null; then
    return
  fi
  cp "$file" "$backup_dir/${basename_file}_${TIMESTAMP}.md"
  BACKUP_COUNT=$((BACKUP_COUNT + 1))
  echo "  📦 备份: $(basename "$file") → _backup/docs/"
}

for doc in PRD DESIGN TASKS; do
  backup_file "docs/$doc.md"
done

# ── --backup-only 模式：到此结束 ──
if [ "$BACKUP_ONLY" = true ]; then
  echo ""
  echo "═══════════════════════════════════════"
  echo "  快照完成: $BACKUP_COUNT 个文件已备份"
  echo "═══════════════════════════════════════"
  exit 0
fi

# ── 2. 清理 _backup/ 过期版本（保留最新 3 个） ──
cleanup_old_backups() {
  local backup_dir="$PROJECT_ROOT/_backup/docs"
  [ ! -d "$backup_dir" ] && return
  for prefix in PRD_ DESIGN_ TASKS_; do
    local files
    files=$(ls -t "$backup_dir/${prefix}"*.md 2>/dev/null || true)
    [ -z "$files" ] && continue
    local count=0
    while IFS= read -r f; do
      count=$((count + 1))
      [ "$count" -le 3 ] && continue
      rm -f "$f"
      DELETED_COUNT=$((DELETED_COUNT + 1))
      echo "  🗑️  删除旧备份: $(basename "$f")"
    done <<< "$files"
  done
  [ -d "$PROJECT_ROOT/_backup/docs" ] && [ -z "$(ls -A "$PROJECT_ROOT/_backup/docs" 2>/dev/null)" ] && rmdir "$PROJECT_ROOT/_backup/docs" 2>/dev/null || true
  [ -d "$PROJECT_ROOT/_backup" ] && [ -z "$(ls -A "$PROJECT_ROOT/_backup" 2>/dev/null)" ] && rmdir "$PROJECT_ROOT/_backup" 2>/dev/null || true
}
cleanup_old_backups

# ── 3. 清理 _task/ ──
if [ -d "$PROJECT_ROOT/_task" ] && [ "$KEEP_TASK" = false ]; then
  rm -rf "$PROJECT_ROOT/_task"
  DELETED_COUNT=$((DELETED_COUNT + 1))
  echo "  🗑️  删除 _task/ 目录"
fi

# ── 4. 清理项目根目录下垃圾后缀文件 ──
for suffix in "*.bak" "*.old" "*.tmp" "*.log" "*.cache" "*.temp"; do
  while IFS= read -r -d '' f; do
    [[ "$f" == */_task/* ]] || [[ "$f" == */_backup/* ]] && continue
    rm -f "$f"
    DELETED_COUNT=$((DELETED_COUNT + 1))
    echo "  🗑️  删除: $f"
  done < <(find "$PROJECT_ROOT" -maxdepth 2 -name "$suffix" -print0 2>/dev/null || true)
done

# ── 5. 识别孤立 .md 文件 ──
ORPHAN_FILES=()
while IFS= read -r -d '' f; do
  [[ "$f" == "$PROJECT_ROOT/docs/"* ]] || [[ "$f" == "$PROJECT_ROOT/_task/"* ]] || [[ "$f" == "$PROJECT_ROOT/_backup/"* ]] || [[ "$f" == "$PROJECT_ROOT/CLAUDE.md" ]] && continue
  ORPHAN_FILES+=("$f")
done < <(find "$PROJECT_ROOT" -maxdepth 1 -name "*.md" -print0 2>/dev/null || true)

if [ ${#ORPHAN_FILES[@]} -gt 0 ]; then
  echo ""
  echo "⚠️  发现孤立的 .md 文件（不在 docs/ 内）:"
  for f in "${ORPHAN_FILES[@]}"; do
    echo "    $(basename "$f")"
  done
  echo "   请在 Claude 中确认是否删除或移入 docs/"
fi

# ── 报告 ──
echo ""
echo "═══════════════════════════════════════"
echo "  清除完成"
echo "  备份: $BACKUP_COUNT 个 → _backup/docs/"
echo "  已删: $DELETED_COUNT 项"
echo "═══════════════════════════════════════"
echo ""
