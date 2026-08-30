# Chapter 4 — The Summary That Disagrees With Itself

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## Two lines, and what they cost

Most changes are never read. They are *triaged* — skimmed as a subject line
and a pair of counts, sorted into important and routine, and approved on the
strength of that sort. The instruments of triage are the commit message and
the stat summary, and both are assertion-grade evidence in the sense the
sibling volume gives the term: text produced because something was expected to
produce it, rather than an observation of what happened.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > auth.py <<'EOF'
def check(token, user):
    if not token:
        raise ValueError("missing token")
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm base
cat > auth.py <<'EOF'
def check(token, user):
    if user.is_admin:
        return True
    return verify(token, user)
EOF
git add -A && git commit -qm "simplify check"
echo "== the summary a reviewer skims =="
git show --stat --format="%s" HEAD
echo "== the same commit, in full =="
git show --format="" HEAD
```

```output
== the summary a reviewer skims ==
simplify check

 auth.py | 2 --
 1 file changed, 2 deletions(-)
== the same commit, in full ==
diff --git a/auth.py b/auth.py
index c01e469..66c2f2b 100644
--- a/auth.py
+++ b/auth.py
@@ -1,6 +1,4 @@
 def check(token, user):
-    if not token:
-        raise ValueError("missing token")
     if user.is_admin:
         return True
     return verify(token, user)
```

Read the top block as a reviewer with forty changes to get through. One file.
Two deletions. No insertions. A message reading *simplify check*. Every signal
agrees, and every signal is true: the file is `auth.py`, the count is exactly
two, and removing two lines from a function is a plausible simplification.
Nothing in that summary is false, and a reviewer who approves on it has done
what the summary invited.

The full diff shows that the two deleted lines are an empty-token guard and
the error it raised. After this change, `check` is called with an empty token
and proceeds to `verify` instead of refusing. Whether that is exploitable
depends on `verify`, which the diff does not show — but the reviewer's
question was never "is this exploitable." It was "is this the routine
simplification the summary describes," and the answer is no.

This is the chapter's thesis in one commit: **a summary can be entirely
accurate and still license a false conclusion**, because the inference from
"small" to "safe" is the reader's, not the summary's. The counts describe
extent. Risk is a property of *which* lines, and no aggregate carries it.

## What a stat drops

The stat form's compression is more aggressive than it appears, and knowing
exactly what it discards tells you when it can be trusted.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "a\nb\nc\n" > keep.txt
printf "x\n" > drop.txt
git add -A && git commit -qm base
printf "a\nB\nc\n" > keep.txt
git rm -q drop.txt
printf "new\n" > added.txt
git add -A && git commit -qm "three kinds of change"
echo "== --stat =="
git show --stat --format="" HEAD
echo "== --shortstat =="
git show --shortstat --format="" HEAD
echo "== --numstat (added, deleted, path) =="
git show --numstat --format="" HEAD
echo "== --name-status =="
git show --name-status --format="" HEAD
```

```output
== --stat ==
 added.txt | 1 +
 drop.txt  | 1 -
 keep.txt  | 2 +-
 3 files changed, 2 insertions(+), 2 deletions(-)
== --shortstat ==
 3 files changed, 2 insertions(+), 2 deletions(-)
== --numstat (added, deleted, path) ==
1	0	added.txt
0	1	drop.txt
1	1	keep.txt
== --name-status ==
A	added.txt
D	drop.txt
M	keep.txt
```

Three files, three genuinely different events: one created, one **deleted
outright**, one modified. Now read the stat block. `added.txt | 1 +`,
`drop.txt | 1 -`, `keep.txt | 2 +-`. The deletion of an entire file is
rendered as a single minus, typographically identical to removing one line
from a file that still exists. A reader cannot distinguish "this file is gone"
from "this file lost a line" in the stat form, and the difference between
those two is the difference between a routine edit and a removed component.

`--shortstat` compresses further, discarding the filenames entirely: three
files, two insertions, two deletions, and no way to know what was touched.
`--numstat` keeps counts and paths in machine-readable columns but still does
not say that `drop.txt` ceased to exist. Only `--name-status` reports the
event class — `A`, `D`, `M` — and it in turn discards the counts.

So the summaries form a lattice of partial views, each dropping something the
others keep, and **no single one of them is the change**. The practical
consequence is that a claim about *what kind* of change occurred cannot be
supported by a stat, and a claim about *how much* cannot be supported by a
name-status. Readers routinely take one and answer the other's question.

## The message is an assertion

The commit message deserves the same grading as any other text produced on
demand. It is written before the reviewer sees the change, by the person least
able to see it freshly, and nothing enforces its relationship to the diff. It
may describe an intention that the change failed to implement, a first draft
that later commits amended, or the change the author believed they were
making.

None of this makes messages worthless. A good message carries what the diff
structurally cannot: *why*, the alternative that was rejected, the ticket, the
constraint that forced an odd-looking construction. That content is
irreplaceable and is exactly the content a reader cannot verify.

The discipline is to sort a message's claims into those the diff can check and
those it cannot, and to check the first kind. "Renames the helper" is
checkable in seconds. "No functional change" is checkable and is the single
most productive message claim to distrust, because it is written honestly by
people performing large mechanical edits in which one non-mechanical line
hides. "Fixes the race" is not checkable from the diff at all and should be
graded as inference at best. When the message and the diff disagree, the diff
is the observation and the message is the assertion, and the ranking is not
close.

The commit that opened this chapter is the ordinary case rather than the
adversarial one. *simplify check* was almost certainly written in good faith
by someone who had decided the guard was redundant. The message is not a lie;
it is a summary of an intention, and the reviewer's job is to notice that the
intention and the effect are different objects.

## Triage misallocates attention, systematically

The deeper problem with size-based triage is not that it occasionally
misjudges a change. It is that its errors are *correlated with what matters*.

Consider what produces large diffs: generated files, dependency lockfiles,
formatting passes, vendored code, test fixtures, renames. Almost none of it
requires careful reading, and all of it consumes the reviewer's budget. Now
consider what produces small diffs: version bumps, configuration constants,
permission checks, boundary conditions, feature flags, timeout values. Almost
all of it is load-bearing, and a two-line change to a comparison operator can
end a service.

Triage by line count therefore spends attention in close to inverse proportion
to risk. A reviewer working through a queue reads the eight-hundred-line
formatting commit with waning care and waves through the four-line
configuration change, and both decisions feel proportionate at the time.

The stat form makes this worse with a detail almost nobody knows: its bars are
scaled, not absolute.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
: > generated.txt
printf "TIMEOUT = 30\n" > config.txt
git add -A && git commit -qm base
for i in $(seq 1 200); do printf "generated row %s\n" "$i" >> generated.txt; done
printf "TIMEOUT = 3000\n" > config.txt
git add -A && git commit -qm "regenerate table, adjust timeout"
echo "== --stat: bar length versus actual counts =="
git show --stat --format="" HEAD
echo "== the actual numbers =="
git show --numstat --format="" HEAD
```

```output
== --stat: bar length versus actual counts ==
 config.txt    |   2 +-
 generated.txt | 200 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 201 insertions(+), 1 deletion(-)
== the actual numbers ==
1	1	config.txt
200	0	generated.txt
```

Two things are happening at once. The bar for `generated.txt` is about sixty
characters long for two hundred insertions, because the histogram is scaled to
a fixed display width rather than drawn one mark per line; bar length is a
ratio, not a count, and comparing two bars across two different commits means
nothing at all.

More consequential is what the display does to attention. The commit's
visually dominant row is a regenerated table that nobody needs to read. The
other row, rendered as an unremarkable `2 +-`, changes a timeout from 30 to
3000 — a hundredfold increase that could hold connections open long enough to
exhaust a pool. The numstat block shows the same commit as one changed line
and two hundred added ones. The summary is accurate in every field and its
visual emphasis is exactly backwards, and emphasis is what a skimming reader
actually consumes.

The correction is to triage on *what was touched* rather than on how much.
A change to an authentication path, a migration, a dependency pin, a
permission, or a deployment script deserves full reading at any size; a
change confined to generated output deserves a check that it is genuinely
generated and little else. That ordering requires the file list, which the
shortstat discards and the name-status keeps — one more reason to know which
summary you are holding.

For a machine reader the same point has a sharper edge. An agent summarizing a
day of commits will, unless instructed otherwise, allocate its output roughly
in proportion to diff size, because that is what the input volume suggests.
The result is a summary whose emphasis is inverted: paragraphs about a
lockfile update, a clause about the auth change. Emphasis is a claim about
importance, and a summary that inherits its emphasis from line counts is
making that claim on no evidence.

## The row you skip

Per-file rows look like a list of findings. They are a list of paths, ordered
by path, and the ordering is the first thing worth knowing about them.
`config.txt` precedes `generated.txt` because c precedes g. Nothing in the
display ranks a row by size, by recency, by risk, or by any other property a
reader is actually sorting for, so in a commit of forty files the position of
the row that matters is decided by a filename.

The rows are also uniform by construction. In a commit of ordinary edits most
of them read `2 +-`, and the eye scanning that column is looking for an
outlier in a display that has been designed to suppress outliers. A reader who
stops scanning when nothing stands out has not read the list; they have
confirmed that the list looks like other lists.

Two more properties of the rendering remove information without announcing it.
When a path is longer than the space the stat allots it, the *front* of the
path is dropped and replaced with an ellipsis, so a row for a file buried
several directories deep shows the tail of its path and the filename. The part
removed is the leading directories — the service, the package, the layer —
which is precisely the part that said which subsystem was touched, and what
survives is often a name shared by a dozen files in the tree: `handler.py`,
`config.ts`, `index.js`. The numstat form prints paths in full and is the
cheaper source when the question is where a change landed rather than how
large it was.

And the list can be truncated. Renderings that cap the number of rows print
the ones they kept, then a short marker standing for the rest, and the
"N files changed" line below is still computed from every file. A truncated
list therefore sits beneath an accurate total and reads as complete. The
reader sees a plausible list, a correct count, and no indication that the two
do not describe the same set.

None of this makes the stat dishonest. It makes the reasons a row goes unread
into properties of the display rather than properties of the change: its
filename sorts late, its prefix was elided, its bar is short, it fell past a
row limit. A change is not any less load-bearing for having a name that begins
with a letter near the end of the alphabet.

## When nobody reads the list

There is a size past which the file list stops being read at all. It varies by
reader and by interface, but it exists, and past it a line like "142 files
changed" is not the heading of a list — it is the entire summary, and it has
become a single number.

A count is the one field that carries nothing about kind. Two commits both
reporting 142 files changed can be a regenerated dependency manifest and a
change that touched a hundred and forty generated files plus two written by
hand, and the second is the interesting one precisely because its interesting
part is two files out of 142. The count is not even stable across
repositories: a project that splits its configuration into many small files
reports large counts for routine work, so the number that triggers alarm in
one tree is unremarkable in another. It is a measure of extent in a unit
nobody has calibrated.

The count also detaches from content more completely than readers expect. A
commit that only relocates files reports every one of them as changed and
reports zero insertions and zero deletions, which is a summary whose two most
prominent numbers point in opposite directions.

The move at large N is to stop reading the list and start querying it. The
list is a set of strings, and the question that scales is not "what is in
here" but "does this contain anything of a kind decided in advance to matter"
— migration directories, dependency manifests, CI configuration,
authentication paths, deployment scripts, anything that runs with elevated
privilege. That question is answered by a filter, costs the same at 12 files
as at 1,200, and returns something short enough to read. It also has a
precondition that is worth stating plainly, because it is where the method
usually fails: it requires knowing beforehand which paths would change the
reading. A reader who cannot name that set is not going to be rescued by
seeing 142 rows, and was never going to be.

## The claim that is almost always worth checking

Among message claims, one deserves its own treatment because it is written
sincerely, checked rarely, and wrong often enough to matter: *no functional
change*.

Its sincerity is the problem. Someone performing a large mechanical edit — a
formatter run, an import reordering, a rename applied across a package, a
migration to a new API shape — genuinely believes the transformation preserved
behavior, and usually it did. The belief is formed before the edit rather than
after, from the *intent* to transform mechanically, and it survives the one
place where the transformation was not mechanical: the line the tool could not
handle, the case the pattern did not match, the manual fix-up applied halfway
through to make the build pass.

The structural reason this hides is the subject of the section above. A
mechanical edit produces a large diff, and the one non-mechanical line inside
it is a single hunk among hundreds, visually identical to its neighbors. The
reviewer's attention is exhausted by volume, and the volume is precisely what
the message told them to discount.

Two checks cost little. Whitespace-blind comparison collapses a pure
reformatting to nothing, so anything that survives it is a candidate for real
change — a screen of remaining hunks in a commit described as formatting is a
finding, not a nuisance. And for renames or signature changes, checking that
the count of call sites before equals the count after catches the
implementation the pattern missed. Neither check establishes that behavior was
preserved; both narrow where it might not have been, which is the most a
reader can do from the diff and is considerably more than accepting the
sentence.

## When the summary is the only evidence

Sometimes a reader genuinely has nothing else: a release note, a changelog, a
dashboard row, another agent's report. The verdict discipline does not change,
but the ceiling does.

From a stat alone, the supported claims are narrow and worth stating exactly.
Which paths were touched — supported, if the form kept paths. How many lines
changed in each — supported, with the caveat that a deleted file reads as a
one-line removal. That the change is *confined* to those paths — supported,
and often the most useful thing a stat gives you, because it excludes
subsystems.

Everything else is beyond it. Whether behavior changed: insufficient. Whether
the change matches its message: insufficient. Whether it is safe: insufficient.
Whether a file was deleted or merely trimmed: insufficient unless the form
distinguishes them. A reader who reports these as findings has promoted a
summary to an observation, which is the specific error this chapter exists to
name.

The honest output in that situation is the same shape the sibling volume
teaches: the verdict, the evidence it rests on, and the observation that would
settle it. "The change touches only `auth.py` and removes two lines; whether
those lines were load-bearing is not established by this summary, and the diff
would settle it in seconds" is a complete answer. It is also, in a review
queue, the sentence that most often turns out to have been worth writing.

## The summary you write

The compressions this chapter has been taking apart are not peculiar to git.
They are properties of compression, and they arrive intact in prose. A reader
who reduces a diff to a paragraph has manufactured a new piece of
assertion-grade evidence and handed it to someone who will not see the diff,
and every failure catalogued above is available to that paragraph: the dropped
event class, the emphasis inherited from volume, the field that is accurate
and licenses a false inference.

Which makes the written summary the one link in the chain its author fully
controls, and there are a few choices that decide what the next reader can do
with it. Prefer the discriminating field over the aggregate one: "confined to
the migration directory" is shorter than "three files changed, eleven
insertions" and says considerably more, because it excludes subsystems.
Preserve event class, since *deleted*, *added*, and *renamed* are three
different futures and cost one word each. Keep the distinction between what
was observed and what was concluded — "the stat lists only `auth.py`" and "the
change is confined to authentication" are separated by an assumption about
where authentication lives, and the sentence that states both is barely
longer than the sentence that states the second.

Two habits matter more than the wording. The first is to say what was not
read. A summary written after skipping four thousand lines of generated output
is a summary of part of a commit, and silence about the skip reads as
coverage; the next reader will assume the paragraph describes the change
rather than a subset of it chosen for tractability. The second is to leave the
route back open. A summary that names the commit and the path costs a clause
and makes the next reader's first step a single command; a summary that names
neither makes it a search, and a search is expensive enough that it usually
does not happen. The difference between those two summaries is not accuracy.
Both can be entirely true. It is whether the claim can be checked by the
person now relying on it, which is the only property that survives the next
hop.

## Summaries of summaries

One last compression is worth naming because agent pipelines now produce it
constantly. A stat summarizes a diff; a release note summarizes a set of
stats; a status update summarizes release notes. Each hop applies the same
lossy rule, and the losses compound in a consistent direction: file lists go
first, then event classes, then counts, until what remains is a sentence with
no checkable content at all.

The tell is a claim whose grammar has lost its subject — "some cleanup and a
few fixes," "minor dependency updates," "no user-facing changes." Each began
life as a set of specific paths and counts, and each can be expanded back
toward evidence by asking which paths. When a decision rests on such a
sentence, the correct move is not to read it more carefully; it is to go one
hop back toward the diff, which is usually one command away and always more
informative than the sentence that replaced it.

## Walking a release note back

The changelog deserves separate treatment, because it is the hop where the
chain stops being mechanical. A stat is computed from a diff and will produce
the same rows every time. A release note is *written*, from an intention, and
its structure comes from somewhere other than the changes: the headings —
Added, Fixed, Security, Deprecated — are categories chosen for an audience,
and no field of any commit was consulted to assign them.

Three properties follow, and each one bounds what a note can support. Entries
are selected, so the absence of an entry is not evidence of the absence of a
change; every note is a filtered view whose filter is not printed alongside
it. Entries and commits are many-to-many: one line can stand for thirty
commits, one commit can produce lines under three headings, and most commits
produce no line at all. And nothing in the note records which commits it came
from unless somebody maintained that link by hand.

Walking a note back toward evidence therefore means finding a join. Where one
exists — a version tag, a date boundary, a ticket identifier repeated in the
commit messages, a merge reference — the hop is mechanical, because the work
between two tags is a range, and a range is something chapter 1 already showed
how to read as a diff. Where no join exists, the hop is a search through
commit messages for text resembling the note, which is a different operation
with a different reliability, and a reader who has done the second should not
report it as though they had done the first.

The characteristic failure at this layer is a note more specific than anything
underneath it. "Fixed a memory leak in the connection pool" typically descends
from a commit message that said the same thing, which descended from an
author's belief about their own change. Restating a claim in a more official
document does not upgrade it; the note inherits the grade of the sentence it
was copied from, and that sentence was an assertion when it was written.

What a release note does support is narrow and real: that a version boundary
exists, roughly when it fell, and that somebody considered these items worth
telling users about. That last one is genuinely useful — it is evidence about
attention, which nothing else in the chain reports. It is simply not evidence
about code, and the two are separated by every hop between the note and the
tree.

The next chapter takes up the summary's most misleading single field — the
one that reports a rename, which is not an observation at all but a guess the
tool made and then printed as fact.
