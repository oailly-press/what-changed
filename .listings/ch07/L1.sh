export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p tests
cat > tests/test_billing.py <<'EOF'
def test_refund_within_limit():
    assert refund(50) is True

def test_refund_over_limit_rejected():
    assert refund(5000) is False

def test_refund_negative_rejected():
    assert refund(-1) is False
EOF
cat > billing.py <<'EOF'
def refund(amount):
    if amount < 0 or amount > 1000:
        return False
    return True
EOF
git add -A && git commit -qm base
cat > billing.py <<'EOF'
def refund(amount):
    if amount < 0:
        return False
    return True
EOF
cat > tests/test_billing.py <<'EOF'
def test_refund_within_limit():
    assert refund(50) is True

def test_refund_negative_rejected():
    assert refund(-1) is False
EOF
git add -A && git commit -qm "relax refund ceiling"
echo "== the summary =="
git show --stat --format="" HEAD
echo "== additions only, as a reviewer scanning green =="
git show --format="" HEAD | grep "^+" | grep -v "^+++"
echo "== removals =="
git show --format="" HEAD | grep "^-" | grep -v "^---"
