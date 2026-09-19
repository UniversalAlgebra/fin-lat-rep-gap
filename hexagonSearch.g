# File: hexagonSearch.g
# Author: William DeMeo
# Date: 2026.09.18
#
# Description: verifies that no group of order at most 2000 has the hexagon,
# the six-element lattice made of two 3-chains between a common bottom and
# top (L6 in the article), as an upper interval in its subgroup lattice.  This
# is the claim made in Section 1 of the article beside the sizes of the known
# representations, the smallest of which is Palfy's in A11 (see Hexagon.g).
#
# The search is pentagonSearch.g's.  Its two reductions transfer word for word,
# because the hexagon's two coatoms also meet at its bottom:
#
#   1.  H may be taken core-free.  If N = Core_G(H) then [H,G] is isomorphic
#       to [H/N, G/N] and G/N is a smaller group.  So if some group of order
#       at most n has a hexagon upper interval, one with a core-free bottom
#       does too.
#
#   2.  H is the intersection of two maximal subgroups.  The two coatoms B and
#       C of [H,G] are maximal in G, and their meet in the interval is B ⋀ C,
#       which is the bottom of the hexagon.  So H = B ⋀ C, with B taken from
#       a set of class representatives.
#
# A third reduction, from Aschbacher [1], makes the range above 255 cheap.
# Proposition 2 of [1]: if H is core-free in G and the only modular elements
# of [H,G] are its two ends (Aschbacher's "A-lattice"), then G has a unique
# minimal normal subgroup, and it is a direct product of nonabelian simple
# groups.  Such a G is not solvable.  The hexagon is an A-lattice (the
# program checks this for the record, in hexagonModularElements below), so
# above order 255 only the non-solvable groups are examined: there are 1010
# of them in the Small Groups Library, in 38 orders up to 2000.  Order 1024
# is not in the library, but a group of prime-power order is solvable.  The
# sweep to 255 examines every group, solvable or not, and so does not depend
# on [1].
#
# Each candidate interval is compared with the hexagon's covering relation by
# a brute-force isomorphism test over the 24 relabelings of its middle, never
# by counting atoms or covers.  A count-based search in 2010 reported
# SmallGroup(24,12) and SmallGroup(960,11358) as hexagons; neither is.  In
# the latter, the index-80 subgroups isomorphic to A4 have intervals with 13
# and with 5 intermediate subgroups.
#
#   [1] M. Aschbacher, On intervals in subgroup lattices of finite groups,
#       J. Amer. Math. Soc. 21 (2008), 809-830.
#
# Result (GAP 4.15.1, 2026.09.18):
#
#   modular elements of the hexagon: [ 0, 5 ]
#   gap> hexagonSearch(3, 255);
#   ### FINISHED range [3,255].  0 group(s): [  ]
#   gap> hexagonSearchNonsolvable(256, 2000);
#   ### FINISHED non-solvable range [256,2000]: 1010 groups examined, 0 group(s) found: [  ]
#
# Neither run prints a HEXAGON line.  The first took about eight minutes for
# its 7010 groups; the second about sixteen minutes, most of it spent selecting the
# 588 non-solvable groups of order 1920 out of 241004.

SizeScreen([256,]);

# The hexagon's covering relation: 0 the bottom, 5 the top, two 3-chains.
hexTarget := Set([[0,1],[1,2],[2,5],[0,3],[3,4],[4,5]]);

# Is the interval IntermediateSubgroups returns the hexagon?  Its inclusions
# are covering pairs on {0, ..., m+1}, with 0 the bottom H and m+1 the top
# G, so an isomorphism fixes those two and permutes the middle.
isHexInterval := function(r)
    local m, top, perms, f, mapped;
    m := Length(r.subgroups);
    if m <> 4 then return false; fi;
    top := m + 1;
    for perms in PermutationsList([1..m]) do
        f := function(x)
            if x = 0 then return 0;
            elif x = top then return 5;
            else return perms[x]; fi;
        end;
        mapped := Set(r.inclusions, e -> [ f(e[1]), f(e[2]) ]);
        if mapped = hexTarget then return true; fi;
    od;
    return false;
end;

# The modular elements of the hexagon, for the record: an element m is
# modular when (a ∨ m) ∧ b = a ∨ (m ∧ b) for all a <= b.  Expect [ 0, 5 ].
hexagonModularElements := function()
    local leq, i, j, k, join, meet, isModular;
    leq := List([0..5], i -> List([0..5], j -> i = j or [i,j] in hexTarget));
    for k in [1..6] do for i in [1..6] do for j in [1..6] do
        if leq[i][k] and leq[k][j] then leq[i][j] := true; fi;
    od; od; od;
    join := function(a, b)
        local ubs;
        ubs := Filtered([0..5], x -> leq[a+1][x+1] and leq[b+1][x+1]);
        return First(ubs, x -> ForAll(ubs, y -> leq[x+1][y+1]));
    end;
    meet := function(a, b)
        local lbs;
        lbs := Filtered([0..5], x -> leq[x+1][a+1] and leq[x+1][b+1]);
        return First(lbs, x -> ForAll(lbs, y -> leq[y+1][x+1]));
    end;
    isModular := m -> ForAll([0..5], a ->
                     ForAll(Filtered([0..5], b -> leq[a+1][b+1]), b ->
                            meet(join(a,m), b) = join(a, meet(m,b))));
    return Filtered([0..5], isModular);
end;
Print("modular elements of the hexagon: ", hexagonModularElements(), "\n");

# The test applied to one group: the core-free intersections of two maximal
# subgroups, each interval compared with the hexagon.  Returns a record for
# the group if it has a hexagon upper interval, and fail otherwise, printing a
# HEXAGON line in the first case.
hexagonWitnesses := function(G, n, k)
    local maxes, cand, good, reps, B, C, H;
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
    good := Filtered(cand, H -> isHexInterval(IntermediateSubgroups(G, H)));
    if Length(good) = 0 then return fail; fi;
    # AddSet removed duplicate subgroups, not conjugate ones.
    reps := [];
    for H in good do
      if ForAll(reps, K -> RepresentativeAction(G, K, H) = fail) then
        Add(reps, H);
      fi;
    od;
    Print("HEXAGON  SmallGroup(", n, ",", k, ") = ", StructureDescription(G),
          ": ", Length(good), " subgroup(s) H in ", Length(reps),
          " conjugacy class(es); orders ", Set(good, Size), ", indices ",
          Set(good, H -> Index(G, H)), ", isomorphism type ",
          StructureDescription(good[1]), "\n");
    return rec(order := n, id := k,
               witnesses := Length(good), classes := Length(reps),
               subgroupOrders := Set(good, Size),
               indices := Set(good, H -> Index(G, H)),
               isomorphismType := StructureDescription(good[1]));
end;

# Every group of order n1 to n2.
hexagonSearch := function(n1, n2)
    local found, n, k, r;
    found := [];
    for n in [n1..n2] do
      for k in [1..NrSmallGroups(n)] do
        r := hexagonWitnesses(SmallGroup(n, k), n, k);
        if r <> fail then Add(found, r); fi;
      od;
      Print("# order ", n, " done (", NrSmallGroups(n), " groups); ",
            "hexagon groups found so far: ", Length(found), "\n");
    od;
    Print("### FINISHED range [", n1, ",", n2, "].  ", Length(found),
          " group(s): ", found, "\n");
    return found;
end;

# Only the non-solvable groups of order n1 to n2, by Aschbacher's Proposition
# 2.  A non-solvable group of order at most 2000 has a nonabelian simple
# composition factor of order 60, 168, 360, 504, 660 or 1092, so its order is
# divisible by 60, 168, 504, 660 or 1092; the other orders are skipped without
# consulting the library, as is 1024, which the library does not contain.
hexagonSearchNonsolvable := function(n1, n2)
    local found, total, n, ids, id, r;
    if n2 > 2000 then
        Error("the divisibility test below is only right up to order 2000");
    fi;
    found := [];
    total := 0;
    for n in [n1..n2] do
      if n = 1024 or not ForAny([60, 168, 504, 660, 1092], d -> n mod d = 0) then
        continue;
      fi;
      ids := IdsOfAllSmallGroups(Size, n, IsSolvableGroup, false);
      total := total + Length(ids);
      for id in ids do
        r := hexagonWitnesses(SmallGroup(id), n, id[2]);
        if r <> fail then Add(found, r); fi;
      od;
      Print("# order ", n, " done (", Length(ids), " non-solvable groups of ",
            NrSmallGroups(n), "); hexagon groups found so far: ",
            Length(found), "\n");
    od;
    Print("### FINISHED non-solvable range [", n1, ",", n2, "]: ", total,
          " groups examined, ", Length(found), " group(s) found: ", found, "\n");
    return found;
end;

# hexagonSearch(3, 255);
# hexagonSearchNonsolvable(256, 2000);
