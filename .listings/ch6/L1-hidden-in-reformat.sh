export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > limits.conf <<'EOF'
max_retries=3
timeout_seconds=30
pool_size=10
burst_limit=100
EOF
git add -A && git commit -qm base
cat > limits.conf <<'EOF'
max_retries = 3
timeout_seconds = 30
pool_size = 10
burst_limit = 1000
EOF
git add -A && git commit -qm "normalize spacing in limits.conf"
echo "== how many changed lines does the plain diff show? =="
git show --format="" HEAD | grep -c "^[+-][^+-]"
echo "== the same commit, whitespace-insensitive =="
git show --format="" -w HEAD | grep -E "^[+-][^+-]"
