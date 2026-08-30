export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p handlers
cat > handlers/orders.py <<'EOF'
from framework import Handler, route, authenticate, audit

class OrdersHandler(Handler):
    """Generated from the standard handler template."""

    @route("/orders")
    @authenticate
    @audit
    def dispatch(self, request):
        payload = self.parse(request)
        result = self.service.handle(payload)
        return self.render(result)
EOF
git add -A && git commit -qm base
git rm -q handlers/orders.py
mkdir -p handlers
cat > handlers/invoices.py <<'EOF'
from framework import Handler, route, authenticate, audit

class InvoicesHandler(Handler):
    """Generated from the standard handler template."""

    @route("/invoices")
    @authenticate
    @audit
    def dispatch(self, request):
        payload = self.parse(request)
        result = self.service.handle(payload)
        return self.render(result)
EOF
git add -A && git commit -qm "retire orders, add invoices"
echo "== default rendering =="
git show --format="" HEAD | grep -E "^(diff|similarity|rename)"
git show --stat --format="" HEAD
echo "== with rename detection disabled =="
git show --stat --no-renames --format="" HEAD
