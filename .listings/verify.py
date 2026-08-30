#!/usr/bin/env python3
"""Re-execute every listing in the manuscript and byte-compare its transcript.

Extracts each ```bash listing and the ```output block that follows it from the
chapter files, re-runs the listing in a throwaway directory under the
publisher's gate environment, and compares the captured output byte-for-byte
against the printed transcript. Exits nonzero if any listing mismatches or
fails.

The run environment is deliberately minimal and machine-independent:
  PATH=/usr/bin:/bin          the gate's restricted path
  HOME=<tempdir>              a scratch home, so no personal git config leaks in
  GIT_CONFIG_NOSYSTEM=1       ignore /etc/gitconfig
  GIT_CONFIG_GLOBAL=/dev/null ignore ~/.gitconfig
This pins git to its own defaults (diff.renames on, diff.renameLimit 1000,
core.autocrlf off, three lines of context), which are the conditions the back
matter documents, so the byte comparison holds on any machine with the same git.

Run from the repository root, or from anywhere:  python3 .listings/verify.py
"""
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PAIR_RE = re.compile(r"```bash\n(.*?)```\n+```output\n(.*?)```", re.S)

GATE_ENV_BASE = {
    "PATH": "/usr/bin:/bin",
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_CONFIG_GLOBAL": "/dev/null",
}


def main() -> int:
    fails = 0
    total = 0
    for ch in sorted(ROOT.glob("ch*.md")):
        blocks = PAIR_RE.findall(ch.read_text(encoding="utf-8"))
        for i, (script, printed) in enumerate(blocks, 1):
            total += 1
            with tempfile.TemporaryDirectory(prefix="wc-verify-") as tmp:
                env = dict(GATE_ENV_BASE)
                env["HOME"] = tmp
                sp = Path(tmp) / "listing.sh"
                sp.write_text(script, encoding="utf-8")
                proc = subprocess.run(
                    ["bash", str(sp)], cwd=tmp, text=True, timeout=30, env=env,
                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                real = proc.stdout.rstrip("\n")
                want = printed.rstrip("\n")
                if real != want or proc.returncode != 0:
                    fails += 1
                    print(f"MISMATCH {ch.name} listing {i} (rc={proc.returncode})")
                    print("-- printed --")
                    print(want)
                    print("-- actual --")
                    print(real)
                else:
                    print(f"ok {ch.name} listing {i}")
    print(f"listings checked: {total}; mismatches: {fails}")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
