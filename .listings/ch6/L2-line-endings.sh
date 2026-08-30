export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "alpha\nbeta\n" > data.txt
git add -A && git commit -qm base
printf 'alpha\r\nbeta\r\n' > data.txt
git add -A && git commit -qm "touch data"
echo "== does the content look different? =="
git show --format="" HEAD | grep -E "^[+-][^+-]" | cat -v
echo "== byte counts before and after =="
echo "before: $(git show HEAD^:data.txt | wc -c)"
echo "after:  $(git show HEAD:data.txt | wc -c)"
echo "== whitespace-insensitive view =="
git show --format="" -w HEAD | grep -cE "^[+-][^+-]" || true
