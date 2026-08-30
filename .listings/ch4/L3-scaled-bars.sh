export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
: > generated.txt
printf "TIMEOUT = 30\n" > config.txt
git add -A && git commit -qm base
for i in $(seq 1 200); do printf "generated row %s\n" "$i" >> generated.txt; done
printf "TIMEOUT = 3000\n" > config.txt
git add -A && git commit -qm "regenerate table, adjust timeout"
echo "== --stat: bar length versus actual counts =="
git show --stat --format="" HEAD
echo "== the actual numbers =="
git show --numstat --format="" HEAD
