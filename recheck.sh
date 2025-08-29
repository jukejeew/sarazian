cd ~/Projects/Sarazian

# สร้างโฟลเดอร์ (เผื่อยังไม่มี)
mkdir -p layouts/shortcodes

# เขียน shortcodes แบบ .md (ถ้าไฟล์ยังไม่มี ให้สร้างใหม่ยกชุด)
cat > layouts/shortcodes/about.md <<'MD'
{{ $variant := .Page.Params.variant | default .Site.Params.aboutVariant | default "full" }} 

{{ if eq $variant "compact" -}}

สาระเซียนคือการเล่าเรื่องที่ไม่รีบร้อน  
เชื่อว่าธุรกิจ เศรษฐกิจ และไลฟ์สไตล์  
ไม่ใช่เส้นขนาน แต่เป็นด้ายสามเส้นที่ถักกันอยู่ทุกวัน  

เราไม่รีบให้คำตอบ  
เพียงชวนคุณจิบช้า ๆ แล้วฟังเสียงของตัวเอง  

{{- else -}}

ในโลกที่เรื่องราววิ่งผ่านตาเร็วพอ ๆ กับแสงไฟจราจร  
หลายครั้งเราหลงลืมว่า **เรื่องเล็ก ๆ ก็มีชีวิต**  

สาระเซียนเกิดขึ้นจากความเชื่อเรียบง่ายว่า  
การเล่าเรื่อง ไม่ใช่แค่การบันทึก แต่คือการหายใจร่วมกับเวลา  

เราจึงหยิบ *เส้นด้ายสามเส้น* มาถักทอ  
- ด้ายของธุรกิจ ที่พูดถึงการสร้างและความพยายาม  
- ด้ายของเศรษฐกิจ ที่โยงชีวิตเล็ก ๆ เข้ากับโครงสร้างใหญ่  
- ด้ายของไลฟ์สไตล์ ที่บอกเล่าเสียงหัวใจและวิถีวันธรรมดา  

ทั้งหมดนี้ ไม่ได้ต้องการคำตอบตายตัว  
แต่ชวนให้คนอ่านได้หยุด ลองเงี่ยหูฟังเสียงตัวเอง  

> ☕ ทุกเรื่องราวมีชีวิต  
> คล้ายไออุ่นจากแก้ว ที่แทรกไปกับแสงแรก ก่อนละลายบนบรรทัดที่ค่อย ๆ ตื่นขึ้นมา  

{{- end }}
MD

cat > layouts/shortcodes/footer-note.md <<'MD'
{{ $mode := .Page.Params.footer | default .Site.Params.articleFooter | default "slogan" }}

{{ if eq $mode "slogan" -}}

---

> ☕ ทุกเรื่องราวมีชีวิต  
> คล้ายไออุ่นจากแก้ว ที่แทรกไปกับแสงแรก ก่อนละลายบนบรรทัดที่ค่อย ๆ ตื่นขึ้นมา

{{- end }}
MD

cat > layouts/shortcodes/credit.md <<'MD'
{{ $mode := .Page.Params.credit | default .Site.Params.articleCredit | default "show" }}

{{ if eq $mode "show" -}}

---

บทความนี้เผยแพร่บน *เพจสาระเซียน*  
เขียนโดย *วัยสนธยา*

{{- end }}
MD

cat > layouts/shortcodes/license.md <<'MD'
{{ $mode := .Page.Params.license | default .Site.Params.licenseType | default "copyright" }}

{{ if eq $mode "copyright" -}}

© 2025 วัยสนธยา — สงวนลิขสิทธิ์

{{ else if eq $mode "cc" -}}

เผยแพร่ภายใต้สัญญาอนุญาต [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.th)  

{{- end }}
MD

