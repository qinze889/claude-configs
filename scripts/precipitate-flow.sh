#!/usr/bin/env bash
# 流程沉淀脚本
# 用法: precipitate [流程名称] [--type universal|project-specific] [--project 项目名]
# 不带参数时进入交互模式

set -euo pipefail

FLOW_RECORDS_DIR="$HOME/.claude/flow-records"
TEMPLATE_FILE="$FLOW_RECORDS_DIR/_template.md"
INDEX_FILE="$FLOW_RECORDS_DIR/_index.md"
NOW=$(date +%Y%m%d_%H%M%S)
DATE_TAG=$(date +%Y-%m-%d)

# 解析参数
NAME=""
TYPE=""
PROJECT=""
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type|-t) TYPE="$2"; shift 2 ;;
    --project|-p) PROJECT="$2"; shift 2 ;;
    --project-path|-pp) PROJECT_PATH="$2"; shift 2 ;;
    --help|-h)
      echo "用法: precipitate [流程名称] [--type universal|project-specific] [--project 项目名] [--project-path 路径]"
      echo ""
      echo "  交互模式: 不带参数运行，逐一问答"
      echo "  快速模式: 带参数直接创建"
      echo ""
      echo "  --type (-t)          universal | project-specific"
      echo "  --project (-p)       项目名（仅 project-specific）"
      echo "  --project-path (-pp) 项目绝对路径（仅 project-specific）"
      exit 0 ;;
    -*)
      echo "未知参数: $1"
      exit 1 ;;
    *)
      NAME="$1"
      shift ;;
  esac
done

# ── 交互式补全 ──
if [ -z "$NAME" ]; then
  echo ""
  read -r -p "📋 流程名称（必填）: " NAME
  if [ -z "$NAME" ]; then
    echo "❌ 流程名不能为空"
    exit 1
  fi
fi

if [ -z "$TYPE" ]; then
  echo ""
  echo "类型选择:"
  echo "  1) universal       — 跨项目通用（→ 全局 CLAUDE.md + 创建 skill）"
  echo "  2) project-specific — 某项目特有（→ 项目 CLAUDE.md）"
  read -r -p "选择 [1/2] (default 2): " TYPE_CHOICE
  if [ "$TYPE_CHOICE" = "1" ]; then
    TYPE="universal"
  else
    TYPE="project-specific"
  fi
fi

if [ "$TYPE" = "project-specific" ] && [ -z "$PROJECT" ]; then
  echo ""
  read -r -p "📁 项目名（如 毕业论文/港华合同）: " PROJECT
  echo ""
  echo "已知项目路径（来自 CLAUDE.md）:"
  echo "  1) 毕业论文         → Desktop/信管223#-滕泉泉-2200400220/"
  echo "  2) 港华合同         → Desktop/归档/合同文档/港华/港华总文件/"
  echo "  3) 手动输入路径"
  read -r -p "选择 [1/2/3] (default 3): " PROJECT_PATH_CHOICE
  case "$PROJECT_PATH_CHOICE" in
    1) PROJECT_PATH="$HOME/Desktop/信管223#-滕泉泉-2200400220" ;;
    2) PROJECT_PATH="$HOME/Desktop/归档/合同文档/港华/港华总文件" ;;
    3)
      read -r -p "输入项目绝对路径: " PROJECT_PATH
      PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
      ;;
    *)
      read -r -p "输入项目绝对路径: " PROJECT_PATH
      PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"
      ;;
  esac
fi

# ── Slug 化文件名 ──
SLUG=$(echo "$NAME" | sed -E 's/[^a-zA-Z0-9一-鿿_-]/-/g' | sed -E 's/-+/-/g' | sed -E 's/^-|-$//g')
if [ "$TYPE" = "universal" ]; then
  TARGET_DIR="$FLOW_RECORDS_DIR/universal"
else
  TARGET_DIR="$FLOW_RECORDS_DIR/project-specific"
fi
RECORD_FILE="$TARGET_DIR/${SLUG}.md"

# ── 从模板创建记录 ──
if [ -f "$RECORD_FILE" ]; then
  echo ""
  echo "⚠️  记录已存在: $RECORD_FILE"
  read -r -p "覆盖? [y/N] " OVERWRITE
  if [ "$OVERWRITE" != "y" ] && [ "$OVERWRITE" != "Y" ]; then
    echo "已取消"
    exit 0
  fi
fi

sed -e "s/{{date}}/$DATE_TAG/g" \
    -e "s/name: \"\"/name: \"$NAME\"/g" \
    -e "s/type: universal | project-specific/type: $TYPE/" \
    -e "s/project: \"\"/project: \"${PROJECT:-}\"/" \
    "$TEMPLATE_FILE" > "$RECORD_FILE"

echo ""
echo "✅ 记录已创建: $RECORD_FILE"
echo ""

# ── 更新 _index.md ──
ENTRY_LINE="- [$NAME]($TYPE/${SLUG}.md)"
UNIVERSAL_PLACEHOLDER="\\*（尚无通用流程沉淀）\\*"
PROJECT_PLACEHOLDER="\\*（尚无项目流程沉淀）\\*"

if [ "$TYPE" = "universal" ]; then
  if grep -q "$UNIVERSAL_PLACEHOLDER" "$INDEX_FILE"; then
    sed -i "s|$UNIVERSAL_PLACEHOLDER|$ENTRY_LINE|" "$INDEX_FILE"
  else
    sed -i "/^## 通用流程（跨项目）$/a\\$ENTRY_LINE" "$INDEX_FILE"
  fi
else
  if grep -q "$PROJECT_PLACEHOLDER" "$INDEX_FILE"; then
    sed -i "s|$PROJECT_PLACEHOLDER|$ENTRY_LINE|" "$INDEX_FILE"
  else
    sed -i "/^## 项目特有流程$/a\\$ENTRY_LINE" "$INDEX_FILE"
  fi
fi

echo "📑 已更新索引: _index.md"

# ── 针对项目特有流程：更新项目 CLAUDE.md ──
if [ "$TYPE" = "project-specific" ] && [ -n "${PROJECT_PATH:-}" ] && [ -d "$PROJECT_PATH" ]; then
  PROJECT_CLAUDE="$PROJECT_PATH/CLAUDE.md"
  if [ ! -f "$PROJECT_CLAUDE" ]; then
    echo "# $PROJECT 项目 CLAUDE.md" > "$PROJECT_CLAUDE"
    echo "" >> "$PROJECT_CLAUDE"
  fi
  {
    echo ""
    echo "### $NAME"
    echo "来源: $RECORD_FILE"
    echo ""
  } >> "$PROJECT_CLAUDE"
  echo "📝 已追加到项目 CLAUDE.md: $PROJECT_CLAUDE"
fi

# ── 针对通用流程：创建 skill 骨架 + 更新全局 CLAUDE.md ──
if [ "$TYPE" = "universal" ]; then
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

> 由流程沉淀自动生成 ($DATE_TAG)
> 完整记录: $RECORD_FILE

## 触发条件

## 输入

## 执行步骤

更多详情见完整记录文件。
SKILLEOF
    echo "🧩 Skill 骨架已创建: $SKILL_DIR"
    echo "   运行 npx skills 来注册"
  else
    echo "ℹ️  Skill 目录已存在，跳过创建: $SKILL_DIR"
  fi

  # 更新全局 CLAUDE.md（只写摘要，不要从模板复制空字段）
  GLOBAL_CLAUDE="$HOME/.claude/CLAUDE.md"
  if [ -f "$GLOBAL_CLAUDE" ]; then
    {
      echo ""
      echo "### $NAME"
      echo "类型: universal | 来源: $RECORD_FILE"
      echo ""
    } >> "$GLOBAL_CLAUDE"
    echo "📝 已追加到全局 CLAUDE.md: $GLOBAL_CLAUDE"
  fi
fi

# ── 最终提醒 ──
echo ""
echo "═══════════════════════════════════════"
echo "  流程沉淀完成！"
echo ""
echo "  记录文件: $RECORD_FILE"
echo "  后续操作:"
echo "    1. 编辑记录文件补全步骤细节"
if [ "$TYPE" = "universal" ]; then
  echo "    2. 完善 skill/instructions.md"
  echo "    3. 运行 npx skills 注册 skill"
fi
echo "═══════════════════════════════════════"
echo ""
