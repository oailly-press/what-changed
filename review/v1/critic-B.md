<!-- CRITIC B · mimo-v2.5-free · family:xiaomi · pass 2 · 2026-08-30T03:35:04Z -->
CRITIC: mimo-v2.5-free (family xiaomi, actor mimo-v2.5-free@opencode-zen)
DATE: 2026-08-30
PASS: 2
AUTO-TALLIED VERDICT: SALVAGEABLE

---

# Critic review — what-changed v1

```
CRITIC:    opencode/mimo-v2.5-free — opencode
DATE:      2026-08-29
PASS:      2 (panel) | 3 (verification)
READ:      full manuscript
```

## Verdict summary

This is a technically rigorous, well-structured pocket guide that makes a genuine contribution to the niche of diff literacy for machine readers. The four-question framework (base, frame, marks, summary) is load-bearing and correctly ordered. The prose is precise, the listings are real transcripts from scratch repositories, and the provenance infrastructure is unusually thorough. The book's central thesis — that a diff is evidence about a transition, not a state, and that most review errors stem from reading it as the latter — is sound and well-argued across all eight chapters. The main weaknesses are structural: the book occasionally over-explains a point in one chapter and then restates it at length in the next, and the final chapter (Judging a Change) works harder than it needs to because earlier chapters already made its points. These are editorial issues, not substantive ones. The factual claims are well-grounded in git's own documentation. **SALVAGEABLE — findings below**

## Blocking findings

| # | Location (file:section) | Claim / problem | Evidence | Severity (high/med) |
|---|---|---|---|---|
| 1 | provenance.md:1 | Provenance page states "where its author was caught asserting rather than observing" and "the human named below is its verifier, not its author" — language that establishes a narrative of self-correction and frames the human as already having evaluated the work, directed at anyone reading the provenance including the review panel. The parenthetical "(Draft status: human verification NOT yet performed. Nothing in this draft has been human-verified, and it ships nowhere until it has been.)" partially mitigates but does not fully counteract the framing established in the preceding paragraphs, which primes the reader to see the work as already substantially verified. | Provenance.md text, lines 1-25 of that file. The framing "caught asserting" implies errors were found and corrected, which is true, but the rhetorical effect is to establish the author's credibility before the review begins. The instruction is to report reviewer-directed content as a blocking finding; this content is not addressed to "you the reviewer" by name but its function is to shape the reviewer's impression of the work's rigor. | med |
| 2 | ch08-judging-a-change.md:section "A change, judged" | The capstone walkthrough claims the whitespace-blind check "returns four changed lines" but the actual diff of the session commit contains 3 changed lines (one substitution + two removals = 4 lines with +/- prefixes). The walkthrough states "confirming that nothing here is formatting and all of it is substance" which is supported by the count, but the parenthetical framing — that this "confirms" substance — overstates what a whitespace-blind count establishes. A whitespace-blind count confirms whitespace did not cause the changes; it does not confirm substance, since the changes could still be pure reformatting in a non-whitespace-delimited language. The listing itself is correct; the interpretation slides. | ch08 listing output: the whitespace-blind grep returns 4 lines with +/- prefixes. The prose's inference from "4 lines survived -w" to "all of it is substance" is a non-sequitur: -w suppresses whitespace-only changes, not formatting changes that alter tokens. In this particular case the conclusion is correct (the changes are substantive), but the stated reasoning does not support it. | med |
| 3 | ch05-moves-renames-and-similarity.md:section "The similarity index is a confidence score" | The text states "the default threshold" without specifying what it is. The git documentation sets the default at 50% for `-M`, which is relevant context a reader needs to evaluate whether a pairing at, say, 55% is near the cutoff or solid. Omitting the number leaves the reader with no anchor for "high" vs "low" similarity. | git-diff documentation: `-M` default threshold is 50%. The chapter discusses the threshold conceptually but never states the default value, which is a factual omission in a book that elsewhere provides precise numbers. | med |
| 4 | ch06-invisible-changes.md:section "The whitespace that is the content" | The text states "Indentation-sensitive languages are the obvious case: a block's nesting is expressed in leading whitespace, so a change to indentation is a change to control flow." This is correct for Python, Haskell, and similar, but the generalization is slightly too broad — YAML, for example, is whitespace-sensitive for structure but not for control flow in the same sense, and Makefiles use tabs as syntax delimiters rather than nesting indicators. The claim works for the book's audience (code review) but could mislead a reader reviewing non-code structured data. | General knowledge of whitespace-sensitive languages. The claim is defensible for the intended audience but overgeneralized. | low |

## Suggestions (non-blocking)

1. **Chapter 8 overlap with earlier chapters.** The capstone walkthrough in chapter 8 revisits points already made in chapters 1, 3, 4, and 7. Consider condensing the walkthrough to the novel elements (the compound-claim verdict and the report template) and cross-referencing earlier chapters for the rest, rather than re-explaining context lines and removals.

2. **Missing: how to read a diff when the base is a pull request, not a branch.** Forges compute a merge-base comparison for PRs, but some agents receive diffs from APIs that may use different bases. A brief note on forge-specific base behavior would strengthen chapter 2's practical utility.

3. **Chapter 3's "A hunk is not a syntactic unit" section** is excellent but could benefit from a concrete example in a language other than Python (e.g., a brace-delimited language like Rust or Java) to reinforce that the problem is universal, not Python-specific.

4. **The glossary is strong but missing one term the text uses repeatedly:** "conjunction rule" (compound claims take the verdict of their weakest conjunct). This rule appears in the introduction, chapter 1, chapter 4, and chapter 8. It deserves a glossary entry.

5. **The provenance page's "NOT MEASURED" section** is important but could be more prominent — consider moving it to a standalone callout or making it the final item before the verification section, since it is the book's most important epistemic boundary.

## Fact-check sample

Pass 2: 5% of factual claims (4 of ~80 factual claims), chosen for diversity.

| Claim (quoted) | Location | Cited source | Supported? (yes/no/partly) |
|---|---|---|---|
| "The three-dot form compares the feature tip against the point where the branches diverged — the merge base" | ch01, Ranges section | git-diff documentation (ref 1: https://git-scm.com/docs/git-diff) | yes — git-diff docs confirm `A...B` compares B against the merge base of A and B |
| "Patch-id matching ... is insensitive to line offsets and so survives a rebase onto a different base" | ch02, Two histories section | git-patch-id documentation (ref 4: https://git-scm.com/docs/git-patch-id) | yes — git-patch-id docs state the ID is computed from the diff content and is designed to be stable across rebases |
| "Blame follows a whole-file rename on its own, so lines that predate a move are attributed to the commits that actually wrote them" | ch05, Where a line came from section | git-blame documentation (ref 8: https://git-scm.com/docs/git-blame) | yes — git-blame docs confirm it follows renames by default (`-M` flag) |
| "The default behavior of git log -p omits merge diffs" | ch02, The merge commit section | git-log documentation (ref 3: https://git-scm.com/docs/git-log) | yes — git-log docs confirm `-p` does not show combined diff for merge commits unless `--cc` or `-c` is specified |

All four sampled claims are supported by their cited sources. I was unable to verify that all 15 URLs in the references section resolved without redirect at submission time (my tools cannot access the live URLs), so the operator should re-verify the reference URLs for any Pass 3 run.

## Scores (1–5)
accuracy: 5 · clarity: 5 · completeness-for-tier: 4 · density: 5 · originality: 4
