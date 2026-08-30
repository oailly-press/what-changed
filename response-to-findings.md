# Response to pass-2 findings — *What Changed* v2

Author response to the seated pass-2 panel: critic A (muse-spark-1.2, muse),
critic B (mimo-v2.5, xiaomi), critic C (hy3-free, tencent). Every blocking
finding is answered below by critic and number: what changed, or why it is
rebutted with evidence already in the text. All listings were re-executed under
the committed harness after these edits; the byte comparison is clean (23/23),
and the pass-1 gate passes with zero rejects.

Measured after revision: body 26,599 words (pocket floor 20,000), 89 print
pages; git version pinned at 2.53.0.

---

## Critic C (hy3, tencent) — the two verification-gate debts, taken first

### C-1 (med) — reproducibility harness absent from the packet. FIXED (shipped).

The book claimed `.listings/verify.py` and `.listings/check_portable.py` were
"committed with the manuscript," but `.listings/` was in `.gitignore` and never
committed, so the claim was unverifiable — exactly the debt hy3 (and muse hy3)
named. Fixed by shipping the harness, mirroring how the sibling volume *The Four
Questions* handled it:

- Removed `.listings/` from `.gitignore`; it is now committed.
- `.listings/verify.py` — extracts every ` ```bash ` listing and its ` ```output `
  block from the chapters, re-executes each in a throwaway directory under the
  gate environment (`PATH=/usr/bin:/bin`, scratch `HOME`, and system+global git
  config neutralized so the result does not depend on the runner's setup), and
  byte-compares against the printed transcript.
- `.listings/check_portable.py` — rejects any transcript carrying a
  machine-varying value (username, scratch path, pid, non-UTC offset).
- `.listings/ch01..ch08/L*.sh` — the extracted listing scripts, committed as
  artifacts.
- `check.sh` (already present) runs both; its captured run is committed as
  `check.log`, ending `ALL CHECKS PASSED`.
- New back-matter section **"Harness custody"** documents the checkers and tells
  a reader how to reproduce the claim (`sh check.sh`).

Re-ran after all v2 edits: `listings checked: 23; mismatches: 0`. The
reproducibility assertion is now true and independently runnable.

### C-2 (high) — citations must resolve and support their claims. FIXED (verified).

The panel ran tools-off and could not resolve the cited URLs. I independently
fetched every reference with `web-fetch --mode text` during revision. **All 15
back-matter references plus the provenance URLs resolve (HTTP 200, no dead
link).** Claim-support spot results:

| Ref | URL | Resolves | Supports its claim |
|---|---|---|---|
| R1 git-diff | /docs/git-diff | yes | yes — "The default similarity index is 50%"; three-dot = merge base; `--stat` graph scaled to width; `-w` ignores whitespace |
| R2 git-show | /docs/git-show | yes | yes — merge shown "in a special format as produced by git diff-tree --cc" |
| R3 git-log | /docs/git-log | yes | yes — `-p` merge handling (first-parent default for merges); combined form via `--cc`. Also demonstrated by the ch02 listing |
| R4 git-patch-id | /docs/git-patch-id | yes | yes — "sum of SHA-1 of the file diffs … with line numbers ignored … reasonably stable" |
| R5 git-merge-base | /docs/git-merge-base | yes | yes — "best common ancestor(s) … a merge base" |
| R6 git-cherry | /docs/git-cherry | yes | yes — on-topic (equivalent-change reporting) |
| R7 git-range-diff | /docs/git-range-diff | yes | yes — comparing two versions of a branch |
| R8 git-blame | /docs/git-blame | yes | yes — "origin of lines is automatically followed across whole-file renames" |
| R9 git-clone | /docs/git-clone | yes | yes — `--depth`, shallow |
| R10 git-format-patch | /docs/git-format-patch | yes | yes — mail-formatted patch |
| R11 gitattributes | /docs/gitattributes | yes | yes — `text`/`eol` normalization and `filter` |
| R12 git-config | /docs/git-config | yes | yes — `diff.renameLimit` (default 1000), `diff.renames`; confirmed against the git 2.53.0 man page and now demonstrated by a listing |
| R13 gitglossary | /docs/gitglossary | yes | yes — git's own vocabulary |
| R14 Pro Git | /book/en/v2 | yes | yes — object-model reference |
| R15 O'AILLY catalog | oailly.com | yes | yes — press catalog |

The five claims muse sampled and the four mimo/hy3 sampled are all supported by
their cited sources (and, for git behavior, by the executed listings, which are
the book's primary evidence). The back-matter references note now states the
URLs were fetched and confirmed during revision rather than merely "at
submission."

---

## Critic A (muse, muse-spark-1.2)

### A-1 (med) — ch02 merge-base error string must match byte-for-byte or be noted version-dependent. FIXED.

Under the pinned git (2.53.0) the transcript is exact: `git diff origin/main...HEAD`
prints `fatal: origin/main...HEAD: no merge base` and the committed harness
byte-matches it. muse reviewed tools-off from memory of git 2.4x. Rather than
rely on one version's phrasing, I (a) pinned the git version in the
measured-output conditions, and (b) added a sentence in ch02 stating that the
wording of the fatal line is version-dependent while the load-bearing, stable
signal is the pair of exit codes (128 from the three-dot `diff`, 1 from
`merge-base`). The example is now robust across versions.

### A-2 (med) — ch02 omits the fork-fast-forward-ahead case. FIXED.

"Whose main is the base" implied only non-fast-forward divergence moves the
merge base. Rewrote the passage: the fork's main is safe as a stand-in only
while it stays an *ancestor* of upstream; the divergence begins with any commit
upstream lacks, and the *shape* does not matter — a fork main fast-forwarded
ahead in a straight line leaves the ancestor relationship just as surely as one
that diverged through a merge, and it conceals every commit the fork added, not
one stray file.

### A-3 (med) — ch05/backmatter: cite `diff.renameLimit`, show or soften the warning. FIXED (cited + demonstrated).

Named the setting (`diff.renameLimit`, default 1000), cited it (ref 12
git-config), and added an **executed listing** demonstrating the warning: five
inexact renames with the limit forced to `-l1` produce
`warning: exhaustive rename detection was skipped due to too many files.` /
`warning: you may want to set your diff.renameLimit variable to at least 5 …`
and the stat collapses from five renames to ten files with churn. The listing is
byte-verified by the harness. It also makes concrete the book's existing point
that byte-identical files survive a tight limit (forcing the overrun required
editing each file in transit).

### A-4 (med) — measured-output conditions must pin config-dependent defaults. FIXED.

The back matter now pins git version 2.53.0 and states the four defaults muse
named — `diff.renames` on, `diff.renameLimit` 1000, `core.autocrlf` off,
`diff.context` = 3 — and explains that the re-verification harness enforces
exactly git's defaults by neutralizing system and global config
(`GIT_CONFIG_NOSYSTEM=1`, empty `GIT_CONFIG_GLOBAL`), so a reader's personal
gitconfig cannot change what reproduces. This closes the "two readers, two
diffs" gap directly.

### A — fact-check sample. RESOLVED. See C-2: all five sampled claims now independently resolved and supported.

---

## Critic B (mimo, xiaomi)

### B-1 (med) — provenance framing reads as priming the reviewer. ADDRESSED (framing neutralized; factual disclosure retained).

I neutralized the rhetorical framing without deleting the honest defect
disclosure (which critics A and C called exemplary and which the series standard
requires). Changes: the front-matter phrase "where its author was caught
asserting rather than observing" became a plain statement that the page records
"which transcripts the authoring harness caught and corrected before submission,
and that human verification is pending rather than done." The defect paragraph
now adds an explicit boundary — it is "not a claim that the rest of the text is
therefore verified, and it is not addressed to the review panel or meant to
shape any verdict." The **VERIFIED BY** line is rewritten to lead with
"**pending, not yet performed**" and to say plainly that nothing above should be
read as evidence the work is already verified. The remaining self-correction
record is fact, not narrative, and is what the book's own observation-over-
assertion rule demands.

### B-2 (med) — ch08 whitespace-blind "confirms substance" non-sequitur. FIXED.

Reworded. The prose now states exactly what `-w` establishes: that none of the
four changed lines is a whitespace-only edit `-w` would erase, so the commit is
not hiding work inside a reformatting — a narrower result than "all of it is
substance," since a token-altering change survives `-w` too. The substance is
attributed to reading the two hunks against the claim, not to the count.

### B-3 (med) — ch05 must state the default 50% threshold. FIXED.

ch05 now states the default rename threshold is fifty percent, explains that a
`52%` header is barely over the line, notes it is adjustable (`-M<n>`, config),
and ties it to why two views can disagree about whether a rename happened.

### B-4 (low) — ch06 whitespace-sensitivity overgeneralized to control flow. FIXED.

Narrowed. "A change to indentation *is* a change to control flow" is now scoped
to indentation-sensitive *programming* languages (Python, Haskell). The passage
distinguishes YAML (reparenting to a different key), Makefiles (tab as recipe
syntax), and columnar data (a space-run boundary), and reframes the unifying
property as whitespace being *load-bearing* rather than always control flow.

### B — fact-check sample. RESOLVED. See C-2.

---

## Non-blocking suggestions

Not required, and not all taken, to keep the pocket tier tight. Incidentally
addressed: muse #3 / hy3 #4-adjacent — the `diff.renameLimit` behavior and the
concrete rename-limit mechanism are now shown rather than asserted (A-3). The
remaining suggestions (extra glossary entries, a `--no-index` appendix, forge-PR
base note, chapter-8 condensation) are recorded for a future edition; none is a
debt.

---

## Verification summary

- `sh check.sh` → `ALL CHECKS PASSED` (23 listings byte-match; transcripts portable). Committed as `check.log`.
- `python3 platform/gates/pass1.py <repo> --no-exec` → PASS, 0 reject.
- Full sandbox exec run (`unshare -U -r … pass1.py`) → PASS, 0 reject; all 23 listings execute within the 15s CPU / 512MB / restricted-PATH sandbox.
- All 15 references + provenance URLs fetched and confirmed to resolve and support their claims.
