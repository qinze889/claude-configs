#!/usr/bin/env bash
# 流程进化脚本
# 用法: evolve [流程名]
# 不带参数时列出所有流程供选择

set -euo pipefail

FLOW_RECORDS_DIR="$HOME/.claude/flow-records"
INDEX_FILE="$FLOW_RECORDS_DIR/_index.md"
DATE_TAG=$(date +%Y-%m-%d)

# ── 帮助 ──
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  echo "用法: evolve [流程名|--help|-h]"
  echo ""
  echo "交互式管理流程进化：标记状态、变更类型、加版本日志。"
  echo ""
  echo "操作说明:"
  echo "  1) 标记状态   — draft → stable → deprecated"
  echo "  2) 变更类型   — project-specific → universal（升级）"
  echo "  3) 加版本日志 — 记一条 changelog"
  echo "  4) 查看流程   — 读当前记录"
  echo "  5) 编辑流程   — 用 vim 编辑"
  echo ""
  echo "不带参数时进入交互选择模式。"
  echo "带流程名（或模糊匹配）时直接进入该流程的进化菜单。"
  exit 0
fi

# ── 解析参数 ──
TARGET_NAME="${1:-}"

# 如果没传名字，进入选择模式
if [ -z "$TARGET_NAME" ]; then
  # 收集所有流程文件
  FLOW_FILES=()
  FLOW_LABELS=()
  while IFS='|' read -r name type slug filepath; do
    FLOW_FILES+=("$filepath")
    FLOW_LABELS+=("[$type] $name")
  done < <(find "$FLOW_RECORDS_DIR/universal" "$FLOW_RECORDS_DIR/project-specific" -name "*.md" ! -name "_*" 2>/dev/null | while read -r f; do
    basename=$(basename "$f" .md)
    dirname=$(basename "$(dirname "$f")")
    name=$(head -20 "$f" | grep "^name:" | sed 's/^name: *"\(.*\)"/\1/')
    [ -z "$name" ] && name="$basename"
    echo "$name|$dirname|$basename|$f"
  done | sort)

  if [ ${#FLOW_FILES[@]} -eq 0 ]; then
    echo "❌ 还没有沉淀的流程，先跑一个沉淀一下？"
    exit 0
  fi

  echo ""
  echo "📋 选择要进化的流程:"
  echo ""
  for i in "${!FLOW_LABELS[@]}"; do
    echo "  $((i+1))) ${FLOW_LABELS[$i]}"
  done
  echo "  0) 取消"
  echo ""
  read -r -p "选择编号: " CHOICE
  if [ -z "$CHOICE" ] || [ "$CHOICE" = "0" ]; then
    echo "已取消"
    exit 0
  fi
  IDX=$((CHOICE - 1))
  [ "$IDX" -lt 0 ] || [ "$IDX" -ge "${#FLOW_FILES[@]}" ] && { echo "❌ 无效选择"; exit 1; }
  RECORD_FILE="${FLOW_FILES[$IDX]}"
  LABEL="${FLOW_LABELS[$IDX]}"
else
  # 通过名称查找
  MATCHES=()
  while IFS='|' read -r name type slug filepath; do
    if [[ "$name" == *"$TARGET_NAME"* ]] || [[ "$slug" == *"$TARGET_NAME"* ]]; then
      MATCHES+=("$filepath|$name|$type")
    fi
  done < <(find "$FLOW_RECORDS_DIR/universal" "$FLOW_RECORDS_DIR/project-specific" -name "*.md" ! -name "_*" 2>/dev/null | while read -r f; do
    basename=$(basename "$f" .md)
    dirname=$(basename "$(dirname "$f")")
    name=$(head -20 "$f" | grep "^name:" | sed 's/^name: *"\(.*\)"/\1/')
    [ -z "$name" ] && name="$basename"
    echo "$name|$dirname|$basename|$f"
  done)

  if [ ${#MATCHES[@]} -eq 0 ]; then
    echo "❌ 未找到匹配的流程: $TARGET_NAME"
    exit 1
  elif [ ${#MATCHES[@]} -eq 1 ]; then
    IFS='|' read -r RECORD_FILE NAME TYPE <<< "${MATCHES[0]}"
    LABEL="[$TYPE] $NAME"
  else
    echo "找到多个匹配:"
    for i in "${!MATCHES[@]}"; do
      IFS='|' read -r f n t <<< "${MATCHES[$i]}"
      echo "  $((i+1))) [$t] $n"
    done
    read -r -p "选择编号: " CHOICE
    IDX=$((CHOICE - 1))
    IFS='|' read -r RECORD_FILE NAME TYPE <<< "${MATCHES[$IDX]}"
    LABEL="[$TYPE] $NAME"
  fi
fi

echo ""
echo "═══════════════════════════════════════"
echo "  当前流程: $LABEL"
echo "  文件: $RECORD_FILE"
echo "═══════════════════════════════════════"

# ── 读取当前状态 ──
CURRENT_STATUS=$(grep "^status:" "$RECORD_FILE" | sed 's/^status: *//')
CURRENT_VERSION=$(grep "^version:" "$RECORD_FILE" | sed 's/^version: *//')
[ -z "$CURRENT_VERSION" ] && CURRENT_VERSION="1"

echo ""
echo "当前状态: $CURRENT_STATUS | 版本: v$CURRENT_VERSION"
echo ""
echo "进化操作:"
echo "  1) 标记状态   — draft → stable → deprecated"
echo "  2) 变更类型   — project-specific → universal（升级）"
echo "  3) 加版本日志 — 记一条 changelog"
echo "  4) 查看流程   — 读当前记录"
echo "  5) 编辑流程   — 用 vim 编辑"
echo "  0) 取消"
echo ""
read -r -p "选择操作: " ACTION

case "$ACTION" in
  1)
    echo ""
    echo "可选状态: draft, stable, deprecated"
    read -r -p "新状态 [stable]: " NEW_STATUS
    [ -z "$NEW_STATUS" ] && NEW_STATUS="stable"
    sed -i "s/^status: .*/status: $NEW_STATUS/" "$RECORD_FILE"
    echo "✅ 状态已更新: $CURRENT_STATUS → $NEW_STATUS"
    ;;
  2)
    # 只允许 project-specific → universal
    CURRENT_DIR=$(basename "$(dirname "$RECORD_FILE")")
    SLUG=$(basename "$RECORD_FILE" .md)
    if [ "$CURRENT_DIR" = "universal" ]; then
      echo "⚠️  已经是 universal 类型，不支持降级"
      exit 0
    fi
    echo ""
    echo "升级为 universal 后将会:"
    echo "  • 文件移到 universal/"
    echo "  • 创建 skill 骨架"
    echo "  • 追加到全局 CLAUDE.md"
    read -r -p "确定升级? [y/N] " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
      echo "已取消"
      exit 0
    fi
    # 更新 frontmatter
    sed -i 's/^type: project-specific/type: universal/' "$RECORD_FILE"
    # 移动文件
    NEW_PATH="$FLOW_RECORDS_DIR/universal/$SLUG.md"
    mv "$RECORD_FILE" "$NEW_PATH"
    echo "✅ 流程已升级为 universal"
    echo "   新位置: $NEW_PATH"

    # 更新 _index.md: 从 project-specific 部分删除旧条目，并追加到 universal 部分
    if [ -f "$INDEX_FILE" ]; then
      # 构造旧条目的链接模式: [NAME](project-specific/SLUG.md)
      OLD_LINK="- \\[$NAME\\]\\(project-specific/$SLUG\\.md\\)"
      # 删除 project-specific section 中匹配的行
      sed -i "/$OLD_LINK/d" "$INDEX_FILE"
      # 构造新条目，追加到 universal section 末尾
      NEW_LINK="- [$NAME](universal/$SLUG.md)"
      # 找到 universal section 标题行，在其后追加
      sed -i "/^## 通用流程（跨项目）$/a\\$NEW_LINK" "$INDEX_FILE"
      echo "📝 已更新 _index.md: 从 project-specific 移至 universal"
    fi

    # 创建 skill (不覆盖已有)
    SKILL_DIR="$HOME/.agents/skills/$SLUG"
    if [ ! -d "$SKILL_DIR" ]; then
      mkdir -p "$SKILL_DIR"
      cat > "$SKILL_DIR/skill.json" <<SKILLEOF
{
  "name": "$SLUG",
  "description": "$NAME",
  "source": "flow-records",
  "trigger": ["$SLUG"],
  "version": "1.0.0"
}
SKILLEOF
      cat > "$SKILL_DIR/instructions.md" <<SKILLEOF
# $NAME

> 由 evolve 升级生成 ($DATE_TAG)
> 完整记录: $NEW_PATH

## 触发条件

## 输入

## 执行步骤

更多详情见完整记录文件。
SKILLEOF
      echo "🧩 Skill 骨架已创建: $SKILL_DIR"
    fi

    # 追加到全局 CLAUDE.md
    GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
    if [ -f "$GLOBAL_CLAUDE" ]; then
      {
        echo ""
        echo "### $NAME"
        echo "类型: universal | 来源: $NEW_PATH"
        echo ""
      } >> "$GLOBAL_CLAUDE"
      echo "📝 已追加到全局 CLAUDE.md"
    fi
    RECORD_FILE="$NEW_PATH"
    ;;
  3)
    echo ""
    echo "当前版本: v$CURRENT_VERSION"
    read -r -p "新版本号 (直接回车 = $((CURRENT_VERSION + 1))): " NEW_VER
    [ -z "$NEW_VER" ] && NEW_VER=$((CURRENT_VERSION + 1))
    echo "这次改了啥？写一句 changelog（如: 补充步骤三, 增加验证方法）"
    read -r -p "> " CHANGE_MSG
    if [ -n "$CHANGE_MSG" ]; then
      sed -i "s/^version: .*/version: $NEW_VER/" "$RECORD_FILE"
      sed -i "s/^updated: .*/updated: $DATE_TAG/" "$RECORD_FILE"
      # 在 changelog 区块追加
      awk -v date="$DATE_TAG" -v msg="$CHANGE_MSG" '
        /^changelog:/ { print; print "  - date: " date; print "    change: " msg; next }
        { print }
      ' "$RECORD_FILE" > "$RECORD_FILE.tmp" && mv "$RECORD_FILE.tmp" "$RECORD_FILE"
      echo "✅ v$CURRENT_VERSION → v$NEW_VER | $CHANGE_MSG"
    else
      echo "已取消"
    fi
    ;;
  4)
    echo ""
    echo "───────────────────────────────────────"
    cat "$RECORD_FILE"
    echo "───────────────────────────────────────"
    ;;
  5)
    # 在 Git Bash 下尝试用 vim 或 nano
    if command -v vim &>/dev/null; then
      vim "$RECORD_FILE"
    elif command -v nano &>/dev/null; then
      nano "$RECORD_FILE"
    else
      echo "❌ 未找到编辑器 (vim/nano)"
      echo "   直接编辑: $RECORD_FILE"
    fi
    ;;
  *)
    echo "已取消"
    exit 0
    ;;
esac

# 更新记录文件的 updated 字段（状态变更和编辑操作也更新时间戳）
if [ "$ACTION" = "1" ] || [ "$ACTION" = "5" ]; then
  sed -i "s/^updated: .*/updated: $DATE_TAG/" "$RECORD_FILE"
fi
