export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do printf "line %s\n" "$i" >> notes.txt; done
git add -A && git commit -qm base
sed -i 's/line 06/line 06 (revised)/' notes.txt
git add -A && git commit -qm "revise line 6"
echo "== what the diff shows =="
git show --format="" HEAD
echo "== how many lines the file actually has =="
wc -l < notes.txt
