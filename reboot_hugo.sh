#!/usr/bin/env bash
# reboot-hugo.sh — ยกเครื่อง Hugo ให้คลีนแบบไม่งอแง
# - เอา shortcode (credit/footer-note/license) ออกจาก Markdown
# - ใส่ partial "post-tail.html" ต่อท้ายบทความจาก layout
# - อัปเดต single.html ให้เรียก partial
# - เติมบล็อก [params] ที่จำเป็นใน hugo.toml ถ้ายังไม่มี
# - (opt) --fresh จะล้าง content/ แล้วสร้างโพสต์ตัวอย่างใหม่
set -euo pipefail

FRESH=false
[[ "${1:-}" == "--fresh" ]] && FRESH=true

ROOT="$(pwd)"
STAMP=$(date +%Y%m%d-%H%M%S)
BK=".reboot_backup_$STAMP"
mkdir -p "$BK"

# 0) หาไฟล์คอนฟิก
CONFIG=""
for f in hugo.toml config.toml; do
  [[ -f $f ]] && CONFIG="$f" && break
done
if [[ -z "$CONFIG" ]]; then
  echo "❌ ไม่พบ hugo.toml / config.toml"; exit 1
fi

# 1) สำรองของเดิม (เผื่อใจ)
cp -a "$CONFIG" "$BK"/ 2>/dev/null || true
[[ -d layouts ]] && cp -a layouts "$BK"/layouts
[[ -d themes  ]] && cp -a themes  "$BK"/themes
[[ -d content ]] && cp -a content "$BK"/content
echo "🗂  สำรองไว้ที่ $BK"

# 2) ปิดใช้งาน shortcode .md ที่อาจทับชื่อ (ทั้งโปรเจกต์/ธีม)
find layouts themes -type f -path "*/shortcodes/*.md" -print0 2>/dev/null \
 | while IFS= read -r -d '' f; do mv "$f" "${f}._off"; echo "⛔ off: $f"; done

# 3) ลบเรียก shortcode ออกจาก Markdown (paired + self-closed)
if [[ -d content ]]; then
  find content -type f -name "*.md" -print0 \
  | xargs -0 perl -0777 -i -pe '
      s/\{\{%[ \t]*footer-note[ \t]*%\}\}.*?\{\{%[ \t]*\/footer-note[ \t]*%\}\}//gs;
      s/\{\{%[ \t]*credit[ \t]*%\}\}.*?\{\{%[ \t]*\/credit[ \t]*%\}\}//gs;
      s/\{\{%[ \t]*license[ \t]*%\}\}.*?\{\{%[ \t]*\/license[ \t]*%\}\}//gs;
      s/^\s*\{\{<[ \t]*footer-note[^}]*>\}\}\s*\n?//mg;
      s/^\s*\{\{<[ \t]*credit[^}]*>\}\}\s*\n?//mg;
      s/^\s*\{\{<[ \t]*license[^}]*>\}\}\s*\n?//mg;
    '
fi

# 4) ใส่ partial ต่อท้ายบทความ (HTML ล้วน)
mkdir -p layouts/partials
cat > layouts/partials/post-tail.html <<'TPL'
<div class="post-tail">
  {{ if (ne ((.Site.Params.footerNote.mode | default "show") | lower) "hide") }}
    <hr>
    <p><strong>{{ .Site.Params.footerNote.title | default "หมายเหตุ" }}</strong></p>
    {{ with .Site.Params.footerNote.text }}<p>{{ . }}</p>{{ end }}
  {{ end }}

  {{ if (ne ((.Site.Params.articleCredit | default "show") | lower) "hide") }}
    <hr>
    <p>
      {{ .Site.Params.credit.publishedOn | default "บทความนี้เผยแพร่บน" }}
      <em>{{ .Site.Params.siteName | default "เพจสาระเซียน" }}</em><br>
      {{ .Site.Params.credit.writtenBy | default "เขียนโดย" }}
      <em>{{ .Params.author | default (.Site.Params.author | default "วัยสนธยา") }}</em>
    </p>
  {{ end }}

  {{ if (ne ((.Site.Params.license.mode | default "show") | lower) "hide") }}
    <hr>
    {{ $style := (lower (printf "%v" (.Site.Params.license.style | default "cc"))) }}
    {{ $year  := (or .Date .PublishDate .Lastmod now) | time.Format "2006" }}
    {{ if eq $style "copyright" }}
      <p>© {{ $year }} {{ .Site.Params.license.holder }}</p>
    {{ else }}
      <p>
        {{ .Site.Params.license.label | default "สัญญาอนุญาต" }}
        {{ if .Site.Params.license.url }}
          <a href="{{ .Site.Params.license.url }}" target="_blank" rel="license noopener">
            {{ .Site.Params.license.type | default "CC BY-NC-SA 4.0" }}
          </a>
        {{ else }}
          {{ .Site.Params.license.type | default "CC BY-NC-SA 4.0" }}
        {{ end }}
      </p>
      <p>© {{ $year }} {{ .Site.Params.license.holder }}</p>
    {{ end }}
  {{ end }}
</div>
TPL

# 5) ทำ single.html ให้แปะ partial ถัดจาก .Content
mkdir -p layouts/_default
TARGET="layouts/_default/single.html"
if [[ ! -f "$TARGET" ]]; then
  THEME_SINGLE="themes/PaperMod/layouts/_default/single.html"
  if [[ -f "$THEME_SINGLE" ]]; then
    cp "$THEME_SINGLE" "$TARGET"
  else
    cat > "$TARGET" <<'MINI'
{{ define "main" }}
<main>
  <article class="post-article">
    <section class="post-content">{{ .Content }}</section>
    {{ partial "post-tail.html" . }}
  </article>
</main>
{{ end }}
MINI
  fi
fi
# แทรกถ้ายังไม่มี
if ! grep -q 'partial "post-tail.html"' "$TARGET"; then
  sed -i '/{{[[:space:]]*\.Content[[:space:]]*}}/a {{ partial "post-tail.html" . }}' "$TARGET" \
    || echo '{{ partial "post-tail.html" . }}' >> "$TARGET"
fi

# 6) อัปเดต hugo.toml: เพิ่มบล็อก params ที่ต้องใช้ ถ้ายังไม่มี
append_if_absent () {
  local header="$1"; shift
  grep -q "^\[$header\]" "$CONFIG" 2>/dev/null && return 0
  printf "\n[%s]\n%s\n" "$header" "$*" >> "$CONFIG"
}
append_if_absent "params" \
'  siteName = "เพจสาระเซียน"
  author   = "วัยสนธยา"
  articleCredit = "show"'
append_if_absent "params.credit" \
'  publishedOn = "บทความนี้เผยแพร่บน"
  writtenBy   = "เขียนโดย"'
append_if_absent "params.footerNote" \
'  mode  = "show"
  title = "หมายเหตุ"
  text  = ""'
append_if_absent "params.license" \
'  mode   = "show"        # show | hide
  style  = "cc"           # cc | copyright
  label  = "สัญญาอนุญาต"
  type   = "CC BY-NC-SA 4.0"
  url    = "https://creativecommons.org/licenses/by-nc-sa/4.0/"
  holder = "Sarazian"'

# 7) archetype เขียนโพสต์แบบคลีน (กัน YAML เพี้ยน)
mkdir -p archetypes
cat > archetypes/post.md <<'ARC'
---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: true
categories: []
tags: []
author: "{{ .Site.Params.author }}"
---
ARC

# 8) (ตัวเลือก) เริ่ม content ใหม่แบบสะอาด พร้อมโพสต์ตัวอย่าง
if $FRESH; then
  rm -rf content
  mkdir -p content/posts
  NOW="$(date +%Y-%m-%dT%H:%M:%S%z)"
  cat > content/posts/hello-world.md <<EOF
---
title: "Hello World"
date: $NOW
draft: false
categories: []
tags: []
author: "$(grep -m1 '^  author' "$CONFIG" | sed 's/.*=\s*"\(.*\)"/\1/')"
---

สวัสดีชาวโลก — โพสต์ตัวอย่างที่สร้างใหม่แบบคลีน
EOF
  echo "🧹 fresh content/ created with posts/hello-world.md"
fi

# 9) กันบรรทัดจบ/อักขระแปลกพื้นฐานใน content (เฉพาะที่เป็น UTF-8 อยู่แล้ว)
if [[ -d content ]]; then
  find content -type f -name "*.md" -print0 \
  | xargs -0 -n1 -I{} bash -c '
      f="$1"
      # ถ้า decode เป็น UTF-8 ไม่ได้ จะไม่แตะ (กันพัง)
      if iconv -f utf-8 -t utf-8 "$f" -o /dev/null 2>/dev/null; then
        perl -i -pe '"'"'BEGIN{binmode STDIN,":raw";binmode STDOUT,":raw"} s/^\x{FEFF}//'"'"' "$f"
        sed -i '"'"'s/\r$//'"'"' "$f"
      fi
    ' _ {}
fi

# 10) แนะนำ .gitattributes (ไม่ทับไฟล์เดิม)
if [[ ! -f .gitattributes ]]; then
  printf '%s\n' '*.md text eol=lf' > .gitattributes
fi

echo "✅ เสร็จสิ้น. ทดสอบรัน:  hugo server -D --disableFastRender"

