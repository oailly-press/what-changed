export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > handler.py <<'EOF'
def handle(request):
    if request.user is None:
        raise Unauthorized()
    payload = parse(request.body)
    validate(payload)
    return store(payload)
EOF
git add -A && git commit -qm base
cat > handler.py <<'EOF'
def handle(request):
    if request.user is None:
        raise Unauthorized()
    payload = parse(request.body)
    return store(payload)
EOF
git add -A && git commit -qm "streamline handler"
git show --format="" HEAD
