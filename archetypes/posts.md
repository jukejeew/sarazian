'''
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
author: "{{ .Site.Params.author }}"

footerNote:
  mode: hide
  title: ""
  text: ""

credit:
  mode: hide
  siteName: "{{ .Site.Params.siteName | default "สาระเซียน" }}"
  author: ""

license:
  mode: hide
  style: copyright
  type: "BY-NC-SA 4.0"
  url: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
  holder: "{{ .Site.Params.author }}"
  year: "{{ (time .Date).Year }}"
  text: ""
'''

## Hook เปิดเรื่อง
(เล่าเหตุการณ์/ฉากสั้น ๆ ที่ดึงผู้อ่านเข้ามา)

## Timeline / เนื้อหาหลัก
(เรียงเหตุการณ์/ข้อมูลหลักตามลำดับ หรือสอดแทรกเป็นช่วง ๆ)

## เชื่อมสู่ธุรกิจ
(สิ่งที่ตัวละคร/เรื่องนี้สร้างหรือเกี่ยวข้องกับโลกธุรกิจ)

## ผูกกับเศรษฐกิจ
(มุมมองกว้างขึ้น — ผลกระทบ, ความเชื่อมโยง, ภาพใหญ่)

## ไลฟ์สไตล์
(สะท้อนค่านิยม วิธีคิด หรือการเลือกใช้ชีวิต)

## มุมมองผู้เขียน
(ข้อคิด/บทสรุปที่อยากฝากผู้อ่าน)
