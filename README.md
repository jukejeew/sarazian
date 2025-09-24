# 🌐 Sarazian

เว็บไซต์เพจ **สาระเซียน**  
☕ ทุกเรื่องราวมีชีวิต  

## การพัฒนา & Build

### รันทดสอบในเครื่อง
```bash
hugo server --disableFastRender --renderToDisk -D
```
เปิดที่ <http://localhost:1313/sarazian/>

### Build สำหรับ Deploy
```bash
hugo --gc --minify -d public
```

## Deploy

โครงการนี้ใช้ **GitHub Pages (branch: gh-pages)**  
การ deploy ทำผ่านการผูก `public/` เป็น worktree ของสาขา `gh-pages`

### ครั้งแรก (ตั้งค่า worktree)
```bash
git fetch origin
rm -rf public
git worktree add -B gh-pages public origin/gh-pages
```

### ทุกครั้งที่ build & deploy
```bash
hugo --gc --minify -d public

cd public
git add -A
git commit -m "deploy: rebuild site"
git push origin gh-pages
cd ..
```

---

## หมุดกันพลาด 🛑

- **mainSections** ต้องชี้ไปที่โฟลเดอร์ที่มีโพสต์จริง  
  ```toml
  [params]
    mainSections = ["posts"]
  ```
- ห้ามสร้าง/ลืมลบ `content/_index.md` ถ้าไม่ตั้งใจแก้หน้าแรก  
- โพสต์ต้องไม่เป็น `draft: true` และ `date:` ไม่ล้ำอนาคต  
- เวลาเว็บหน้าแรกหาย → เช็ก 3 จุดนี้ก่อน:  
  1. `mainSections`  
  2. `content/_index.md`  
  3. layout override (`layouts/index.html`)  

---

## โครงสร้างหลัก
```
content/
  posts/       # บทความหลัก
themes/        # PaperMod
config/        # hugo.toml, params
public/        # build outputs (ผูกกับ gh-pages)
```

---

## Author

เขียนและดูแลโดย *วัยสนธยา*  
> บทความนี้เผยแพร่บน **เพจสาระเซียน**
