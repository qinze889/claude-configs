---
name: "手续清单文档批量OCR与结构化提取"
type: project-specific
project: "资产包手续清单整理（已脱敏）"
created: 2026-06-11
updated: 2026-06-11
tags: [ocr, llm-extraction, excel, mineru]
status: stable
version: 1
changelog:
  - date: 2026-06-11
    change: 初版创建
---

## 摘要

对资产包手续文档进行批量 OCR、LLM 结构化信息提取，生成按目录结构排列的 Excel 手续清单。

## 触发条件

收到项目手续清单Excel（汇总表）+ 散落在多级目录下的PDF/JPG原始文件，需要：
1. 提取每个文档的元数据（文号/责任者/题名/日期）
2. 核对物理文件是否齐全
3. 按原始目录顺序输出整洁的Excel

## 环境依赖

- Python 3 + openpyxl（操作Excel）
- `mineru-open-api`（OCR工具，免费额度可用）
- `claude` CLI（LLM提取，需要OAuth登录或API Key）

## 执行步骤

### 第一阶段：物理文件扫描与OCR

1. **建立文件名→物理路径映射**
   ```python
   file_to_relpath = {}
   for root, dirs, files in os.walk(BASE):
       for f in files:
           if f.endswith(('.pdf','.jpg','.jpeg','.png')):
               file_to_relpath[f] = os.path.relpath(...)
   ```

2. **提取清单中的待处理文件列表**
   - 读汇总Excel，五类：备案、接入、荷载报告、并网验收意见、产权证及规划许可证
   - 对比物理文件，找到需要OCR的

3. **批量OCR（mineru-open-api）**
   ```bash
   mineru-open-api extract file1.pdf file2.pdf ... -o _ocr_out/ --token TOKEN -f md,json --timeout 300
   ```
   - 输出：每份文档一个`.json` + 一个`.md`
   - 注意事项：
     - 大文件（>10MB）不能用 `flash-extract`，要用 `extract`
     - 建议每批5-8个文件，避免超时
     - 超时后改为单文件重试

### 第二阶段：LLM结构化提取

4. **从JSON提取有效文本**
   ```python
   # 关键：过滤 footer/logo/stamp/watermark 噪声
   for item in data:
       if t == "text" and txt:
           level = item.get("text_level", 0)  # 1=大标题 2=小标题
   ```

5. **调用claude CLI提取结构化信息**
   ```bash
   claude --print --bare -p "从OCR文档提取结构化信息..."
   ```
   - 字段：文件编号（文号/备案号）、责任者（发文单位）、题名（文档真实标题）、日期
   - Prompt要点：
     - 明确排除"中华人民共和国"等水印文字、排除表格字段值（户号/流程编号）
     - 用 JSON Schema 约束输出格式
   - 技巧：
     - 批次提取（3-5个/批）比单文件效率高
     - 大JSON只截取前3000字符
     - `--bare` 避免加载项目上下文

### 第三阶段：Excel整理

6. **列序调整**
   - 目标列序：序号 | 项目公司 | 项目 | 文件名 | 文件编号 | 责任者 | 题名 | 日期 | 文件类型

7. **按目录结构排序**
   - 解析物理路径：`资产包/公司/项目/子文件夹编号/文件`
   - 排序键：(公司编号, 项目编号, 子文件夹编号, 文件名)
   - 缺失项归入对应公司项目末尾

8. **格式统一**
   - 文件名：去掉`.pdf`扩展名、去掉目录前缀、去掉前导数字编号
   - 日期：统一为 `2023年4月13日` 格式，处理Excel序列号
   - 对齐：全部文字上下左右居中

### 第四阶段：全量审查

9. **物理文件 vs Excel记录对比**
   - 语义归类：手续文件 vs 合同/协议类 vs 资质证照类
   - 合同和资质证照通常不需要加入手续清单
   - 新增文件需重复阶段1-3

## 预期产出

- `手续清单_提取结果.xlsx` — 最终Excel，按目录排序，LLM提取元数据
- `_ocr_out/` — 所有文档的OCR结果（JSON+MD）

## 验证方法

1. Excel行数 = 汇总表应列文件数 + 审查后补充文件数
2. 文件名无`.pdf`后缀、无路径前缀、无前导编号
3. 日期格式统一
4. 用`_audit.py`（本流程脚本之一）检查物理文件覆盖率

## 踩坑笔记

- **文件名匹配的陷阱**：Excel中文件名已去`.pdf`，物理文件名有`.pdf`。对比时stem匹配
- **同名/分期项目排序问题**：目录名没有数字前缀时（"项目一期"/"项目二期"），需要用项目名文本排序而非编号
- **Excel日期序列号**：`45029`这样的数字是Excel序列号（1899-12-30为基准），需用`timedelta`转换
- **mineru超时**：大文件（15MB+）易超时，batch装5个以内，超时降级为单文件
- **OCR图片类文档**：扫描件只有图片块（`type: table`只有`table_body`），没有文本块，提取内容少
- **LLM提取题名纠错**：规则提取容易把表格内"发电户号3105002597479..."当题名，LLM语义理解能正确识别文档标题
- **目录前缀残留**：资产包的文件名在Excel中可能带"8接入系统的批复/"前缀，需要用`os.path.basename`清洗

## 关联

- 关联项目：资产包手续清单（已脱敏）
- 关联流程：[合同PDF批量OCR](合同PDF批量OCR.md)
- 技术文档：mineru.net OCR API
