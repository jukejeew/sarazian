---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
author: "{{ .Site.Params.author }}"

license:
  mode: show
  style: copyright
  holder: "{{ .Site.Params.author }}"
  year: "{{ (time .Date).Year }}"
---

## Hook
(ฉากหรือประโยคเปิด)

## เนื้อหา
(ประเด็นหลัก 2–4 ย่อหน้า)

## มุมมองผู้เขียน
(สรุป/ข้อคิด 3–5 บรรทัด)

