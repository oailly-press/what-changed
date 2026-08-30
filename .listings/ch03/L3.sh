export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf '#!/bin/sh\nrun_backup\n' > deploy.sh
chmod 755 deploy.sh
printf 'AA\000BB\n' > logo.bin
git add -A && git commit -qm base
chmod 644 deploy.sh
printf 'AA\000CC\n' > logo.bin
git add -A && git commit -qm "adjust assets"
echo "== the whole diff =="
git show --format="" HEAD
echo "== how many content lines (+/-) did it print? =="
git show --format="" HEAD | grep -c "^[+-][^+-]" || true
