
---

## 3️⃣ ADR-004: Force Orphan Setting (gh-pages)

```md
# ADR-004: Force Orphan Setting

## Status
Accepted

## Date
2026-01-07

## Context
`force_orphan` เป็น option ของ peaceiris/actions-gh-pages  
- true → สร้าง orphan branch ใหม่ทุกครั้ง  
- false → push ต่อเนื่องเก็บ commit history  

Sarazian philosophy:
- branch `gh-pages` = Published Archive  
- ต้องสามารถดู timeline / diff / rollback  

---

## Decision
**Set `force_orphan: false`**  

---

## Rationale
1. **Published Timeline**
   - ทุก commit = snapshot ของ publish  
   - สามารถ diff ผลลัพธ์เวอร์ชันก่อนหน้าได้  

2. **Auditability**
   - งานเขียนต้องตรวจสอบย้อนหลังได้  
   - branch history = “เล่มที่พิมพ์แล้ว”  

3. **Writer-first mindset**
   - ไม่สนความสะอาด branch แบบ DevOps  
   - สนใจ history ของ content  

---

## Consequences
- branch `gh-pages` มี commit history ของทุก publish  
- commit message ของ output ควรสื่อสารว่าเกิดจาก commit ไหนใน `main`  
- workflow ปรับ mindset จาก DevOps → Writer-first  

---

## References
- peaceiris/actions-gh-pages documentation  
- Sarazian philosophy: gh-pages branch as Published Edition

