---
name: cleanup-temp-files
description: 任务结束后必须清理废弃的临时/中间文件，保持目录干净
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c1fcec9b-f657-4621-90a4-64f3c019430e
---

任务完成后必须清理所有临时文件（图片、调试文本、测试输出、废弃脚本等），保持工作目录干净。

**Why:** 用户不需要看到中间产物，只关心最终结果。废弃文件堆积会干扰判断。

**How to apply:** 每次操作完成后，检查工作目录是否有 `.png`、`.txt`、`.bmp`、中间版本脚本等临时产物，确认无用后立即删除。
