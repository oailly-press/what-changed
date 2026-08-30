export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "shared\n" > shared.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "added by feature\n" > feature.txt
git add -A && git commit -qm "feature work"
git checkout -q main
echo "== before main moves =="
echo "two-dot:   $(git diff --shortstat main..feature)"
echo "three-dot: $(git diff --shortstat main...feature)"
printf "added by main\n" > other.txt
git add -A && git commit -qm "unrelated main work"
echo "== after main moves, feature untouched =="
echo "two-dot:   $(git diff --shortstat main..feature)"
echo "three-dot: $(git diff --shortstat main...feature)"
echo "merge base: $(git merge-base main feature | head -c 7)"
