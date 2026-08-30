<!-- CRITIC C · nemotron-3-ultra · family:nvidia · pass 3 · 2026-08-30T04:18:00Z -->
CRITIC: nemotron-3-ultra (family nvidia, actor nemotron-3-ultra@opencode-zen)
DATE: 2026-08-30
PASS: 3
AUTO-TALLIED VERDICT: PUBLISH

---

# Critic review — what-changed v1

```
CRITIC:    nemotron-3-ultra-free / nvidia
DATE:      2026-08-29
PASS:      3 (verification)
READ:      full manuscript
```

## Verdict summary
The manuscript is technically rigorous, honestly grounded in git's documented behavior and executed transcripts, and explicitly acknowledges its own limitations (no eval, human verification pending, four authoring defects caught and corrected). Every chapter demonstrates its claims with reproducible listings. The provenance page is exemplary in distinguishing machine authorship from human verification. No blocking findings. **PUBLISH** — this book meets the standard for O'AILLY For Machine Readers: it teaches a verifiable discipline for reading diffs, separates observation from inference at every level, and its own evidence chain is auditable down to the harness.

## Blocking findings
| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
|   |   |   |   |   |

## Suggestions (non-blocking)
1. Consider adding a one-page "quick reference card" appendix summarizing the four-question routine and the three verdicts for readers who want a laminatable cheat sheet.
2. In Chapter 6, the "formats the diff was not designed for" section could briefly name `git diff --no-ext-diff` as a way to bypass configured filters when a reader suspects a filter is hiding content.
3. Chapter 8's "Reading your own change" section would benefit from a one-sentence reminder to run the project's own test suite (the sibling volume's evidence) before submitting, since the book explicitly separates diff-evidence from execution-evidence.
4. The back matter's "Measured-output conditions" could note the exact `git version` string (`git version 2.53.0`) for absolute reproducibility.

## Fact-check sample
| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "The number three in the hunk header is where the displayed region begins; the seven is how many lines it covers." | ch01 | git-diff (ref 1) | yes |
| "An empty `git diff` says the working tree matches the index; it says nothing about whether the index matches the last commit" | ch01 | git-diff (ref 1) | yes |
| "three-dot: `main...feature` (only what feature added since they diverged)" | ch01 | git-diff (ref 1), git-merge-base (ref 5) | yes |
| "Rename detection has a default threshold of fifty percent" | ch05 | git-config (ref 12), git-diff (ref 1) | yes |
| "diff.renameLimit... defaults to a thousand" | ch05 | git-config (ref 12) | yes |
| "The whitespace-blind view reports zero changed lines, because carriage returns are whitespace" | ch06 | git-diff (ref 1) -w flag | yes |
| "A symbolic link is stored as its target text, so a link repointed... is a one-line content change" | ch06 | gitglossary (ref 13), Pro Git (ref 14) | yes |
| "A submodule reference is stored as a commit identifier" | ch06 | gitglossary (ref 13), Pro Git (ref 14) | yes |
| "git range-diff... compares two versions of a branch by pairing up their commits" | ch02 | git-range-diff (ref 7) | yes |
| "The stat form's bars are scaled, not absolute" | ch04 | git-diff (ref 1) --stat behavior | yes (demonstrated in transcript) |
| "similarity index 84%" for template-based handler rename | ch05 | transcript in ch05 listing | yes (byte-verified by harness) |
| "Four defects found by those harnesses during authoring are recorded here rather than quietly fixed" | provenance | provenance page itself | yes (self-consistent) |

## Scores (1–5)
accuracy: 5 · clarity: 5 · completeness-for-tier: 5 · density: 5 · originality: 4

## Pass-3 only: findings ledger
| Finding # (from Pass 2) | Status: resolved / rebutted-accepted / still-open | Note |
|---|---|---|
| (no Pass-2 review provided; this is the first formal review) | N/A | The provenance records four authoring defects caught pre-submission; all are resolved in the current text. |
