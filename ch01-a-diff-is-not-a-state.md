# Chapter 1 — A Diff Is Not a State

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## The second evidence class

A machine that reads command output for a living reads two kinds of evidence.
The first is the transcript: what a command did, told through status,
commentary, and output. The volume this one accompanies takes that class
apart. The second is the diff — evidence about what a *change* does — and it
arrives constantly in the work agents are actually given. Review this pull
request. Summarize what landed yesterday. Is this patch safe to merge. Does
this commit do what its message says. Each of those is a judgment about
change-evidence, and each is answered wrongly in ways that recur often enough
to be catalogued.

The diff deserves its own book because it is not a transcript with different
formatting. It has a grammar of its own: prefixes that separate what changed
from what merely surrounds it, headers whose numbers describe regions rather
than content, rename detection that is inference presented as fact, and
summaries that routinely disagree with the detail they summarize. It has its
own silences. And it has a boundary so fundamental that this chapter is named
for it, and so easy to cross that a reader who has not been warned will cross
it in the first paragraph of the first review.

The routine adapts the four questions to change-evidence, and the order is
again load-bearing. **What is the base?** — against what is this a change.
**What is in frame?** — which files and hunks are here, and what was elided.
**What do the marks mean?** — the grammar, read rather than skimmed. **What
does the change do that the summary does not say?** The verdict vocabulary is
the same three words the sibling volume uses, and for the same reason: a claim
about a change is either supported by the diff, contradicted by it, or beyond
what the diff can settle, and the third case is the one readers convert into
the first.

## Transitions, not states

Here is the boundary, in one transcript.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
for i in 01 02 03 04 05 06 07 08 09 10 11 12; do printf "line %s\n" "$i" >> notes.txt; done
git add -A && git commit -qm base
sed -i 's/line 06/line 06 (revised)/' notes.txt
git add -A && git commit -qm "revise line 6"
echo "== what the diff shows =="
git show --format="" HEAD
echo "== how many lines the file actually has =="
wc -l < notes.txt
```

```output
== what the diff shows ==
diff --git a/notes.txt b/notes.txt
index b5c3b6e..526e896 100644
--- a/notes.txt
+++ b/notes.txt
@@ -3,7 +3,7 @@ line 02
 line 03
 line 04
 line 05
-line 06
+line 06 (revised)
 line 07
 line 08
 line 09
== how many lines the file actually has ==
12
```

The diff displays seven lines of a twelve-line file. Lines 1, 2, 10, 11, and
12 are not in it, not because they are unchanged in some interesting way, but
because the format shows changed regions plus a few lines of surrounding
context and nothing else. The number three in the hunk header is where the
displayed region begins; the seven is how many lines it covers. Everything
outside that window is simply absent from the evidence.

So the reader who is asked "what does notes.txt contain now?" cannot answer
from this diff. They can answer "line 6 now reads *line 06 (revised)*", which
is a claim about a transition and is fully supported. They can answer "lines
3 through 9 are as shown", also supported, because context lines are the
file's content in the region displayed. They cannot answer anything about
lines 1, 2, or 10 through 12, and the diff gives no signal that those lines
exist — the count at the bottom of the listing is a separate observation,
added here precisely because the diff would not have supplied it.

This is the founding rule and it generalizes past this example: **a diff
testifies to a difference between two states and displays only the
neighborhood of that difference.** Claims of the form "the file now
contains X" are supported only when X falls inside a displayed hunk. Claims of
the form "the file contains only X" are almost never supported by a diff
alone, because the format is under no obligation to mention what did not
change. Readers cross this line constantly, and the crossing is invisible:
nothing in the output looks incomplete, because the output is complete for
what it is.

## The numbers in the header describe regions

The line `@@ -3,7 +3,7 @@ line 02` is the most information-dense text in a
diff and the most often skipped. Its four numbers are two pairs: on the old
side, the region shown begins at line 3 and runs for 7 lines; on the new side,
the same. The trailing text after the closing marks is not part of the
arithmetic at all — it is a context hint, a nearby line the tool guessed might
help a human locate the region, and in code it is usually a function
signature. Chapter 3 treats the hint as the heuristic it is, since it is
routinely wrong in ways that mislead readers who take it for a scope
declaration.

Two readings follow immediately. First, when the two counts differ, the change
altered how many lines exist: `@@ -10,6 +10,8 @@` says six lines became eight.
Comparing the counts is the fastest way to see whether a hunk is a net
addition, a net removal, or a replacement, before reading a single line of its
content. Second, and more useful for judgment, the *starting* numbers tell you
where in the file you are, which is the only thing that makes claims about a
hunk's position checkable. A reader who cannot say which region of a file a
hunk covers cannot say whether the change is near the code that concerns them.

What the header does not do is describe the change. It bounds the display. A
large hunk is not a large change — a single altered line inside a densely
packed region produces a wide window — and a small hunk is not a small one,
since removing a guard takes two lines. Reading the header as a size signal is
the first, mildest form of the mistake the chapter on summaries takes apart at
full scale.

## The empty diff, and what it settles

A diff that prints nothing is a real answer, and it is a stronger one than a
transcript's silence usually is. If a comparison produces no output and exits
cleanly, the two states are identical in every respect the comparison covers.
That is a substantive finding: it excludes an entire class of explanation.

The qualification is in "every respect the comparison covers," and it is the
same qualification this chapter has been repeating. An empty `git diff` says
the working tree matches the index; it says nothing about whether the index
matches the last commit, which is a different comparison that can be
simultaneously non-empty — exactly the situation the staging transcript above
constructs. An empty diff restricted to one path says nothing about other
paths. An empty diff produced with whitespace suppression says the two states
differ in no way *except possibly whitespace*, which is a claim with a hole in
it that the later chapter on invisible changes is written to close.

So the reading is: empty output plus a clean exit supports "these two states
are the same, within the scope of this comparison," and supports nothing
wider. It does not support "nothing changed," because the reader has not yet
established that the comparison's scope is the claim's scope. That gap is
where a reviewer concludes a branch is empty when they have diffed it against
itself.

## The reasonable-sounding claim that is not supported

Consider the claims a reviewer might attach to that transcript, sized as the
sibling volume teaches.

*"This commit changed line 6."* Supported. The minus and plus lines are the
change, and the commit contains one file's worth of them.

*"This commit changed only one line."* Supported for this file, and here the
qualification matters. A diff of one file says nothing about whether the
commit touched others; this transcript happens to show the whole commit
because `git show` displays every file in it, but a reader handed a fragment
of a diff has no such guarantee. The habit worth building is to notice
whether you are looking at a commit or at an excerpt of one.

*"After this commit, notes.txt has twelve lines."* Not supported by the diff.
It is true — the listing's final command establishes it — but the diff is not
where that fact came from, and a reader who believes it came from the diff
will make the same inference next time without the second observation.

*"The file has no line 13."* Not supported, and this is the shape that turns
into a bug. The diff cannot exclude content it never displayed.

## One file, and the commit around it

A diff can be restricted to a single path, and when it is, the output is
indistinguishable from the diff of a commit that touched nothing else. The
file header appears, the hunks appear, and there is no counter, no ellipsis,
and no note recording that other files changed alongside it. Restriction
is invisible in exactly the way elision is invisible, and for the same reason:
the output is complete for what it is.

The claim this licenses is narrow and worth stating exactly — *within this
commit, this file changed in these ways*. What it does not license is anything
of the form "this commit does X," because the other files in the commit are
where X may live. That distance is the distance between "this file now reads
X" and "the system now does X," and it is wider than it looks, because a change
is correct or incorrect in company.

Both directions of the error are ordinary. A function that loses a parameter
reads as a break, and the same commit may have updated every call site, in
files the frame excluded. A configuration key that gains a default reads as
harmless, and the file that consumes the key may have been changed in the same
commit to require it. In neither case does the displayed file contain the
evidence that decides the question, and in neither case does it announce that
the evidence is elsewhere.

So the frame has to be established before the content is read: a commit, a file
within a commit, or a fragment of a file. The first supports claims about the
commit, the second about the file, the third about the region. A claim about
the system is supported by none of them. Treating a well-understood file as a
well-understood system is the state-versus-transition error committed one scale
up, with the file playing the part the line played in the seven-line window
above.

## Which two states?

If a diff is a difference between states, the reader's next question is which
two, and the answer is less obvious than it looks. Git compares whatever it
is asked to compare, and the same working tree yields three different diffs
depending on the question.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "alpha\n" > f.txt
git add -A && git commit -qm base
printf "beta\n" >> f.txt
git add f.txt
printf "gamma\n" >> f.txt
echo "== git diff (worktree vs index): the unstaged part =="
git diff --stat
echo "== git diff --staged (index vs HEAD): the staged part =="
git diff --staged --stat
echo "== git diff HEAD (worktree vs HEAD): everything =="
git diff HEAD --stat
```

```output
== git diff (worktree vs index): the unstaged part ==
 f.txt | 1 +
 1 file changed, 1 insertion(+)
== git diff --staged (index vs HEAD): the staged part ==
 f.txt | 1 +
 1 file changed, 1 insertion(+)
== git diff HEAD (worktree vs HEAD): everything ==
 f.txt | 2 ++
 1 file changed, 2 insertions(+)
```

One file, two added lines, and three different true answers: one insertion,
one insertion, two insertions. Nothing here is inconsistent. The bare `git
diff` compares the working tree against the index and sees only the line that
has not been staged. `--staged` compares the index against the last commit and
sees only the line that has. `HEAD` compares the working tree against the last
commit and sees both. The number in the summary is a property of the
comparison, not of the file.

For a reader, the consequence is sharp: **a diff without its command line is
missing the fact that determines what it means.** Handed the first block alone
under the claim "one line was added," the honest verdict is insufficient — the
claim may be about the commit, the staged work, or the working tree, and the
evidence answers a different one of those in each case. This is the shape
question applied to change-evidence, and it is why the routine asks for the
base before it asks anything else.

## Ranges, and the work you did not do

The same ambiguity scales up to branches, where it acquires a second form
that has caused more confused reviews than any other single notation.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "shared\n" > base.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "feature work\n" > feature.txt
git add -A && git commit -qm "feature commit"
git checkout -q main
printf "main work\n" > main.txt
git add -A && git commit -qm "main commit"
echo "== two-dot: main..feature (differences between the two tips) =="
git diff --stat main..feature
echo "== three-dot: main...feature (only what feature added since they diverged) =="
git diff --stat main...feature
```

```output
== two-dot: main..feature (differences between the two tips) ==
 feature.txt | 1 +
 main.txt    | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)
== three-dot: main...feature (only what feature added since they diverged) ==
 feature.txt | 1 +
 1 file changed, 1 insertion(+)
```

The branch under review added one file. The two-dot form reports that it also
*deleted* `main.txt`, which it did not: `main.txt` was created on the main
branch after the two histories diverged, so comparing the tips directly shows
it as absent on the feature side. The deletion is an artifact of the
comparison. The three-dot form compares the feature tip against the point
where the branches diverged — the merge base — and reports only what the
branch actually contributed.

Two failure modes follow, in opposite directions. A reviewer reading a
two-dot range attributes other people's work to the author under review, and
in the deletion direction this is alarming in a way that wastes everyone's
time: the diff appears to show a contributor removing a colleague's file.
Reading the same range for what a branch *adds* has the mirror problem, since
work that main gained since the divergence shows up as though the branch
removed it. Forge interfaces generally show the three-dot comparison for a
pull request, which is why this rarely bites in the browser and frequently
bites at the command line, where the two-dot form is easier to type and looks
like the obvious thing to ask for.

The reader's discipline is not to memorize which is which — though the
distinction is worth holding — but to ask, of any range diff, what the base
actually is. A diff against a moving branch tip answers a different question
every day, because the tip moves. A diff against a merge base answers a
question that stays put: what did this line of work contribute. When a claim
about a branch's contribution rests on a range whose base is unstated, the
verdict is insufficient, and the missing evidence is one word of notation.

## The diff that arrives without its command line

Most change-evidence an agent is asked to judge was produced by someone else
and traveled: pasted into an issue, quoted in a chat thread, attached to a
report, relayed by another agent that summarized it on the way. What arrives is
the output. The invocation that produced it does not come with it, and the
previous two sections are the argument that the invocation is the part that
matters most.

What survives the journey is the file headers, the index line, the hunk
headers, and the marked lines. What does not survive is precisely the set of
choices that fix the meaning: which two states were compared, whether a
pathspec narrowed the result, how much surrounding context was requested,
whether whitespace was suppressed, whether rename detection ran. Each of those
changes what the same visible output means, and none of them leaves a trace in
it.

One fragment of provenance does survive, and it is worth knowing because it is
so easily over-read. The two abbreviated hashes on the `index` line identify
the file's content before and after — they are blob identifiers, not commit
identifiers, and a repository asked to resolve one of them as a commit will
refuse. What they buy is real but modest: a repository at hand can be asked
whether it holds an object with that identifier, which locates the version the
patch was computed from without knowing the command. A patch produced for
mailing carries a commit identifier on its first line; a diff copied out of a
viewer, or produced with the commit header suppressed as the listings in this
chapter produce it, does not.

Relayed evidence carries a second hazard, which is that relaying tends to
shorten. A diff trimmed to fit a message looks exactly like a diff that was
short to begin with, since the format has no notation for the hunks a third
party removed.

The sizing that follows from all this is strict without being useless. A hunk
asserts that in the region displayed, the old side read one way and the new
side reads another, and that assertion survives the loss of the command line
because it is internal to the hunk. Everything above it — what "old" and "new"
refer to, whether the list of files is complete, whether this is what a branch
contributed — is insufficient until someone supplies the invocation. Asking for
it costs one message and settles a question that no amount of re-reading the
output will.

## The routine, run once

The chapter's four questions are short enough to run on the branch transcript
above, and running them once makes the shape of the work clear before later
chapters fill in the detail.

Take the claim a reviewer might plausibly write about that branch: *"the
feature branch adds one file and removes main.txt."*

**What is the base?** The two-dot form, `main..feature`, comparing the two
branch tips. This is the answer that decides everything else, and it is
available only from the command line, not from the output.

**What is in frame?** Two files, presented as a summary rather than as
content. No hunks are shown at all, so nothing in this evidence speaks to
what is *inside* either file. A summary is a frame narrow enough that
questions about content are out of scope by construction.

**What do the marks mean?** In the stat form the marks are counts and
signs: `1 +` for one added line, `1 -` for one removed. The removal is
attributed to `main.txt`, which is the observation the claim rests on.

**What does the change do that the summary does not say?** Here the answer
overturns the claim. The removal is a consequence of comparing tips across a
divergence, not an action the branch took; the three-dot comparison of the
same two branches shows the branch's actual contribution and contains no
deletion. Against the claim as written, the verdict is **contradicted** for
the second conjunct and **supported** for the first, which by the conjunction
rule makes the sentence contradicted as a whole.

Notice that the decisive evidence was not in the diff. It was the notation in
the command, plus a second comparison run to settle what the first could not.
That is the ordinary shape of diff judgment: the output constrains the answer,
and the base determines what the output means.

## What the diff cannot testify to at all

Three classes of question are permanently outside change-evidence, and
recognizing them early saves the effort of looking harder at a diff that
cannot answer.

**Runtime behavior.** A diff shows text. Whether the changed code runs,
whether it is reached, whether it is correct, and whether the tests pass are
facts about execution, and the evidence for them is a transcript, not a diff.
A reviewer who says "this change fixes the bug" is making a claim the diff
can at best make plausible.

**Intent.** Why the change was made lives in the message, the linked issue,
and the author's head. The message is assertion-grade evidence in the sibling
volume's sense: text produced because someone was expected to produce it.
When message and diff disagree, the diff is the observation. The chapter on
summaries takes this apart properly.

**The surrounding state.** Whether the change is safe usually depends on code
the diff does not display — the callers of the modified function, the other
implementations of the changed interface, the migration that has not run yet.
This is the state-versus-transition boundary again, at the scale that matters
most: a change can be locally impeccable and globally wrong, and the diff
shows exactly the local part.

There is a fourth class worth separating from the third, because it looks like
a property of the diff and is not: **whether the change is complete.** A diff
shows what was done, never what was intended to be done and omitted. The
migration written without its rollback, the flag added without its default,
the interface changed in one of its three implementations, the test updated
for the old behavior — each produces a diff that is internally consistent and
locally correct. Nothing marks the absence, because absence has no notation.
This is the sibling volume's absence check, transposed: ask what a *complete*
version of this change would also contain, and look for it. That question is
answerable, often quickly, and it is the single highest-yield habit a diff
reader can adopt. It is also the reason a review that only reads the diff will
miss a class of defect that a review which knows the codebase catches without
effort — a limit worth stating plainly rather than pretending the format is
self-sufficient.

None of this makes diffs weak evidence. It makes them evidence about a
specific thing, and the reader's advantage comes from knowing which thing.
The next chapter stays with the base, because the question "against what?"
has more answers than this chapter needed — merge bases that move, histories
that are rewritten under a review, and the ordinary case where the diff you
are reading was computed against a commit that no longer exists.
