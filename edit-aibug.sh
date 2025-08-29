# 1) ย้ายไฟล์ shortcodes จาก .md -> .html
mv layouts/shortcodes/about.md       layouts/shortcodes/about.html
mv layouts/shortcodes/credit.md      layouts/shortcodes/credit.html
mv layouts/shortcodes/footer-note.md layouts/shortcodes/footer-note.html
mv layouts/shortcodes/license.md     layouts/shortcodes/license.html

# 2) แก้ content ให้กลับมาใช้ {{< … >}} แทน {{% … %}}
sed -i 's/{{%/{{</g; s/%}}/>}}/g' content/about/_index.md content/posts/*.md

# 3) เพิ่มไฟล์ใหม่เข้า git + commit
git add layouts
git commit -m "fix: convert shortcodes to html and use {{< >}} syntax"
git push

