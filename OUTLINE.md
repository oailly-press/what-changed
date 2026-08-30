# What Changed — proposal, evidence map, and status

**Working title:** What Changed
**Subtitle:** Reading diffs, for the machines that review them
**Shelf:** FOR MACHINE READERS (no eval ships with this volume — see below)
**Tier:** Pocket (~25,500 measured words, 8 chapters)
**Proposed book-id:** rogerai-labs--what-changed
**Status:** COMPLETE, gate-passing, NOT SUBMITTED. 8/8 chapters (25,975
measured words), local pass-1 PASS 0 reject / 0 warn on first run, 22
listings executed and byte-verified against their printed transcripts,
matter files and manifest done. Held behind *The Four Questions* per the
one-manuscript-in-pipeline rule — submit when that book clears the pipeline.
No eval ships with this volume and none is claimed; the seed diff fixtures
under eval/ remain a staged experiment, not a shipped corpus.
**Mascot request (draft):** caddisfly larva — it builds its case out of
whatever the streambed hands it, so the case is a legible record of every
place the animal has been: history you read off the object itself. Larval
stage of a metamorphic insect, per the shelf's taxon; not an ant, so clear
of the founder-reserved genus.

## The book-shaped hole

*The Four Questions* taught machines to judge **transcripts** — evidence
about what a command did. The other enormous evidence class an agentic
reader consumes is the **diff**: evidence about what a change does. Models
review pull requests, summarize commits, decide whether a patch is safe, and
answer "what did this change?" dozens of times a session — and they misread
diffs in ways as catalogable as the transcript failures, and less studied.
The diff has its own grammar (prefixes, hunk headers, context lines,
rename detection, similarity indices), its own summaries that routinely
disagree with their own detail (`--stat`), and its own hard boundary: a diff
shows a *transition*, never a *state*, so a reader that answers state
questions from diff evidence is answering out of scope no matter how
carefully it read.

The claim is the sibling of volume one's: a curriculum of worked diff
misreadings, taught with real captured diffs and a four-question routine
adapted to change-evidence, is *designed* to improve a reader-model's
accuracy and calibration on diff-judgment cases. As shipped, that
improvement is neither measured nor claimed — see the eval note below.

## Reader

Primary: a language-model agent that reads diffs — reviewing, summarizing,
or gating changes. Secondary: the person who supervises such agents and has
to decide how much of a review to trust. Assumes the ability to read a
unified diff; assumes no git internals, which chapter 1 supplies as needed.

## The spine

Four questions asked of every diff, in order:
**(1) What is the base?** — against what is this a change?
**(2) What is in frame?** — which files, which hunks, and what was elided?
**(3) What do the marks mean?** — prefixes, context, headers, renames,
modes, binaries.
**(4) What does the change do that the summary does not say?**

1. **A Diff Is Not a State** — the founding boundary: transitions vs states;
   why "the file now contains X" is usually insufficient from a diff alone;
   two-dot and three-dot ranges; staged vs committed vs pushed.
2. **The Base You Did Not Choose** — merge-base semantics, diffing against
   the wrong reference, rebases and force-pushes that change what a diff
   means, and the review that silently includes someone else's work.
3. **Marks and Their Meanings** — the unified format as a grammar: `+`/`-`
   vs context lines (the commonest misread of all: unprefixed lines are
   *unchanged*), hunk headers and their ranges, the function-context hint
   that is a heuristic and not a promise.
4. **The Summary That Disagrees With Itself** — `--stat` and its cousins:
   line counts that hide semantics, "2 deletions" that remove a guard,
   truncated file lists, and why a reviewer who reads only the stat has read
   an assertion, not the change.
5. **Moves, Renames, and Similarity** — rename detection as inference, not
   observation; a move that hides an edit; `-M`/`-C` thresholds; the diff
   that shows a hundred added lines and zero new logic.
6. **Invisible Changes** — whitespace, line endings, encoding, permissions,
   binary files, generated artifacts, and the substantive edit buried in
   reformatting; what `-w` conceals while it clarifies.
7. **Deletions Are Changes Too** — the asymmetry of attention: readers grade
   additions and skim removals, where guards, checks, tests, and error paths
   quietly leave; the absence check adapted to change-evidence.
8. **Judging a Change** — the routine composed; verdicts (supported /
   contradicted / insufficient) on claims about changes; what a diff can
   never testify to (intent, runtime behavior, completeness, dependants);
   sizing a claim; reading your own change; and where this volume and its
   sibling meet.

## The eval — designed, not shipped

This section records the original design and its current status honestly,
because the manuscript makes no measured claim and the two must agree.

**Status: NOT SHIPPED.** No corpus, scorer, or treatment page is part of this
volume, and neither the front matter, the back matter, nor the provenance
claims any measured effect on a reader. The book's value proposition as
submitted is the curriculum and its verified transcripts, not a measurement.

**What exists.** Eight seed fixtures under `eval/`, captured by making real
commits in scratch repositories (`eval/build/seed.py`), retained as a staged
experiment. They are not a corpus: too few, unbalanced, and never held out
against the finished manuscript.

**The design, if it is ever built.** Given (context, diff, claim), emit
`supported` / `contradicted` / `insufficient` plus a 0-100 confidence — the
same contract as *The Four Questions*, so its scorer is reusable and the two
corpora are comparable. Every diff real; conditions no-treatment / compact /
full-book, three runs each; accuracy overall and per family, Brier on
confidence, headline delta against the noise floor, majority-class baseline
published; hold-out enforced by a checker rather than asserted. Diffs are
content-addressed, so with pinned identity and dates the fixtures reproduce
byte-for-byte anywhere, which would make them unusually stable.

The design's key case is already proven inside the book: a commit whose
`--stat` reads `1 file changed, 2 deletions(-)` under the message "simplify
check" removes a token-validation guard. The stat is true and the claim built
on it is false.

## Boundaries

No claims about model internals; no claim of transfer beyond diff judgment;
no claim of any measured effect, since this volume ships no eval. Git's
documented behavior is cited from
git's own documentation at claim time, per the series' version-floor
discipline, and rename detection is described as the heuristic it is.

## Contamination note

Sibling to *The Repository Is the Ledger*, which taught operators to
*produce* legible commits from the writing chair; this book teaches readers
to *judge* them. Shares a subject with that volume and no material: the
catalog-overlap gate enforces the freshness, and the reading-chair framing
is the same inversion volume one performed on the trilogy's first book.
