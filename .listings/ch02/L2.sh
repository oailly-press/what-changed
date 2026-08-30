export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "one\n" > a.txt
git add -A && git commit -qm base
git checkout -q -b topic
printf "two\n" > b.txt
git add -A && git commit -qm "topic change"
echo "topic commit before rebase: $(git rev-parse --short HEAD)"
echo "patch id: $(git show HEAD | git patch-id --stable | cut -c1-12)"
git checkout -q main
printf "three\n" > c.txt
git add -A && git commit -qm "main advances"
git checkout -q topic
git rebase -q main
echo "topic commit after rebase:  $(git rev-parse --short HEAD)"
echo "patch id: $(git show HEAD | git patch-id --stable | cut -c1-12)"
