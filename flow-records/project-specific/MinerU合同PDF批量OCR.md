---
name: MinerU合同PDF批量OCR
type: project-specific
project: 港华尽调合同处理
created: 2026-06-08
updated: 2026-06-08
tags: [mineru, ocr, contract, pdf]
status: stable
version: 2
changelog:
  - date: 2026-06-08
    change: v3: 明确 数字PDF→local pdftotext / 图片PDF→MinerU API 的分层策略
  - date: 2026-06-08
    change: v2: 废弃 Windows OCR，统一走 MinerU API
  - date: 2026-06-08
    change: 初版创建
---

## 核心策略：数字PDF vs 图片PDF

项目先通过 `classify_pdfs.py` 将所有 PDF 分为两类，**走不同处理路径**：

| PDF 类型 | 判定标准 | 处理方式 | 速度 |
|---------|---------|---------|------|
| **数字PDF（TEXT）** | `pdftotext` 提取字符 > 100 | `pdftotext` 本地提取第一页文本，取最长行做标题 | 毫秒级 |
| **图片PDF（SCAN）** | `pdftotext` 提取字符 ≤ 100 | 调 MinerU API 云端 OCR | 10~30秒/份 |
| ERROR | 读取失败 | 跳过 | — |

> 数字PDF叫"本地OCR"不准确——实际就是 `pdftotext` 直接读内嵌文本，不需要 OCR。**只有图片PDF才真正需要 OCR**，走 MinerU API。

## 触发条件

需要对 PDF 合同进行 OCR 提取标题或文本内容时。

## 完整流程

```
① 分类 → ② 匹配（可选）→ ③ 单公司 OCR → ④ 汇总
```

### ① PDF 分类（`classify_pdfs.py`）

区分哪些 PDF 需要 OCR：

- 用 `pdftotext -f 1 -l 1` 提取第一页
- 字符数 > 100 → **TEXT**（pdftotext 能读，无需 OCR）
- 字符数 ≤ 100 → **SCAN**（扫描件，需要 OCR）
- 出错 → **ERROR**（跳过）
- 同时用 `strings` 检查是否含图片对象（辅助判断）
- 输出：`pdf_category_analysis.json`

```bash
python classify_pdfs.py
```

### ② 匹配（可选）

将 Excel 台账与 PDF 文件名对应，生成各公司任务单：

- `match_all.py` → 19 文件夹统一匹配，输出 `_匹配报告.txt`
- `generate_mapping.py` → 两层匹配输出 CSV/TXT 对照表
- 输出各公司 `task_*.json`

### ③ 单公司 OCR 提取（`extract_company_titles.py`）[推荐]

支持断点续传、TEXT/SCAN 分流，推荐的主流程：

```bash
# 单公司
python extract_company_titles.py \
  --task-json tasks/task_1.json \
  --category-json pdf_category_analysis.json \
  --output results/result_1.json
```

**处理逻辑：**

1. 读取 `task_*.json` → 获取该公司所有待处理 PDF
2. 查 `pdf_category_analysis.json` → 判断类型
3. **TEXT 型** → `pdftotext` 本地提取第一页文本，取最长行做标题
4. **SCAN 型** → 调 MinerU API（curl 子进程版）：
   - POST `https://mineru.net/api/v1/agent/parse/file` → `task_id` + `file_url`
   - PUT 上传 PDF 到 OSS 预签名 URL
   - 轮询 GET `{task_id}` → `state == 'done'` 取 `markdown_url`（最长等 120s）
   - 下载 markdown，提取 `#`/`##` 标题
5. **ERROR 型** → 跳过
6. 每 5 个自动保存中间结果 `.tmp`，支持断点续传

### ④ 批量 OCR（备选方案）

脚本版本谱系（从旧到新）：

| 脚本 | 实现 | 特点 |
|------|------|------|
| `batch_ocr.py` | urllib | 从 `sheet_folder_map_v2.json` 读数据，按序号→PDF 映射，每 10 条保存 |
| `batch_ocr_v2.py` | curl 子进程 | 和 v1 逻辑类似，换 curl |
| `batch_ocr_final.py` | curl 子进程 | 多了一些状态统计，同上 |
| `extract_company_titles.py` | curl 子进程 | **最完整**：TEXT/SCAN 分流 + 断点续传 + 命令行参数 + 单公司粒度 |

## MinerU API 调用参数

```json
{
  "file_name": "xxx.pdf",
  "language": "ch",
  "page_range": "1",
  "enable_table": true,
  "is_ocr": true,
  "enable_formula": false
}
```

> 标题提取只扫第一页（`page_range: "1"`），如需要全部 OCR 文本可改为 `"1-"`。

## 输出格式

### OCR 结果 JSON

```json
{
  "sheet": "洛阳晶航",
  "folder": "1 洛阳晶航光伏发电有限公司",
  "seq": 5,
  "seq_str": "5",
  "pdf": "5 合同.pdf",
  "original_name": "屋顶租赁合同",
  "code": "FBSCON-2024-001",
  "title": "屋顶租赁及能源管理合同",
  "status": "success",
  "method": "ocr",
  "category": "SCAN"
}
```

- `status`: `success` / `text_extracted` / `no_title` / `ocr_failed` / `create_failed` / `upload_failed` / `query_failed`
- `method`: `ocr`（MinerU）/ `pdftotext`（本地）/ `ocr_fallback`（TEXT 失败降级）

## 踩坑笔记

- MinerU API **无认证密钥**，可能是 IP 白名单或 Cookie 会话认证
- 脚本中禁用了 SSL 验证（`verify=False` / `ctx.check_hostname = False`）
- API 限流：每个 SCAN 请求间隔 2~3 秒，否则可能 429
- 上传 OSS 用 PUT 方法，Content-Type 必须设 `application/pdf`
- 任务轮询最长 120 秒，超过视为超时
- curl 子进程版（extract_company_titles.py）比 urllib 版更稳定，推荐优先用
- Windows OCR（`winrt.windows.media.ocr`）已废弃，不要再用

## 关联

- 项目根 CLAUDE.md：`Desktop/归档/合同文档/港华/港华总文件/CLAUDE.md`
- Python 脚本目录：`合同扫描件/`
- 分类结果：`合同扫描件/pdf_category_analysis.json`
- OCR 结果：`合同扫描件/ocr_results.json`
- 任务单：`合同扫描件/task_*.json`
