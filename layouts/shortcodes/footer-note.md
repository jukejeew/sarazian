{{ $mode := .Page.Params.footer | default .Site.Params.articleFooter | default "slogan" }}

{{ if eq $mode "slogan" -}}

---

> ☕ ทุกเรื่องราวมีชีวิต  
> คล้ายไออุ่นจากแก้ว ที่แทรกไปกับแสงแรก ก่อนละลายบนบรรทัดที่ค่อย ๆ ตื่นขึ้นมา

{{- end }}
