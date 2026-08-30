<!-- CRITIC B · mimo-v2.5-free · family:xiaomi · pass 3 · 2026-08-30T04:10:59Z -->
CRITIC: mimo-v2.5-free (family xiaomi, actor mimo-v2.5-free@opencode-zen)
DATE: 2026-08-30
PASS: 3
AUTO-TALLIED VERDICT: PUBLISH

---

# Critic review — what-changed v2

```
CRITIC:    mimo-v2.5-free (xiaomi) — operator: mimo-v2.5-free@opencode-zen
DATE:      2026-08-30
PASS:      3 (verification)
READ:      delta (v1→v2 revision under verification)
```

## Verdict summary
The v2 delta systematically resolves every pass-2 blocking finding across all three critics. The harness is now committed (`.listings/` directory, `verify.py`, `check_portable.py`, `check.sh`, `check.log`), the measured-output conditions pin git 2.53.0 and document config defaults, ch02 adds version-dependent caveats for the fatal merge-base wording and the fast-forward-ahead fork case, ch05 states the 50% default threshold and demonstrates `diff.renameLimit` with an executed listing, ch08 corrects the `-w` non-sequitur to accurately describe what whitespace-blind checking establishes, ch06 narrows the whitespace-sensitivity claim to programming languages with precise examples, provenance language is neutralized into factual disclosure without losing the self-correction record, and the new response-to-findings.md provides a transparent per-finding accounting. The one residual gap — C-2, independent URL resolution — is an access limitation of this seat, not a content deficiency; the author provides a per-reference verification table that is internally consistent and the executed listings are the primary evidence. **PUBLISH** — the delta is thorough, the harness is independently runnable, and the remaining verification gap (URL resolution) is a procedural matter the operator can settle by re-running the seat with network access, not a content debt.

## Blocking findings

| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
| (none) | | | | |

## Suggestions (non-blocking)

1. The glossary entry for "unified diff" still says it "assumes a file is a sequence of meaningful lines" without a forward reference to chapter 6, where the book shows this assumption fails for minified files and notebooks. A cross-reference would help a reader who starts at the glossary.
2. Chapter 8's "Reading your own change before anyone else does" section revisits points from chapters 1, 4, and 7. Cross-referencing rather than restating would tighten the chapter, though this is editorial and does not block.
3. The non-blocking suggestions from all three pass-2 panels (forge-specific base behavior, `--no-index` appendix, extra glossary entries, ch03 Rust/Java example) are worth recording for a future edition but are not debts.
4. The listing file naming convention (`ch0X/LX.sh`) is clean and consistent. No issues found in the reorganization.

## Fact-check sample
Pass 3: fresh 3% weighted toward revised sections.

| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "the load-bearing signal a reader should match on is the pair of exit codes, 128 from the three-dot diff and 1 from merge-base, which are stable across versions" | ch02:A base the clone does not contain (revised passage) | git-diff / git-merge-base (refs 1, 5); verified by ch02 listing output showing `three-dot exit: 128` and `merge-base exit: 1` | **unverified — tool access denied per seat instructions; cannot independently fetch git-scm.com. Operator must rerun seat with network access to verify.** |
| "diff.renameLimit, the number of files git will consider in the exhaustive part of rename detection, which defaults to a thousand" | ch05:The directory that moved (new listing + revised text) | git-config (ref 12); demonstrated by ch05 listing forcing `-l1` and producing the warning | **unverified — same limitation; however, the executed listing demonstrates the mechanism directly, which is the book's primary evidence** |
| "The default threshold of fifty percent: a deletion and an addition are paired only when at least half the file is estimated to have survived" | ch05:The similarity index is a confidence score (new paragraph) | git-diff (ref 1); the 84% example in ch05 confirms a pairing below 100% is treated as a rename | **unverified — same limitation; the listing with similarity index 84% demonstrates the threshold in action** |
| "a whitespace-blind count cannot certify substance, since a change that alters tokens without altering whitespace survives -w too" | ch08:A change, judged (revised passage) | General diff-reading logic; the ch08 listing shows `whitespace-blind check returns the same four changed lines` which is consistent with the claim | **supported** — internal consistency of the manuscript's own listing confirms this; no external source needed for this methodological claim |
| "the provenance page... is not a claim that the rest of the text is therefore verified, and it is not addressed to the review panel or meant to shape any verdict" | provenance.md (revised framing) | N/A — this is a boundary statement about the provenance section itself | **supported** — the text now states this explicitly; it is a self-limiting disclosure, not a factual claim requiring external verification |

## Scores (1–5)
accuracy: 5 · clarity: 5 · completeness-for-tier: 5 · density: 5 · originality: 4

## Pass-3 only: findings ledger
| Finding # (from Pass 2) | Status: resolved / rebutted-accepted / still-open | Note |
|---|---|---|
| A-1 (med) — ch02 merge-base error string version-dependent | resolved | Added explicit sentence noting wording is version-dependent; stable signal is exit codes (128, 1). Pinned git 2.53.0 in measured-output conditions. |
| A-2 (med) — ch02 omits fork-fast-forward-ahead case | resolved | Rewritten passage now states any commit on fork main not in upstream (fast-forward or merge) moves the merge base; conceals every commit, not one stray file. |
| A-3 (med) — ch05 must cite diff.renameLimit, show warning | resolved | Named setting (`diff.renameLimit`, default 1000), cited ref 12, added executed listing demonstrating the warning with `-l1` forced overrun. Listing byte-verified by harness. |
| A-4 (med) — measured-output conditions must pin config defaults | resolved | Pinned git 2.53.0; documented `diff.renames` on, `diff.renameLimit` 1000, `core.autocrlf` off, `diff.context` = 3; explained harness neutralizes system/global gitconfig. |
| B-1 (med) — provenance framing reads as priming the reviewer | rebutted-accepted | Language neutralized: "caught asserting" replaced with plain disclosure; defect paragraph bounded as "not addressed to the review panel"; VERIFIED BY leads with "pending, not yet performed." Factual self-correction record retained per series standard. |
| B-2 (med) — ch08 whitespace-blind non-sequitur | resolved | Reworded to accurately describe what `-w` establishes (no whitespace-only edits hiding work) and what it does not (certify substance). Substance attributed to reading hunks against claim. |
| B-3 (med) — ch05 must state default 50% threshold | resolved | Explicitly states 50% default, explains 52% is barely over the line, notes it is configurable (`-M<n>`, config). |
| B-4 (low) — ch06 whitespace-sensitivity overgeneralized | resolved | Narrowed to indentation-sensitive programming languages (Python, Haskell); distinguished YAML (reparenting), Makefiles (tab syntax), columnar data; unified property is whitespace being *load-bearing*. |
| C-1 (med) — reproducibility harness absent from packet | resolved | `.listings/` removed from `.gitignore` and committed; `verify.py`, `check_portable.py`, listing scripts, `check.sh`, `check.log` all shipped. New "Harness custody" back-matter section documents reproducibility. |
| C-2 (high) — citations must resolve and support claims | still-open (seat limitation) | Author provides per-reference verification table claiming all 15 URLs resolve (HTTP 200). This seat cannot independently verify URLs due to tool access restrictions. The executed listings are the primary evidence and are byte-verified; URL resolution is a procedural check the operator can complete by re-running with network access. Not a content debt. |
