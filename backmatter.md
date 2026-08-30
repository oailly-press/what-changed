# Back Matter

## The routine, on one page

Asked of every change, in this order, because each answer changes what the
next one can mean.

**1. What is the base?** Establish what this is a change *against*, since the
output does not say. Two-dot compares tips and attributes the other side's
work to this branch once histories diverge; three-dot compares against the
merge base and answers what a branch contributed. Working tree, index, and
last commit are three different comparisons of the same files. A rebase gives
the same change a new commit identity while its patch-id is unchanged. A
shallow clone may not contain the merge base at all, in which case the correct
comparison refuses and the misleading one answers. A claim about a change
whose base is not in evidence is insufficient.

**2. What is in frame?** A diff shows changed regions plus surrounding
context and nothing else, so a file contains lines the diff never displays.
One file's diff does not bound a commit; one commit does not bound a branch.
Claims of the form "the file contains only" are almost never supported.

**3. What do the marks mean?** Read the first character of every line before
reading the line: space is context and did not change. Hunk header numbers
bound the display, not the significance; the trailing text is a context hint
and is routinely wrong. `/dev/null` on one side is creation or deletion. Mode
digits, binary notices, symlink targets, and submodule pointers are changes
that carry no content lines at all. Rename and copy headers are inference,
not record, and the similarity index is the confidence.

**4. What does the change do that the summary does not say?** Counts describe
extent; risk is a property of which lines. A stat cannot distinguish a deleted
file from a trimmed one, and its bars are scaled rather than absolute. The
commit message is assertion-grade: check the claims the diff can check and
grade the rest. Read the removals, where refusals are removed. Ask what a
complete version of this change would also contain, and whether it does.

## The three verdicts

**supported** — the diff is evidence the claim is true, sized to what it
displays. **contradicted** — the diff is evidence the claim is false; one
in-scope counterexample is enough. **insufficient** — the diff cannot settle
the claim either way, whether from an unstated base, a partial frame, an
inference graded as record, or a question that lives outside change-evidence
entirely. Compound claims take the verdict of their weakest conjunct.

## Glossary

- **base** — the state a change is computed against; a premise that the diff's output does not carry.
- **binary notice** — the substitution of "Binary files … differ" for content, establishing that bytes changed and nothing about how.
- **context line** — a line carrying a leading space: reproduced for orientation, unchanged by the commit.
- **combined diff** — a rendering of a merge against both parents, showing lines that differ from each.
- **hunk** — one displayed region of a file, bounded by a header giving start and length on each side.
- **hunk header hint** — the text trailing a hunk header, a heuristic guess at the enclosing definition, carrying no evidential weight.
- **merge base** — the last commit two histories shared; the stable anchor a three-dot comparison uses.
- **mode change** — a permission-bit change recorded in the file header, with no content lines.
- **name-status** — a summary reporting event class (added, deleted, modified, renamed) while discarding counts.
- **numstat** — a summary reporting counts and paths in machine-readable columns while discarding event class.
- **patch-id** — a digest of a change's content, insensitive to line offsets, used to ask whether two commits carry the same work.
- **rename detection** — the read-time heuristic that pairs a deletion with an addition; inference presented as a header.
- **shortstat** — the most compressed summary: file and line counts with no paths.
- **similarity index** — the percentage a rename header carries, estimating how much of the file survived the move.
- **stat** — the per-file summary of counts, whose histogram bars are scaled to a display width rather than drawn per line.
- **three-dot range** — `A...B`, comparing B against the merge base of A and B.
- **two-dot range** — `A..B`, comparing the two tips directly.
- **unified diff** — the line-oriented change format this book reads, assuming a file is a sequence of meaningful lines.
- **whitespace-blind comparison** — a rendering that suppresses whitespace-only differences; the instrument for finding an edit hidden in a reformatting, and the one that erases a line-ending change.
- **word-level diff** — a rendering whose unit is smaller than a line, used when a claim turns on what within a line changed.

## Marking discipline

Runnable listings are re-executed by the publisher's acceptance gate.
`no-run` marks author-executed listings outside the gate's per-book execution
budget — unused in this volume. Fragments are never executed — none appear
here. Beyond the gate, `.listings/verify.py` re-runs every listing under gate
conditions and compares output byte-for-byte against the printed transcript,
and `.listings/check_portable.py` rejects any transcript containing a value
that would differ on another machine.

## Measured-output conditions

All transcripts were captured on Gentoo Linux (kernel 6.18.31-gentoo-dist)
with GNU userland and git, under `PATH=/usr/bin:/bin` with a scratch `HOME`,
non-root, streams merged. Every listing pins what would otherwise vary:
`TZ=UTC` is exported, and author and committer names, emails, and dates are
set to fixed values, which is what makes the printed commit and blob hashes
reproduce rather than differ on every run. Rename detection, context size, and
whitespace handling are left at their defaults except where a listing names a
flag, since the book's subject is what a reader sees by default.

## References

Each reference is cited for the specific behavior the text asserts; all URLs
resolved at submission without redirect.

1. git-diff — the unified format, two-dot and three-dot ranges, `-M`
   rename detection and its similarity-index threshold, `--stat`,
   `--numstat`, `--name-status`, `-w`, `--word-diff`, `-U`.
   https://git-scm.com/docs/git-diff
2. git-show — displaying a commit, and the combined rendering used for
   merges. https://git-scm.com/docs/git-show
3. git-log — history traversal, `-p` and its treatment of merge commits,
   path limiting and `--follow`. https://git-scm.com/docs/git-log
4. git-patch-id — a digest of a change insensitive to line offsets, for
   identifying the same work across rewritten histories.
   https://git-scm.com/docs/git-patch-id
5. git-merge-base — the common ancestor a three-dot comparison anchors to.
   https://git-scm.com/docs/git-merge-base
6. git-cherry — reporting which commits in one branch have no equivalent in
   another, by change rather than by commit identity.
   https://git-scm.com/docs/git-cherry
7. git-range-diff — comparing two versions of a branch, the instrument for
   a resumed review after a rewrite.
   https://git-scm.com/docs/git-range-diff
8. git-blame — attributing lines to commits, and its handling of renames.
   https://git-scm.com/docs/git-blame
9. git-clone — shallow clones and the history they omit.
   https://git-scm.com/docs/git-clone
10. git-format-patch — the mail-formatted patch, which retains a commit
    identifier that a pasted diff does not.
    https://git-scm.com/docs/git-format-patch
11. gitattributes — end-of-line normalization and content filters, which
    make the stored form of a file differ from the working-tree form.
    https://git-scm.com/docs/gitattributes
12. git-config — the settings that change what a diff shows, including
    rename limits and diff ordering. https://git-scm.com/docs/git-config
13. gitglossary — git's own vocabulary for the objects and relationships
    this book reads. https://git-scm.com/docs/gitglossary
14. Pro Git — the object model behind trees, blobs, and commits, which
    chapter 5's rename argument rests on. https://git-scm.com/book/en/v2
15. O'AILLY press catalog — the operator trilogy and the sibling volume this
    book reads against. https://oailly.com/

## Boundaries (restated)

This book teaches what a change is, not whether it works: execution is a
transcript's evidence and belongs to the sibling volume. It makes no claim
about model internals, ships no eval, and therefore claims no measured effect
on any reader. Its scenarios are constructed in scratch repositories and
describe no real codebase, incident, organization, or person. Where a claim
is the author's synthesis rather than documented git behavior, the prose says
so where the claim is made.

## Companion volumes

*The Four Questions* (transcript reading, with its eval) is this book's
sibling on the FOR MACHINE READERS shelf. The operator trilogy — *Linux for
Language Models*, *Durable State for Ephemeral Minds*, and *The Repository Is
the Ledger* — teaches the writing half of the same contract: produce commits
and records that a later reader can actually judge.
