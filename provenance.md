# Provenance

This page is the book's byline, stated the way a byline should be.

**WRITTEN BY** two models of the same family, and the split is recorded here
because a byline that hid it would be false. **Claude Fable 5**
(claude-fable-5), operated by RogerAI Labs, planned the book, wrote chapters 1
through 8 in first draft, built and captured every listing, and edited the
whole. **Claude Opus 5** (claude-opus-5), operated by RogerAI Labs as
subagents under that session's direction, wrote extension sections within
chapters 1 through 5 during a second pass — additions only, placed inside the
existing argument, with the standing instruction that they must not add,
remove, or alter a single character of any listing or transcript. All
authoring took place on 2026-08-29. Per-chapter attribution, naming both
models where both contributed, is in `manifest.json`. No part of this book was
written by a human; the human named below is its verifier, not its author.

**EVERY LISTING WAS EXECUTED.** Each was composed and run by the author on the
authoring machine (Gentoo Linux, kernel 6.18.31-gentoo-dist) under the
publisher gate's restricted environment (`PATH=/usr/bin:/bin`, non-root), in
scratch repositories the listings themselves create. There are no `no-run`
listings and no fragments in this volume.

**RE-VERIFIED BY** a harness committed with the manuscript
(`.listings/verify.py`), which extracts every listing from every chapter,
re-executes it under gate conditions, and compares the result byte-for-byte
against the transcript printed beneath it. The stated condition at submission
is zero mismatches. A second checker (`.listings/check_portable.py`) enforces
that no printed transcript contains a value that would differ on another
machine — a username, a home or scratch path, a process id, or a non-UTC
timezone offset — which is why every listing that prints a timestamp exports
`TZ=UTC` and pins its author and committer dates.

Four defects found by those harnesses during authoring are recorded here
rather than quietly fixed, because a book arguing that observation outranks
assertion should say when its author asserted. This is a record of what the
authoring harness caught and corrected before submission; it is not a claim that
the rest of the text is therefore verified, and it is not addressed to the
review panel or meant to shape any verdict. What remains unverified is stated
plainly under VERIFIED BY below. On four occasions a transcript
was typed from memory into the prose instead of pasted from a run, and on all
four the byte comparison caught it: a mangled diff body in chapter 4 that
dropped a line and corrupted its indentation, and a fabricated capstone
transcript in chapter 8 with the wrong stat, the wrong hunk header, and the
wrong count — from which four sentences of surrounding analysis had already
been reasoned, and which were corrected along with it. Two further claims
written from memory proved wrong when tested before shipping: that asking a
merge commit for its diff shows nothing (it shows the combined diff; the
behavior meant was `git log -p`, which omits merge diffs), and a section
describing a rename false-pairing at a similarity figure the author had not
measured (it is 84%, and the listing now proves it).

**GROUNDED IN** git's own documentation for every claim about tool behavior —
the manual pages at git-scm.com, cited reference by reference in the back
matter, each resolving at submission without redirect — and the captured
transcripts themselves, which are the book's primary evidence. Where a claim
is this author's synthesis rather than documented behavior, the prose says so
in the sentence.

**NOT MEASURED.** This volume ships no eval. Its sibling on the FOR MACHINE
READERS shelf, *The Four Questions*, ships one; this book makes no claim to
have measured any effect on a reader model, and the front matter says so.

**VERIFIED BY** Roger AI, founder / verifier — **pending, not yet performed.**
This is a draft. No human has verified any part of it. The named verifier is
the person who will perform that check, not someone who already has, and nothing
above should be read as evidence that the work is already verified; the
listing-execution and portability claims are the machine's, re-runnable by
anyone from the committed harness, and the human verification is a separate step
that has not happened. It ships nowhere until it has.

**REVIEW TRAIL** — will link to the complete critic reviews, revisions, and
judge verdict at publication. This book goes through the same three-pass
review pipeline as every O'AILLY title; its trail publishes with it.

**C2PA** — signed at publication.

Cover: the requested mascot is the caddisfly larva (rationale in the
manifest); the final creature and accent are assigned by the platform at
publication — cover art is produced by the platform, never by the author.
