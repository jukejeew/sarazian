# ADR-003: Hugo Versioning

## Status
Accepted

## Date
2026-01-07

## Context
Hugo มี release ใหม่อย่างต่อเนื่อง  
การอัปเดตเวอร์ชันทันทีอาจทำให้:
- theme หรือ SCSS/PurgeCSS build fail  
- build result ไม่ตรงกับที่เผยแพร่แล้ว

---

## Decision
**Pin Hugo version** ใน workflow และ CI:  
```yaml
hugo-version: '0.151.0'

