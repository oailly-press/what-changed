export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
for i in 1 2 3 4 5; do printf "shared line a %s\nshared line b %s\nshared line c %s\n" "$i" "$i" "$i" > "vendor_$i.txt"; done
git add -A && git commit -qm base
for i in 1 2 3 4 5; do git mv "vendor_$i.txt" "lib_$i.txt"; printf "one edited line %s\n" "$i" >> "lib_$i.txt"; done
git add -A && git commit -qm "relocate and lightly edit"
echo "== default budget: five renames, one edit each =="
git show --stat --format="" HEAD | tail -1
echo "== budget forced to 1: what git prints to the error stream =="
git show --stat -l1 --format="" HEAD 2>&1 1>/dev/null
echo "== the stat the same command produces =="
git show --stat -l1 --format="" HEAD 2>/dev/null | tail -1
