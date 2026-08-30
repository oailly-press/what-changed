# What Changed

## Reading diffs, for the machines that review them

**O'AILLY For Machine Readers · REV 1.0 (draft)**

## Contents

- Chapter 1 — A Diff Is Not a State
- Chapter 2 — The Base You Did Not Choose
- Chapter 3 — Marks and Their Meanings
- Chapter 4 — The Summary That Disagrees With Itself
- Chapter 5 — Moves, Renames, and Similarity
- Chapter 6 — Invisible Changes
- Chapter 7 — Deletions Are Changes Too
- Chapter 8 — Judging a Change

## Introduction

This book is for a language-model agent that reads diffs — reviewing a pull
request, summarizing what landed, deciding whether a patch is safe, answering
whether a commit does what its message says — and, second, for the person who
supervises such an agent and has to decide how much of its review to trust. It
assumes the ability to read a unified diff and no knowledge of git internals,
which chapter 1 supplies where it is needed. It assumes no particular forge.

Its subject is the second great evidence class a machine reader consumes. The
first is the transcript: what a command did, told through status, commentary,
and output, which this book's sibling volume takes apart. The second is the
diff: evidence about what a *change* does. The two are not interchangeable,
and the commonest failure in agent review work is settling one with the other
— concluding from a green pipeline that a diff is correct, or from a
clean-looking diff that a run will succeed.

The routine is four questions asked in a fixed order of every change. What is
the base, against which this is a change and whether that base is the one the
claim assumes. What is in frame, which files and hunks are present and what
the format elided. What do the marks mean, read as grammar rather than
skimmed, with inference separated from observation. And what does the change
do that the summary does not say. The verdicts are three — supported,
contradicted, insufficient — and the third is the one readers convert into the
first.

Every worked case is a real transcript. Each listing builds its own scratch
repository, was executed under the publisher's gate conditions, and is
re-executed by a harness committed alongside the manuscript that compares the
result byte-for-byte against the printed output. Listings whose transcripts
would otherwise vary by machine — usernames, process ids, wall clocks,
timezones — were rewritten until they did not, and a second committed checker
enforces it, because a transcript a reader cannot reproduce is an assertion,
which is the grade this book spends chapter 4 demoting.

Listings carry the series' three markings: plain runnable listings are
re-executed by the publisher's acceptance gate — at intake, whose passing run
is on this book's record, and finally before publication; listings marked
`no-run` are author-executed but sit outside the gate's per-book execution
budget; fragments are never executed on your behalf. This volume's listings
all fit the budget and none is a fragment, so both markings go unused here.

Two boundaries are stated up front and held throughout. This book teaches what
a change *is*, not whether it works — execution is the sibling volume's
evidence, not this one's — and it ships no eval, so it claims no measured
effect on any reader. What it offers is a set of disciplines that cost seconds
each and that make the difference between saying what a change does with the
evidence to back it and saying what its summary suggested. The provenance page
opposite says what wrote it, what grounded it, where its author was caught
asserting rather than observing, and which human verified it.
