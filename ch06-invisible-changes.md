# Chapter 6 — Invisible Changes

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## Why this class is worth a chapter

Before the cases, the reason they belong together. Every other chapter in this
book concerns a change the reader could see and misjudged: context mistaken
for change, a base misunderstood, a summary trusted past its evidence. Those
failures are corrected by reading more carefully. This chapter's failures are
not, and that difference is what makes them worth isolating.

When the difference between two versions of a line is a character that renders
as nothing, no amount of attention recovers it. When a change lives in a mode
bit, in a submodule pointer, or in the bytes of a binary, there is no line to
attend to. When the substantive edit is one hunk in eight hundred mechanical
ones, careful reading of all eight hundred is exactly the strategy that
exhausts the reader before the hunk that mattered. In each case the remedy is
a different *instrument*, not more effort with the same one, and knowing which
instrument to reach for requires knowing the class exists.

That is also why this chapter's failures survive experienced reviewers. A
reader who has learned to distrust summaries and check bases will still stare
at two identical-looking lines and conclude the diff is noise, because nothing
in their training says *stop looking and start measuring*. The classes below
are catalogued so that the shape of each becomes recognizable in the two or
three seconds before a reader decides there is nothing here.

## Changes you cannot see by looking

Every chapter so far has assumed that reading a diff carefully is possible in
principle — that the marks, the base, and the summary can each mislead, but
that the lines themselves are legible. This chapter takes the cases where they
are not: changes carried in characters that render as nothing, in metadata
that carries no lines at all, and in volume so large that a real edit hides
inside it. What unites them is that careful reading does not help, because the
difference is not visible on the screen.

## The edit inside the reformatting

Start with the most common instance, which is also the most exploitable.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > limits.conf <<'EOF'
max_retries=3
timeout_seconds=30
pool_size=10
burst_limit=100
EOF
git add -A && git commit -qm base
cat > limits.conf <<'EOF'
max_retries = 3
timeout_seconds = 30
pool_size = 10
burst_limit = 1000
EOF
git add -A && git commit -qm "normalize spacing in limits.conf"
echo "== how many changed lines does the plain diff show? =="
git show --format="" HEAD | grep -c "^[+-][^+-]"
echo "== the same commit, whitespace-insensitive =="
git show --format="" -w HEAD | grep -E "^[+-][^+-]"
```

```output
== how many changed lines does the plain diff show? ==
8
== the same commit, whitespace-insensitive ==
-burst_limit=100
+burst_limit = 1000
```

The commit says it normalizes spacing, and it does: four lines gain spaces
around their equals signs, producing eight changed lines in the plain
rendering. A reviewer checking the claim reads four before-and-after pairs
that differ only in whitespace, confirms the message, and approves.

One of those pairs is not like the others. `burst_limit` goes from 100 to
1000 — a tenfold increase to a rate limit — and in the plain diff it is the
fourth of four visually identical whitespace changes. The whitespace-blind
view isolates it in one command: everything that was only spacing collapses to
nothing, and what survives is the change that was never about spacing at all.

This is the chapter's central technique and it is worth stating as a rule:
**when a commit claims to be formatting, read it whitespace-blind, and treat
anything that survives as the real content of the commit.** The check costs
one flag. It converts a claim that is expensive to verify by reading — four
pairs here, four hundred in a real reformatting — into one that is nearly free.

Nothing here requires bad faith. Editors reformat on save, and a developer who
changed a limit and then saved a file has produced exactly this commit
honestly. The reader's problem is the same either way: the volume is doing the
hiding, and the message is directing attention away from the one line that
matters.

## When invisibility runs the other way

The same flag that reveals a hidden edit can conceal a real one, and the case
is worth seeing because it inverts the advice above.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "alpha\nbeta\n" > data.txt
git add -A && git commit -qm base
printf 'alpha\r\nbeta\r\n' > data.txt
git add -A && git commit -qm "touch data"
echo "== does the content look different? =="
git show --format="" HEAD | grep -E "^[+-][^+-]" | cat -v
echo "== byte counts before and after =="
echo "before: $(git show HEAD^:data.txt | wc -c)"
echo "after:  $(git show HEAD:data.txt | wc -c)"
echo "== whitespace-insensitive view =="
git show --format="" -w HEAD | grep -cE "^[+-][^+-]" || true
```

```output
== does the content look different? ==
-alpha
-beta
+alpha^M
+beta^M
== byte counts before and after ==
before: 11
after:  13
== whitespace-insensitive view ==
0
```

Every line of the file changed, and in an ordinary rendering the before and
after are indistinguishable: `alpha` was replaced by `alpha`. The `^M` visible
here is an artifact of asking for control characters to be shown; without that
request, a reviewer sees identical text on both sides of every pair and
reasonably concludes the diff is broken or the commit is empty.

The byte counts settle what happened: eleven bytes became thirteen, two extra
bytes for two carriage returns. The file's line endings changed from LF to
CRLF, which is a real change with real consequences — shell scripts that fail
to execute, hash mismatches against a published checksum, parsers that include
a stray carriage return in the last field of every record.

And the whitespace-blind view reports zero changed lines, because carriage
returns are whitespace. The flag that isolated the hidden edit in the previous
listing erases this one completely. Neither rendering is wrong; each answers a
different question, and a reader who runs only one of them will be confidently
wrong about one of these two commits.

The practical form: when a diff shows pairs that look identical, the
difference is in characters that do not render, and the instruments are the
byte count, a control-character-revealing view, or a hex comparison. Reaching
for those is fast once the possibility is in mind, and the possibility only
comes to mind if a reader knows this class exists.

## Why both flags are needed, and neither is a default

The two listings above establish something worth stating directly, because it
determines how a careful reader actually works: there is no single rendering
that shows every change. The plain diff hides an edit inside reformatting by
burying it among visually identical pairs. The whitespace-blind diff hides a
line-ending change by discarding exactly the bytes that changed. Each is the
other's blind spot, and a reader who has one habit has one blind spot.

The resolution is not to pick the better flag but to know which question each
answers, and to notice which question the claim under judgment requires. A
claim that a commit is *purely* formatting is a claim that the
whitespace-blind view is empty — so run it, and the claim is settled in a
second. A claim that two versions of a file are *identical* is a claim about
bytes, and the whitespace-blind view cannot support it, because it is designed
to ignore a category of byte difference. The instrument has to match the
predicate, and the predicates differ by more than they appear to.

There is a third rendering worth having in the repertoire for the same reason.
When both views disagree with intuition, comparing sizes settles it: a byte
count is indifferent to rendering, to whitespace conventions, and to what
characters happen to look like, which is why it appeared in the line-ending
listing as the line that ended the argument. Any time a reader finds
themselves staring at two lines that look the same and are printed as
different, the fastest path out is to stop looking and start counting.

## Changes that carry no lines

Chapter 3 showed a commit that changed two files and printed no content lines
at all: a mode bit removed, a binary replaced. That case belongs to this
chapter's family and deserves restating as a reading rule rather than a
curiosity.

File modes are content-free changes with operational consequences. Adding the
executable bit to a script is what makes it runnable; removing it is what
silently stops a deployment step. The change lives entirely in the header's
mode digits, so any review process that reads only `+` and `-` lines, and any
summary that reports only insertions and deletions, is blind to it.

Binary changes are content-free by construction: the format substitutes a
notice for the content. A reader can establish *that* an image, a compiled
artifact, a font, or a database fixture differs, and can establish nothing
about how. Claims about binary content are therefore insufficient from the
diff in essentially every case, and the honest report says so and names what
would settle it — a hash comparison against a known-good build, a rendering,
an extraction of the relevant field.

Two further members of this family are worth naming because they arrive
without ceremony. A symbolic link is stored as its target text, so a link
repointed from one path to another is a one-line content change that reads
like an edit to a tiny file and behaves like a change to which code runs. And
a submodule reference is stored as a commit identifier, so updating one shows
as a single line with two hashes — the smallest possible diff for what may be
an enormous change, since the entire history of another repository sits behind
that identifier.

## The whitespace that is the content

Everything above treats whitespace as noise to be seen past. In a family of
formats it is the opposite, and the same flag that clarifies elsewhere
destroys the evidence here.

Indentation-sensitive languages are the obvious case: a block's nesting is
expressed in leading whitespace, so a change to indentation *is* a change to
control flow. A line moved out of a conditional and a line whose indentation
changed are the same edit, and the whitespace-blind view reports nothing. The
same holds for structured formats whose nesting carries meaning, for
whitespace-delimited data where a column boundary is a run of spaces, and for
any file where trailing whitespace is significant to a parser downstream.

The consequence for the chapter's central technique is a boundary rather than
an exception. Whitespace-blind reading is the right instrument for finding a
substantive edit hidden inside a reformatting, and it is the wrong instrument
for judging whether a reformatting was safe, in exactly the languages where
reformatting is most likely to be unsafe. A reader who applies it uniformly
will one day approve a commit that moved a statement out of a loop, and the
diff will have said so plainly in a rendering they chose not to look at.

The practical rule is to let the file type set the posture. Where whitespace
is syntax, read the plain diff and treat every indentation change as a
candidate behavior change; where it is decoration, use the blind view to
separate the mechanical from the substantive. Knowing which kind of file is
in front of you is not a diff-reading skill, which is one more instance of
this book's recurring limit: the format supplies the evidence and the reader
supplies what it means.

## Encoding, normalization, and the character that is not the character

The last invisible class concerns characters that render alike and are not
alike. A file converted between encodings, a Unicode string normalized from
one composition form to another, a non-breaking space substituted for an
ordinary one, a Cyrillic character standing in for a Latin one that looks
identical: each produces a diff whose two sides are visually the same and
whose bytes differ.

Most instances are innocent — an editor's default changed, a copy-paste
carried a stray character — and the consequences are still real: an identifier
that no longer matches, a lookup that fails, a comparison that returns false
between two strings that print the same. A few instances are not innocent,
which is why the class is worth knowing rather than merely tolerating.

The reading discipline is the one this chapter has repeated. Visual identity
between a removed line and an added line is evidence that the change is not
visual, not evidence that there is no change. The diff has already told you
something changed by printing the pair at all; it is declining to tell you
what, and the reader's job is to ask with a sharper instrument rather than to
conclude the pair is noise.

## The repository can be configured to lie to you

One further source of invisibility sits below the diff entirely, in the
machinery that decides what git considers the file's content.

Line-ending normalization is the common case. A repository can be configured
to store one convention and check out another, so the bytes in the working
tree differ from the bytes in the object store by design. The effect on
reading is that a change may be visible locally and absent from the committed
diff, or the reverse, depending on which side of the conversion a reader is
standing. When a diff shows a line-ending change that nobody made, or fails to
show one that someone did, this machinery is the first place to look.

Filters that transform content on the way in and out have the same shape and
larger consequences. A repository can be set up so that a file is stored in
one form and appears in another — secrets scrubbed, large files replaced by
pointers, generated content collapsed. Where such a filter is configured, the
diff describes the stored form, and a reader reasoning about what the running
system loads is reasoning about the wrong artifact. The tell is usually a file
whose diff seems implausibly small for the change described, or a pointer-like
line where content was expected.

The reading discipline is modest, because a reader usually cannot inspect the
configuration of a repository they are reviewing at arm's length: hold the
possibility, and treat any surprising invisibility — a change that must have
happened and does not appear, or an appearance with no author — as a question
about the pipeline rather than about the author. Attributing a
normalization artifact to a person is a specific and avoidable
unfairness, and it happens most often to whoever committed on the platform
with the minority convention.

## Formats the diff was not designed for

The unified format assumes a file is a sequence of meaningful lines. Where
that assumption fails, the rendering degrades in ways worth recognizing,
because the degradation looks like an ordinary diff rather than like a
malfunction.

Minified and single-line files are the clearest case. A bundle, a compacted
data file, or a long generated declaration occupies one line, so any change to
it renders as that line removed and re-added in full. The diff is technically
complete and practically unreadable: the changed token is somewhere in
thousands of characters, and the line-based format has no way to point at it.
The word-level view from chapter 3 is the instrument here, and where the
content is machine-generated the better move is to leave the artifact alone
and read the source it was generated from.

Structured documents whose serialization is not stable have a subtler problem.
A file that a tool rewrites wholesale on every save — reordering keys,
renumbering identifiers, re-emitting embedded output — produces diffs whose
volume has no relationship to the semantic change. Two of these are worth
naming because they are ubiquitous: dependency lockfiles, where a
one-dependency bump can rewrite hundreds of lines of transitive pins, and
computational notebooks, where the stored document interleaves source, output,
and execution counters so that merely running a cell changes the file. In both
cases the reader's question — what actually changed in meaning — is answered
by a purpose-built comparison rather than by the line diff, and in the absence
of one the honest verdict about the semantic change is insufficient.

The general shape is the same across all of these. The diff is showing you a
faithful comparison of a representation, and your question is about what the
representation encodes. When the two diverge far enough, reading harder does
not close the gap; changing the comparison does.

## What to do with a large diff

The chapter's cases converge on a practical problem: how to review a change
whose volume defeats reading. The answer is not to read faster.

Separate the mechanical from the substantive before reading anything.
Whitespace-blind comparison removes pure formatting; what remains is the
candidate set. Where a rename is involved, chapter 5's similarity index tells
you whether to expect a small edit inside the move. Where generated files
dominate, confirm they are genuinely generated — the file list, not the line
count, answers this — and read the generator's input instead, which is
usually a fraction of the size and is the thing a human actually wrote.

Then check the classes that carry no lines: modes, binaries, symlinks,
submodule pointers. A short, explicit pass over the file headers finds all
four in seconds, and none of them will be found by reading content.

What remains after both passes is usually small enough to read properly, and
it is the part of the change that a reviewer's attention was always meant for.
The failure this chapter guards against is not laziness; it is a reviewer
spending genuine effort on the parts of a diff that were never load-bearing,
and arriving at the end with a budget exhausted and the substantive lines
unread.

## The invisible classes, as a checklist

The chapter's cases are diverse and the reading habits that catch them are
few. Stated as the pass a reader actually runs, in the order that costs least:

Read the file headers before any content. Modes, binaries, symlinks, and
submodule pointers are all declared there, all carry no content lines, and all
are missed by any process that starts with the `+` and `-` marks. This pass
takes seconds and finds the entire class.

When a commit claims to be formatting, run the whitespace-blind view and treat
whatever survives as the commit's real content. When a commit claims to be
substantive and the whitespace-blind view is empty, the change is whitespace,
which in an indentation-sensitive file may still be a behavior change.

When a removed line and an added line look identical, stop reading and start
measuring. Byte counts, control-character rendering, or a hex comparison
settle in one command what staring cannot settle at all. Visual identity
across a printed pair is evidence that the difference is not visual, never
evidence that there is no difference.

When a file's diff is implausible for the change described — enormous for a
small edit, or trivially small for a large one — suspect the representation
rather than the author. Minified content, unstable serializations, and
repository-level filters all produce this shape, and all are answered by
comparing something other than lines.

And carry the boundary with you: none of these techniques establishes that a
change is correct. They establish what changed, which is the question this
book is about, and which has to be settled before correctness can be
discussed at all.

The final chapter puts the whole routine together and takes up what a diff can
never settle — whether the change is complete, whether it works, and what a
reader owes the person on the other end of a review.
