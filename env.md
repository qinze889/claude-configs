# 环境配置

## 系统

- **OS**：Windows 10 Pro
- **Shell**：Git Bash（MINTty）
- **claude 命令**：配置 `--permission-mode dontAsk`

## Python

- **虚拟环境**：位于 `合同扫描件/.venv/`
- **LLM API**：
  - 主力：DeepSeek（`DEEPSEEK_API_KEY`）
  - 备选：Claude（`ANTHROPIC_AUTH_TOKEN`）

## 操作约定

- **PDF 处理策略**：先 PyMuPDF 分类，数字PDF（文本型）→ PyMuPDF 本地提取，扫描件PDF（图片型）→ MinerU API OCR
- **PDF 操作库**：PyMuPDF（`fitz`）— 所有 PDF 分页、提取页面、合并、文本提取统一用 PyMuPDF
- **会话重点**：`~/.claude/session-highlights/YYYY-MM.md` — 每次收束追加一条，标题含日期+关键词
- 中文 PDF 处理：PyMuPDF 提取页面 + Python 处理
- Excel 操作：openpyxl（不用 pandas）
- 多进程：`multiprocessing.Pool`
- 文件编码：`utf-8-sig`（带 BOM，兼容 Excel 中文）
