# Chapter 3 — Marks and Their Meanings

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## The grammar nobody is taught

A unified diff is a small formal language, and almost every reader acquires
it by osmosis rather than by instruction. That works well enough for the
obvious parts — plus adds, minus removes — and fails at the parts that
decide review comments. This chapter reads the marks deliberately: what each
one asserts, what it does not, and which of them are heuristics wearing the
costume of fact.

The single most consequential rule arrives first, because it produces more
wrong review comments than every base error in the previous chapter combined.

## Unprefixed lines did not change

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > handler.py <<'EOF'
def handle(request):
    if request.user is None:
        raise Unauthorized()
    payload = parse(request.body)
    validate(payload)
    return store(payload)
EOF
git add -A && git commit -qm base
cat > handler.py <<'EOF'
def handle(request):
    if request.user is None:
        raise Unauthorized()
    payload = parse(request.body)
    return store(payload)
EOF
git add -A && git commit -qm "streamline handler"
git show --format="" HEAD
```

```output
diff --git a/handler.py b/handler.py
index 97b2e42..c8cfd1e 100644
--- a/handler.py
+++ b/handler.py
@@ -2,5 +2,4 @@ def handle(request):
     if request.user is None:
         raise Unauthorized()
     payload = parse(request.body)
-    validate(payload)
     return store(payload)
```

Six lines of body are displayed. One changed. The authorization check, the
parse, and the store are all present in the output and none of them is part
of this commit — they carry a leading space, which marks them as context:
lines reproduced so a human can see where the change sits. Only
`validate(payload)`, carrying a leading minus, was touched.

The misreading is to treat everything visible as everything changed, and it
runs in both directions. A reviewer writes "this commit adds an authorization
check" because the check is on the screen and reads as new; the check has been
there all along. A reviewer approves a commit as small because it displays
few lines, when the hunk header's counts — five lines becoming four — are the
actual measure of the edit. The remedy is mechanical and worth making a
reflex: **read the first character of every line before reading the line.**
Space is the past and the present at once. Minus is the past only. Plus is
the present only.

Now read the same transcript for what it does. A validation call was removed
from a request handler between parsing and storing. Against the commit
message, "streamline handler," the diff is not contradicted — nothing in the
message is false — but a claim built on the message, such as "this commit is
a readability change," is contradicted by content: removing a validation step
changes what reaches storage. That gap between a true summary and a false
inference from it is chapter 4's whole subject.

## The header's hint is a guess

The text trailing a hunk header looks like scope and is not.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > svc.py <<'EOF'
def charge_card(amount):
    return gateway.charge(amount)


def refund_card(amount):
    limit = 100
    return gateway.refund(amount, limit)
EOF
git add -A && git commit -qm base
sed -i 's/    limit = 100/    limit = 10000/' svc.py
git add -A && git commit -qm "raise refund limit"
git show --format="" HEAD
```

```output
diff --git a/svc.py b/svc.py
index 75d1f94..f4b1042 100644
--- a/svc.py
+++ b/svc.py
@@ -3,5 +3,5 @@ def charge_card(amount):
 
 
 def refund_card(amount):
-    limit = 100
+    limit = 10000
     return gateway.refund(amount, limit)
```

The header says `def charge_card(amount)`. The change is inside
`refund_card`, two functions down. Nothing is malfunctioning: that trailing
text is a *context hint*, produced by scanning backward from the start of the
displayed region for the nearest line matching a pattern that looks like a
definition. The displayed region begins on a blank line above `refund_card`,
so the nearest preceding match is the previous function's signature.

A reader who takes the hint as scope concludes that a payment charge path was
modified when a refund limit was raised by two orders of magnitude. Both the
attribution and the risk assessment are wrong, and the transcript supports
neither.

The hint is genuinely useful and genuinely unreliable, and its unreliability
is systematic rather than random: it misleads exactly when a change sits near
the top of a function, which is where declarations, limits, and guards
tend to live. Treat it as a navigational aid with no evidential weight. The
scope of a change is determined by reading the changed lines and knowing what
encloses them, which the diff does not tell you, and which is one more reason
review is easier for someone who knows the file.

## The file header, and what "changed" covers

The two lines naming `a/` and `b/` paths carry more than they appear to. When
both name the same path, the file was modified in place. When they differ, a
rename or copy is being asserted — an inference, not an observation, which
chapter 5 takes apart. When one side is `/dev/null`, the file was created or
deleted outright, and that substitution is the only unambiguous signal of
either event.

The `index` line's two abbreviated hashes identify the blob before and after,
and the trailing mode digits report the file's permission bits. A change
confined to the mode produces a diff with a header, no hunks, and a mode line
— a real change with no content, which readers scanning for `+` and `-`
lines will pass over entirely. Making a script executable and removing that
bit look nearly identical at a glance and differ in whether a deployment
still works.

Two further headers appear rarely enough to surprise, and both are visible in
a single commit:

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf '#!/bin/sh\nrun_backup\n' > deploy.sh
chmod 755 deploy.sh
printf 'AA\000BB\n' > logo.bin
git add -A && git commit -qm base
chmod 644 deploy.sh
printf 'AA\000CC\n' > logo.bin
git add -A && git commit -qm "adjust assets"
echo "== the whole diff =="
git show --format="" HEAD
echo "== how many content lines (+/-) did it print? =="
git show --format="" HEAD | grep -c "^[+-][^+-]" || true
```

```output
== the whole diff ==
diff --git a/deploy.sh b/deploy.sh
old mode 100755
new mode 100644
diff --git a/logo.bin b/logo.bin
index c4fe7e2..f16d173 100644
Binary files a/logo.bin and b/logo.bin differ
== how many content lines (+/-) did it print? ==
0
```

Two files changed and the commit printed not one added or removed line. The
first change removed the executable bit from a deployment script, which is
recorded entirely in the mode digits — `100755` becoming `100644` — and which
will stop that script from running wherever something invokes it directly.
The second replaced the contents of a binary, and `Binary files ... differ`
substitutes for the content display, so the diff reports that a change
occurred while showing none of it.

A reader scanning for `+` and `-` sees an empty commit here. A reader who
reads the headers sees a deployment break and an unreviewable asset
replacement. The lesson generalizes past these two cases: **content lines are
not the only place a change can live**, and any review process built on
counting them — including a summary that reports insertions and deletions —
is blind to this whole class by construction. For a claim about a binary the
correct verdict is nearly always insufficient: the diff establishes that the
bytes differ and refuses to say how, and no amount of careful reading extracts
what the format declined to print.

A third marker, `\ No newline at end of file`, records exactly what it says
about one side of the comparison. It matters because tools disagree about
trailing newlines, and a diff that appears to rewrite a final line may be
recording only that.

## How much you are shown is a setting

Context is configurable, and the same change renders differently depending on
how much of its surroundings the producer asked for. A reader who does not
know this reads the amount of context as a property of the change.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > policy.txt <<'EOF'
retention applies to all regions
audit logs are retained for 30 days
access logs are retained for 30 days
billing records are retained for 30 days
exports are retained for 30 days
EOF
git add -A && git commit -qm base
sed -i 's/audit logs are retained for 30 days/audit logs are retained for 3 days/' policy.txt
git add -A && git commit -qm "adjust audit retention"
echo "== default context (3 lines either side) =="
git show --format="" HEAD | grep -c "^ "
echo "== zero context =="
git show --format="" -U0 HEAD
echo "== word-level view of the same change =="
git show --format="" --word-diff=plain -U0 HEAD | tail -3
```

```output
== default context (3 lines either side) ==
4
== zero context ==
diff --git a/policy.txt b/policy.txt
index 5560429..23bed78 100644
--- a/policy.txt
+++ b/policy.txt
@@ -2 +2 @@ retention applies to all regions
-audit logs are retained for 30 days
+audit logs are retained for 3 days
== word-level view of the same change ==
+++ b/policy.txt
@@ -2 +2 @@ retention applies to all regions
audit logs are retained for [-30-]{+3+} days
```

One change, three renderings. The default surrounds it with four context
lines; zero context strips them; the word-level view abandons the line as the
unit entirely.

The zero-context hunk header shows a form the previous chapter's example did
not: `@@ -2 +2 @@`, with no counts at all. When a region is exactly one line
long the count is omitted, so `-2` means line 2 alone, not line 2 onward. A
reader who assumes the numbers always come in pairs will misparse this, and
it appears constantly in machine-generated diffs, which frequently request
zero context to keep patches minimal.

The practical consequence of configurable context is that **the presence of a
line in a diff is not evidence that the line is related to the change.**
Context is a fixed-size window, not a semantic neighborhood: it stops after
three lines whether or not the relevant code continues, and it includes three
lines whether or not they have anything to do with the edit. Reviewers infer
relationship from proximity constantly — the adjacency trap the sibling
volume dismantles for merged output streams, reappearing here in a spatial
form. What sits above a changed line is what happens to sit above it.

## Below the line

The word-level view earns its own note because it changes what a reader can
see. In the line-based renderings, the entire policy line is removed and a
new one added; the reader must diff the two lines mentally to find what
actually moved. The word-level form does it for them: `[-30-]{+3+}`, a
retention window cut from thirty days to three.

That difference matters more than it looks. Line-based diffs systematically
exaggerate small edits and systematically hide them inside long lines. A
single altered digit in a long configuration line is rendered as a wholesale
replacement, which reads as a large change; and in a densely packed line — a
URL, a command, a long boolean expression — the altered token is visually lost
among the identical text surrounding it. Both failures push the same
direction: the reader's attention lands on the wrong part of the line.

For judgment, the discipline is to reach for the word-level view whenever a
claim turns on *what within a line* changed, and to remember that its absence
from a transcript does not make the line-based rendering wrong — only coarse.
When the difference between `30` and `3` decides whether an audit trail
survives a compliance window, coarse is not good enough, and the finer view
costs one flag.

## When the file is one line

The format assumes lines are small. Generated content violates that assumption
without warning, and a bundle, a lockfile, a compiled asset, or a serialized
snapshot may hold thousands of tokens on a single line.

Change one of those tokens and the diff removes the line and adds it back. The
hunk header takes the count-omitted form introduced above, `@@ -1 +1 @@`, since
the region is exactly one line on each side; the summary reports one insertion
and one deletion; and the printed patch runs to many thousands of characters to
convey an edit of a few. Nothing here is a malfunction, and the content is not
treated as binary either — the fallback to a binary rendering keys on the bytes
present, not on how long a line is.

Both coarseness failures from the previous section therefore arrive at once and
at maximum. The extent reported is two lines, which is true and conveys
nothing. The altered token sits somewhere inside a wall of identical-looking
characters, with no marker of its position, and a reader comparing the plus
line against the minus line by eye will not find it. Word-level rendering,
which rescues the ordinary long line, collapses here: its unit is a run of
non-whitespace characters, and minified output exists because its whitespace
was deliberately removed, so the entire line is one word and the word-level
view degenerates into the line-level one. The unit can be redefined — a
supplied pattern can go as fine as one character per word, which does recover
the change — but that is a decision the reader has to know to make, and a
pattern chosen badly renders confidently and wrongly.

The reading that actually works is to classify the file before reading the
hunk. A generated file's diff is evidence about what a generator emitted, not
about what anyone wrote. The question worth asking of it is not what changed
inside the line but whether that output corresponds to the source change in the
same commit — a dependency added, a version pinned, a schema edited. That is a
question about two files together, and the generated file's diff alone cannot
settle it. Where the source is not in frame, the honest verdict on any claim
about what the generated change means is insufficient, and the effort is better
spent finding the input than parsing the output.

## Reading a hunk for its shape

Before the content of a hunk is read, its shape can be read from the counts in
the header, and the shape narrows what the content can be doing. Equal counts
mean a substitution: as many lines left as arrived. A larger new count means
net growth; a larger old count means net removal. A hunk whose old count is
zero is a pure insertion into that position, and one whose new count is zero
removes the region entirely.

That reading is fast and it constrains claims usefully. "This commit only adds
a feature flag" is testable against the hunk shapes before a single line is
examined: if any hunk removes more than it adds, something was taken out, and
the claim owes an account of what. Conversely a change described as a
refactor should show substitutions and rough balance; large asymmetry is a
signal to look harder, not proof of anything.

What the counts cannot tell you is significance, and the temptation to read
them that way is the summary problem in miniature. Removing two lines can end
an outage or cause one. The counts bound the *extent* of an edit within a
region, which is a fact about text, and every question about consequence lives
outside them.

## The order is not a ranking

Within a file, hunks are emitted in ascending position: a change near the top
appears before a change near the bottom, always, regardless of which is
larger or which was made first. Across files, the entries are ordered by path,
compared as text. The comparison is mechanical enough that `lib.txt` precedes
`lib/mod.txt`, because a dot sorts before a slash — the ordering knows nothing
about the tree, only about the string.

What follows is a mismatch nobody designed and everybody lives with. Attention
decays across a long diff, and the ordering has no relationship whatever to
significance. The file that tends to get read most carefully is the one whose
path begins with a digit or an early letter — a changelog, a configuration file
at the repository root — and the file that gets the least is whatever the sort
put last. Neither position was earned. The author's sense of what mattered, the
order in which the work was done, the size of each edit, and the risk each
carries are all discarded before the output is produced.

The second consequence is that a change spread across a codebase is presented
in an order that dismantles its narrative. An interface definition, its three
implementations, the caller that was updated, and the test that covers it will
appear scattered among unrelated paths, and the relation the reader needs — this
declaration changed and these are the places that depend on it — is exactly what
the ordering does not express. Reconstructing it is manual work, and the format
offers no assistance beyond putting the pieces on the same page.

The third consequence runs the other way and is genuinely useful. Because the
order is mechanical, it is predictable, and predictable order gives absence a
location. Two default renderings of the same commit list the same files in the
same sequence, so a reader who expects a file to be present can look where it
would have been rather than searching the whole output. Absence still has no
notation, but it acquires a place to not be — which is the closest the format
comes to reporting an omission. That predictability is worth one caveat: file
order is configurable, so a diff produced by someone else may have been ordered
deliberately, and an order that looks meaningful might be.

## The same line, removed and added

A pattern appears often enough to deserve naming: a line that occurs once as
removed and again as added, with content that looks identical or nearly so.
Three quite different events produce it, and the diff does not distinguish
them.

The first is a genuine edit too small to see — a changed digit, a swapped
operator, a substituted character that renders alike. This is what the
word-level view exists to surface, and it is the case with real consequences.
The second is an invisible-character change: trailing whitespace removed, an
indentation style converted, a line ending altered by an editor on another
platform. The content is the same to a reader and different to the file, and
chapter 6 is written about this class. The third is a *move*: the line was
deleted in one place and inserted in another, which appears as a removal and
an addition at different positions in the same file and is not an edit at all.

Distinguishing them takes seconds and the technique is worth having.
Word-level rendering settles the first case immediately. Whitespace-blind
comparison settles the second: if the change disappears when whitespace is
ignored, whitespace is what changed. And a move announces itself by the
removed and added lines being identical while their positions differ, often
with the surrounding lines moving along with them — a block of removals in
one hunk matching a block of additions in another.

Getting this wrong is expensive in a specific way. A reviewer who reads a
moved block as new code reviews it again, comments on it again, and sometimes
asks for changes to code that has been in production for a year. A reviewer
who reads a moved block as unchanged misses that the move itself may be the
defect — code lifted out of a lock's scope, or above the check that guarded
it, is a behavior change made entirely of relocation.

## A hunk is not a syntactic unit

The window a hunk displays is a changed region plus a fixed number of lines on
either side. Nothing aligns that window to the structure of the language in the
file, and in any language whose constructs span lines the two boundaries come
apart routinely.

Consider a commit that folds two adjacent guards into one, deleting the closing
brace of the first block and the opening line of the second so that the
statement below joins the block above. The hunk that results begins fifteen
lines into the file. It contains a removed closing brace whose matching opening
brace sits far above the top of the window and is not displayed anywhere in the
diff. It contains a removed opening brace whose closing partner is unchanged
context two lines below. Read as text it is a window of eight lines carrying
two removals; read as code it is a change of scope.

Two conclusions are available and both are wrong. The first is that a removed
closing brace with no visible opening indicates damage — in practice it
indicates the edge of the window, and a hunk that is unbalanced within itself
is entirely ordinary. The second is that the removals are the whole change.
They are not, and this is where the chapter's own opening rule needs its
qualification. The statement that joined the block above carries a leading
space. Its text did not change, and the rule that unprefixed lines did not
change is exactly true about text. What encloses that line did change, and its
execution now depends on a condition evaluated in a different place. **A
context line's characters are guaranteed; its meaning is not.**

The same shape appears wherever a construct is opened on one line and closed on
another: an `end` keyword whose `def` is out of frame, a closing tag in markup
whose opening tag is fifty lines up, a bracket that terminates a list the window
never showed. In each, the lines that determine what a displayed line means may
sit outside the window that displays it, and the window has no way to say so.

The technique is the one the context setting already supplies — widen the
window until the enclosing construct is visible, or read the file. The judgment
rule is firmer: when a hunk contains an opener or a closer without its partner,
the scope of the change is larger than the hunk, and any claim about behavior
is insufficient until the enclosing construct is in evidence. This is the
narrowest and most concrete form of the limit chapter 1 stated in general — the
diff shows the local part, and here the local part is bounded by a line count
that the language never agreed to.

## The marks in one pass

The routine for question three, stated as the sequence a reader actually runs.
Take the file headers first and classify the event: modification, creation,
deletion, rename, mode change, or binary. Take the hunk headers next and read
the shapes: where in the file, how large a region, growing or shrinking or
substituting. Only then read lines, first character first, keeping context
separate from change. Finally, ask what the marks do not cover — the hint's
guess, the binary's hidden content, the mode bit that carries no lines — and
note which of those the claim under judgment depends on.

Run in that order, the grammar does most of the work of preventing the
chapter's two headline errors: crediting a change with lines it did not touch,
and trusting a hint that was never a promise. What it cannot prevent is the
error of believing a summary that no one checked against the marks at all,
which is where the next chapter goes.
