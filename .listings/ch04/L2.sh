export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "a\nb\nc\n" > keep.txt
printf "x\n" > drop.txt
git add -A && git commit -qm base
printf "a\nB\nc\n" > keep.txt
git rm -q drop.txt
printf "new\n" > added.txt
git add -A && git commit -qm "three kinds of change"
echo "== --stat =="
git show --stat --format="" HEAD
echo "== --shortstat =="
git show --shortstat --format="" HEAD
echo "== --numstat (added, deleted, path) =="
git show --numstat --format="" HEAD
echo "== --name-status =="
git show --name-status --format="" HEAD
