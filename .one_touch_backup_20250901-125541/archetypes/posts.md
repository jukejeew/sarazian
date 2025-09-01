---
# NOTE
# - Tail partial: layouts/partials/post-tail.html
# - Global defaults: hugo.toml → [params.footerNote], [params.credit], [params.license]
# - Per-post override: ใช้ credit/footerNote/license ด้านล่าง (mode: show|hide)

title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
author: "{{ .Site.Params.author }}"

# --- หางโพสต์ (ปรับเฉพาะบทความนี้) ---
credit:
  mode: show
  siteName: ""
  author: ""

footerNote:
  mode: show
  title: ""
  text: ""

license:
  mode: show
  style: cc
  type: ""
  url: ""
  holder: ""
  year: ""
---
