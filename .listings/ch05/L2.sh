export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > handler.py <<'EOF'
def process(item):
    validated = validate(item)
    enriched = enrich(validated)
    stored = store(enriched)
    audit(stored)
    return stored
EOF
git add -A && git commit -qm base
git mv handler.py processor.py
cat > processor.py <<'EOF'
def process(item):
    validated = validate(item)
    enriched = enrich(validated)
    stored = store(enriched)
    audit(stored)
    notify(stored)
    return stored
EOF
git add -A && git commit -qm "rename and extend"
echo "== default rename detection =="
git show --stat --format="" HEAD
echo "== with detection disabled =="
git show --stat --no-renames --format="" HEAD
