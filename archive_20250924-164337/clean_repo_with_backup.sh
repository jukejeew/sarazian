#!/usr/bin/env bash
# clean_repo_with_backup.sh — Backup ทั้งราก (ยกเว้น .git) แล้วล้าง main ให้เหลือแต่ซอร์ส
set -euo pipefail

# หา root ของ repo แล้ว cd เข้าไป (กันกรณีรันจากโฟลเดอร์อื่น)
REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

STAMP="$(date +'%Y%m%d-%H%M%S')"
BACKUP_DIR="backups"
BACKUP_ZIP="${BACKUP_DIR}/root-backup-${STAMP}.zip"

# สร้าง branch ทำความสะอาด
git checkout -b cleanup-main

# ทำแบ็กอัพทั้งราก (ยกเว้น .git/ กับ backups/)
mkdir -p "$BACKUP_DIR"
if command -v zip >/dev/null 2>&1; then
  zip -r "$BACKUP_ZIP" . -x ".git/*" "${BACKUP_DIR}/*"
else
  BACKUP_ZIP="${BACKUP_ZIP%.zip}.tar.gz"
  tar --exclude="./.git" --exclude="./${BACKUP_DIR}" -czf "$BACKUP_ZIP" .
fi
echo "✅ Backup -> $BACKUP_ZIP"

# เขียน .gitignore (กันของบิ้ว/ขยะกลับมาอีก)
cat > .gitignore <<'EOF'
# Hugo local build
/public/
/publish/

# Build outputs (ให้ gh-pages เท่านั้น)
index.html
index.xml
index.json
robots.txt
sitemap.xml
404.html
/categories/
/tags/
/series/

# Hugo tmp/backup
.hugo_build.lock
hugo.toml.bak*
hugo.toml.__tmp__
.content_*backup*/
.reboot_backup_*/
.reset_backup_*/
.shortcode_reset_backup_*/

# OS/editor junk
.DS_Store
Thumbs.db
*.swp
EOF

# ลบของไม่จำเป็นออกจาก index (ไม่ไปยุ่งซอร์สจริง)
git rm -r --cached \
  index.html index.xml index.json robots.txt sitemap.xml 404.html \
  categories tags series \
  public publish \
  hugo.toml.bak* hugo.toml.__tmp__ \
  .content_*backup* .reboot_backup_* .reset_backup_* .shortcode_reset_backup_* \
  2>/dev/null || true

git add .gitignore "$BACKUP_DIR/" || true
git commit -m "chore: backup root & cleanup main (remove build outputs, add .gitignore)"

git push origin cleanup-main

echo
echo "🎉 เสร็จแล้ว! เปิด Pull Request จาก 'cleanup-main' -> 'main' บน GitHub เพื่อตรวจ diff แล้วค่อย merge."
