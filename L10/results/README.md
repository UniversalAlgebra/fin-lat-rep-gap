# `L10/results`

The output of each program under [`L10/`](..), committed beside the program
that produced it.  Two reasons it is kept: the report
[`docs/L10-is-representable.md`](../../docs/L10-is-representable.md) quotes
these numbers and a reader should be able to see where each one comes from,
and a later run can be diffed against them to show that nothing moved.

Everything here is generated.  Do not edit it by hand; rerun the program
instead, as [the main README](../../README.md#the-l10-programs) describes.

## The files

| File | Written by | What it holds |
| --- | --- | --- |
| `verifyPSL264.txt` | `verifyPSL264.g` | Tian's interval recomputed from his two matrices, and each lemma of his proof corroborated separately. |
| `tomScan.txt` | `scanAndResolve.sh` | The marks-only scan of all 414 tables of marks: one `HIT` or `AMBIGUOUS` line per candidate, then the totals. |
| `resolve/` | `scanAndResolve.sh` | One file per table recomputed explicitly.  See below. |
| `resolveSummary.txt` | `summarizeResolve.sh` | One line per explicit recomputation: group, class, orders, index, core-freeness, verdict.  67 lines, 6 positive. |
| `scanAndResolve.log` | `scanAndResolve.sh` | The driver's own run: which tables it launched, their exit statuses, and the summary it printed. |
| `certificateSizing.txt` | `certificateSizing.g` | Double coset counts and sampled word lengths for the two smallest representations. |
| `l10.raw.json`, `l10.search.json` | `pipelineRaw.g`, then agda-algebras | The two intervals in the FLRP campaign's interchange format, and that campaign's independent isomorphism verdict on them. |

## `resolve/`: one file per table of marks

The scan leaves 67 candidate intervals that the marks alone cannot settle or
that they settle as a hit.  Each is recomputed in its own GAP process, and each
process writes one file here, so there are 50 files for the 50 distinct tables
involved.  They are small, about 700 bytes each.

They are kept rather than summarised away because they carry what
`resolveSummary.txt` drops: the **orders**, the **structures** and above all
the **covers** of the interval that was found.  The summary records a verdict;
these records show the lattice the verdict is about.  The interval quoted for
Sp(6,2) in the report is read straight off the file below.

A file holds up to three kinds of line.

```
HIT S6(2) |G|=1451520 class 705 |H|=42 index 34560 interval orders [ 42, 336, 1512, 5040, 12096, 40320, 1451520 ]
scanned 1 tables; size-7 upper intervals: 25; marks-exact hits: 1; ambiguous cases: 0
EXPLICIT S6(2) class 705: |G| = 1451520 |H| = 42 (C7 : C6) index 34560 core-free true; interval size 7 orders [ 336, 1512, 5040, 12096, 40320 ] structures [ "PSL(3,2) : C2", "PSL(2,8) : C3", "S7", "PSU(3,3) : C2", "S8" ] covers [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 1, 4 ], [ 1, 5 ], [ 2, 6 ], [ 3, 5 ], [ 4, 6 ], [ 5, 6 ] ]; target: true (1876 ms)
```

+  **`HIT`** or **`AMBIGUOUS`**, one per candidate class, repeated from the
   marks-only scan.  `HIT` means the marks alone determined the interval and it
   matched the target; `AMBIGUOUS` means some conjugacy class meets the
   interval more than once, so the marks cannot place its members and the
   up-count profile was the only thing that matched.
+  **`scanned`**, the totals for this one table.
+  **`EXPLICIT`**, one per candidate class, the recomputation through
   `IntermediateSubgroups` on the table's own permutation group.  This is the
   authoritative line, and `target:` at its end is the verdict.

Reading the `EXPLICIT` line: `covers` numbers the interval with **0 for the
bottom `H`** and **`size - 1` for the top `G`**, the interior nodes taking the
positions of `orders` and `structures` in between, so `[ 1, 4 ]` means the
subgroup of order 336 is maximal in the one of order 12096.  Those covers are
what the isomorphism test consumes, and they determine the roles uniquely:
L10 has no nontrivial automorphism, so there is exactly one way to label an
interval isomorphic to it.

Two things will otherwise look wrong.

+  **The file names are the table names with every character a filename may
   not hold replaced by `_`**, which is not reversible.  Read the table's real
   name off the first line of the file rather than from its name.  For
   instance `2__1_4_-_A5.txt` is `2^(1+4)-:A5`, `_A5xA5__4.txt` is `(A5xA5):4`,
   and `2._2_5_S6_.txt` is `2.(2^5:S6)`.
+  **Two distinct tables can sanitize alike**, and the second then takes a
   `_2` suffix: `2_4_A8.txt` is `2^4:A8` and `2_4_A8_2.txt` is `` 2^4`A8 ``.
   The driver assigns the suffix in its sequential part, under `LC_ALL=C`, so
   the assignment does not move between runs.  Without this the second run
   overwrote the first, which is how a verdict once went missing.

**`(order 960)` where other lines name a group**.  Naming a subgroup with
`StructureDescription` is a convenience, not part of the test, and on
`2^6:U4(2)` and `G2(4)` it runs for over half an hour after a verdict reached
in about a second, which is longer than the driver's time limit allows.  The
driver turns naming off for exactly those two, and their lines give orders
instead.  The verdict is unaffected.

**`tables.txt` is an input, not a result**.  It is the list of tables the
driver decided to recompute, derived from `tomScan.txt`, and it is written
here because that is where the driver works.

## Regenerating

From the repository root:

```sh
gap -A -q -b L10/verifyPSL264.g       # verifyPSL264.txt
L10/scanAndResolve.sh                 # the scan, resolve/, the summary, the log
gap -A -q -b L10/certificateSizing.g  # certificateSizing.txt
```

The driver clears `resolve/` before it starts, so a rerun whose candidate set
has changed cannot leave a stale table behind in the summary.  It exits nonzero
if the scan fails or if any recomputation does.  The per-table timings in
milliseconds differ from run to run, and GAP does not name every subgroup
canonically, so a diff of `resolve/` after a rerun is expected to show those
two things and nothing else.
