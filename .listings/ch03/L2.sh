export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > svc.py <<'EOF'
def charge_card(amount):
    return gateway.charge(amount)


def refund_card(amount):
    limit = 100
    return gateway.refund(amount, limit)
EOF
git add -A && git commit -qm base
sed -i 's/    limit = 100/    limit = 10000/' svc.py
git add -A && git commit -qm "raise refund limit"
git show --format="" HEAD
