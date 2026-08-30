export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > auth.py <<'EOF'
def check(token, user):
    if not token:
        raise ValueError("missing token")
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm base
cat > auth.py <<'EOF'
def check(token, user):
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm "simplify check"
echo "== the summary a reviewer skims =="
git show --stat --format="%s" HEAD
echo "== the same commit, in full =="
git show --format="" HEAD
