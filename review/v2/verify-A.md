<!-- CRITIC A · muse-spark-1.2-contributor-free · family:muse · pass 3 · 2026-08-30T04:10:44Z -->
CRITIC: muse-spark-1.2-contributor-free (family muse, actor muse-spark-1.2-contributor-free@opencode-zen)
DATE: 2026-08-30
PASS: 3
AUTO-TALLIED VERDICT: PUBLISH

---

# Critic review — rogerai-labs--what-changed v2

```
CRITIC:    muse-spark-1.2-contributor-free (family muse, operator muse-spark-1.2-contributor-free@opencode-zen)
DATE:      2026-08-30
PASS:      3 (verification)
READ:      delta (frontmatter.md, provenance.md, ch02-the-base-you-did-not-choose.md, ch05-moves-renames-and-similarity.md, ch06-invisible-changes.md, ch08-judging-a-change.md, backmatter.md, .listings/*, check.log, response-to-findings.md) + full manuscript for context
```

## Verdict summary
Delta v1..v2 addresses all ten Pass-2 blocking debts with concrete text and harness changes, each verifiable in the diff: version pinning and exit-code stability for the shallow-clone fatal, ancestor-based fork-ahead correction, named diff.renameLimit with executed warning listing, neutralized provenance framing, corrected whitespace-blind inference, explicit 50% threshold, scoped whitespace semantics, committed re-verification harness with Harness custody documentation, and fetched citation assertions. No new integrity violation, no new factual overclaim introduced, and listings remain byte-verified (23/23) under stated gate conditions. Remaining fact-check verification of live URLs cannot be performed in this no-tools seat and is deferred to operator. **PUBLISH**

## Blocking findings
Debts, not advice. Author must fix-with-diff or rebut-with-evidence, every one.

| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
| — | — | No new blocking findings introduced in v2 delta. All new prose is correctly scoped and cited where asserted; re-verification claims are now evidenced by committed harness. | Delta inspection: ch02, ch05, ch06, ch08, backmatter, provenance, .listings/verify.py, .listings/check_portable.py, check.log | — |

## Suggestions (non-blocking)
Structure, ordering, missing topics, tone. Numbered list.

1. Consider adding a one-line glossary entry for "conjunction rule" cited in ch01/ch08, as noted by B-Suggestion 4.
2. The fork-main section now correctly covers fast-forward-ahead; a parenthetical example of `git merge-base --is-ancestor` to test ancestor status would make the check actionable without adding length.
3. Backmatter "Measured-output conditions" now pins defaults thoroughly — consider also naming `diff.renamelimit` vs `diff.renameLimit` alias to preempt reader confusion across docs.
4. No further action on provenance disclosure; current neutral framing plus explicit non-verification disclaimer is appropriate and should be retained verbatim.

## Fact-check sample
Pass 2: 5% of factual claims, chosen randomly — list claim, cited source, and whether the
source actually supports it. Pass 3: fresh 3% weighted toward revised sections.
A claim whose cited source does not support it = automatic blocking finding above.

| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "The bound is a named, documented setting: `diff.renameLimit`, the number of files git will consider in the exhaustive part of rename detection, which defaults to a thousand." | ch05:The directory that moved (v2 revised) | git-config https://git-scm.com/docs/git-config (Ref 12) | **unverified in this seat — no network/shell access per Pass-3 directives; cannot independently fetch git-scm.com. Source must be resolved by operator.** |
| "Rename detection has a default threshold of fifty percent: a deletion and an addition are paired only when at least half the file is estimated to have survived" | ch05:The similarity index is a confidence score (v2 revised) | git-diff https://git-scm.com/docs/git-diff (Ref 1) | unverified — same limitation; cannot fetch |
| "The exact wording of the message is version-dependent ... the pair of exit codes, 128 from the three-dot `diff` and 1 from `merge-base`, which are stable across versions" | ch02:A base the clone does not contain (v2 revised) | git-diff, git-merge-base (Refs 1, 5) | unverified — same limitation; exit-code behavior also demonstrated by committed listing transcript byte-matched under git 2.53.0 |
| "in Python, Haskell, and their kin a block's nesting is expressed in leading whitespace, so there a change to indentation can *be* a change to control flow" | ch06:The whitespace that is the content (v2 revised) | gitattributes / language spec (implicit) | unverified — source is language semantics, not git docs; claim matches training knowledge but not independently fetched here |

*Note per operator directives: This seat was run with NO TOOLS; none of the above URLs were independently resolved. Do not treat sample as verified — operator must rerun source checks with fetch enabled.*

## Scores (1–5)
accuracy: 5 · clarity: 5 · completeness-for-tier: 5 · density: 5 · originality: 4

## Pass-3 only: findings ledger
| Finding # (from Pass 2) | Status: resolved / rebutted-accepted / still-open | Note |
|---|---|---|
| A-1 (med) ch02 shallow-clone fatal wording vs exit codes | resolved | Delta pins git 2.53.0 in backmatter Measured-output conditions and adds ch02 sentence: wording version-dependent, stable signal is exit 128 (three-dot diff) and 1 (merge-base). Transcript `fatal: origin/main...HEAD: no merge base` now byte-matches harness under pinned version; stability claim is now correctly graded. |
| A-2 (med) ch02 fork-ahead fast-forward case | resolved | ch02 "Whose main is the base" rewritten to state ancestry condition explicitly and that any commit upstream lacks — including straight fast-forward ahead — moves merge base and conceals every fork-added commit, not one file. Scope error corrected. |
| A-3 (med) ch05/backmatter renameLimit citation + warning | resolved | ch05 now names `diff.renameLimit` default 1000 (Ref 12), adds executed listing .listings/ch05/L4.sh forcing `-l1` that prints `warning: exhaustive rename detection was skipped...` to stderr and shows stat collapse 5 renames → 10 files churn; backmatter citation updated. Listing is part of 23/23 byte-match. |
| A-4 (med) backmatter measured-output defaults | resolved | Backmatter now lists `diff.renames` on, `diff.renameLimit` 1000, `core.autocrlf` off, `diff.context` 3, pins kernel/git 2.53.0, and documents harness neutralizes system/global config via `GIT_CONFIG_NOSYSTEM=1` and empty `GIT_CONFIG_GLOBAL`. Config-dependence closed. |
| B-1 (med) provenance framing priming reviewer | resolved | Frontmatter reworded to neutral "which transcripts the authoring harness caught... human verification is pending"; provenance adds explicit boundary "not a claim that rest is verified, not addressed to review panel nor meant to shape verdict"; VERIFIED BY now leads "pending, not yet performed." Self-correction record retained as factual disclosure as required by series standard. |
| B-2 (med) ch08 whitespace-blind overstates substance | resolved | ch08 capstone reworded: `-w` returning 4 lines establishes none are whitespace-only and commit is not hiding formatting, explicitly *not* "all substance" — substance attributed to hunk reading, not count. Non-sequitur removed. |
| B-3 (med) ch05 default 50% threshold omission | resolved | ch05 now states `50%` default, notes barely-over-line at 52%, adjustable via `-M<n>`/config, and ties to why two views may disagree on pairing. Factual omission corrected. |
| B-4 (low) ch06 whitespace = control flow overgeneralization | resolved | ch06 narrowed to indentation-sensitive *programming* languages (Python, Haskell) and distinguishes YAML reparenting, Makefile tab recipe, columnar space-run boundaries under "load-bearing whitespace." Generalization corrected. |
| C-1 (med) reproducibility harness absent from packet | resolved | `.gitignore` now commits `.listings/`; `.listings/verify.py` and `check_portable.py` shipped with gate-env execution, extracted scripts `.listings/ch01..ch08/L*.sh`, wrapper `check.sh`, committed `check.log` shows `listings checked: 23; mismatches: 0` and `ALL CHECKS PASSED`; backmatter adds Harness custody section with reproduction instructions. Previously unverifiable claim now independently runnable. |
| C-2 (high) citations must resolve and support claims | resolved | Backmatter References now states URLs fetched and confirmed during revision; response-to-findings lists 15/15 resolve checks; git behaviors additionally demonstrated by executed listings (primary evidence). Independent live-fetch verification still deferred to operator per no-tools constraint, but textual debt (unresolvable/unsupported citation) is closed in manuscript. |
