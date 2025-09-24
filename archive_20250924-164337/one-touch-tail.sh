#!/usr/bin/env bash
# one-touch-tail.sh — ตั้งค่าหางโพสต์ + CC icons + archetype + config ครบในหนึ่งครั้ง
set -euo pipefail

say(){ printf "%s\n" "$*"; }
ERR(){ printf "❌ %s\n" "$*" >&2; exit 1; }

# 0) คอนฟิกหลัก
CONFIG=""
for f in hugo.toml config.toml; do [[ -f $f ]] && CONFIG="$f" && break; done
[[ -n "$CONFIG" ]] || ERR "ไม่พบ hugo.toml/config.toml"

STAMP=$(date +%Y%m%d-%H%M%S)
BK=".one_touch_backup_$STAMP"
mkdir -p "$BK"
cp -a "$CONFIG" "$BK"/ 2>/dev/null || true
[[ -d layouts    ]] && cp -a layouts    "$BK"/layouts
[[ -d archetypes ]] && cp -a archetypes "$BK"/archetypes
[[ -d content    ]] && cp -a content    "$BK"/content
[[ -d static     ]] && cp -a static     "$BK"/static
say "🗂  สำรองไว้ที่ $BK"

# 1) ลบการเรียก shortcode ออกจาก Markdown ทั้งหมด (กันเว็บล้ม)
if [[ -d content ]]; then
  find content -type f -name "*.md" -print0 |
    xargs -0 perl -0777 -i -pe '
      s/\{\{%[ \t]*(footer-note|footnote|credit|license)[ \t]*%\}\}.*?\{\{%[ \t]*\/\1[ \t]*%\}\}//gs;
      s/^\s*\{\{[<%][ \t]*(footer-note|footnote|credit|license)[^}]*\}\}\s*\n?//mg;
    '
fi

# 2) ลบไฟล์ shortcode ที่อาจยังเหลือ
rm -f layouts/shortcodes/{footer-note,footnote,credit,license}.html 2>/dev/null || true
rm -f layouts/shortcodes/{footer-note,footnote,credit,license}.md   2>/dev/null || true
rmdir layouts/shortcodes 2>/dev/null || true

# 3) partial: post-tail.html (footnote/credit + CC icons, ไม่มี © ที่นี่)
mkdir -p layouts/partials
cat > layouts/partials/post-tail.html <<'TPL'
<!--
Tail partial: layouts/partials/post-tail.html
Override รายโพสต์: front matter → credit.*, footerNote.*, license.*
Global defaults: hugo.toml → [params.footerNote], [params.credit], [params.license]
-->
<div class="post-tail">
  {{/* ---------- FOOTNOTE ---------- */}}
  {{ $fnMode := lower (printf "%v" (or .Params.footerNote.mode .Params.footerNote .Site.Params.footerNote.mode "show")) }}
  {{ if ne $fnMode "hide" }}
    <hr>
    <p><strong>{{ or .Params.footerNote.title .Site.Params.footerNote.title "หมายเหตุ" }}</strong></p>
    {{ with (or .Params.footerNote.text .Site.Params.footerNote.text "") }}{{ . | markdownify | safeHTML }}{{ end }}
  {{ end }}

  {{/* ---------- CREDIT ---------- */}}
  {{ $crMode := lower (printf "%v" (or .Params.credit.mode .Params.credit .Site.Params.articleCredit "show")) }}
  {{ if ne $crMode "hide" }}
    <hr>
    {{ $pub := or .Site.Params.credit.publishedOn "บทความนี้เผยแพร่บน" }}
    {{ $by  := or .Site.Params.credit.writtenBy   "เขียนโดย" }}
    {{ $site := or .Params.credit.siteName .Site.Params.siteName "เพจสาระเซียน" }}
    {{ $author := or .Params.credit.author .Params.author .Site.Params.author "วัยสนธยา" }}
    <p>{{ $pub }} <em>{{ $site }}</em><br>{{ $by }} <em>{{ $author }}</em></p>
  {{ end }}

  {{/* ---------- LICENSE (ไอคอน + ข้อความ, ไม่มี © ที่นี่) ---------- */}}
  {{ $lcMode := lower (printf "%v" (or .Params.license.mode .Params.license .Site.Params.license.mode "show")) }}
  {{ if ne $lcMode "hide" }}
    <hr>
    {{ $url   := or .Params.license.url   .Site.Params.license.url  "https://creativecommons.org/licenses/by-nc-sa/4.0/" }}
    {{ $label := or .Site.Params.license.label "สัญญาอนุญาต" }}
    {{ $type  := or .Params.license.type  .Site.Params.license.type "CC BY-NC-SA 4.0" }}
    <p style="display:flex;align-items:center;gap:.5rem;flex-wrap:wrap">
      <a href="{{ $url }}" target="_blank" rel="license noopener" style="display:inline-flex;align-items:center;gap:.35rem;text-decoration:none">
        <img src="/cc/cc.svg" alt="CC"  width="22" height="22" loading="lazy"/>
        <img src="/cc/by.svg" alt="BY"  width="22" height="22" loading="lazy"/>
        <img src="/cc/nc.svg" alt="NC"  width="22" height="22" loading="lazy"/>
        <img src="/cc/sa.svg" alt="SA"  width="22" height="22" loading="lazy"/>
        <span style="font-weight:600">{{ $type }}</span>
      </a>
      <span>— {{ $label }}</span>
    </p>
  {{ end }}
</div>
TPL

# 4) single.html: ให้เรียก partial ถัดจาก .Content
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
grep -q 'partial "post-tail.html"' "$TARGET" || \
  sed -i '/{{[[:space:]]*\.Content[[:space:]]*}}/a {{ partial "post-tail.html" . }}' "$TARGET" || true

# 5) archetype สำหรับ posts + โน้ต
mkdir -p archetypes
rm -f archetypes/default.md 2>/dev/null || true   # กันตกไปใช้ default
cat > archetypes/posts.md <<'ARC'
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
ARC

# 6) ดาวน์โหลดย้ายไอคอน CC ไว้เสิร์ฟจากเว็บตัวเอง
mkdir -p static/cc
fetch(){
  local url="$1" dst="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSLo "$dst" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dst" "$url"
  else
    ERR "ไม่พบ curl/wget สำหรับดาวน์โหลด $url"
  fi
}
fetch "https://mirrors.creativecommons.org/presskit/icons/cc.svg" static/cc/cc.svg
fetch "https://mirrors.creativecommons.org/presskit/icons/by.svg" static/cc/by.svg
fetch "https://mirrors.creativecommons.org/presskit/icons/nc.svg" static/cc/nc.svg
fetch "https://mirrors.creativecommons.org/presskit/icons/sa.svg" static/cc/sa.svg

# 7) ฟังก์ชันแก้/เติมค่าในตาราง TOML แบบปลอดภัย
ensure_table(){
  local tbl="$1"
  grep -q "^\[$(printf '%s' "$tbl" | sed 's/\./\\./g')\]" "$CONFIG" 2>/dev/null || {
    printf "\n[%s]\n" "$tbl" >>"$CONFIG"
  }
}
set_kv(){
  local tbl="$1" key="$2" val="$3"
  local esc_tbl
  esc_tbl=$(printf '%s' "$tbl" | sed 's/\./\\./g')
  awk -v TBL="$tbl" -v KEY="$key" -v VAL="$val" '
    BEGIN{INS=0; FS=OFS=""}
    function emit(){print}
    /^ *\[/{
      if(in){if(!found){print KEY " = " VAL} in=0}
      header=substr($0, match($0, /\[[^]]+\]/))
      if(header=="[" TBL "]"){in=1}
      emit(); next
    }
    {
      if(in && $0 ~ "^[ \t]*" KEY"[ \t]*="){
        print KEY " = " VAL; found=1; next
      }
      emit()
    }
    END{ if(in && !found){print KEY " = " VAL} }
  ' "$CONFIG" > "$CONFIG.__tmp__" && mv "$CONFIG.__tmp__" "$CONFIG"
}

# 8) เติม/แก้ค่าที่จำเป็นใน hugo.toml (ไม่ทับของเดิมถ้ามี)
ensure_table "params"
set_kv "params" "articleCredit" "\"show\""
set_kv "params" "defaultTheme" "\"dark\""

ensure_table "params.footerNote"
set_kv "params.footerNote" "mode" "\"show\""
set_kv "params.footerNote" "title" "\"หมายเหตุ\""
# ปล่อย text ให้ผู้เขียนไปตั้งเองได้

ensure_table "params.credit"
set_kv "params.credit" "publishedOn" "\"บทความนี้เผยแพร่บน\""
set_kv "params.credit" "writtenBy" "\"เขียนโดย\""

ensure_table "params.license"
set_kv "params.license" "mode" "\"show\""
set_kv "params.license" "label" "\"สัญญาอนุญาต\""
set_kv "params.license" "type" "\"CC BY-NC-SA 4.0\""
set_kv "params.license" "url" "\"https://creativecommons.org/licenses/by-nc-sa/4.0/\""
set_kv "params.license" "holder" "\"Sarazian\""
set_kv "params.license" "showHolder" "false"   # ให้ธีมพิมพ์ © ที่ฟุตเตอร์เท่านั้น

ensure_table "markup.highlight"
set_kv "markup.highlight" "noClasses" "false"
set_kv "markup.highlight" "lineNos" "true"

ensure_table "markup.goldmark.renderer"
set_kv "markup.goldmark.renderer" "unsafe" "true"

# 9) กัน CRLF/BOM เบื้องต้น (ถ้าไฟล์เป็น UTF-8 อยู่แล้วค่อยแตะ)
if [[ -d content ]]; then
  find content -type f -name "*.md" -print0 |
    xargs -0 -n1 -I{} bash -c '
      f="$1"
      if iconv -f utf-8 -t utf-8 "$f" -o /dev/null 2>/dev/null; then
        perl -i -pe '"'"'BEGIN{binmode STDIN,":raw";binmode STDOUT,":raw"} s/^\x{FEFF}//'"'"' "$f"
        sed -i '"'"'s/\r$//'"'"' "$f"
      fi
    ' _ {}
fi

# 10) .gitattributes กัน CRLF ในอนาคต
[[ -f .gitattributes ]] || printf '%s\n' '*.md text eol=lf' > .gitattributes

say "✅ เสร็จสิ้น — partial + archetype + CC icons + config ถูกตั้งค่าแล้ว"
say "👉 ทดสอบ: hugo server -D --disableFastRender"

