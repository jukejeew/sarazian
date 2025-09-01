---
# NOTE
# - Tail partial (แก้ไขได้ที่): layouts/partials/post-tail.html
# - ตั้งค่าเริ่มต้นทั้งเว็บ: hugo.toml → [params.footerNote], [params.credit], [params.license]
# - ปรับรายโพสต์: แก้บล็อก credit/footerNote/license ด้านล่าง (mode: show|hide)
title: "Test"
date: 2025-09-01T11:35:38+07:00
draft: true
categories: []
tags: []
author: "วัยสนธยา"

# เปิด/ปิด/ปรับ “หางโพสต์” เฉพาะบทความนี้
credit:
  mode: show     # show | hide
  siteName: ""   # ว่าง = ใช้ params.siteName
  author: ""     # ว่าง = ใช้ .Params.author หรือ params.author

footerNote:
  mode: show     # show | hide
  title: ""      # ว่าง = ใช้ params.footerNote.title
  text: ""       # ข้อความหมายเหตุสั้น ๆ

license:
  mode: show     # show | hide
  style: cc      # cc | copyright
  type: ""       # ว่าง = ใช้ params.license.type
  url: ""        # ว่าง = ใช้ params.license.url
  holder: ""     # ว่าง = ใช้ params.license.holder
  year: ""       # ว่าง = ใช้ปีของโพสต์

---
# บทความทดสอบ
