export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "base\n" > f.txt
git add -A && git commit -qm base
git checkout -q -b side
printf "side\n" >> f.txt
git add -A && git commit -qm side
git checkout -q main
printf "main\n" >> f.txt
git add -A && git commit -qm main
git merge -q side > /dev/null 2>&1
printf "base\nresolved\n" > f.txt
git add -A && git commit -qm "merge with resolution" > /dev/null 2>&1
echo "== git log -p on the merge: how many +/- lines? =="
git log -p -1 --format="" | grep -c "^[+-]"
echo "== git log -p --cc on the same merge =="
git log -p -1 --cc --format="" | grep -c "^[+-]"
echo "== the resolution, compared against the first parent =="
git diff HEAD^1 HEAD | grep "^[+-]" | tail -2
