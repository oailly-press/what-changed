export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
for i in 1 2 3 4 5 6 7 8 9 10; do printf "shared line %s\n" "$i" >> mod_a.py; done
for i in 1 2 3 4 5 6 7 8 9 10; do printf "other line %s\n" "$i" >> mod_b.py; done
git add -A && git commit -qm base
git mv mod_a.py kept_a.py
printf "one new line\n" >> kept_a.py
git mv mod_b.py rewritten_b.py
: > rewritten_b.py
for i in 1 2 3 4 5 6 7 8; do printf "completely different %s\n" "$i" >> rewritten_b.py; done
printf "other line 9\n" >> rewritten_b.py
git add -A && git commit -qm "one light rename, one heavy"
echo "== headers, default threshold =="
git show --format="" HEAD | grep -E "^(diff|similarity|rename|---|\+\+\+)"
echo "== stat, default =="
git show --stat --format="" HEAD
