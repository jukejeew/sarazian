#!/usr/bin/env bash
# clean-reinit.sh — รีเซ็ต repo Hugo ใหม่หมด แล้ว push main ด้วย SSH
# ⚠️ ใช้เมื่อมั่นใจว่าอยากล้างประวัติเดิมทั้งหมด

set -euo pipefail

# แก้ตรงนี้ให้เป็นของคุณ
REPO_SSH="git@github.com:jukejeew/sarazian.git"

echo "⚠️ จะล้าง .git ทั้งหมด แล้ว init repo ใหม่ → $REPO_SSH"
read -p "ยืนยัน? (พิมพ์ YES เพื่อทำจริง): " confirm
if [[ "$confirm" != "YES" ]]; then
  echo "ยกเลิก"
  exit 1
fi

# 1) ลบประวัติ git เดิม
rm -rf .git

# 2) init repo ใหม่
git init
git branch -M main
git remote add origin "$REPO_SSH"

# 3) stage + commit ใหม่หมด
git add .
git commit -m "Clean start"

# 4) force push ไป main
git push -u --force origin main

echo "✅ เสร็จแล้ว: repo ถูกล้างใหม่หมด และ push ไป main แล้ว"
echo "👉 จากนี้ GitHub Actions จะ build + deploy ไป gh-pages ให้อัตโนมัติ"

