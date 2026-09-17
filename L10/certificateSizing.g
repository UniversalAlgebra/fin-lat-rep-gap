# File: L10/certificateSizing.g
# Author: William DeMeo
# Date: 2026.09.17
#
# Description: measures what a machine-checkable certificate of "[H, G] is
# isomorphic to L10" would have to contain, for the two smallest known
# representations: G = PSL(2,64) with H = S3 (Tian), and G = Sp(6,2) with
# H = 7:6 (found by L10/tomScan.g).
#
# The hard half of such a certificate is that there are no subgroups between H
# and G other than the listed ones.  Every subgroup X with H < X is the join of
# the subgroups <H, g> for g in X, so it suffices to identify <H, g> for every
# g in G, and <H, g> depends only on the double coset H g H.  For g outside the
# union of the interval's coatoms, <H, g> = G, and a short certificate of that
# is a word over H and g reaching an element of a coatom (stage 1) followed by
# a word over that coatom and g reaching a fixed set of elements known to
# generate G together with H (stage 2).  This program counts the double
# cosets, splits them by whether the representative lies in a coatom, and
# samples the lengths of the two words by breadth-first search in the coset
# action of G on G/H.
#
# Run from the repository root, with a GAP that has the tomlib package:
#
#     gap -A -q -b L10/certificateSizing.g
#
# Result (GAP 4.15.1, 2026.09.17): see L10/results/certificateSizing.txt.
# PSL(2,64)/S3 has 7303 double cosets, 7275 of them outside the three
# coatoms; in a sample of 150 the stage-1 words have 3 to 9 letters, with two
# outliers of 15 and 19, and the stage-2 words 3 to 8.  Sp(6,2)/7:6 has 847
# double cosets, 805 outside; in a sample of 100 the stage-1 words have 2 to 5
# letters and the stage-2 words 3 to 6.  The samples are drawn with a fixed
# random seed, so the run is reproducible; the PSL(2,64) half takes about a
# quarter of a minute and the Sp(6,2) half about six minutes.

SetPrintFormattingStatus("*stdout*", false);
Read("L10/latticeTests.g");
Reset(GlobalMersenneTwister, 20260917);

# Breadth-first search from the base point of a coset action, over the
# permutations `gens`, returning the first depth at which a point of
# `targets` is reached.
FLR_BfsDepth := function(n, gens, targets)
  local seen, frontier, depth, nxt, p, q, s;
  seen := BlistList([1 .. n], [1]);
  frontier := [1];
  depth := 0;
  while Length(frontier) > 0 do
    if ForAny(frontier, q -> q in targets) then
      return depth;
    fi;
    nxt := [];
    for p in frontier do
      for s in gens do
        q := p ^ s;
        if not seen[q] then
          seen[q] := true;
          Add(nxt, q);
        fi;
      od;
    od;
    frontier := nxt;
    depth := depth + 1;
  od;
  return fail;
end;

# `coatoms` are the maximal members of [H, G] below G; `stage2` is the
# subgroup whose elements the stage-2 word may use (an atom of the interval);
# `gensG` is a set S with <H, S> = G; `nSamples` double coset representatives
# outside the coatoms are sampled.
FLR_SizeCertificate := function(label, G, H, coatoms, stage2, gensG, nSamples)
  local t, dc, inside, outside, act, n, hI, tgt1, tgt2, s2gens, sample, d1, d2, g, gI;
  Print("== ", label, ": |G| = ", Size(G), " |H| = ", Size(H), " index ", Index(G, H), "\n");
  t := Runtime();
  dc := DoubleCosetRepsAndSizes(G, H, H);
  Print("double cosets H g H: ", Length(dc), " (", Runtime() - t, " ms); sizes sum to |G|: ",
        Sum(List(dc, x -> x[2])) = Size(G), "\n");
  inside := Filtered(dc, x -> ForAny(coatoms, M -> x[1] in M));
  outside := Filtered(dc, x -> not ForAny(coatoms, M -> x[1] in M));
  Print("representatives inside a coatom: ", Length(inside), "; outside: ", Length(outside), "\n");
  act := FactorCosetAction(G, H);
  n := Index(G, H);
  hI := List(GeneratorsOfGroup(H), x -> Image(act, x));
  tgt1 := Set(Concatenation(List(coatoms, M -> List(Elements(M), a -> 1 ^ Image(act, a)))));
  RemoveSet(tgt1, 1);
  tgt2 := List(gensG, y -> [1 ^ Image(act, y)]);
  s2gens := List(Elements(stage2), a -> Image(act, a));
  sample := List([1 .. nSamples], i -> Random(outside)[1]);
  d1 := [];
  d2 := [];
  t := Runtime();
  for g in sample do
    gI := Image(act, g);
    Add(d1, FLR_BfsDepth(n, Concatenation(hI, [gI, gI^-1]), tgt1));
    Add(d2, Maximum(List(tgt2, y -> FLR_BfsDepth(n, Concatenation(s2gens, [gI, gI^-1]), y))));
  od;
  Print("sample of ", nSamples, " outside representatives, BFS time ", Runtime() - t, " ms\n");
  Print("stage-1 depths (word over H, g, g^-1 reaching a coatom): ", Collected(d1), "\n");
  Print("stage-2 depths (word over the stage-2 subgroup, g, g^-1 reaching the generators): ", Collected(d2), "\n");
end;

# Tian's representation: G = PSL(2,64), H = S3, coatoms A5, D126, PSL(2,8),
# stage 2 over the A5, and <u, v, h> = G for h = diag(alpha, alpha^-1).
F := GF(64);
z := Zero(F);
o := One(F);
u := ImmutableMatrix(F, [[o,o],[z,o]]);
v := ImmutableMatrix(F, [[z,o],[o,z]]);
alpha := PrimitiveRoot(F);
h := ImmutableMatrix(F, [[alpha, z], [z, alpha^-1]]);
G := SL(2,64);
H := Subgroup(G, [u,v]);
r := IntermediateSubgroups(G, H);
A := First(r.subgroups, X -> Size(X) = 60);
D := First(r.subgroups, X -> Size(X) = 126);
L := First(r.subgroups, X -> Size(X) = 504);
FLR_SizeCertificate("PSL(2,64) / S3", G, H, [A, D, L], A, [h], 150);

# The Sp(6,2) representation from TomLib: H = 7:6 of index 34560, coatoms
# PGammaL(2,8) (order 1512), U3(3):2 (12096) and S8 (40320), stage 2 over the
# PGammaL(2,8), and the table's own generators of G.
if LoadPackage("tomlib") = true then
  tom := TableOfMarks("S6(2)");
  G := UnderlyingGroup(tom);
  ords := OrdersTom(tom);
  # The class of 7:6 whose upper interval is L10: the classes of order 42 with
  # exactly seven overgroups, by the marks; the scan identifies it the same way.
  cands := Filtered([1 .. Length(ords)], i -> ords[i] = 42 and
             Sum(List([1 .. Length(ords)], j -> ContainingTom(tom, i, j))) = 7);
  Print("classes of order 42 in S6(2) with a 7-element upper interval: ", cands, "\n");
  H := RepresentativeTom(tom, cands[1]);
  r := IntermediateSubgroups(G, H);
  K := First(r.subgroups, X -> Size(X) = 1512);
  M1 := First(r.subgroups, X -> Size(X) = 12096);
  M2 := First(r.subgroups, X -> Size(X) = 40320);
  FLR_SizeCertificate("Sp(6,2) / 7:6", G, H, [K, M1, M2], K, GeneratorsOfGroup(G), 100);
else
  Print("tomlib is not available; the Sp(6,2) measurement was skipped\n");
fi;
QUIT_GAP(0);
