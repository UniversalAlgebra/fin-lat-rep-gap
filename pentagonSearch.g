# File: pentagonSearch.g
# Author: William DeMeo
# Date: 2026.09.13
#
# Description: verifies that SmallGroup(216,153) is the smallest group having
# the pentagon N5 as an upper interval in its subgroup lattice, a claim made in
# Section 1 of the article.
#
# Two observations make this an easy search rather than a hopeless one.
#
#   1.  H may be taken core-free.  If N = Core_G(H) then the interval [H,G] is
#       isomorphic to [H/N, G/N], and G/N is a smaller group, so a smallest
#       example has Core_G(H) trivial.
#
#   2.  H is the intersection of two maximal subgroups.  The two coatoms B and
#       C of the interval [H,G] are maximal subgroups of G, and the meet of B
#       and C in the interval is B /\ C, which is the bottom of the pentagon.
#       So H = B /\ C, and conjugating the whole configuration lets us take B
#       from a set of class representatives.  This is what makes the search
#       cheap: only maximal subgroups are needed, never the full subgroup
#       lattice, which is prohibitive for the 2328 groups of order 128.
#
# Result (GAP 4.15.1, 2026.09.13): among all groups G with 3 <= |G| <= 216 the
# only one with a pentagon upper interval is SmallGroup(216,153).  It has
# twelve such subgroups H, forming a single conjugacy class, each cyclic of
# order 6, so each gives index [G:H] = 36.  Running time about five minutes.

SizeScreen([256,]);

# An interval with three intermediate subgroups is the pentagon exactly when it
# has two atoms and two coatoms, one element being both.  Counting covering
# pairs is not enough: the modular lattice H < a < {b,c} < G also has three
# intermediate subgroups and five covering pairs.
isPentagonInterval := function(r)
    local m, top, atoms, coatoms;
    m := Length(r.subgroups);
    if m <> 3 then return false; fi;
    top := m + 1;
    atoms   := Set(Filtered(r.inclusions, p -> p[1] = 0), p -> p[2]);
    coatoms := Set(Filtered(r.inclusions, p -> p[2] = top), p -> p[1]);
    return Length(atoms) = 2 and Length(coatoms) = 2
           and Length(Intersection(atoms, coatoms)) = 1;
end;

pentagonSearch := function(n1, n2)
    local found, n, k, G, maxes, cand, B, C, H;
    found := [];
    for n in [n1..n2] do
      for k in [1..NrSmallGroups(n)] do
        G := SmallGroup(n, k);
        maxes := Concatenation(List(ConjugacyClassesMaximalSubgroups(G), AsList));
        cand := [];
        for B in MaximalSubgroupClassReps(G) do
          for C in maxes do
            H := Intersection(B, C);
            if Size(H) < Size(B) and Size(Core(G, H)) = 1 then
              AddSet(cand, H);
            fi;
          od;
        od;
        for H in cand do
          if isPentagonInterval(IntermediateSubgroups(G, H)) then
            AddSet(found, [n, k, Size(H), Index(G, H)]);
            Print("PENTAGON  SmallGroup(", n, ",", k, ")  |H| = ", Size(H),
                  "  [G:H] = ", Index(G, H), "\n");
          fi;
        od;
      od;
      Print("# order ", n, " done (", NrSmallGroups(n), " groups); ",
            "distinct results so far: ", Length(found), "\n");
    od;
    Print("### FINISHED.  [order, id, |H|, index]: ", found, "\n");
    return found;
end;

# pentagonSearch(3, 216);
