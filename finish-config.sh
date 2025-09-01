#!/usr/bin/env bash
set -euo pipefail

# หาไฟล์คอนฟิก
CONFIG=""
for f in hugo.toml config.toml; do [[ -f $f ]] && CONFIG="$f" && break; done
[[ -n "$CONFIG" ]]

# สร้างหัวตารางถ้ายังไม่มี
ensure_table() {
  local tbl="$1"
  local pat
  pat="$(printf '%s' "$tbl" | sed 's/\./\\./g')"
  grep -q "^\[$pat\]" "$CONFIG" 2>/dev/null || printf "\n[%s]\n" "$tbl" >> "$CONFIG"
}

# เติม key ถ้าในตารางนั้นยังไม่มี (ไม่ทับของเดิม) — เข้ากันได้กับ mawk
set_kv() {
  local tbl="$1" key="$2" val="$3"
  awk -v TBL="$tbl" -v KEY="$key" -v VAL="$val" '
    BEGIN { in=0; found=0 }
    /^\[[^]]+\]$/ {
      if (in && !found) { print KEY " = " VAL; }
      in = ($0=="[" TBL "]"); found=0;
      print; next;
    }
    {
      if (in && $0 ~ "^[ \t]*" KEY "[ \t]*=") { found=1; }
      print;
    }
    END {
      if (in && !found) { print KEY " = " VAL; }
    }
  ' "$CONFIG" > "$CONFIG.__tmp__" && mv "$CONFIG.__tmp__" "$CONFIG"
}

# ---- ตั้งค่าที่ต้องมีให้ตรงตามงานนี้ ----
ensure_table "params"
set_kv "params" "articleCredit" "\"show\""
set_kv "params" "defaultTheme" "\"dark\""

ensure_table "params.footerNote"
set_kv "params.footerNote" "mode" "\"show\""
set_kv "params.footerNote" "title" "\"หมายเหตุ\""

ensure_table "params.credit"
set_kv "params.credit" "publishedOn" "\"บทความนี้เผยแพร่บน\""
set_kv "params.credit" "writtenBy" "\"เขียนโดย\""

ensure_table "params.license"
set_kv "params.license" "mode" "\"show\""
set_kv "params.license" "label" "\"สัญญาอนุญาต\""
set_kv "params.license" "type" "\"CC BY-NC-SA 4.0\""
set_kv "params.license" "url" "\"https://creativecommons.org/licenses/by-nc-sa/4.0/\""
set_kv "params.license" "holder" "\"Sarazian\""
set_kv "params.license" "showHolder" "false"   # © ให้ธีมพิมพ์ที่ฟุตเตอร์เท่านั้น

ensure_table "markup.highlight"
set_kv "markup.highlight" "noClasses" "false"
set_kv "markup.highlight" "lineNos" "true"

ensure_table "markup.goldmark.renderer"
set_kv "markup.goldmark.renderer" "unsafe" "true"

echo "✅ finish-config: อัปเดต $CONFIG เสร็จ"
