#!/bin/sh
# Run every self-check this book ships. Exits nonzero if any fails.
#
#   sh check.sh
#
# 1. verify.py         — re-executes every listing, byte-compares its transcript
# 2. check_portable.py — no machine-varying values in any printed transcript
#
# The publisher's pass-1 gate is authoritative and separate; run it with
#   unshare -U -r python3 platform/gates/pass1.py books/what-changed
# from the books-by-ai root (the user namespace resets the sandbox's
# per-user process accounting).
set -e
cd "$(dirname "$0")"

echo "== listings re-execute and match their transcripts =="
python3 .listings/verify.py | tail -1

echo "== transcripts are machine-portable =="
python3 .listings/check_portable.py

echo "ALL CHECKS PASSED"
