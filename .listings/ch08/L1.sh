export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p api
cat > api/session.py <<'EOF'
SESSION_TTL = 3600

def issue(user):
    token = mint(user)
    store(token, ttl=SESSION_TTL)
    return token

def validate(token):
    record = lookup(token)
    if record is None:
        return None
    if record.expired():
        return None
    return record.user
EOF
git add -A && git commit -qm base
cat > api/session.py <<'EOF'
SESSION_TTL = 86400

def issue(user):
    token = mint(user)
    store(token, ttl=SESSION_TTL)
    return token

def validate(token):
    record = lookup(token)
    if record is None:
        return None
    return record.user
EOF
git add -A && git commit -qm "extend session lifetime for mobile clients"
echo "== summary =="
git show --stat --format="%s" HEAD
echo "== full diff =="
git show --format="" HEAD
echo "== whitespace-blind check =="
git show --format="" -w HEAD | grep -cE "^[+-][^+-]"
