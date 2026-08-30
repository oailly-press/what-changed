# Chapter 2 — The Base You Did Not Choose

*Draft status: author draft; human verification pending. Every runnable listing
was executed by the author during writing in a scratch repository the listing
itself creates; printed outputs are real transcripts.*

## Evidence that changes while you are not looking

Chapter 1 established that a diff is a comparison between two states and that
the reader must know which two. This chapter takes the harder half of that
question. In practice the base is rarely something the reader chose; it is
supplied by a tool, a forge, a habit, or a colleague's command line, and it
has a property transcripts do not: **it moves.** A transcript, once captured,
is a photograph of a moment. A diff computed against a branch name is a
photograph whose subject is re-posed every time someone else commits.

The consequence is a class of misreading with no equivalent in the transcript
world. The same command, run twice against an unchanged branch, returns
different evidence — and both results are correct. A reader who does not know
this attributes the difference to the change under review, which is precisely
where it did not come from.

## The branch did not move, and the diff did

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "shared\n" > shared.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "added by feature\n" > feature.txt
git add -A && git commit -qm "feature work"
git checkout -q main
echo "== before main moves =="
echo "two-dot:   $(git diff --shortstat main..feature)"
echo "three-dot: $(git diff --shortstat main...feature)"
printf "added by main\n" > other.txt
git add -A && git commit -qm "unrelated main work"
echo "== after main moves, feature untouched =="
echo "two-dot:   $(git diff --shortstat main..feature)"
echo "three-dot: $(git diff --shortstat main...feature)"
echo "merge base: $(git merge-base main feature | head -c 7)"
```

```output
== before main moves ==
two-dot:    1 file changed, 1 insertion(+)
three-dot:  1 file changed, 1 insertion(+)
== after main moves, feature untouched ==
two-dot:    2 files changed, 1 insertion(+), 1 deletion(-)
three-dot:  1 file changed, 1 insertion(+)
merge base: f675635
```

Nothing was done to the feature branch between the two measurements. One
commit landed on main, touching a file the branch has never heard of. The
two-dot comparison responds by reporting that the branch now changes two files
and deletes one line; the three-dot comparison reports exactly what it
reported before.

Read the two-dot result as evidence and it says something false in a
particularly damaging way. It does not merely overstate the branch's size — it
attributes a *deletion* to an author who deleted nothing. In a review this is
the finding that stops everything, because removing a colleague's file looks
deliberate and looks careless at once. The reviewer who writes "you appear to
have dropped other.txt" has read the output correctly and the evidence
incorrectly, and the resulting exchange costs two people twenty minutes to
arrive back where they started.

The three-dot form is stable because its base is not a moving branch tip but
the merge base — the last commit the two histories shared, printed here as
`f675635`. That commit does not move when main advances. Anchoring to it is
what makes the question "what did this branch contribute" answerable at all,
and it is why forge interfaces present pull requests this way. The command
line does not default to it, which is the whole reason this chapter exists.

For judgment the rule is compact. A claim about *what a branch contributed*
requires a merge-base comparison; a two-dot range cannot support it once the
histories have diverged, and whether they have diverged is not visible in the
diff. A claim about *how two tips differ right now* — which is a real question
when deciding whether to deploy one or the other — is exactly what two-dot
answers, and three-dot would answer it wrongly. Neither form is correct in
general. The reader's job is to notice which question the evidence in front of
them was computed to answer.

## The same change, a different identity

The second way a base moves is more disorienting, because it changes the
identity of the change itself rather than the comparison around it.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "one\n" > a.txt
git add -A && git commit -qm base
git checkout -q -b topic
printf "two\n" > b.txt
git add -A && git commit -qm "topic change"
echo "topic commit before rebase: $(git rev-parse --short HEAD)"
echo "patch id: $(git show HEAD | git patch-id --stable | cut -c1-12)"
git checkout -q main
printf "three\n" > c.txt
git add -A && git commit -qm "main advances"
git checkout -q topic
git rebase -q main
echo "topic commit after rebase:  $(git rev-parse --short HEAD)"
echo "patch id: $(git show HEAD | git patch-id --stable | cut -c1-12)"
```

```output
topic commit before rebase: 7b37ad3
patch id: 5ef6b1067251
topic commit after rebase:  8718db3
patch id: 5ef6b1067251
```

The commit identifier changed. The patch identifier did not. Those two facts
together are the precise statement of what a rebase does: it produces a new
commit — new parent, new hash, new object — carrying the same change. The
commit hash covers the whole history and metadata, so replaying the work onto
a different parent necessarily yields a different one. The patch-id is a
digest of the diff itself, deliberately insensitive to context such as line
offsets, which is why it is the tool for asking "is this the same change?"
across histories that have been rewritten.

This matters to a reader for two reasons that arrive at different times.
Immediately: a review comment anchored to `7b37ad3` now points at a commit no
branch contains. The comment is not wrong, and the code it discusses may be
present verbatim, but the anchor is dangling, and a reader who concludes the
change was withdrawn has misread a rewritten history as a reverted one.
Later: when someone asks whether a fix that landed on a release branch is the
same fix that landed on main, hashes cannot answer — cherry-picks and rebases
guarantee different hashes for identical content — while patch-ids can.

The general lesson is that git has two notions of sameness and they answer
different questions. Identity of *commit* answers "is this the same entry in
this history." Identity of *change* answers "is this the same work." Reviews
run on the first and reason about the second, and the gap between them is
where a reader concludes that work vanished, was duplicated, or was applied
twice, when the history was merely reshaped.

## When the ground moves mid-review

Put the two mechanisms together and the practical hazard appears. A reviewer
reads a branch on Monday, leaves comments, and returns on Wednesday. In
between, the author rebased onto a main that had advanced. Every commit hash
has changed. The line numbers in the comments may no longer correspond to the
lines they were attached to. A two-dot diff now includes other people's work.
And none of this is announced by the evidence: the branch has the same name,
the same description, and a diff that renders without complaint.

The reader's defense is a habit rather than a tool. Establish the base
explicitly before forming any judgment that will be written down: which
commit is the merge base, and is the diff in front of you computed against it.
When resuming a review, ask whether the branch has been rewritten since the
last read, because that single fact determines whether prior comments still
attach to anything. And when a claim depends on "this is the same change we
reviewed," reach for a comparison that survives rewriting rather than for the
hash, which does not.

Git provides a purpose-built instrument for the resumed review, `git
range-diff`, which compares two versions of a branch by pairing up their
commits and showing how each one changed between the versions. It is the right
answer to "what did the author actually alter since I last looked," and it is
strictly better than re-reading the whole branch, because re-reading cannot
distinguish the parts that are new from the parts you already approved. This
volume does not print a range-diff transcript, because its output format is
dense enough to deserve the extended treatment it gets in the chapter on
summaries; the pointer belongs here, where the need for it arises.

## Two histories that hold the same work

The patch-id result has a consequence worth drawing out, because it is the
question a reader is most often asked about release management and least
often equipped to answer: has this fix reached that branch?

Hashes cannot answer it. A cherry-pick produces a new commit for the same
change by construction; so does a rebase; so does a backport that adjusts
context to fit an older file. Searching a release branch for the main
branch's commit hash will report absence for every fix that arrived by any of
those routes, which is most of them. A reader who reports "the fix is not on
the release branch" on that evidence has measured commit identity and made a
claim about change identity.

The instruments that answer the real question fall into three tiers, and the
tiers differ in what they tolerate. Patch-id matching, as the transcript
above demonstrates, is insensitive to line offsets and so survives a rebase
onto a different base; it does not survive a backport that had to alter the
change to apply. `git cherry` uses exactly this comparison to report which
commits in one branch have no equivalent in another, which makes it the
purpose-built tool for the question. Where the change had to be adapted,
neither will match, and the only honest evidence is the content itself: does
the release branch's file contain the corrected logic. That last check is a
state question, which chapter 1 established a diff cannot answer, so the
evidence has to come from reading the file rather than from any comparison of
histories.

The judgment discipline follows the tiers. "The same commit is present"
is a strong claim available only when no rewriting occurred. "An equivalent
change is present" is what patch-id supports and is usually the claim that
matters. "The corrected behavior is present" is a claim about state and
requires looking at the state. Readers slide between the three because
English lets them, and the slide is invisible until a release ships without a
fix that three people confirmed had landed.

## Bases that are not branches

Three more base choices appear often enough in agent work to name, each
answering a question readers routinely confuse with the others.

A **tag or release** as base answers "what has changed since we shipped." It
is stable, which makes it good evidence, and it is usually far behind, which
makes the resulting diff large and its per-change attribution poor. A finding
drawn from such a diff belongs to the interval, not to any one author.

The **working tree against the index against HEAD** triad from chapter 1
answers questions about local, uncommitted state. Its distinguishing property
is that it is not shared: no one else can reproduce it, and it will not exist
tomorrow. Evidence of this kind supports claims about what is about to be
committed and nothing about what the project contains.

A **stash or a specific blob** as base answers narrow historical questions and
appears mostly in recovery work. The thing worth knowing is that such
comparisons are legitimate and that their bases are invisible in the output,
so a diff arriving without its command line may have been computed against
something a reader would never guess.

Behind all three is the same discipline. The base is a premise, and premises
that arrive unstated are assumed rather than known. When a claim about a
change matters and the base is not in evidence, the honest verdict is
insufficient, and the missing evidence is usually one line of command that
someone did not think to paste.

## A base the clone does not contain

Every comparison so far assumed the base was present. A clone made for speed
may not contain it. Fetching a single commit's worth of history gives a
repository the branch tips and nothing behind them, and the commit where two
histories diverged is behind them by definition.

In that state the tooling does not quietly choose a different base.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work
git init -q -b main origin
cd origin
printf "shared\n" > base.txt
git add -A && git commit -qm base
git checkout -q -b feature
printf "feature\n" > feature.txt
git add -A && git commit -qm "feature work"
git checkout -q main
printf "main\n" > main.txt
git add -A && git commit -qm "main work"
cd ..
git clone -q --depth 1 --no-local --branch feature "file://$PWD/origin" shallow 2>/dev/null
cd shallow
git fetch -q --depth 1 origin main:refs/remotes/origin/main 2>/dev/null
echo "is shallow: $(git rev-parse --is-shallow-repository)"
echo "== three-dot against the fetched main =="
git diff --stat origin/main...HEAD > /dev/null 2>err.txt
echo "three-dot exit: $?"
cat err.txt
echo "== merge-base =="
git merge-base origin/main HEAD > /dev/null 2>&1
echo "merge-base exit: $?"
echo "== two-dot still answers =="
git diff --stat origin/main..HEAD
```

```output
is shallow: true
== three-dot against the fetched main ==
three-dot exit: 128
fatal: origin/main...HEAD: no merge base
== merge-base ==
merge-base exit: 1
== two-dot still answers ==
 feature.txt | 1 +
 main.txt    | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)
```

The three-dot form refuses outright — exit 128, `no merge base` — and
`merge-base` exits 1 without printing one. Both failures are loud and
unambiguous, which is the good news.

The trap is what remains available. The two-dot form still works, because comparing two tips needs no
ancestry at all, and it produces a confident, complete, thoroughly misleading
answer: the branch appears to delete everything the target branch gained. A
wrapper written to try the correct comparison and fall back when it fails has
therefore downgraded the base silently, and its output looks like every other
diff.

The diagnosis is one question the repository will answer directly —
`git rev-parse --is-shallow-repository` returns true or false — and the repair
is to fetch enough history that the merge base exists as an object. Neither
costs much. What costs a great deal is reading a two-dot result as a branch's
contribution: it is the misreading this chapter opened with, arriving by a
route that leaves no trace, because here the merge base is not merely unused
but missing.

The generalization is that a checkout performed by a machine embodies a base
decision made in configuration, by someone who was optimizing for how long the
clone takes. That decision is not in the diff, and the diff will not mention
that it was made.

## A merge base too old to be useful

Three-dot comparison is stable however long a branch lives; what decays is the
usefulness of what it reports. The removed lines in such a diff are the file as
it stood at the merge base. If the target branch has since changed those same
lines, the minus side displays a version of the file that exists nowhere — not
on the branch, which replaced it, and not on the target, which moved past it.

That is a sharper problem than the diff being large. A reader who takes the
minus side as "what the code says today" is wrong, and nothing in the output
distinguishes an old merge base from a recent one. A branch that raised a
timeout to sixty can show itself replacing a thirty that the target branch
already raised to forty-five, and the diff is correct: sixty is what the branch
did to thirty. It is simply answering a question about a state that has been
superseded.

Two questions separate here that were one question for a young branch. *What
did this branch contribute* is what three-dot answers, and it stays answerable.
*What happens if this branch lands* is a different question, and no diff
answers it, because the comparison against an ancestor cannot surface a
conflict — it is not a merge, and it does not attempt one. So "this branch
changes only the timeout" can be fully supported while "landing this branch
changes only the timeout" remains insufficient on the same evidence.

The age of a merge base is checkable, and it changes for a reason: merging the
target branch into the topic moves the merge base forward to the commit that
was merged, and rebasing moves it by moving the branch. Until one of those
happens, the base is where the branch started, however many months ago that
was, and the minus side is a historical document.

## The merge commit, which has two bases

A merge has two parents, so the question "what did this commit change" has no
single answer, and different commands resolve the ambiguity differently. The
resulting inconsistency is a live trap for anyone reading history in bulk.

```bash
export TZ=UTC
export GIT_AUTHOR_NAME=A GIT_AUTHOR_EMAIL=a@e
export GIT_COMMITTER_NAME=A GIT_COMMITTER_EMAIL=a@e
export GIT_AUTHOR_DATE="2026-01-01T00:00:00Z" GIT_COMMITTER_DATE="2026-01-01T00:00:00Z"
mkdir work && cd work && git init -q -b main
printf "base\n" > f.txt
git add -A && git commit -qm base
git checkout -q -b side
printf "side\n" >> f.txt
git add -A && git commit -qm side
git checkout -q main
printf "main\n" >> f.txt
git add -A && git commit -qm main
git merge -q side > /dev/null 2>&1
printf "base\nresolved\n" > f.txt
git add -A && git commit -qm "merge with resolution" > /dev/null 2>&1
echo "== git log -p on the merge: how many +/- lines? =="
git log -p -1 --format="" | grep -c "^[+-]"
echo "== git log -p --cc on the same merge =="
git log -p -1 --cc --format="" | grep -c "^[+-]"
echo "== the resolution, compared against the first parent =="
git diff HEAD^1 HEAD | grep "^[+-]" | tail -2
```

```output
== git log -p on the merge: how many +/- lines? ==
0
== git log -p --cc on the same merge ==
4
== the resolution, compared against the first parent ==
-main
+resolved
```

The merge in that repository is not a formality. Both branches changed the
same line, the conflict was resolved by hand, and the resolution discarded
both sides in favour of a third value. It is a genuine authored change with
no representation in either parent.

`git log -p` shows zero changed lines for it. Not a summary, not an
abbreviation: nothing. Patch output for merges is off by default, so a
history read this way presents the merge as an empty event. Ask the same
command for the combined form and four changed lines appear; compare against
the first parent directly and the resolution is explicit, replacing `main`
with `resolved`.

For a reader the consequence is specific and serious. Bulk history readings —
"summarize what landed this week," "find where this line changed" — are
usually built on patch output over a commit range, and if merges are silent
in that output then every hand-resolved conflict is invisible to the summary.
That is the population of changes most likely to contain a quietly dropped
fix, because a resolution is where someone decides which side survives and
can decide wrongly. The absence is not evidence that merges changed nothing;
it is the default answering a question it was never asked.

The rule is to treat silence about a merge as "not yet asked." When a claim
depends on what a merge did, name the base explicitly — one parent, or the
combined form that shows lines differing from both — and read the resolution
rather than inferring it from the parents.

## Whose main is the base

A fork-based workflow puts two repositories in play, each with a branch called
main, and the two are different refs that happen to share a name. The change is
offered to one of them; the checkout on the reader's disk usually points at the
other.

While the fork's main is merely behind the upstream's, nothing goes wrong. Both
give the same merge base, because being behind means being an ancestor, and the
three-dot diff is identical whichever name is used. The divergence begins the
moment the fork's main carries a commit the upstream never took — a sync
performed as a merge rather than a fast-forward, a local convenience change, a
revert that was never proposed. From then on the two refs have separate tips
and separate merge bases with the topic branch.

The consequence is quiet, which is what makes it worth naming. A topic branch
that inherited the fork's extra commit shows one contribution when compared
against the fork's main and two when compared against the upstream's, and the
extra file is real work that the upstream project would receive. The
fork-local comparison is the *smaller* one. It does not invent changes, as a
two-dot range does; it conceals them, and a concealed contribution produces no
alarming output for anyone to investigate.

So the base belongs to the repository that will receive the change, not to the
one the comparison happens to be run in. Naming the remote explicitly costs one
token of typing, and what it settles is which project's history the change is
being measured against — a question that has two defensible answers and only
one correct one for the claim being made.

## Why the browser and the terminal disagree

A reader who checks a pull request in a forge interface and then reproduces
it at a terminal will sometimes find two different diffs for the same change,
and the discrepancy is usually one of three things rather than a defect.

The base is the first. Forge interfaces present a merge-base comparison, so
their file counts and line totals match the three-dot form and not the
two-dot form a reader is likely to type. When the numbers differ and the
branch has diverged, this alone explains it.

Rename detection is the second, and it is a matter of degree rather than
presence: detection is configurable, and interfaces and command lines do not
always run it with the same settings. The same commit can therefore appear as
a rename with a small edit in one view and as a wholesale deletion plus
addition in another, with wildly different line counts and the same
underlying change. Chapter 5 takes this apart; here it is enough to know that
a line-count disagreement between two views is not evidence that one of them
is wrong.

The third is the range itself. An interface showing "changes since your last
review" is comparing two versions of the branch, not the branch against its
base, which is a different question with a different answer — the resumed
review problem from earlier in this chapter, presented as though it were the
ordinary view.

None of the three is a fault, and a reader who knows them stops treating the
disagreement as a puzzle. The productive response is not to decide which view
is authoritative but to name what each one computed, because the two views
are usually answering different questions and both answers may be needed.

## What a stated base buys

It is worth naming what improves when the base is explicit, because the effort
is small and the payoff is not obvious in advance.

Attribution becomes possible: a merge-base comparison bounds the change to one
line of work, so a finding can be addressed to the person who can act on it.
Re-running becomes possible: a diff against a fixed commit can be reproduced
next week and will show the same thing, which is what allows a disagreement to
be settled rather than re-argued. Scope becomes checkable: a reviewer can say
which files were in frame and be right about it. And the review's claims
acquire a shelf life, because a conclusion drawn against a named base remains
true of that comparison even after the branches move on.

None of that requires knowing more git than this chapter has used. It requires
treating "against what?" as the first question rather than an implementation
detail — which is the same move the previous volume made when it insisted that
a status be attributed to a specific command before it is read. Evidence
without its provenance is not weak evidence. It is evidence whose meaning has
not been fixed yet, and fixing it is the reader's work.

The next chapter turns to the marks themselves: what the prefixes, headers,
and hints in a unified diff actually assert, and the one confusion between
changed lines and context lines that produces more wrong review comments than
every base error in this chapter combined.
