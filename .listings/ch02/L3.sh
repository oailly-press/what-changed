export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work
git init -q -b main origin
cd origin
printf "shared\n" > base.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "feature\n" > feature.txt
git add -A && git commit -qm "feature work"
git checkout -q main
printf "main\n" > main.txt
git add -A && git commit -qm "main work"
cd ..
git clone -q --depth 1 --no-local --branch feature "file://$PWD/origin" shallow 2>/dev/null
cd shallow
git fetch -q --depth 1 origin main:refs/remotes/origin/main 2>/dev/null
echo "is shallow: $(git rev-parse --is-shallow-repository)"
echo "== three-dot against the fetched main =="
git diff --stat origin/main...HEAD > /dev/null 2>err.txt
echo "three-dot exit: $?"
cat err.txt
echo "== merge-base =="
git merge-base origin/main HEAD > /dev/null 2>&1
echo "merge-base exit: $?"
echo "== two-dot still answers =="
git diff --stat origin/main..HEAD
