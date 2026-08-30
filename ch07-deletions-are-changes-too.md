# Chapter 7 — Deletions Are Changes Too

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## An asymmetry of attention

Readers grade additions and skim removals. The habit is nearly universal, it
is understandable, and it is where the most consequential changes hide.

The reason is structural rather than careless. An added line is a thing to
evaluate: it has syntax to check, a name to judge, logic to follow. A removed
line is, on the screen, an absence — the reviewer's eye passes over it looking
for what replaced it, and when nothing replaced it there is nothing to
evaluate. Removed code also feels safe in a way added code does not: it cannot
contain a bug, because it is not there. That intuition is exactly backwards
for a whole class of code, because the code most often removed is the code
that existed to prevent something.

Guards, bounds checks, error branches, validation, retries, timeouts,
assertions, and tests are all *negative* infrastructure: they earn their keep
by refusing things. Deleting them produces a diff that looks like
simplification and a system that has lost a refusal.

## Everything in the removals

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
mkdir -p tests
cat > tests/test_billing.py <<'EOF'
def test_refund_within_limit():
    assert refund(50) is True

def test_refund_over_limit_rejected():
    assert refund(5000) is False

def test_refund_negative_rejected():
    assert refund(-1) is False
EOF
cat > billing.py <<'EOF'
def refund(amount):
    if amount < 0 or amount > 1000:
        return False
    return True
EOF
git add -A && git commit -qm base
cat > billing.py <<'EOF'
def refund(amount):
    if amount < 0:
        return False
    return True
EOF
cat > tests/test_billing.py <<'EOF'
def test_refund_within_limit():
    assert refund(50) is True

def test_refund_negative_rejected():
    assert refund(-1) is False
EOF
git add -A && git commit -qm "relax refund ceiling"
echo "== the summary =="
git show --stat --format="" HEAD
echo "== additions only, as a reviewer scanning green =="
git show --format="" HEAD | grep "^+" | grep -v "^+++"
echo "== removals =="
git show --format="" HEAD | grep "^-" | grep -v "^---"
```

```output
== the summary ==
 billing.py            | 2 +-
 tests/test_billing.py | 3 ---
 2 files changed, 1 insertion(+), 4 deletions(-)
== additions only, as a reviewer scanning green ==
+    if amount < 0:
== removals ==
-    if amount < 0 or amount > 1000:
-def test_refund_over_limit_rejected():
-    assert refund(5000) is False
-
```

The additions consist of one line, and it is innocuous: a negative-amount
check, which any reviewer would approve without pausing. Everything the commit
actually does is in the other block. The upper bound on refunds is gone, so an
amount of five thousand now returns true where it returned false. And the test
that asserted exactly that behavior is gone too, in the same commit, so the
suite will pass.

Read the summary again with that knowledge: `2 files changed, 1 insertion(+),
4 deletions(-)`. It is accurate, it is small, and it describes the removal of
a financial control and its safety net as four deletions. The message — *relax
refund ceiling* — is even honest about the intent. What no field of the
summary carries is that the change removes the only automated check that would
have caught it going wrong.

## Why the guard was there

A removed refusal raises a question the diff cannot answer and the repository
usually can: why did this exist?

Most guards are not written speculatively. They are written after something
happened — a malformed input reached a parser, a negative amount produced a
credit, a retry storm took down a dependency — and the code that prevents a
recurrence rarely carries the story. The comment explaining it was omitted as
obvious, or written and later tidied away, so the guard survives as an
unexplained constraint. Chapter 7 of the sibling volume made the same
observation about controls in general: an unexplained constraint looks exactly
like an accident of history, and clearing away accidents of history is good
engineering, which is how well-intentioned people remove the thing that was
holding.

The instruments for recovering the story are ordinary and underused. The
commit that introduced the line usually has a message, and that message is
frequently a one-sentence incident report. The pull request it came from may
carry a discussion. The test that accompanies it names the case it feared. All
three are one command or one click from the diff under review, and none of
them requires knowing the codebase — only knowing to ask.

That is the difference between a review comment that stalls a change and one
that improves it. "Why are you removing this?" puts the burden on the author
to reconstruct history. "This bound was added in the commit that fixed the
over-refund incident; what covers that case now?" is the same question with
the work already done, and it usually produces either a good answer or a
quick withdrawal. A reader with access to the history has an advantage over a
reader with access only to the diff, and this is the place that advantage pays
the most.

## Test deletions are a category of their own

A change that modifies behavior and deletes the test covering that behavior
should be read as a single act, not two. The deletion is what allows the
modification to pass, and the pairing is worth watching for on its own.

Legitimate reasons to delete a test exist and are common: the feature is gone,
the test was duplicated, it asserted an implementation detail, it was flaky
and worthless. Each of those is defensible and each should be *stated*, since
a reader cannot distinguish them from the diff. The question to ask of any
removed test is what behavior it asserted and whether that behavior still
matters. If it does, something else must now cover it, and the commit that
removed the test is the place to say what.

The reader's practical instrument is the file list rather than the content. A
commit touching both an implementation file and its corresponding test file,
where the test file's change is net-negative, is a shape worth pausing on
regardless of size — and it is visible from a stat, which is one of the few
things a stat is genuinely good for. When the same commit removes assertions
and relaxes the thing they asserted, the burden of explanation belongs in the
message, and its absence is a finding.

## The shapes a removal takes

Removals arrive in several forms, and the form determines both how visible the
removal is and what it is likely to mean.

A **line removal** inside a function is the case above: the guard, the branch,
the assertion. It is the least visible form, because it renders as a minus
among context and the reviewer's attention is drawn to whatever replaced it.

A **whole-file deletion** is the most visible in the diff proper, where the
new side reads `/dev/null`, and among the least visible in a summary, where
chapter 4 showed it rendering as a single minus indistinguishable from
trimming one line. When a file disappears, the question is never only whether
its contents were needed but whether anything still refers to it by name —
imports, build manifests, deployment scripts, documentation.

A **removal by replacement** is a deletion wearing an addition's clothes: the
old implementation is deleted and a new one added in the same hunk, so the
counts balance and the change reads as a rewrite. The risk is that a rewrite
silently drops a case the original handled. Reading it well means treating the
removed block as a specification — every branch it contained is a claim about
a case that occurs — and checking the added block against it.

A **removal by omission** is the hardest, because it appears nowhere. A
configuration key that stops being written, a field that stops being
populated, a call that stops being made because its caller was restructured:
each leaves a diff in which the relevant line is simply absent from the new
side without ever appearing with a minus, if the surrounding code was rewritten
enough that the tool paired nothing. This is chapter 5's threshold effect
turning a removal into an unmatched region, and it is why a rewrite of any
size deserves a check of what the old version did that the new one does not
mention.

## What a deletion does not tell you

Deletions carry an asymmetry of evidence as well as of attention: the diff
shows what was removed and nothing about what depended on it.

A removed function may have callers. A removed configuration key may be read
by a deployment script. A removed error branch may have been the only handler
for a condition that still occurs. A removed field may be consumed by another
service. None of these dependencies appear in the diff, and all of them
determine whether the deletion is safe. This is chapter 1's boundary in its
sharpest form — the change is local, the consequences are not — and it is why
a deletion often needs *more* context to judge than an addition of the same
size.

The verdict discipline follows. From the diff alone, "this code is no longer
present" is supported. "This code was unused" is not — it is an inference
requiring evidence the diff does not contain, and the evidence is a search of
the codebase. "This deletion is safe" is a claim about the whole system and is
insufficient from change-evidence in nearly every case. Readers routinely
report the second and third as though the first established them, because the
first is obvious and the others feel like it.

## The revert, and what it does not restore

A revert is the most confident-looking deletion in a repository. It carries a
generated message naming the commit it undoes, its diff is the original's
inverted, and it invites a reader to approve on the strength of the
relationship rather than the content. That invitation is worth declining, for
three reasons that the diff does show if it is read.

A revert restores text, not state. Reverting the commit that added a database
migration removes the migration file and leaves the migrated database exactly
as it was; reverting a commit that wrote to an external system unwrites
nothing. Whenever the original change had effects outside the repository, the
revert addresses only the half that lived inside it, and the mismatch is
invisible in a diff that looks perfectly symmetrical.

A revert is computed against the current state, not the original one.
Anything that landed between the original commit and the revert — a bug fix
inside the same function, a rename, a second feature built on the first — is
in the file the revert edits, and the revert may remove or mangle it while
appearing merely to undo. The instrument is the revert's own diff read as an
ordinary change: if it removes lines that were not in the commit being
reverted, something else is being reverted too.

And a partial revert, where someone reverted a commit and then restored one
piece of it, produces a history in which the original commit is recorded as
undone while part of it survives. A reader tracing why a behavior exists will
find the commit that added it and the commit that removed it, and neither
explains the behavior in front of them.

The related case is history rewriting, which removes commits from a branch
outright. Where a revert leaves evidence — a commit whose diff is the
original inverted — a force-push leaves none: the work is simply no longer in
the branch, and a reader comparing today's branch against last week's review
sees an absence with no author and no message. Chapter 2's range-diff is the
instrument for that comparison, and the absence of any such evidence is
precisely why the comparison has to be run rather than assumed.

## The absence check, pointed at removals

The sibling volume's absence check — ask what a true claim's evidence would
also contain, then look for it — has a specific form here. For any deletion,
ask what a *safe* deletion would also contain, and check whether it does.

A safely removed function comes with the removal of its callers, or with
evidence there were none. A safely removed configuration key comes with the
removal of the code that reads it. A safely removed test comes with either the
removal of the behavior it tested or a replacement assertion elsewhere. A
safely relaxed bound comes with an explanation of why the bound existed and
why it no longer does.

Each of those is checkable in the diff itself, and their absence is a concrete
finding rather than a vague unease: not "this makes me uncomfortable" but
"the commit removes `refund`'s upper bound and the test asserting it, and adds
no replacement check — what now prevents an over-limit refund?" That sentence
is short, specific, answerable, and much more useful to the author than an
approval would have been.

## The commented-out line, and the flag left behind

Two near-relatives of deletion deserve their own note because they are
deletions in effect and additions in the diff.

Commenting code out removes its behavior while leaving its text. The diff
shows a removed line and an added line that differ by a comment marker, which
reads as a formatting change to a skimming eye and is a functional removal.
The same asymmetry of attention applies, with an extra wrinkle: commented-out
code often stays for years, and its presence in the file makes a later reader
believe the path exists. When a claim rests on a code path being present, the
question is whether it is *live*, and the diff answers that only if the reader
reads the marker.

Disabling by flag is the same act at one further remove. A change that sets a
feature flag's default to false, or that wraps a block in a condition that is
never true in production, removes behavior without removing a line — the diff
shows an ordinary edit to a constant. This is chapter 4's small-diff problem
and this chapter's attention problem at once: the change is one line, it adds
rather than removes, and it turns something off. Nothing about its shape
signals what it does, which is why configuration constants deserve reading at
any size.

Both cases sharpen the chapter's rule. What matters is not whether the diff
*looks* like a removal but whether the change removes a behavior, and those
two questions come apart in exactly the cases where the answer matters most.

## Removal as the correct answer

A chapter arguing that removals deserve attention risks teaching that removals
are suspicious, which is a different and worse habit. Most deletions are good.
Dead code costs comprehension on every future read; an unused dependency is
attack surface; a test asserting an implementation detail obstructs the
refactor that would improve it; a feature nobody uses carries maintenance
weight forever. A codebase that only grows is not a well-cared-for codebase.

What distinguishes the deletions worth pausing on is not their size or their
proportion but whether they remove a *refusal*. Code that produces behavior
and code that prevents behavior look identical in a diff and fail differently
when removed: deleting a producer breaks something visibly, and the breakage
is its own alarm; deleting a preventer breaks nothing today and removes the
alarm itself. That asymmetry, rather than any general caution, is what earns
guards, bounds, validations, error branches, and assertions their extra
scrutiny.

The corollary matters for a reader's tone. A finding about a removed guard is
a question about what now prevents the thing, not an accusation; the answer is
frequently good — the check moved upstream, the type system now excludes the
case, the caller was the only path and it validates. Asking produces that
answer in one exchange. Withholding approval without asking produces a
stalled review and no information, which serves nobody and teaches the author
that review is an obstacle rather than a second pair of eyes.

## Reading a deletion-heavy change

Some changes are legitimately mostly removals — dead code cleanups, feature
removals, dependency drops — and treating every one with suspicion is as
unhelpful as treating none. The distinguishing questions are cheap.

What class of code was removed? Negative infrastructure — guards, bounds,
handlers, assertions — warrants explanation; genuinely dead code does not.
Was anything added to replace a refusal that was removed? A relaxed check with
no compensating control is a different change from one that moves validation
elsewhere. Do the removals cross a boundary, taking out both an implementation
and the thing that verified it? And does the message account for the removal
at all, or only for the addition?

That last question catches a surprising share of real problems. Messages are
written about what the author was trying to add. The removals are often the
means, and the means are what the reviewer needed to hear about. When a
message describes only the addition and the diff is mostly deletions, the
mismatch is not a style issue; it is the summary and the evidence describing
different changes, which is chapter 4's subject arriving with higher stakes.

## Removals, as a reading pass

The habits this chapter argues for compress into a short pass that can be run
on any change without knowing the codebase.

Read the removals first, before the additions, at least once. The ordering is
artificial and that is the point: it defeats the attention asymmetry by
refusing the sequence that produces it. In a change of any size this takes one
command — the removed lines are mechanically extractable — and it puts the
part most likely to matter in front of a fresh reader rather than a tired one.

Classify what was removed. Producing code and preventing code fail
differently when deleted, and only the second class needs an account. Guards,
bounds, validations, error branches, retries, timeouts, assertions, and tests
are the vocabulary worth recognizing on sight.

Check for the paired removal: an implementation change alongside a
net-negative change to its test file, in one commit. That shape is visible in
a stat, which is one of the few things a stat is genuinely good for, and it
is the single most informative signal in this chapter.

Apply the absence check to each removal of a refusal. What would a safe
version of this deletion also contain — the removal of the callers, a
replacement check elsewhere, evidence the case cannot occur — and is it here?
When it is not, the finding writes itself, and it is a question rather than an
accusation.

Finally, size the verdict honestly. "This code is no longer present" is
supported by the diff. "This code was unused" and "this deletion is safe" are
not, and reporting them as though the first established them is the specific
overreach this chapter exists to prevent.
