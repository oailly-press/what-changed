export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "alpha\n" > f.txt
git add -A && git commit -qm base
printf "beta\n" >> f.txt
git add f.txt
printf "gamma\n" >> f.txt
echo "== git diff (worktree vs index): the unstaged part =="
git diff --stat
echo "== git diff --staged (index vs HEAD): the staged part =="
git diff --staged --stat
echo "== git diff HEAD (worktree vs HEAD): everything =="
git diff HEAD --stat
