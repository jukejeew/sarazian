{{ $mode := .Page.Params.credit | default .Site.Params.articleCredit | default "show" }}

{{ if eq $mode "show" -}}

---

บทความนี้เผยแพร่บน *เพจสาระเซียน*  
เขียนโดย *วัยสนธยา*

{{- end }}
