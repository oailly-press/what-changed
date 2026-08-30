# Chapter 8 — Judging a Change

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## The routine as one motion

The four questions do not add up to a procedure until they are run in order on
something real. Stated once, compactly: **what is the base**, against which
this is a change and whether that base is the one the claim assumes; **what is
in frame**, which files and hunks are present and what the format elided;
**what do the marks mean**, read as grammar rather than skimmed, with
inference separated from observation; and **what does the change do that the
summary does not say**.

The order is load-bearing for the same reason it was in the sibling volume.
A base error invalidates everything downstream, so it goes first. Frame
questions decide whether the evidence can bear on the claim at all. The marks
must be read before content can be judged, because a reader who mistakes
context for change is judging the wrong lines. And the summary is checked last,
against everything already established, rather than used as the lens through
which the rest is read.

## A change, judged

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p api
cat > api/session.py <<'EOF'
SESSION_TTL = 3600

def issue(user):
    token = mint(user)
    store(token, ttl=SESSION_TTL)
    return token

def validate(token):
    record = lookup(token)
    if record is None:
        return None
    if record.expired():
        return None
    return record.user
EOF
git add -A && git commit -qm base
cat > api/session.py <<'EOF'
SESSION_TTL = 86400

def issue(user):
    token = mint(user)
    store(token, ttl=SESSION_TTL)
    return token

def validate(token):
    record = lookup(token)
    if record is None:
        return None
    return record.user
EOF
git add -A && git commit -qm "extend session lifetime for mobile clients"
echo "== summary =="
git show --stat --format="%s" HEAD
echo "== full diff =="
git show --format="" HEAD
echo "== whitespace-blind check =="
git show --format="" -w HEAD | grep -cE "^[+-][^+-]"
```

```output
== summary ==
extend session lifetime for mobile clients

 api/session.py | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)
== full diff ==
diff --git a/api/session.py b/api/session.py
index f893bba..4c33b58 100644
--- a/api/session.py
+++ b/api/session.py
@@ -1,4 +1,4 @@
-SESSION_TTL = 3600
+SESSION_TTL = 86400
 
 def issue(user):
     token = mint(user)
@@ -9,6 +9,4 @@ def validate(token):
     record = lookup(token)
     if record is None:
         return None
-    if record.expired():
-        return None
     return record.user
== whitespace-blind check ==
4
```

Take the claim as the message states it: *this change extends session lifetime
for mobile clients.*

**Base.** A single commit against its parent, shown by `git show`, so the
comparison is unambiguous and the evidence is the whole commit rather than an
excerpt. Nothing here depends on a branch tip that may have moved.

**Frame.** One file, two hunks. The first covers lines 1 to 4, the second 9
to 14 on the old side. Everything between line 4 and line 9 is outside the
frame, so the file contains code this diff does not show — chapter 1's rule,
and it matters here because a reader cannot conclude that nothing else in the
session module changed behavior; only that nothing else in it was *edited*.

**Marks.** In the first hunk, one line removed and one added: a substitution.
In the second, two removed and none added — the counts in the header say six
lines became four. The unprefixed lines around them are context and were not
touched, including `if record is None: return None`, which a hurried reader
may credit to this commit.

**Content against the claim.** The first hunk does what the message says: the
time-to-live constant goes from 3600 to 86400, one hour to twenty-four. The
second hunk does something the message does not mention at all: it deletes the
expiry check inside `validate`. After this commit, a session record that has
expired is no longer rejected — `validate` returns its user regardless of age.

That is the finding, and it inverts the change's meaning. The message
describes extending session lifetime to a day. The diff extends nominal
lifetime to a day *and removes the enforcement of any lifetime whatsoever*.
A token that expired last month now validates. The whitespace-blind check
returns four changed lines, confirming that nothing here is formatting and
all of it is substance.

**Verdict.** The claim has two implicit conjuncts — that the change extends
session lifetime, and that this is what it does. The first is **supported**.
The second is **contradicted**: the commit also removes expiry enforcement,
which is not lifetime extension but its abolition. By the conjunction rule the
claim as written fails, and the report should say which half failed and cite
the hunk.

Notice what carried the judgment. Not suspicion, not knowledge of the
codebase, and not the summary — which was accurate, small, and reassuring at
`1 insertion(+), 3 deletions(-)`. It was reading the removals, which chapter 7
argued readers skip, in a commit whose message directed attention to the
addition.

## Sizing a claim about a change

The verdict in that walkthrough turned on a distinction worth isolating,
because it is the one that decides most reviews: the claim had two conjuncts
and they landed differently.

Claims about changes have the same dimensions the sibling volume gives claims
about transcripts, and each is a place where a review comment goes wrong.
**Scope** — is the claim about this hunk, this file, this commit, or this
branch? A commit-level claim cannot be settled by a diff of one file, and a
branch-level claim cannot be settled by one commit. **Strength** — "this
change is safe" quantifies over every consequence; "this hunk does what the
message says" quantifies over one. The second is answerable from the evidence
and the first is not, and reviewers write the first while checking the second.
**Tense** — "this breaks the API" is a claim about behavior after merge,
which depends on the base the change lands on and on code the diff does not
show. And **subject** — a claim about the *diff* ("the message does not
mention the second hunk"), a claim about the *code* ("expired records now
validate"), and a claim about the *system* ("sessions never expire") require
progressively more evidence, and slide into one another in a single sentence
without anyone noticing.

The practical form is the one the sibling volume recommends: restate the claim
with its scope and quantifier explicit before judging it. "The commit extends
session lifetime" becomes "every behavioral change in this commit is an
extension of session lifetime," at which point the second hunk answers it
without any cleverness at all. Most overclaiming in review survives only in
the unrestated sentence.

## The routine at review scale

A single well-judged commit is the drill. Production reading is a branch of
twenty commits, or a week of them, and the routine has to survive that without
becoming either a rubber stamp or an all-day project.

Two orderings help. The first is to run the base and frame questions once for
the whole set rather than per commit: establish the merge base, confirm which
comparison the interface is showing, and get the file list for the branch as a
whole. Most base errors are properties of the review, not of any one commit,
and catching them once is cheaper than catching them twenty times.

The second is to separate the change into strata before reading any of it,
using the classes the previous chapters supplied. Generated and vendored
paths go in one pile, to be confirmed as generated rather than read.
Whitespace-only and rename-only commits go in another, verified with one flag
each. What remains is the substantive stratum, and it is usually a small
fraction of the volume and nearly all of the risk. This is the same
misallocation argument chapter 4 made about a single commit, applied to a
queue: the reader's budget should be spent where the evidence says the
behavior changed.

Within the substantive stratum, read commit by commit rather than as a
squashed whole where the history allows it. A well-made series carries its own
argument — each commit a step with its own message — and reading it in order
is how the author's reasoning becomes available. Where the series is not
well-made, the squashed diff is the more honest artifact, since a history of
"fix", "fix again", "actually fix" is a record of the author's process rather
than of the change, and reviewing it step by step spends attention on drafts.

Two failure modes bracket this. Reading everything with equal care exhausts
the reviewer before the substantive stratum, which is how large changes get
their thinnest review at the point of highest risk. Reading only the summary
and approving on volume is the failure chapter 4 documented. The routine's
value is that it makes the triage explicit and evidence-based, so that what
went unread went unread on purpose and the report can say so.

## What a diff can never settle

Four classes of question stay outside change-evidence no matter how carefully
it is read, and naming them prevents the effort of looking harder at a source
that cannot answer.

**Whether it works.** Execution is a transcript's evidence, not a diff's. The
tests, the build, the run: all of them are the sibling volume's subject, and a
review that concludes "this is correct" from a diff has crossed into a claim
it cannot support.

**Whether it is complete.** A diff shows what was done and has no notation for
what was intended and omitted — the migration without its rollback, the
interface changed in one of three implementations. Absence has no marks, so
completeness is checked by knowing what a complete version would contain, not
by reading harder.

**Why.** Intent lives in the message, the ticket, and the author. The message
is assertion-grade, and where it conflicts with the diff the diff wins; where
it supplies reasons the diff cannot contain, it is irreplaceable and
unverifiable at once.

**What depends on it.** Callers, consumers, downstream services, and
deployment paths are all outside the frame. This is why deletions are harder
to judge than additions of equal size, and why the honest verdict on "safe" is
so often insufficient.

## Confidence, and the cost of each error

The verdict travels with a number, for the same reason it does in the sibling
volume: two supported verdicts can rest on very different evidence, and the
word alone cannot say which. A claim confirmed by a hunk that shows exactly
what it asserts deserves high confidence. The same word, reached because a
stat looked small and nothing seemed alarming, deserves very little — and the
two are indistinguishable in a review comment unless the number says so.

The errors are not symmetric, and the asymmetry runs the same direction it
does everywhere in this series. A false supported — approving a change whose
effect was not what the reader concluded — propagates: it merges, it ships, it
becomes the base for the next change, and it is discovered by the failure it
failed to predict. A false insufficient — asking for evidence that turned out
to exist — costs one exchange and is discovered immediately by the person who
answers. When the evidence is genuinely thin and the change touches something
expensive to get wrong, that asymmetry says which way to lean.

It does not say to lean that way always. A reader who marks every change
insufficient has stopped being a reviewer and become a delay, and will be
routed around, after which their caution protects nothing at all. The
calibration that matters is the ordinary one: read the evidence, say what it
supports, price the rest, and let the stakes of the specific change set how
much unbridged inference is tolerable. That last judgment belongs to the
person who owns the consequences, and keeping it separate from the verdict is
what makes a reader's judgments usable by someone whose risk tolerance differs
from their own.

## The report a reader owes

A review comment is a claim, and it enters someone else's evidence chain at
whatever grade its author gives it. Four elements make it auditable, and they
are the same four the sibling volume asks of any verdict.

State the claim as you read it, so a disagreement about what was being judged
surfaces immediately. Give the verdict as one of the three words rather than a
mood; "this seems risky" is not a finding and cannot be answered. Cite the
load-bearing evidence by hunk or line rather than summarizing it, so the
author can check the same thing you checked. And when the verdict is
insufficient, name the observation that would settle it, because that sentence
is what converts a blocked review into a next step.

Applied to the session commit, the whole report is three sentences: the
message describes extending session lifetime, the second hunk also deletes the
expiry check in `validate` so expired records now validate, and if that is
intentional the message should say so and the tests asserting expiry need
attention. Short, checkable, and addressed to the specific line — which is
the difference between a review that improves a change and one that only
records that someone looked.

## Where the two volumes meet

This book and its sibling divide the evidence a machine reader consumes, and
the division is worth stating because most real questions cross it.

A diff answers what a change *is*. A transcript answers what happened when
something *ran*. Neither answers the other's question, and the commonest
failure in agent review work is to settle one with the other: concluding from
a green pipeline that a diff is correct, or from a clean-looking diff that a
run will succeed. The pipeline exercised the code that existed when it ran,
against the inputs it had; the diff describes text. Both are evidence, and the
bridge between them is an inference that should be named rather than assumed.

Used together they are considerably stronger than either alone. A diff shows
that an expiry check was deleted; a transcript of the test suite shows whether
anything noticed. A diff shows a dependency pin changed; a transcript of the
build shows what actually resolved. When both are available, the productive
question is whether they agree — and disagreement between them is among the
most informative findings a reader can produce, because it usually means the
tests do not cover the changed behavior, which is a finding about the test
suite as much as about the change.

The shared discipline is the one both volumes are built on. Grade the
evidence: an observation outranks an inference outranks an assertion, whether
the assertion is a commit message or a summary line printed by a tool. Size
the claim to what the evidence covers. Name what is missing rather than
filling it with a guess. And when the honest answer is that the evidence does
not settle the question, say so and say what would — which is the same
sentence in both books and, in both, the one most often worth writing.

## Reading your own change before anyone else does

The reader this book trains is, increasingly, also a writer of changes. An
agent that reviews diffs also produces them, and the same routine run on your
own work before you submit it catches a different and more embarrassing class
of problem than running it on someone else's.

The reason it works is that producing a change and reading one use different
knowledge. While writing, you know what you meant, and the diff is a record of
what you did; the gap between those is exactly what a reviewer will find.
Reading your own diff as evidence — with no memory of intent admitted — is the
cheapest way to close it.

Four checks find most of what self-review catches. Read the whole diff, not
the parts you remember writing: debugging statements, a commented-out
experiment, a temporarily loosened check that was going to be restored, and a
file added by a tool rather than by you all show up here and nowhere else. Read
the removals, because the change you made to get something working may have
removed a refusal you did not think about. Check the message against the diff
rather than against your intention, since a message written before the work
finished describes a plan and the diff describes the outcome. And name what
the change does not include — the migration's rollback, the second
implementation of the interface, the test for the new branch — because
completeness has no notation and a reader will assume its absence means
absence of need.

There is a discipline question underneath this that belongs to both volumes.
A change submitted with an honest account of its own limits is easier to
review, more likely to be approved, and more useful when it later turns out to
be wrong, because the record shows what was known at the time. A change
submitted with a confident summary that outruns its diff extracts a small
advantage now and costs it back with interest at the first incident. The
asymmetry is the same one this series keeps finding: overclaiming is cheap
today and expensive on a schedule you do not control.

## The failure modes, catalogued

A short list of how the routine dies in practice, each mapping to the chapter
that treats it, so a reader can recognize the death in their own traces.

**Base unexamined** — a two-dot range read as a branch's contribution, or a
comparison against a tip that moved since the last read. Chapter 2. The tell
is a deletion nobody made.

**Frame mistaken for whole** — concluding what a file contains from the hunks
a diff displayed, or what a commit did from one file's diff. Chapter 1. The
tell is a claim of the form "the file contains only."

**Context credited as change** — approving or objecting to lines that carry a
leading space. Chapter 3. The tell is a review comment about code the commit
never touched.

**Hint read as scope** — taking the function name in a hunk header for the
function being modified. Chapter 3. The tell is an attribution to the wrong
part of a file.

**Summary promoted to observation** — inferring safety from a small stat, or
accepting a message's "no functional change." Chapter 4. The tell is a
verdict with no line cited.

**Inference graded as fact** — treating a rename header, a similarity index,
or a copy header as something recorded rather than computed. Chapter 5. The
tell is certainty about a pairing the tool guessed.

**Invisible change unmeasured** — concluding that identical-looking lines are
noise, or that a commit with no content lines is empty. Chapter 6. The tell is
a diff dismissed as broken.

**Removals skimmed** — reading the additions and passing over what left.
Chapter 7. The tell is a summary that describes only what was added when the
diff is mostly deletions.

**Conjuncts averaged** — a claim with two halves reported as supported
because one half was. This chapter. The tell is the word "mostly."

The list is not a substitute for the routine; it is what the routine prevents,
written in the form a reader is most likely to recognize after the fact.

## Reading as the reviewer you would want

The disciplines in this book are unglamorous: check the base, read the first
character of every line, distrust the summary, treat renames as inference,
look at what was removed. None of them requires cleverness and all of them
cost seconds. What they buy is the ability to say what a change does with the
evidence to back it, and to say clearly when the evidence runs out.

The reader this book has been training is not a skeptic who blocks everything;
that reader is as useless as the one who approves everything, and is wrong
just as often while feeling more responsible. It is a reader whose confidence
tracks the evidence — high when a hunk shows exactly what a claim asserts, low
when a summary is standing in for a diff, and explicit about the difference.

The caddisfly builds its case from whatever the current brings, and the case
it carries is a legible record of every place it has been. A repository's
history is the same kind of object: not a story someone told about the work,
but the accumulated evidence of what was actually done, available to anyone
willing to read the marks. The next change is already waiting for that
reading.
