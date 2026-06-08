---
name: pdf-pipeline-strategy
description: 数字PDF→PyMuPDF本地提取，图片PDF→MinerU API OCR的PDF处理pipeline
metadata: 
  node_type: memory
  type: reference
  originSessionId: 0473e8a8-d6ec-4695-80b6-c8a32deca16f
---

PDF 处理分 pypeline：
1. PyMuPDF 分类（字符数 >100 为数字PDF，≤100 为图片PDF）
2. 数字PDF → PyMuPDF 提取第一页文本，取最长行做标题
3. 图片PDF → MinerU API（mineru.net）云端 OCR，取 markdown 标题

**Why:** 数字PDF只取内嵌文本，毫秒级；图片PDF才需要正经 OCR，走免费 API。

**How to apply:** 遇到 PDF 处理任务，先分类再分流。PDF 分页/合并/提取统一用 PyMuPDF（已装，项目依赖里已有）。
