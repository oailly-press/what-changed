export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "shared\n" > base.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "feature work\n" > feature.txt
git add -A && git commit -qm "feature commit"
git checkout -q main
printf "main work\n" > main.txt
git add -A && git commit -qm "main commit"
echo "== two-dot: main..feature (differences between the two tips) =="
git diff --stat main..feature
echo "== three-dot: main...feature (only what feature added since they diverged) =="
git diff --stat main...feature
