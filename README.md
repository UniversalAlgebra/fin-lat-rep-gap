# fin-lat-rep-gap

GAP programs written for the article *Representing Finite Lattices as
Congruence Lattices of Finite Algebras*, by William DeMeo, Ralph Freese, and
Peter Jipsen.  The article itself, and the rest of the project, is in
[UniversalAlgebra/fin-lat-rep][].

These programs cover the group-theoretic part of the paper: showing that a
given lattice is an interval in the subgroup lattice of a finite group, or the
union of a filter and an ideal in one, and searching the Small Groups Library
for groups whose subgroup lattices contain a given upper interval.  The other
two methods the paper uses live elsewhere; see
[What is not here](#what-is-not-here) below.

## The programs

| File | What it does | Where the paper uses it |
| --- | --- | --- |
| [`findUpperIntervals.g`](findUpperIntervals.g) | Searches the Small Groups, transitive, and primitive group libraries for upper intervals `[H,G]` of a prescribed size, and writes a catalog of the isomorphism types found. | The search behind the claim that `SmallGroup(216,153)` is the smallest group with a pentagon as an upper interval (Section 1). |
| [`PJ11.gap`](PJ11.gap) | Realizes **L<sub>11</sub>** as the union of a filter and an ideal in `Sub(SmallGroup(216,153))`, first on 216 points, then on 108. | Section 3.  The file is the computation written out in the discussion after the figure for L<sub>11</sub>, command for command. |
| [`PJ17.gap`](PJ17.gap) | Realizes **L<sub>17</sub>** as an interval in `Sub(SmallGroup(288,1025))`, where `SmallGroup(288,1025)` is (A<sub>4</sub> × A<sub>4</sub>) : C<sub>2</sub>. | Section 4, the catalog entry for L<sub>17</sub>.  This is a different representation from the 12-element one tabulated there. |
| [`Hexagon.g`](Hexagon.g) | Checks that Pálfy's example in A<sub>11</sub> really is a hexagon, on a set of size 9! = 362880. | Section 1, the discussion of L<sub>6</sub> and the representations found by Pálfy and Aschbacher. |
| [`pentagonSearch.g`](pentagonSearch.g) | Verifies that `SmallGroup(216,153)` is the smallest group with the pentagon N<sub>5</sub> as an upper interval. | Section 1, the claim about N<sub>5</sub> and `SmallGroup(216,153)`. |

`L` numbering is the paper's.  It agrees with the `PJ` and `J` numbering used
in the `.ua` files and in Peter Jipsen's catalog, so `PJ11` is L<sub>11</sub>,
`B11` is the algebra for L<sub>11</sub>, and so on.

## The L<sub>10</sub> programs

L<sub>10</sub>, the one lattice with at most seven elements that the paper
leaves open, is the congruence lattice of a finite algebra after all.  Chenxiao
Tian's note of 2026-08-28 represents it as the interval [S<sub>3</sub>, PSL(2,64)],
and a scan of GAP's library of tables of marks finds five more groups with
L<sub>10</sub> as an upper interval, one of them, Sp(6,2) above a Frobenius
group of order 42, with the smaller index 34560.  The programs under
[`L10/`](L10/) verify the note, run the scan, and measure what a machine-checked
certificate would cost; the report
[`docs/L10-is-representable.md`](docs/L10-is-representable.md) gives the
results and the reasoning, and `L10/results/` holds the outputs the report
quotes.

| File | What it does | Output |
| --- | --- | --- |
| [`L10/verifyPSL264.g`](L10/verifyPSL264.g) | Recomputes Tian's interval [S<sub>3</sub>, PSL(2,64)] from his two matrices and corroborates each lemma of his proof. | `L10/results/verifyPSL264.txt` |
| [`L10/tomScan.g`](L10/tomScan.g) | Hunts a target lattice (L<sub>10</sub> by default) as an upper interval across every table of marks in TomLib, from the marks alone, then recomputes the candidates explicitly. | `L10/results/tomScan.txt` |
| [`L10/scanAndResolve.sh`](L10/scanAndResolve.sh) | Runs the scan and then one explicit recomputation per table, several at a time. | `L10/results/resolve/` |
| [`L10/summarizeResolve.sh`](L10/summarizeResolve.sh) | Reduces those recomputations to one line each, with the verdict. | `L10/results/resolveSummary.txt` |
| [`L10/certificateSizing.g`](L10/certificateSizing.g) | Counts the double cosets and samples the word lengths a certificate of the two smallest representations would need. | `L10/results/certificateSizing.txt` |
| [`L10/pipelineRaw.g`](L10/pipelineRaw.g) | Cross-checks both intervals with the isomorphism test of the agda-algebras FLRP campaign; needs that repository. | `L10/results/l10.search.json` |
| [`L10/latticeTests.g`](L10/latticeTests.g) | The target lattice as a poset, and the two routines the others share. | |

These need the `tomlib` package, which standard GAP distributions include, and
are run from the repository root, as follows:

    gap -A -q -b L10/verifyPSL264.g

## Running them

Everything here runs on a plain GAP with the Small Groups Library, which comes
with a standard GAP distribution.  Nothing else is needed.

    gap Hexagon.g

or, from inside a GAP session, as follows:

    gap> Read("findUpperIntervals.g");
    gap> findUpperIntervals([3, 255, 4, 10, 1, 1, 0, 1]);

That call finds every upper interval `[H,G]` with between 4 and 10 elements and
`H` core-free, among the groups `G` of order 3 to 255.  `findUpperIntervals.g`
documents its own arguments at the head of each function.

`pentagonSearch.g` answers one question rather than building a catalog, and is
much faster for it, as follows:

    gap> Read("pentagonSearch.g");
    gap> pentagonSearch(3, 216);

It avoids computing a single full subgroup lattice.  If `[H,G]` is a pentagon
then its two coatoms are maximal subgroups `B` and `C` of `G`, and the meet of
`B` and `C` in the interval is `B` &cap; `C`, which is the bottom `H`.  So the
candidates for `H` are the intersections of pairs of maximal subgroups, and `B`
may be taken from a set of class representatives.  Without that, the 2328
groups of order 128 alone take longer than the whole rest of the search.

For each group it finds, it reports how many subgroups witness the pentagon,
how many conjugacy classes they fall into, and their orders, indices and
isomorphism type, so the whole claim is established by this one program.

Several routines in `findUpperIntervals.g` write their results to a file.  By
default those files go to the directory GAP was started in.  To send them
elsewhere, set `FLR_OUTPUT_DIR` before reading the file, as follows:

    gap> FLR_OUTPUT_DIR := "/tmp/gap-outputs/";;
    gap> Read("findUpperIntervals.g");

The directory must already exist and the name must end in a slash.

## Reproducing the paper's numbers

All four programs were run on **GAP 4.15.1** on 2026-09-13.  Each reproduces
the result the paper quotes, as follows:

| Program | Result |
| --- | --- |
| `PJ11.gap` | `IntermediateSubgroups(G,H)` returns covers `[[0,1],[0,2],[1,3],[2,4],[3,4]]`, so `[H,G]` is the pentagon with `[G:H] = 36`.  `H` is cyclic of order 6; its subgroup of order 2 has index 108 and is covered in `B` by subgroups avoiding `A` and `C`, while its subgroup of order 3 has index 72 and is covered by none, which is exactly the paper's conclusion that 108 is the best this method gives. |
| `PJ17.gap` | Covers `[[0,1],[0,2],[0,3],[0,4],[1,6],[2,5],[3,5],[4,5],[5,6]]`, a lattice isomorphic to L<sub>17</sub>, with `[G:H] = 48`. |
| `Hexagon.g` | Exactly 2 maximal subgroups of A<sub>11</sub> contain `H = C11 : C5`; they meet at `H`; `[H,M11]` and `[H,M11Other]` are 3-element chains; `[H,A11]` has covers `[[0,1],[0,2],[1,3],[2,4],[3,5],[4,5]]`, the hexagon; and `[A11:H] = 362880 = 9!`. |
| `findUpperIntervals.g` | Reads and runs, and `findUpperIntervals([3,48,4,6,1,1,0,1])` produces its catalog of upper intervals of size 4 to 6 among the groups of order 3 to 48. |
| `pentagonSearch.g` | `pentagonSearch(3, 216)` examines, for every group of order at most 216, the core-free intersections of pairs of maximal subgroups, which are the only subgroups that can sit at the bottom of a pentagon interval.  Over the 214 orders from 3 to 216 it prints exactly one line: `PENTAGON  SmallGroup(216,153): 12 subgroup(s) H in 1 conjugacy class(es); orders [ 6 ], indices [ 36 ], isomorphism type C6`.  Six to thirteen minutes, depending on the machine. |

## A warning about indices into GAP's lists

Two of these programs originally picked subgroups out by their **position** in
the list returned by `ConjugacyClassesSubgroups` or
`MaximalSubgroupClassReps`.  Those positions are not stable across GAP
versions, and both programs had drifted, as follows:

+  In `Hexagon.g`, `MaximalSubgroupClassReps(M11)[4]` was PSL(2,11) when the
   script was written.  On GAP 4.15.1 it is S<sub>5</sub>, and every step after
   it was then working on the wrong subgroups: the script reported 5 maximal
   subgroups containing `H` instead of 2, and `M11 = Intersection(...)` came
   out false.  The whole argument collapsed silently, with no error.
+  In `PJ11.gap`, `ConjugacyClassesSubgroups(B)[4]` was a subgroup of `H` when
   the script was written.  On GAP 4.15.1 it is not, so the second half of the
   minimality argument was checking the wrong group.

Both are now fixed by selecting subgroups by the property that identifies them,
which is their order in these cases.  If you add a program here, select
subgroups by a property and not by an index.

## What is not here

Three other pieces of software behind the paper live in their own repositories,
as follows:

+  **The algebras.**  The unary algebras B<sub>1</sub>, ..., B<sub>35</sub>
   whose congruence lattices are the lattices catalogued in the paper are in
   `CongruenceLatReps/SmallLatticeReps.ua` in [UACalc/AlgebraFiles][], together
   with the groups and G-sets used here.  They are UACalc files; open them with
   the [Universal Algebra Calculator][].
+  **The closure algorithm**, which is the main workhorse of the paper and
   produces minimal representations, is part of UACalc itself:
   `org/uacalc/alg/conlat/BasicPartition.java` in [UACalc/uacalcsrc][], in the
   section headed `// Work on the concrete representation problem`.  The
   relevant methods are `unaryPolymorphisms` and `unaryPolymorphismsAlgebra`,
   reached from the congruence lattice drawing in the UACalc user interface.
+  **The overalgebras construction** of [DeMeo (2013)][], used for
   B<sub>3</sub>, B<sub>6</sub>, B<sub>7</sub>, B<sub>9</sub>,
   B<sub>13</sub>, B<sub>27</sub>, and B<sub>28</sub>, is in
   [williamdemeo/Overalgebras][], along with `gap2uacalc.g`, the program that
   converted the GAP groups and G-sets used here into the `.ua` files above.

## `obsolete/`

`obsolete/Install_new_IntermediateSubgroups_method.gap` installs a fast method
for `IntermediateSubgroups` that GAP did not have when this work was done.  It
is no longer needed: the same method has been in the GAP library since GAP 4.9.
See [`obsolete/README.md`](obsolete/README.md).

## Provenance

These files were part of [UniversalAlgebra/fin-lat-rep][] under `programs/gap/`
until September 2026, and their history there is preserved in this repository.
Earlier and messier versions of several of them, along with a great deal of
related exploratory work, are in [williamdemeo/GAP_wjd][].

## License

MIT; see [`LICENSE.txt`](LICENSE.txt).

The one exception is
`obsolete/Install_new_IntermediateSubgroups_method.gap`, which is an early
version of GAP library code contributed by Alexander Hulpke and is covered by
GAP's own license, the GNU General Public License version 2 or later.  The MIT
license does not apply to it.

## How to cite

Cite the article, and cite this repository for the programs:

    @misc{fin-lat-rep-gap,
      author = {William DeMeo},
      title  = {fin-lat-rep-gap: {GAP} programs for representing finite lattices},
      year   = {2026},
      note   = {Available at: \verb+https://github.com/UniversalAlgebra/fin-lat-rep-gap+},
    }

This research was supported by the National Science Foundation under Grant
No. 1500235.

[UniversalAlgebra/fin-lat-rep]: https://github.com/UniversalAlgebra/fin-lat-rep
[UACalc/AlgebraFiles]: https://github.com/UACalc/AlgebraFiles
[UACalc/uacalcsrc]: https://github.com/UACalc/uacalcsrc
[williamdemeo/Overalgebras]: https://github.com/williamdemeo/Overalgebras
[williamdemeo/GAP_wjd]: https://github.com/williamdemeo/GAP_wjd
[Universal Algebra Calculator]: https://uacalc.org
[DeMeo (2013)]: https://doi.org/10.1007/s00012-013-0226-3
