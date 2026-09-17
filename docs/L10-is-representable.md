# L10 is representable: Tian's interval in PSL(2,64), a smaller one in Sp(6,2), and what our searches could not see

File: `docs/L10-is-representable.md`.  Date: 2026-09-17.

## Summary

On 2026-08-28 Chenxiao Tian posted a seven-page note, *The exceptional
seven-element lattice as a subgroup interval in PSL2(64)* [Tian], claiming
that the last lattice with at most seven elements not known to be the
congruence lattice of a finite algebra is an interval in the subgroup lattice
of PSL(2,64).  The lattice is L<sub>10</sub> in our manuscript [DFJ] and
L<sub>7</sub> in DeMeo's thesis [DeMeo 2012], which is the name Tian uses.
This report answers three questions about the note and records the programs
behind the answers.  In brief, the answers are the following.

+  **The result is correct**.  Recomputing the interval in GAP from the note's
   two generating matrices, with no input from the note's tables, gives exactly
   the five intermediate subgroups and the nine covers it claims, and the
   interval is isomorphic to L<sub>10</sub>.  Every step of the proof was
   corroborated separately, and the isomorphism test of the agda-algebras
   campaign agrees.  The lattice in the note is the lattice in the thesis, in
   the manuscript, and in the agda-algebras library.
+  **It is not the only such interval, and not the smallest**.  A scan of the
   414 tables of marks in GAP's TomLib finds six upper intervals isomorphic to
   L<sub>10</sub>: in PSL(2,64), Sp(6,2), its double cover, McL, McL.2 and
   Co3.  All six were recomputed explicitly.  The one in Sp(6,2), above a
   core-free Frobenius group 7:6 of index 34560, gives an algebra on 34560
   elements, smaller than Tian's 43680.  So the minimal representation of
   L<sub>10</sub> has between 16 and 34560 elements.
+  **A machine-checked certificate is a project, not a file**.  The easy
   direction of Pálfy–Pudlák is already formalized in agda-algebras, so what a
   certificate must establish is that no other subgroup lies between H and G.
   The campaign's certificate format cannot carry a carrier of 34560 or
   43680 elements.  A certificate organized by double cosets would be about a
   fifth of a megabyte for the Sp(6,2) representation and about a megabyte for
   PSL(2,64), with hundreds of thousands of group multiplications to replay,
   on new infrastructure.
+  **Our searches were organized by the size of the algebra, and the examples
   live far outside their range**.  Every search for this lattice, in the
   manuscript and in the agda-algebras campaign, went through the algebras or
   transitive groups of a given degree, and reached degree 12; the library of
   transitive groups ends at degree 48.  Nothing was ever scanned group by
   group, which is what finds these examples in under a minute.

## The lattice and the claim

L<sub>10</sub> is the product of a two-element chain and a three-element chain
with one further element x that is a complement of every other nontrivial
element, as follows:

```text
                 ⊤
              /  |  \
         (1,1)  (0,2) \
         /   \  /      \
     (1,0)   (0,1)      x
          \    |       /
               ⊥
```

Its covers are ⊥ ≺ (1,0), (0,1), x;  (1,0), (0,1) ≺ (1,1);  (0,1) ≺ (0,2);
and (1,1), (0,2), x ≺ ⊤.  It is simple, and the manuscript's Section 5 shows
that a representation of minimal size must be a transitive G-set, so that the
question is whether L<sub>10</sub> is an upper interval [H, G] in the subgroup
lattice of some finite group, with H core-free.

The same lattice carries four names.  It is L<sub>10</sub> in the manuscript
[DFJ], L<sub>7</sub> in Chapter 6 of DeMeo's thesis [DeMeo 2012], `L7` in the
agda-algebras library (`Examples.Classical.Lattices.L7`, whose numbering
0 = ⊥, 1 = (1,0), 2 = (0,1), 3 = x, 4 = (1,1), 5 = (0,2), 6 = ⊤ the programs
here follow), and L<sub>7</sub> again in Tian's note, which defines it by the
covers 0 ≺ J<sub>1</sub>, J<sub>2</sub>, K;  J<sub>1</sub> ≺ M<sub>2</sub>;
J<sub>2</sub> ≺ M<sub>1</sub>, M<sub>2</sub>;  K, M<sub>1</sub>, M<sub>2</sub> ≺ 1.
Those are the covers above with J<sub>1</sub> = (1,0), J<sub>2</sub> = (0,1),
K = x, M<sub>1</sub> = (0,2), M<sub>2</sub> = (1,1).

Tian's Theorem 1.1 states that for G = SL(2,64), which is PSL(2,64) because
the characteristic is two, and H = SL(2,2) ≅ S<sub>3</sub> embedded through
the subfield GF(2) ⊂ GF(64), the interval [H, G] has exactly five proper
intermediate subgroups, of types D<sub>18</sub>, D<sub>42</sub>, A<sub>5</sub>,
D<sub>126</sub> and PSL(2,8), with covers forming L<sub>10</sub>.  Theorem 1.2
turns the coset action into an algebra with 43680 elements and three unary
operations whose congruence lattice is L<sub>10</sub>, and Corollary 1.3
concludes that every lattice with at most seven elements is the congruence
lattice of a finite algebra.

## 1.  Is the result legit?

Yes.  The verification is `L10/verifyPSL264.g`, whose output is
`L10/results/verifyPSL264.txt`; everything below is read off that output.

**The interval, recomputed**.  From the two matrices u = [[1,1],[0,1]] and
v = [[0,1],[1,0]] over GF(64), GAP's `IntermediateSubgroups(SL(2,64), ⟨u,v⟩)`
returns five subgroups, of orders 18, 42, 60, 126, 504 and structures
D<sub>18</sub>, D<sub>42</sub>, A<sub>5</sub>, D<sub>126</sub>, PSL(2,8), with
the cover list

```text
[[0,1],[0,2],[0,3],[1,4],[1,5],[2,4],[3,6],[4,6],[5,6]]
```

(0 is H, 6 is G, and [i,j] means i is maximal in j), which is the note's
equation (5).  A brute-force isomorphism test against the up-sets of
L<sub>10</sub> answers true, with D<sub>42</sub> = (1,0),
D<sub>18</sub> = (0,1), A<sub>5</sub> = x, D<sub>126</sub> = (1,1) and
PSL(2,8) = (0,2).

**The proof, step by step**.  Each lemma of the note rests on a fact that GAP
confirms independently, as follows:

| Step in the note | Claim | GAP |
| --- | --- | --- |
| Lemma 2.1 | N<sub>G</sub>(H) = H, C<sub>G</sub>(C<sub>3</sub>) ≅ C<sub>63</sub>, N<sub>G</sub>(C<sub>3</sub>) ≅ D<sub>126</sub>, one class of S<sub>3</sub>, 43680 conjugates | all as stated |
| Proposition 2.2 (Dickson) | maximal subgroups of orders 4032, 504, 130, 126, 60, one class each of A<sub>5</sub> and PSL(2,8) | `MaximalSubgroupClassReps` gives exactly those orders; `IsomorphicSubgroups` gives one class of each |
| Lemma 2.3 | 4368 · 10 = 43680 incidences between S<sub>3</sub> and A<sub>5</sub>, 520 · 84 = 43680 between S<sub>3</sub> and PSL(2,8) | 4368 conjugates of A<sub>5</sub> with 10 copies of S<sub>3</sub> each; 520 conjugates of PSL(2,8) with 84 each |
| Lemma 2.4 | the A<sub>5</sub> and PSL(2,8) above H are the subfield groups, the D<sub>126</sub> is N<sub>G</sub>(C<sub>3</sub>) | the A<sub>5</sub> has entries in GF(4), the PSL(2,8) in GF(8), and D<sub>126</sub> = N<sub>G</sub>(C<sub>3</sub>) |
| Lemma 3.2 | G = ⟨u, v, h⟩ for h = diag(α, α<sup>−1</sup>) | true |
| Section 4 | TomLib's table of marks for L2(64): overgroup orders 6, 18, 42, 60, 126, 504, 262080, multiplicity one each | class 16 of 76, exactly those orders and multiplicities |

Proposition 3.1, the coset-congruence correspondence, is the easy direction of
Pálfy–Pudlák and is formalized in agda-algebras as `FLRP.Bridge`, at both the
semantic and the decidable layer.

**A second isomorphism test**.  The agda-algebras campaign has its own
pipeline for intervals found in GAP: the interval is written as a JSON record,
and a Python stage re-derives its meet and join tables and tests them against
the target lattice.  Run on this interval (`L10/pipelineRaw.g`, then
`gap_search.py` in agda-algebras) it returns the verdict `positive` with the
witness `[0, 2, 1, 3, 4, 5, 6]`; the report is `L10/results/l10.search.json`.

**What the proof rests on**.  The note takes two things from the literature:
Dickson's classification of the maximal subgroups of PSL(2,q), in the form
given by King and Giudici, and Theorem 6.1.1 of the thesis, that every other
lattice with at most seven elements is representable, for Corollary 1.3.
Nothing else is assumed, and the computations above are corroboration, not
premises.  The note is on ResearchGate and not on arXiv; a quick web search
found no earlier appearance of the result.

## A scan of TomLib: five more groups, one of them smaller

Since Tian's check used the table of marks of one group, the natural next
question is what the other tables say.  GAP's TomLib holds the complete
subgroup class structure of 414 almost simple and related groups, and the
marks alone determine, for each class of subgroups H, the size of the upper
interval [H, G] and often its shape.  `L10/tomScan.g` does the scan, and
`L10/scanAndResolve.sh` follows it with an explicit recomputation of every
candidate.

**Method**.  For a fixed representative H of class i, the number of subgroups
of class j containing H is mark(j, i) · |K<sub>j</sub>| · |class j| / |G|,
so summing over j gives |[H, G]| without touching the group.  When every class
meets the interval once, the poset is determined too: the unique class-j
member lies in the unique class-k member iff some class-k subgroup contains
some class-j subgroup, because a class-k subgroup containing the class-j
member contains H.  Such intervals are tested exactly.  When a class meets the
interval twice, the marks no longer place the two conjugates relative to each
other, but the number of interval members above each member is still exact,
so the multiset of these up-counts is compared with that of L<sub>10</sub>
(1, 2, 2, 2, 3, 4, 7), and a match is recomputed explicitly with
`IntermediateSubgroups` on the table's own permutation group.

**Results**.  The marks-only scan takes 40 s and finds 3936 upper intervals
with seven elements, of which six are isomorphic to L<sub>10</sub> with every
class occurring once, and 61 have a repeated class and the right up-count
profile.  All six hits and the 61 ambiguous cases were then recomputed
explicitly, one GAP process per table.  The six hits are the following, with
the intermediate subgroups listed in the numbering of the diagram above:

| G | order of G | H | index [G : H] | (1,0) | (0,1) | x | (1,1) | (0,2) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PSL(2,64) | 262080 | S<sub>3</sub> | 43680 | D<sub>42</sub> | D<sub>18</sub> | A<sub>5</sub> | D<sub>126</sub> | PSL(2,8) |
| **Sp(6,2)** | 1451520 | **7:6** | **34560** | S<sub>7</sub> | L<sub>3</sub>(2):2 | PΓL(2,8) | S<sub>8</sub> | U<sub>3</sub>(3):2 |
| 2.Sp(6,2) | 2903040 | 2 × 7:6 | 34560 | the same modulo the center; H is not core-free | | | | |
| McL | 898128000 | 3:(5:8), order 120 | 7484400 | 3<sup>1+4</sup>:(5:8) | 3:(2.S<sub>5</sub>) | 5<sup>1+2</sup>:(3:8) | 3<sup>1+4</sup>:(2.S<sub>5</sub>) | 2.A<sub>8</sub> |
| McL.2 | 1796256000 | order 240 | 7484400 | the same extended by two | | | | |
| Co3 | 495766656000 | order 1440 | 344282400 | 3<sup>1+4</sup>:(SL(2,5):2<sup>2</sup>), order 116640 | SL(2,9):D<sub>12</sub>, order 8640 | U<sub>3</sub>(5):S<sub>3</sub> | 3<sup>1+4</sup>:(SL(2,9):2<sup>2</sup>), order 699840 | 2.Sp(6,2) |

In every one of them H is core-free except in 2.Sp(6,2), whose interval is the
Sp(6,2) interval seen through the center.  The Sp(6,2) representation is the
one to remember: G acting on the 34560 cosets of a Frobenius group of order
42 is an algebra with 34560 elements and two unary operations (the group's
two standard generators) whose congruence lattice is L<sub>10</sub>.  The
agda-algebras pipeline confirms it too, with the witness
`[0, 2, 3, 1, 5, 4, 6]`, in the same `l10.search.json` report.

**The ambiguous cases**.  All 61 were recomputed, and all 61 are negative:
in each the interval is a different seven-element lattice, most
often a five-element chain with two extra atoms that are also coatoms, as in
A<sub>12</sub>, S<sub>12</sub>, M<sub>24</sub>, HS, HS.2 and the
U<sub>4</sub>(3) family.  The full list, with each group, its H, the index and
the verdict, is `L10/results/resolveSummary.txt`.  What matters for the
minimum is that every ambiguous interval of index below 34560 is negative,
from index 240 up through 2<sup>6</sup>:U<sub>4</sub>(2) at 1728 and 2304,
S<sub>4</sub>(4).2 at 8160 and the U<sub>4</sub>(3) family at 34020, so none
of them competes with the Sp(6,2) representation, and the two cases at index
34560 itself are the Sp(6,2) and 2.Sp(6,2) hits already in the table above.
TomLib is a library of specific groups and not a census, so a negative result
says nothing about groups outside it; within it, the Sp(6,2) representation is
the smallest.

## 2.  Formalizing the result

+ Is there a way to formalize/codify the result in Agda (e.g., in the agda-algebras library)?
+ How large would a formal Agda certificate be?

**What is already there**.  `FLRP.Bridge` proves that the congruence lattice
of the coset G-set G ↷ G/H is order-isomorphic to the interval [H, G], for any
group and subgroup, constructively and at the decidable layer, and its
corollary turns a group representation into a `Representableᵈ` witness.  So
the algebra-level consequence (Tian's Theorem 1.2) costs nothing once the
interval is established.  The whole difficulty is Theorem 1.1: exhibiting the
five intermediate subgroups is easy, and proving that there are no others is
the content.

**Why the current certificate route cannot carry it**.  The campaign's
certificates (`Setoid.Congruences.Certificates`, the WP-6 design) describe an
algebra by its operation tables on a carrier of n elements and pin its
congruence lattice by a pointer and a Freese trace for every pair of carrier
elements: n<sup>2</sup> entries.  At n = 43680 that is 1.9 × 10<sup>9</sup>;
at 34560 it is 1.2 × 10<sup>9</sup>.  The emitter's literal cap is 31, the
largest certified carrier in the census is 19, and that certificate takes 28 s
to check.  The direct route is out by five orders of magnitude.

**What a certificate would contain**.  The way through is symmetry.  Every
subgroup X with H < X is the join of the subgroups ⟨H, g⟩ for g in X, so it
suffices to identify ⟨H, g⟩ for every g in G, and ⟨H, g⟩ depends only on the
double coset HgH.  For g inside one of the three coatoms, ⟨H, g⟩ is one of
the five listed subgroups, and a short word shows it.  For g outside them,
⟨H, g⟩ = G, certified by a word over H and g that reaches an element of a
coatom (stage 1) and then a word over that coatom and g that reaches a fixed
set of elements known to generate G together with H (stage 2).  On the
algebra side the same certificate reads as principal congruences at the base
coset, one per H-orbit on G/H, with the lattice's join table closing the
argument.  `L10/certificateSizing.g` measures the two ingredients, as follows:

| representation | double cosets HgH | outside the coatoms | stage-1 word length | stage-2 word length | group elements as |
| --- | --- | --- | --- | --- | --- |
| PSL(2,64) / S<sub>3</sub> | 7303 | 7275 | 3 to 9, with outliers at 15 and 19 | 3 to 8 | 2 × 2 matrices over GF(64) |
| Sp(6,2) / 7:6 | 847 | 805 | 2 to 5 | 3 to 6 | permutations of 28 points |

The word lengths are breadth-first search depths in the coset action over
samples of 150 and 100 double coset representatives, so a certificate would
carry ten to twenty letters per representative, with a few longer ones.  Per
representative the checker also has to verify that the listed representatives
exhaust G, which is a size count: the double cosets have sizes |H|<sup>2</sup>
/ |H ∩ H<sup>g</sup>| that must sum to |G|, and |G| itself needs a proof (a
counting argument over GF(64) for SL(2,64), or a stabilizer chain for the
permutation group).

**Estimate**.  For PSL(2,64), about 7300 lines each holding a matrix, its
double coset size and about 20 letters: half a megabyte to a megabyte as Agda
source, with on the order of 10<sup>5</sup> to 10<sup>6</sup> matrix
multiplications over GF(64) to replay.  For Sp(6,2), about 800 lines each
holding a permutation of 28 points: a fifth of a megabyte, with a comparable
number of permutation multiplications, since the exhaustiveness check costs
|H|<sup>2</sup> per representative.  At the evaluator speeds measured on the
A<sub>5</sub> tables in the campaign, either replay is hours of type-checking
against the 18 to 28 s of the largest current certificates.  Beyond the file,
the work is new infrastructure: GF(64) arithmetic or a stabilizer-chain
certificate for the group order, a certificate schema keyed by double coset
representatives, and the theorem that principal congruences at the base coset
determine the congruence lattice of a transitive G-set.  It is a feasible
project of some weeks, not a certificate that the existing emitter can
produce, and neither route needs Dickson's classification: the double coset
enumeration replaces it.

## 3.  Why didn't our search programs find this example?

We did search for it, explicitly and repeatedly, but always through the
algebras or transitive groups of a given size, in increasing order of size,
because the question we were asking was the size of a minimal representation.
The searches on record are the following:

| Search | Where | Range | Outcome |
| --- | --- | --- | --- |
| closed sublattices of Eq(n) isomorphic to L<sub>10</sub> | agda-algebras, `eqsearch.py` | n ≤ 8, all copies; n = 9, 10, 12, uniform copies (the transitive case) | none closed; no algebra on at most 12 elements |
| point-stabilizer intervals of transitive groups | agda-algebras, `scan_transitive.g` | degrees 8, 9, 10, 12 (50, 34, 45 and 301 groups; 11 and 13 are prime) | 18 seven-element intervals at degree 12, none L<sub>10</sub> |
| upper intervals in the Small Groups Library | this repository, `findUpperIntervals.g`, `pentagonSearch.g` | orders up to 216 to 255 | the pentagon in SmallGroup(216,153); nothing for L<sub>10</sub> |
| second-maximal upper intervals in primitive groups | this repository, `findUpperIntervalsInPrimitiveGroups` | by degree, affine type in the recorded example | no run reaching degree 65 on record |
| parachute lattices as upper intervals | agda-algebras, `hunt_parachutes.g` | orders up to 300 | none |

Chaining the manuscript's transitivity theorem through these sizes gives the
campaign's standing bound: a minimal representation of L<sub>10</sub>, if one
exists, has at least 16 elements.  That bound is still correct.  What the
searches could not see is that the examples sit at degrees 34560 and 43680, in
groups of order 1.4 million and 262080, far beyond any degree-by-degree
enumeration: the transitive groups library ends at degree 48, and the algebra
side of the campaign was already at its limits at twelve points.  The
primitive-groups routine in `findUpperIntervals.g` is the one tool that could
have found Tian's interval, since S<sub>3</sub> is second maximal in PSL(2,64),
which is a primitive group of degree 65; but it was written for the affine
case and, as far as the record shows, never run to degree 65 on the almost
simple groups.

The lesson is about the organization of the search rather than its
thoroughness.  Scanning by group, through tables of marks, finds both
representations and four more in 40 s, because the table of a group records
every interval at once; scanning by degree cannot reach them at all.  The
thesis's Theorem 6.3.1 already pointed this way: a group with L<sub>10</sub>
as a core-free upper interval must be primitive, nonsolvable and subdirectly
irreducible, with no nontrivial abelian normal subgroup, which is the
territory of the almost simple groups that TomLib covers.

## Programs and reproduction

All programs are under `L10/` and run from the repository root on a GAP with
the `tomlib` package, which standard distributions include.  The results they
produced on 2026-09-17 with GAP 4.15.1 and TomLib 1.2.11 are under
`L10/results/` and are what this report quotes.

| Program | What it does | Output |
| --- | --- | --- |
| `L10/latticeTests.g` | L<sub>10</sub> as up-sets, the cover-list-to-order routine, and the isomorphism test the other programs share | |
| `L10/verifyPSL264.g` | recomputes Tian's interval and corroborates each lemma | `results/verifyPSL264.txt` |
| `L10/tomScan.g` | scans TomLib for a target lattice as an upper interval, from the marks, and recomputes candidates explicitly | `results/tomScan.txt` |
| `L10/scanAndResolve.sh` | runs the scan and then one explicit recomputation per table, in parallel | `results/resolve/*.txt`, `results/scanAndResolve.log` |
| `L10/summarizeResolve.sh` | reduces the per-table recomputations to one line each: group, H, index, core-freeness, verdict | `results/resolveSummary.txt` |
| `L10/certificateSizing.g` | counts double cosets and samples word lengths for the two smallest representations | `results/certificateSizing.txt` |
| `L10/pipelineRaw.g` | cross-checks both intervals with the agda-algebras isomorphism test; needs that repository | `results/l10.raw.json`, `results/l10.search.json` |

To reproduce, from the repository root, run the following:

```sh
gap -A -q -b L10/verifyPSL264.g
L10/scanAndResolve.sh
gap -A -q -b L10/certificateSizing.g
```

The driver runs whatever `gap` is on the path.  Where GAP is not on the path,
or is reached through a wrapper, put that command in `GAP`, which is the only
reason the variable exists; the runs recorded here were made that way, from a
Nix shell holding GAP and TomLib, as follows:

```sh
GAP="nix develop /path/to/agda-algebras#gap --command gap" L10/scanAndResolve.sh
```

The scan itself is 40 s; the explicit recomputations that follow take a few
seconds each once a table is loaded, with the largest tables taking minutes to
load, and the driver runs four at a time.  In total the scan settled 67
intervals explicitly: the six hits, re-derived as a check on the tables, and
all 61 ambiguous cases.

Two things in this pipeline are worth knowing before rerunning it.  Naming a
subgroup with `StructureDescription` is a convenience and not part of the test,
and on a few tables it costs far more than the mathematics: the verdicts for
2<sup>6</sup>:U<sub>4</sub>(2) and G2(4) are reached in one or two seconds and
the naming of the resulting subgroups of order 30000 to 60000 then runs for
over half an hour, so those three verdicts were taken with
`FLR_STRUCTURE := false` and report orders in place of names.  And TomLib
contains distinct tables whose names differ only in a character that cannot go
in a filename, `2^4:A8` and ``2^4`A8``, so the driver assigns the output names
in its sequential part and disambiguates them; without that the second run
silently overwrites the first, which is how one verdict went missing on the
first pass here.

## Provenance

This report and the programs under `L10/` were written with AI assistance
(Claude Fable 5.1 and Claude Opus 5, Anthropic) in a working session on
2026-09-17.  Every computation described here was run in that session with
GAP 4.15.1 and TomLib 1.2.11, and its output is committed beside the program
that produced it.

## References

+  [Tian] Chenxiao Tian, *The exceptional seven-element lattice as a subgroup
   interval in PSL2(64)*, dated 2026-08-28, [ResearchGate][Tian].
+  [DeMeo 2012] William DeMeo, *Congruence lattices of finite algebras*,
   Ph.D. thesis, University of Hawai'i at Mānoa, 2012, [arXiv:1204.4305][DeMeo 2012].
   Chapter 6 defines L<sub>7</sub> and proves Theorem 6.1.1 and Theorem 6.3.1.
+  [DFJ] William DeMeo, Ralph Freese, Peter Jipsen, *Representing finite
   lattices as congruence lattices of finite algebras*, manuscript,
   [UniversalAlgebra/fin-lat-rep][DFJ].
+  [Connor–Leemans] Thomas Connor and Dimitri Leemans, *An atlas of subgroup
   lattices of finite almost simple groups*, Ars Math. Contemp. 8 (2015),
   [doi:10.26493/1855-3974.455.422][Connor–Leemans].
+  [TomLib] Thomas Merkwitz, Liam Naughton, Götz Pfeiffer, *TomLib: the GAP
   library of tables of marks*, [GAP package][TomLib].
+  [GAP] The GAP Group, *GAP: Groups, Algorithms, and Programming*, version
   4.15.1, [gap-system.org][GAP].
+  [Pálfy–Pudlák] Péter Pál Pálfy and Pavel Pudlák, *Congruence lattices of
   finite algebras and intervals in subgroup lattices of finite groups*,
   Algebra Universalis 11 (1980), 22–27.
+  [agda-algebras] The Agda Universal Algebra Library, [ualib/agda-algebras][agda-algebras];
   the L<sub>10</sub> search record is `docs/notes/flrp-l7-eq6.md` there, and
   the bridge is `src/FLRP/Bridge.lagda.md`.

[Tian]: https://www.researchgate.net/publication/414130064_THE_EXCEPTIONAL_SEVEN-ELEMENT_LATTICE_AS_A_SUBGROUP_INTERVAL_IN_PSL_2_64
[DeMeo 2012]: https://arxiv.org/abs/1204.4305
[DFJ]: https://github.com/UniversalAlgebra/fin-lat-rep
[Connor–Leemans]: https://doi.org/10.26493/1855-3974.455.422
[TomLib]: https://gap-packages.github.io/tomlib/
[GAP]: https://www.gap-system.org
[agda-algebras]: https://github.com/ualib/agda-algebras
