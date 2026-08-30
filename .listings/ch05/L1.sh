export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "content\n" > original.txt
git add -A && git commit -qm base
git mv original.txt renamed.txt
git add -A && git commit -qm "rename only"
echo "== what the commit's tree actually records =="
git ls-tree -r HEAD
echo "== the parent's tree =="
git ls-tree -r HEAD^
echo "== blob identity: same object? =="
echo "before: $(git rev-parse HEAD^:original.txt)"
echo "after:  $(git rev-parse HEAD:renamed.txt)"
