<!-- CRITIC C · hy3-free · family:tencent · pass 2 · 2026-08-30T03:35:15Z -->
CRITIC: hy3-free (family tencent, actor hy3-free@opencode-zen)
DATE: 2026-08-30
PASS: 2
AUTO-TALLIED VERDICT: PUBLISH

---

# Critic review — what-changed v1

```
CRITIC:    opencode/hy3-free (model family: hy3; operator: opencode runtime) — non-Claude, distinct from author family Claude / RogerAI Labs
DATE:      2026-08-29
PASS:      2 (panel)
READ:      full manuscript
```

## Verdict summary
This is a technically strong, unusually well-structured pocket guide. Its central thesis — that a diff is change-evidence with a grammar, a base premise, and a summary that routinely outruns it — is sound, and the worked transcripts I could examine against my own git knowledge are accurate in detail (hunk-header arithmetic, two-dot vs three-dot, rename inference, whitespace-blind blind spots, mode/binary/symlink/submodule cases, merge-diff silence, patch-id stability). The manuscript is therefore SALVAGEABLE. The debts are not content errors I could confirm but verification-gate gaps: the reproducibility claim rests on harnesses and chapter transcripts absent from the review packet, and the fact-check sample could not be resolved against the manuscript's own cited sources because this seat was run without tool access. Both must be settled before a Pass 3 publish verdict.

## Blocking findings
Debts, not advice. Author must fix-with-diff or rebut-with-evidence, every one.

| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
| 1 | frontmatter.md "Every worked case is a real transcript" + provenance.md "EVERY LISTING WAS EXECUTED" / "RE-VERIFIED BY .listings/verify.py" | Claims every listing was executed under gate conditions and byte-for-byte re-verified by committed harnesses `.listings/verify.py` and `.listings/check_portable.py`. The review packet contains neither harness nor the chapter transcripts; only separate eval seed fixtures (eval/seed.py, eval/cases-seed.json) are present. The reproducibility assertion is therefore unverifiable from the packet. | Packet inventory: no `.listings/` directory shipped; eval artifacts are 8 synthetic cases, not the chapter listings. Per the book's own rule (observation outranks assertion), an unverified reproducibility claim is a debt. | med |
| 2 | backmatter.md References 1–15 + instruction to verify claims against cited sources | Fact-check sample could not be independently resolved: this seat was instructed "Do NOT use tools," so the git-scm.com / git book URLs were not fetched. Per the gate rules the sample is NOT verified and the operator must rerun the seat with tool access. | Reviewer training supports the sampled claims, but that is not the manuscript's own cited sources; the rule explicitly requires source resolution, not reviewer memory. | high |

## Suggestions (non-blocking)
1. Reconcile provenance's "four defects found by the harnesses" with the absence of the harness from the packet — either ship `.listings/verify.py` + `check_portable.py` and the captured chapter transcripts, or soften the absolute "zero mismatches" language to "at authoring time, on the authoring machine."
2. The eval seed fixtures (W-01…W-08) reuse the Chapter 4 `auth.py` example verbatim, which is good consistency, but the eval set does not exercise the harder chapters' claims (two-dot/three-dot at scale, shallow-clone merge-base failure, merge-diff silence, copy-header false pairing). A reader verifying the book's thesis would want seed cases covering those.
3. Glossary entry "unified diff" says it "assumes a file is a sequence of meaningful lines" — fine, but the book later shows this assumption fails (minified/single-line, notebooks). Consider a cross-reference from the glossary to Ch6 rather than leaving the glossary as the last word.
4. Chapter 2's merge-base-aging section could state the concrete command to check base age (`git merge-base --is-ancestor` / `git rev-list --count`), since the book elsewhere insists on naming the base explicitly.
5. Frontmatter says listings "all fit the budget and none is a fragment, so both markings go unused" — good, but the marking-discipline section in backmatter still explains `no-run` and fragments at length for a volume where neither applies; trim or note "retained for series consistency."

## Fact-check sample
Pass 2: ~5% of factual claims, chosen across chapters. **All sampled claims are supported by the reviewer's git knowledge, but NONE were resolved against the manuscript's cited sources (tool access denied — see Blocking finding #2). Sample is NOT verified; operator must rerun.**

| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "git stores no rename information at all; a commit records a tree of paths pointing at content" | ch05 "Nothing recorded a rename" | Ref 14 (Pro Git object model), Ref 13 (gitglossary) | partly* (true per training; source unverified) |
| "A two-dot range A..B compares the two tips directly" | ch01 "Ranges, and the work you did not do" / glossary | Ref 1 (git-diff) | partly* |
| "git log -p shows zero changed lines for [a merge]; patch output for merges is off by default" | ch02 "The merge commit, which has two bases" | Ref 3 (git-log) | partly* |
| "its [--stat] bars are scaled, not absolute" | ch04 "Triage misallocates attention" | Ref 1 (git-diff --stat) | partly* |
| "a digest of a change's content, insensitive to line offsets" (patch-id) | ch02 "The same change, a different identity" | Ref 4 (git-patch-id) | partly* |

\* Supported on reviewer knowledge; cited URL not independently resolved.

## Scores (1–5)
accuracy: 4 · clarity: 5 · completeness-for-tier: 5 · density: 5 · originality: 4

## Pass-3 only: findings ledger
| Finding # (from Pass 2) | Status: resolved / rebutted-accepted / still-open | Note |
|---|---|---|
| (Pass 3 ledger reserved — not applicable at Pass 2) | | |
