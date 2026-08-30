export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > policy.txt <<'EOF'
retention applies to all regions
audit logs are retained for 30 days
access logs are retained for 30 days
billing records are retained for 30 days
exports are retained for 30 days
EOF
git add -A && git commit -qm base
sed -i 's/audit logs are retained for 30 days/audit logs are retained for 3 days/' policy.txt
git add -A && git commit -qm "adjust audit retention"
echo "== default context (3 lines either side) =="
git show --format="" HEAD | grep -c "^ "
echo "== zero context =="
git show --format="" -U0 HEAD
echo "== word-level view of the same change =="
git show --format="" --word-diff=plain -U0 HEAD | tail -3
