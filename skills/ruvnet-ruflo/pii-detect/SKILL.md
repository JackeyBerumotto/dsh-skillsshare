---
name: pii-detect
description: 检测并标记文本、代码和配置中的个人身份信息（PII）。在提交代码、写日志、存储数据或发送可能包含邮箱、电话号码、SSN、API 密钥或密码的模型回复之前使用。 | Detect and flag personally identifiable information (PII) in text, code, and configurations. Use before committing code, writing logs, storing data, or sending model responses that might contain emails, phone numbers, SSNs, API keys, or passwords.
argument-hint: "<input-text>"
allowed-tools: mcp__claude-flow__aidefence_has_pii mcp__claude-flow__aidefence_scan mcp__claude-flow__aidefence_analyze mcp__claude-flow__transfer_detect-pii Bash
---

# PII Detection

Detect personally identifiable information before it enters logs, commits, or responses.

## When to use

Before committing code, storing data, or sending responses that might contain PII (emails, phone numbers, SSNs, API keys, passwords).

## Steps

1. **Quick PII check** — call `mcp__claude-flow__aidefence_has_pii` with the text for a boolean result
2. **Detailed scan** — call `mcp__claude-flow__transfer_detect-pii` for categorized PII findings
3. **Full analysis** — call `mcp__claude-flow__aidefence_analyze` for context-aware PII detection
4. If PII found, flag the specific locations and suggest redaction

## PII categories detected

- Email addresses, phone numbers
- Social security numbers, tax IDs
- Credit card numbers
- API keys, tokens, passwords
- Physical addresses
- Names linked to sensitive data
