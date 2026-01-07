# ADR-001: Publishing as Archive

## Status
Accepted

## Date
2026-01-07

## Context
Sarazian เป็นงานเขียนสายสาระเซียน  
เน้น **long-form content**, thought-driven, และเป็นงานเขียนที่มีคุณค่าทางความคิดและประสบการณ์  

Workflow ปัจจุบันใช้ Hugo + GitHub Pages + GitHub Actions  
โดยการ deploy จะสร้าง static site จาก content ที่อยู่ใน branch `main` แล้ว push ไปยัง branch `gh-pages`  

ข้อพิจารณาที่สำคัญ:
- งานเขียนแต่ละชิ้นควรเก็บ **Published Edition History**  
- Artifact จาก GitHub Actions มี **Retention period** → ไม่ถาวร  
- GitHub Pages branch ปัจจุบันสามารถทำหน้าที่เป็น **archive ของงานที่เผยแพร่แล้ว**  
- Hugo build deterministic → สามารถ rebuild ผลงานเก่าได้ หาก version ถูก lock  

---

## Decision
**ใช้ branch `gh-pages` เป็น Published Archive**  
- `force_orphan: false` → เก็บ commit history ของ output ทุกครั้ง  
- commit message ของแต่ละ deploy จะระบุข้อความของ commit บน `main` เพื่อสะท้อน context ของการเผยแพร่  
- Hugo version ถูก pinned (`0.151.0`) เพื่อให้ reproducible และมั่นใจว่างานเก่าไม่พัง  
- Workflow ถูกออกแบบให้ **cancel-in-progress: true** เพื่อให้ branch แสดง "เล่มล่าสุด" เป็นหลัก  

---

## Rationale
1. **Traceability / Auditability**  
   - ทุก commit ใน gh-pages = snapshot ของงานที่เผยแพร่  
   - สามารถดู diff / rollback / inspect ผลงานย้อนหลังได้  

2. **Stability over Freshness**  
   - เนื้อหาที่เผยแพร่ต้องถูกต้องและไม่พังเมื่อ rebuild  
   - Version lock ของ Hugo ทำให้ reproduce output ได้เสมอ  

3. **Editorial Philosophy Alignment**  
   - Branch `gh-pages` เปรียบเสมือน **เล่มพิมพ์แล้ว**  
   - Archive ของงานเขียนต้อง **ถาวร และตรวจสอบย้อนกลับได้**  

4. **Minimize Noise**  
   - Cancel in-progress builds → ลด CI noise จาก typo / push ซ้ำเร็ว ๆ  

---

## Consequences
- Repository จะมี branch `gh-pages` ที่ยาวเป็น timeline ของ publish output  
- การเปลี่ยนแปลงทุกครั้งสามารถ diff ดูได้  
- Artifact ของ GitHub Actions ไม่จำเป็นสำหรับเก็บงานถาวร  
- Workflow และ config ต้องสอดคล้องกับ editorial mindset ไม่ใช่ trend ของ platform เท่านั้น  

---

## References
- Hugo `.GitInfo` feature → ใช้วันที่แก้ไขล่าสุด  
- GitHub Actions peaceiris/actions-gh-pages documentation  
- Sarazian workflow: Hugo + gh-pages + pinned Hugo version

