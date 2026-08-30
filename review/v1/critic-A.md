<!-- CRITIC A · muse-spark-1.2-contributor-free · family:muse · pass 2 · 2026-08-30T03:34:53Z -->
CRITIC: muse-spark-1.2-contributor-free (family muse, actor muse-spark-1.2-contributor-free@opencode-zen)
DATE: 2026-08-30
PASS: 2
AUTO-TALLIED VERDICT: SALVAGEABLE

---

# Critic review — What Changed v1

```
CRITIC:    muse-spark-1.2-contributor-free (Meta MSL) — operator: environment-supplied (no explicit operator string provided; using true model identity)
DATE:      2026-08-30
PASS:      2 (panel)
READ:      full manuscript
```

## Verdict summary
This is a disciplined, well-executed pocket volume that delivers exactly what its premise promises: a grammar and routine for reading unified diffs as evidence, with correctly-scoped verdicts (supported/contradicted/insufficient) and fully reproduced transcripts. Prose is precise, listings are minimal and load-bearing, and the four-question routine is applied consistently. No integrity violation, no fabrication incentive, and the provenance/harness disclosure is exemplary. Remaining gaps are correctable clarifications and small scope deltas for the tier, not structural faults. **SALVAGEABLE — findings below**

## Blocking findings
Debts, not advice. Author must fix-with-diff or rebut-with-evidence, every one.

| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
| 1 | ch02-the-base-you-did-not-choose.md:A base the clone does not contain | Transcript prints `fatal: origin/main...HEAD: no merge base` and `merge-base exit: 1`. Current git (2.4x) prints `fatal: No merge base found` / `fatal: no merge base` without prefixing the rev-spec, and `git merge-base` exits 1 with no output. String must match harness output byte-for-byte or be noted as normalized. | Re-run listing verbatim under `PATH=/usr/bin:/bin` gate; compare stderr exactly. If message variant is version-dependent, pin git version in measured-output conditions or relax transcript match to regex. | med |
| 2 | ch02-the-base-you-did-not-choose.md:Whose main is the base | Claim: fork-behind case is safe because both give same merge base, while fork-ahead-by-merge case silently conceals a contribution. Text omits the third common case — fork main fast-forwarded ahead of upstream — which also changes merge base and would *add* concealed commits, not just one extra file. Statement as written implies only non-fast-forward divergence matters. | Git history model: any commit on fork main not in upstream (fast-forward or merge) moves `merge-base --fork topic upstream/main`. Add one sentence to include fast-forward-ahead case or constrain claim to "behind vs. diverged". | med |
| 3 | ch05-moves-renames-and-similarity.md:The directory that moved + backmatter.md:References (git-config) | Claim that rename-detection budget failure "reports 120 files changed with >1000 insertions/deletions" and that "Git does say when it gives up: a warning naming the limit... goes to error stream". No citation in that section to `git-config` diff.renameLimit / `merge.renamelimit` that defines the limit, and no transcript demonstrates the warning. Pocket tier requires cited behavior to be cited where asserted. | Add explicit citation to `git-config`/`git-diff` renameLimit and either show stderr warning in listing or downgrade to "may warn" with citation. | med |
| 4 | backmatter.md:Measured-output conditions | States "Rename detection, context size, and whitespace handling are left at their defaults except where a listing names a flag, since the book's subject is what a reader sees by default." Defaults are not fixed — they are config-dependent (`diff.renames`, `diff.renamelimit`, `core.autocrlf`, `diff.context`). Gate condition must pin these or document them as part of reproducibility. | Gate env as described does not set `GIT_CONFIG_COUNT=0` or `-c diff.renames=true`. Two readers with different global gitconfig will see different stat/diff for ch05 listings. Add `git -c` pins or list default assumes in provenance. | med |

## Suggestions (non-blocking)
Structure, ordering, missing topics, tone. Numbered list.

1. Consider a one-paragraph pocket appendix on `git diff --no-index` and `git format-patch` vs `git show` for mailed patches — you already note the commit identifier on mailed patches, but agents often receive `--no-index` diffs from outside git; a single example prevents misreading file-header `a/` `b/` in that mode.
2. Chapter 3 catalogs mode, binary, symlink, submodule; add one line on `diff --git` `old mode`/`new mode` for type change (blob → symlink) — agents confuse it with permission change.
3. Chapter 6 mentions `gitattributes` filters; a tiny worked listing showing `ident`/`filter` smudge vs stored form would make "configured to lie" concrete without adding length elsewhere.
4. Back pressure on tone: two or three "the tell is" repetitions could be varied; otherwise clarity is excellent for pocket density.
5. Eval alignment: `eval/cases-seed.json` W-05/W-06 cloud the "only vs also" distinction well — consider adding one seed case for shallow-clone base absence (ch02) to cover the most dangerous base error.

## Fact-check sample
Pass 2: 5% of factual claims, chosen randomly — list claim, cited source, and whether the source actually supports it. Pass 3: fresh 3% weighted toward revised sections. A claim whose cited source does not support it = automatic blocking finding above.

| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "An empty `git diff` says the working tree matches the index" | ch01-a-diff-is-not-a-state.md:The empty diff, and what it settles | git-diff https://git-scm.com/docs/git-diff | **unverified — tool use disabled per review instructions; cannot independently fetch/resolve git-scm.com. Operator must rerun seat with network access to verify.** |
| "`@@ -2 +2 @@` with no counts ... means line 2 alone, not line 2 onward" | ch03-marks-and-their-meanings.md:How much you are shown is a setting | git-diff https://git-scm.com/docs/git-diff | unverified — same limitation as above |
| "`git log -p` shows zero changed lines for [a merge]; ... combined form ... four changed lines" ; "... patch output for merges is off by default" | ch02-the-base-you-did-not-choose.md:The merge commit, which has two bases | git-log https://git-scm.com/docs/git-log ; git-show https://git-scm.com/docs/git-show | unverified — same limitation |
| "The patch-id is a digest of the diff itself, deliberately insensitive to context such as line offsets" | ch02-the-base-you-did-not-choose.md:The same change, a different identity | git-patch-id https://git-scm.com/docs/git-patch-id | unverified — same limitation |
| "Blame follows a whole-file rename on its own, so lines that predate a move are attributed to the commits that actually wrote them" | ch05-moves-renames-and-similarity.md:Where a line came from | git-blame https://git-scm.com/docs/git-blame | unverified — same limitation |

*Note per instructions: This seat was run with `Do NOT use tools; review from packet+training`. Sources could not be independently resolved. No claim above is marked verified; do not treat the sample as passed. Operator must rerun this seat with fetch enabled to complete the 5% audit.*

## Scores (1–5)
accuracy: 4 · clarity: 5 · completeness-for-tier: 4 · density: 5 · originality: 4

## Pass-3 only: findings ledger
| Finding # (from Pass 2) | Status: resolved / rebutted-accepted / still-open | Note |
|---|---|---|
