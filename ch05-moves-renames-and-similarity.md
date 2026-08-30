# Chapter 5 — Moves, Renames, and Similarity

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## Nothing recorded a rename

A diff that says `old.py => new.py` looks like a fact retrieved from a record.
It is not. Git stores no rename information at all; a commit records a tree of
paths pointing at content, and a rename is reconstructed, at read time, by a
heuristic comparing the two trees.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "content\n" > original.txt
git add -A && git commit -qm base
git mv original.txt renamed.txt
git add -A && git commit -qm "rename only"
echo "== what the commit's tree actually records =="
git ls-tree -r HEAD
echo "== the parent's tree =="
git ls-tree -r HEAD^
echo "== blob identity: same object? =="
echo "before: $(git rev-parse HEAD^:original.txt)"
echo "after:  $(git rev-parse HEAD:renamed.txt)"
```

```output
== what the commit's tree actually records ==
100644 blob d95f3ad14dee633a758d2e331151e950dd13e4ed	renamed.txt
== the parent's tree ==
100644 blob d95f3ad14dee633a758d2e331151e950dd13e4ed	original.txt
== blob identity: same object? ==
before: d95f3ad14dee633a758d2e331151e950dd13e4ed
after:  d95f3ad14dee633a758d2e331151e950dd13e4ed
```

Two trees, one blob. The content object `d95f3ad…` is byte-identical on both
sides and is referenced under a different name in each. The word "rename"
appears nowhere; it is a *conclusion a reader draws* from noticing that the
same content is present under a new path, and git draws it on the reader's
behalf when it renders a diff.

This is the chapter's foundation and it upgrades chapter 3's grading. A `+`
line is an observation: the text is there. A rename header is an
**inference** — well-founded, usually right, and produced by an algorithm
whose parameters are configurable and whose confidence is not shown. Grading
it as an observation is how a reader ends up certain about something the
evidence merely suggests.

## The same commit, two sizes

Because the inference is optional, the same commit produces materially
different evidence depending on how it is read.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
cat > handler.py <<'EOF'
def process(item):
    validated = validate(item)
    enriched = enrich(validated)
    stored = store(enriched)
    audit(stored)
    return stored
EOF
git add -A && git commit -qm base
git mv handler.py processor.py
cat > processor.py <<'EOF'
def process(item):
    validated = validate(item)
    enriched = enrich(validated)
    stored = store(enriched)
    audit(stored)
    notify(stored)
    return stored
EOF
git add -A && git commit -qm "rename and extend"
echo "== default rename detection =="
git show --stat --format="" HEAD
echo "== with detection disabled =="
git show --stat --no-renames --format="" HEAD
```

```output
== default rename detection ==
 handler.py => processor.py | 1 +
 1 file changed, 1 insertion(+)
== with detection disabled ==
 handler.py   | 6 ------
 processor.py | 7 +++++++
 2 files changed, 7 insertions(+), 6 deletions(-)
```

One commit. Read one way it is a rename with a single added line; read the
other it is a six-line deletion and a seven-line creation across two files.
Thirteen changed lines versus one, and neither rendering is wrong.

The consequences run in both directions, and both appear in real reviews.
Without detection, a reviewer re-reads an entire moved file as though it were
new, spends the review budget on code that was already approved once, and
comments on decisions made a year ago. With detection, the opposite: the
rename header compresses the whole move into one line and the *one added line
inside it* — here `notify(stored)`, a new side effect in a storage path — is
rendered as innocuously as any other single insertion. The first failure wastes
attention; the second hides a change inside a move, which is precisely where
people put changes they do not want discussed.

The reader's move is to notice that a rename header is a claim about
similarity and to ask how similar. Which is a number, and it is printed.

## The similarity index is a confidence score

When content changed as well as moved, the diff header carries a `similarity
index` percentage: the algorithm's estimate of how much of the file survived.
One hundred percent means the content is byte-identical and the inference is
as safe as any in this book. Anything less means the file was edited during
the move, and the percentage is a rough measure of how much.

That number is the most under-read field in the diff format. A reader who sees
`similarity index 96%` can treat the rename as solid and go looking for the
small edit. A reader who sees `similarity index 52%` is looking at something
that is half a rewrite, presented under a header that says "rename," and the
appropriate response is to read it as new code that happens to share a
lineage.

The threshold matters too, and it is easiest to see when two moves of the same
kind are made in one commit.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
for i in 1 2 3 4 5 6 7 8 9 10; do printf "shared line %s\n" "$i" >> mod_a.py; done
for i in 1 2 3 4 5 6 7 8 9 10; do printf "other line %s\n" "$i" >> mod_b.py; done
git add -A && git commit -qm base
git mv mod_a.py kept_a.py
printf "one new line\n" >> kept_a.py
git mv mod_b.py rewritten_b.py
: > rewritten_b.py
for i in 1 2 3 4 5 6 7 8; do printf "completely different %s\n" "$i" >> rewritten_b.py; done
printf "other line 9\n" >> rewritten_b.py
git add -A && git commit -qm "one light rename, one heavy"
echo "== headers, default threshold =="
git show --format="" HEAD | grep -E "^(diff|similarity|rename|---|\+\+\+)"
echo "== stat, default =="
git show --stat --format="" HEAD
```

```output
== headers, default threshold ==
diff --git a/mod_a.py b/kept_a.py
similarity index 91%
rename from mod_a.py
rename to kept_a.py
--- a/mod_a.py
+++ b/kept_a.py
diff --git a/mod_b.py b/mod_b.py
--- a/mod_b.py
+++ /dev/null
diff --git a/rewritten_b.py b/rewritten_b.py
--- /dev/null
+++ b/rewritten_b.py
== stat, default ==
 mod_a.py => kept_a.py |  1 +
 mod_b.py              | 10 ----------
 rewritten_b.py        |  9 +++++++++
 3 files changed, 10 insertions(+), 10 deletions(-)
```

Both files were moved by the same command. The first survives as a rename at
ninety-one percent similarity; the second, rewritten during its move, falls
below the cutoff and is reported as a file deleted to `/dev/null` and an
unrelated file created from it — the creation-and-deletion markers chapter 3
introduced, arriving here for a file that was neither created nor deleted.

Nothing in that output records that `mod_b.py` and `rewritten_b.py` are the
same file's history. The information exists in the repository — the commit was
made with `git mv` — but the format does not carry it, because the format
reports what the heuristic concluded rather than what the author did. A
reader tracing the module's history backward will find it beginning at this
commit, and the trail before it is not broken so much as unreconstructed.

Loosening the threshold has the opposite failure: the tool begins pairing
files that merely resemble each other, manufacturing rename headers between
modules that share nothing but boilerplate. Both directions are configuration
rather than truth, and neither is visible in the output unless the command
line is shown alongside it.

There is a further limit worth knowing: detection compares files, so it finds
paths that moved and is not designed to track a *block* that moved from one
file into another. A block lifted out of one module and dropped into a second
shows as a deletion in one and an addition in the other, with no header
connecting them, and the reader who does not recognize the code will review it
as new.

## A refactor with something in it

The commit where all of this compounds is the large reorganization: a package
given a new layout, forty files moved to new homes, and — announced or not —
a handful of real changes distributed through the move. Every property above
works against the reader at once. The renames compress, so the commit looks
small. The edits inside them are single insertions among hundreds. And the
budget that would have caught them is being spent on paths.

The reading order that fails is the one the diff arrives in, which is path
order. It interleaves the mechanical and the substantive with no separation,
and after the twelfth consecutive pure move a reader is calibrated to expect
the thirteenth. Calibration is the mechanism here; the substantive hunk is not
missed because it is subtle but because it arrives in a position where nothing
was expected.

The partition that works is available because the tool already computed it.
The similarity score is printed once per pair in the summary form, and appears
as a column in the name-status form — `R100`, `R087` — which makes it
sortable, and sorting on it splits the commit into three piles that want three
different kinds of attention.

Pairs at one hundred percent are pure moves. Their content is byte-identical
and the only questions left are where they landed and whether anything still
refers to the old path. Pairs below one hundred contain at least one edited
line each, and every one of them is a place where an edit was made under cover
of a move; this pile is small, and it is where the reading budget belongs.
Files that are neither renamed nor paired are ordinary modifications, usually
few, and usually the actual change the commit was made to deliver.

Reading in that order — modifications first, scored moves second, pure moves
last and fast — inverts the arrival order and matches effort to content. It
also produces a fact worth stating on its own, which the summary never
reports: how many files are in the third pile. A reorganization that also
contains four ordinary modifications is two changes sharing a commit, and the
stat has one row format for both.

## The directory that moved

Vendored dependencies, generated clients, and third-party trees get relocated
wholesale, and such a move is a rename event repeated across every path
beneath the directory — hundreds or thousands of pairs, no content change in
any of them. The rendering has a compression of its own for this case: the
common prefix and suffix are factored out and only the differing middle is
shown in braces, so a single row reads as one path with an arrow embedded in
it rather than as two paths side by side.

That is compact and it has a consequence. The old directory name and the new
one no longer appear as complete strings in the row, so a reader filtering the
file list for a directory may not find it in the form they typed — the string
was split across the brace. Name-status and numstat print both paths in full,
and are what a search should be pointed at.

The counts behave oddly too. A pure-move row carries a zero in its count
column, because no line changed, and contributes nothing to the totals. A
commit that relocates five hundred files therefore reports five hundred files
changed, zero insertions, and zero deletions: the file count at its maximum
and the content at its minimum, in the same three-clause sentence.

For a move of this kind the useful question is not whether it happened but
whether it was *pure*. One file among a thousand that arrives at ninety-six
percent instead of one hundred is a file that was edited during a move nobody
was reading, and the score column answers the question in a single pass. The
answer is usually an empty set and occasionally is the entire finding.

Detection also has a budget, which matters at exactly this scale. Pairing
files by content is a comparison across candidates, and git bounds the work it
will do; past the bound it stops looking for content-similar pairs and reports
what is left as ordinary additions and deletions. The effect on a large move
is the difference between sixty renames with one added line each and a hundred
and twenty files changed with more than a thousand insertions and a thousand
deletions — the same commit, the same tree, and a rendering that has stopped
reconstructing what happened.

Two details make this worth carrying. Git does say when it gives up: a warning
naming the limit and the value that would suffice. But the warning goes to the
error stream rather than into the diff, so a pipeline that captures the diff
and discards the rest keeps a rendering that looks like an enormous rewrite
and loses the one line explaining that it is not. And the failure is
selective. Byte-identical files are matched cheaply and survive a tight limit;
the pairs that drop out first are the ones that were edited during the move,
which are exactly the pairs a reader most needed to see paired.

## Moves inside a file are invisible

Chapter 3 introduced the removed-and-added line and named the move as one
cause. At the scale of a block, that case has a property worth isolating: the
diff format has no notation for it at all.

Move a function from the top of a file to the bottom and the diff shows its
lines removed in one hunk and added in another, exactly as though the function
had been deleted and a new one written. There is no header, no similarity
index, and no marker of any kind. The rename machinery does not apply, because
the path did not change.

What makes this more than an aesthetic problem is that the move itself can be
the defect. Code relocated above the check that guarded it, lifted out of a
lock's scope, or hoisted out of a try block is behaviorally different while
being textually identical — every line the same, every line in a new place.
A reader comparing the removed block against the added block character by
character will find them equal and conclude nothing changed, which is exactly
wrong: what changed is not in the lines but in their surroundings, and the
surroundings are context lines the reader has been trained to skim.

Tools help partially. Move-aware colouring can mark blocks that were removed
here and added there, which at least identifies the pairs. Reviewing with
whitespace-blind comparison narrows what remains. But no flag answers the
question that matters — whether the new position changes behavior — and that
question is answered by knowing what encloses the code, which the diff does
not show. When a claim of the form "this commit only moves code" is under
judgment, the supported verdict is usually insufficient, and the evidence that
would settle it is the enclosing structure at both the old and the new site.

## Copies, and the header that asserts one

A copy is the rename inference's near relative and carries an extra hazard.
When copy detection is enabled, the diff can report that a new file was
*copied from* an existing one, which is a stronger claim than a rename: it
asserts a relationship between a file that changed and a file that did not.

Copy detection is off by default in most invocations, which means its absence
is not evidence that no copy occurred. When it is on, its output should be
read with the same grading as a rename header: the pairing is inferred from
content similarity, and two files can be similar because one was copied from
the other, or because both were generated from the same template, or because
both are thin wrappers whose boilerplate dominates their content. The third
case produces confident, wrong copy headers routinely in codebases with a
house style.

For judgment the useful distinction is between what the header licenses and
what a reader wants from it. It licenses "these two files are substantially
similar." Readers want "this file was derived from that one, so review it
accordingly," which is a claim about history that the content similarity does
not establish.

## Two files that were never related

Copy headers are optional, and their hazard is easy to keep at arm's length by
declining to enable them. The rename inference is on by default, and it makes
the same error unasked.

Consider a codebase whose request handlers come from a template: the same
imports, the same base class, the same decorator stack, the same dispatch
body, differing in a class name and a route string. Retire one such handler
and introduce another in the same commit.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p handlers
cat > handlers/orders.py <<'EOF'
from framework import Handler, route, authenticate, audit

class OrdersHandler(Handler):
    """Generated from the standard handler template."""

    @route("/orders")
    @authenticate
    @audit
    def dispatch(self, request):
        payload = self.parse(request)
        result = self.service.handle(payload)
        return self.render(result)
EOF
git add -A && git commit -qm base
git rm -q handlers/orders.py
mkdir -p handlers
cat > handlers/invoices.py <<'EOF'
from framework import Handler, route, authenticate, audit

class InvoicesHandler(Handler):
    """Generated from the standard handler template."""

    @route("/invoices")
    @authenticate
    @audit
    def dispatch(self, request):
        payload = self.parse(request)
        result = self.service.handle(payload)
        return self.render(result)
EOF
git add -A && git commit -qm "retire orders, add invoices"
echo "== default rendering =="
git show --format="" HEAD | grep -E "^(diff|similarity|rename)"
git show --stat --format="" HEAD
echo "== with rename detection disabled =="
git show --stat --no-renames --format="" HEAD
```

```output
== default rendering ==
diff --git a/handlers/orders.py b/handlers/invoices.py
similarity index 84%
rename from handlers/orders.py
rename to handlers/invoices.py
 handlers/{orders.py => invoices.py} | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)
== with rename detection disabled ==
 handlers/invoices.py | 12 ++++++++++++
 handlers/orders.py   | 12 ------------
 2 files changed, 12 insertions(+), 12 deletions(-)
```

The default rendering says `rename from handlers/orders.py` / `rename to
handlers/invoices.py`, at a similarity index of eighty-four percent, and
summarizes the commit as one file changed with two insertions and two
deletions. No file was renamed. An endpoint was retired and a different
endpoint was created, and the two share a template.

The algorithm is not malfunctioning. Those files genuinely are eighty-four
percent identical, and the pairing rule was applied correctly. The whole of
the error is in the reading, and it is expensive: two events — a module
removed and a module created — are rendered as one file lightly modified. The
deleted file's contents never appear as removals. The new file's contents
never appear as additions. Both collapse into the handful of lines where the
templates differ, and the module that left the codebase is not represented in
the summary at all.

The conditions that produce this are ordinary rather than exotic. A house
style or a code generator makes files structurally similar; a commit both adds
and removes such files. Splitting a module and deleting the original, rotating
test fixtures, replacing one adapter implementation with another, retiring a
handler while introducing its successor — all of them satisfy both conditions
without anybody intending anything unusual.

The check is the one this chapter has already used, pointed at a different
kind of failure. Earlier, disabling detection showed how much a *true* pairing
was compressing; here it shows that the pairing is false, and the same commit
renders as a twelve-line deletion and a twelve-line creation in two unrelated
files. A large disagreement between the two renderings is itself the signal —
two insertions against twelve — and it costs one flag to produce.

What remains after that is a point about vocabulary. The header does not say
that two files resemble each other. It says `rename from` and `rename to` — a
sentence in the past tense, about something that happened. The format has no
way to express its own uncertainty except the percentage, and a high
percentage means the files look alike, not that one of them became the other.

## Where a line came from

A rename's cost is not paid in the commit that performs it. It is paid later,
by every reader who asks where a line came from, because the same inference
has to be reconstructed to answer them.

The default behavior of a path-limited history is the plain case. Asking for
the commits that touched a path lists commits under *that* path, and the walk
stops where the path stops existing: the rename commit is the last entry, and
the years of work under the old name are not in the output. The file's
recorded history begins abruptly, and nothing in the listing marks the
beginning as a boundary rather than an origin.

The follow option continues past it by running rename detection at each step,
which works and carries two costs. It inherits the inference, threshold and
all. And it is a single-file instrument: given more than one pathspec it
refuses to run, and given a directory it runs and follows nothing, stopping at
the move exactly as the unfollowed form does. The second case is the one to
watch, because it fails by returning a plausible answer. Most questions about
a refactor are about directories.

Blame behaves differently, and the difference is worth knowing because it is
silent. Blame follows a whole-file rename on its own, so lines that predate a
move are attributed to the commits that actually wrote them, and the origin
column shows the old path. A reader who is not watching that column will see a
filename that does not exist in the current tree and have no reason offered
for it.

Where the threshold declined the pair, all of this stops. A file moved and
substantially rewritten in one commit has, as far as path-limited history is
concerned, no past: its log begins at that commit, its lines are attributed
there, and the earlier work sits in the repository under a path that nothing
in the current tree mentions. The evidence exists; nothing is pointing at it.

Which sets the limits on what an abrupt beginning supports. It does not
establish that the code is new, that it was written by the author of the first
commit, that it has never been reviewed, or that its earlier defects were
never found. It establishes that no path-limited walk found an earlier commit
under this name, which is a statement about the walk. Several ordinary things
produce it: a rename the threshold declined, a wholesale move whose detection
exceeded its budget, an external tree imported in one commit, the history
rewrites chapter 2 describes, or a clone that does not contain the earlier
commits at all — a property of the copy in hand rather than of the project.
Path-limited listings also simplify by default and can omit a merge that
touched the path, which produces gaps in the middle rather than at the start.

The settling observation is about content rather than paths. The parent
commit's tree can be listed and searched for the file's distinctive lines, and
either something recognizable is there under another name or nothing is. That
is a check on the repository rather than on the rendering, and it is the only
one that answers the question the rendering declined to.

## Reading a rename honestly

The routine, in the order that costs least.

Ask first whether detection was on, since the answer is not in the output and
changes what the output means. A stat with no `=>` in it does not establish
that nothing moved.

Read the similarity index when one is present, and let it set your posture:
one hundred percent is a pure move and needs only its position checked; a high
percentage means look for the small edit hiding inside the move; a low
percentage means treat the file as new code with a shared ancestor.

Look for changes *inside* the rename explicitly rather than trusting the
compressed presentation, because the one added line inside a moved file is the
easiest place in this format for a real change to pass unnoticed.

Treat unpaired deletions and additions with suspicion when they are similar in
size and shape, since they may be a move the threshold declined to pair or a
block relocated between files.

Remember that the inference also runs backward. When the question is where a
line came from rather than what changed, a path-limited history begins where
detection stopped, not where the code began.

And when the claim under judgment is that a change is *only* structural, say
what would make that true and check it: the enclosing scope at both sites, the
call sites that still resolve, and the absence of any hunk that is not part of
the move. A structural-only claim is one of the most common in review and one
of the least often verified, because verifying it requires reading the parts
of the diff the reader was told to skip.

The next chapter stays with changes that hide inside presentation, and takes
the case where the text on screen is identical on both sides and the file is
different anyway.
