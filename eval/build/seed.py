#!/usr/bin/env python3
"""Seed fixtures for 'What Changed': real diffs captured from real commits.

Each case builds a scratch repository, makes actual commits, and captures
git's own output verbatim. Diffs are content-addressed, so blob hashes
reproduce on any machine.
"""
import json, subprocess, tempfile
from pathlib import Path

CASES = []
ENV = {"PATH": "/usr/bin:/bin", "HOME": "/nonexistent",
       "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@e",
       "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@e",
       "GIT_AUTHOR_DATE": "2026-01-01T00:00:00Z",
       "GIT_COMMITTER_DATE": "2026-01-01T00:00:00Z"}


def case(cid, family, context, script, claim, gold, rationale):
    with tempfile.TemporaryDirectory(prefix="wc-seed-") as tmp:
        sp = Path(tmp) / "case.sh"
        sp.write_text("set -e\ngit init -q -b main .\n" + script)
        r = subprocess.run(["bash", str(sp)], cwd=tmp, text=True, timeout=60,
                           env=ENV, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    CASES.append(dict(id=cid, family=family, context=context,
                      transcript=r.stdout.rstrip("\n"), claim=claim,
                      gold=gold, rationale=rationale))


BASE_AUTH = '''cat > auth.py <<'EOF'
def check(token, user):
    if not token:
        raise ValueError("missing token")
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm base
cat > auth.py <<'EOF'
def check(token, user):
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm "simplify check"
'''

case("W-01", "stat-vs-substance",
     "A reviewer read only the commit's stat summary and its message, which is 'simplify check'.",
     BASE_AUTH + 'git show --stat --format="" HEAD\n',
     "The commit only simplifies the function without changing behavior.",
     "insufficient",
     "The stat reports two deleted lines but shows none of them; a line count cannot establish that behavior is unchanged, and the summary is the only evidence present."),

case("W-02", "stat-vs-substance",
     "The same commit, now shown as a full diff.",
     BASE_AUTH + 'git show --format="" HEAD\n',
     "The commit only simplifies the function without changing behavior.",
     "contradicted",
     "The deleted lines are the empty-token guard and its ValueError; removing a validation check changes behavior for callers passing an empty token."),

case("W-03", "context-lines",
     "A reviewer is asked which lines this commit changed.",
     BASE_AUTH + 'git show --format="" HEAD\n',
     "The commit changed the is_admin branch.",
     "contradicted",
     "The is_admin lines carry a leading space, marking them as unchanged context; only the two minus-prefixed guard lines were changed."),

case("W-04", "diff-is-not-state",
     "A reviewer wants to know what the file contains after the change.",
     BASE_AUTH + 'git show --format="" HEAD\n',
     "After this commit, auth.py contains only the three lines shown as context.",
     "insufficient",
     "A diff shows a transition, not a state: hunks cover only changed regions plus context, so the file may contain lines outside this hunk that the diff never displays."),

case("W-05", "deletions",
     "A dependency file was updated; the reviewer summarized it as an upgrade.",
     '''printf "requests==2.30.0\\ncryptography==41.0.0\\n" > requirements.txt
git add -A && git commit -qm base
printf "requests==2.31.0\\n" > requirements.txt
git add -A && git commit -qm "bump requests"
git show --format="" HEAD
''',
     "The change upgrades requests from 2.30.0 to 2.31.0.",
     "supported",
     "The diff shows exactly that version line replaced; the claim is true as far as it goes, though the same diff also drops cryptography, which the claim does not mention."),

case("W-06", "deletions",
     "The same dependency commit, judged against a wider claim.",
     '''printf "requests==2.30.0\\ncryptography==41.0.0\\n" > requirements.txt
git add -A && git commit -qm base
printf "requests==2.31.0\\n" > requirements.txt
git add -A && git commit -qm "bump requests"
git show --format="" HEAD
''',
     "The change only bumps a version and adds no other risk.",
     "contradicted",
     "The diff also deletes the cryptography pin entirely; a removed dependency is a second, unmentioned change."),

case("W-07", "renames",
     "A file was renamed and edited in the same commit; rename detection is on.",
     '''mkdir -p src
printf "def handler(req):\\n    return 200\\n" > src/old_name.py
git add -A && git commit -qm base
git mv src/old_name.py src/new_name.py
printf "def handler(req):\\n    return 500\\n" > src/new_name.py
git add -A && git commit -qm "rename module"
git show --format="" -M HEAD
''',
     "The commit only renames the module.",
     "contradicted",
     "The diff shows a similarity index below 100% with a changed body line: the return value went from 200 to 500 inside the rename."),

case("W-08", "invisible-changes",
     "A formatting commit was reviewed with whitespace changes suppressed.",
     '''printf "def f(x):\\n    return x+1\\n" > calc.py
git add -A && git commit -qm base
printf "def f(x):\\n        return x + 2\\n" > calc.py
git add -A && git commit -qm "reformat"
echo "== with -w (whitespace-insensitive) =="
git show --format="" -w HEAD
''',
     "The commit is a pure reformatting with no logic change.",
     "contradicted",
     "Even with whitespace suppressed the diff shows the expression changing from x+1 to x + 2; the constant changed, which -w does not hide."),

if __name__ == "__main__":
    out = Path(__file__).resolve().parent.parent / "cases-seed.json"
    out.write_text(json.dumps({"corpus": "what-changed seed fixtures",
                               "captured": "real git commits in scratch repositories",
                               "cases": CASES}, indent=2) + "\n")
    print(f"wrote {len(CASES)} cases")
    for c in CASES:
        print(f"  {c['id']} [{c['family']}] gold={c['gold']}")
