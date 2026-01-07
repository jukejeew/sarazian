# ADR-002: Caching Strategy

## Status
Accepted

## Date
2026-01-07

## Context
Hugo สามารถใช้ caching เพื่อเร่ง build time โดย cache template, resources, และ module download  

ข้อพิจารณาสำคัญ:
- Sarazian เป็นงานเขียนสายสาระเซียน เนื้อหาเป็น Markdown + theme และ static assets ไม่เยอะ
- Build time ปกติอยู่ในหลักวินาที ถึงไม่กี่นาที
- Caching อาจเพิ่ม complexity และ risk ของ stale state  

---

## Decision
**ไม่ใช้ explicit caching ใน CI workflow**  

---

## Rationale
1. **Consistency over speed**
   - งานเขียนต้อง reproducible และ deterministic  
   - Cache อาจทำให้ผลลัพธ์ไม่สด หรือ template update ไม่สะท้อนทันที  

2. **Simplicity**
   - ลดขั้นตอน CI / workflow complexity  
   - ลด risk ของ state ที่ไม่ตรงกับ source  

3. **Writer-first mindset**
   - Writer ไม่ต้องรอ build ที่ซับซ้อน  
   - Build speed ปัจจุบันเพียงพอแล้ว (~10–20 วินาที)  

---

## Consequences
- Build จะ clean ทุกครั้ง → deterministic output  
- Workflow simple และอ่านง่าย  
- ไม่ต้อง manage cache folders / GitHub Actions cache  

---

## References
- Hugo documentation: caching optional  
- Sarazian philosophy: reproducible, long-form writing

