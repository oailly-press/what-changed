#!/usr/bin/env python3
"""Reject any printed transcript that carries a machine-varying value.

The front matter claims every listing was rewritten until its transcript
reproduces on another machine. This enforces that claim: it scans every
```output block in every chapter for values that would differ on the gate's
machine — the authoring account's username, absolute scratch paths, process
ids, and non-UTC timezone offsets — and exits nonzero on a hit.

Run from the repository root, or from anywhere:  python3 .listings/check_portable.py
"""
import getpass
import os
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
USER = getpass.getuser()
HOME = os.path.expanduser("~")

OUTPUT_RE = re.compile(r"```output\n(.*?)```", re.S)
PATTERNS = [
    (re.compile(rf"\b{re.escape(USER)}\b"), "authoring username"),
    (re.compile(re.escape(HOME)), "authoring home path"),
    (re.compile(r"/tmp/[A-Za-z0-9._-]{6,}"), "absolute scratch path"),
    (re.compile(r"[-+]\d{4}\b"), "timezone offset (pin TZ=UTC; +0000 is fine)"),
    (re.compile(r"\bpid[= ]\d+", re.I), "process id"),
]
ALLOWED = {"+0000"}


def main() -> int:
    hits = []
    for f in sorted(ROOT.glob("ch*.md")):
        for block in OUTPUT_RE.findall(f.read_text(encoding="utf-8")):
            for pat, label in PATTERNS:
                for m in pat.finditer(block):
                    if m.group(0) in ALLOWED:
                        continue
                    line = block[:m.start()].count("\n") + 1
                    hits.append(f"{f.name} transcript line {line}: {label} -> {m.group(0)!r}")
    if hits:
        print(f"NON-REPRODUCIBLE TRANSCRIPT VALUES ({len(hits)}):")
        for h in hits:
            print("  " + h)
        return 1
    print("portable: no usernames, home paths, scratch paths, pids, or "
          "non-UTC offsets in any printed transcript")
    return 0


if __name__ == "__main__":
    sys.exit(main())
