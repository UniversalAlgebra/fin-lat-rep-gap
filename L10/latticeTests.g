# File: L10/latticeTests.g
# Author: William DeMeo
# Date: 2026.09.17
#
# Description: the target lattice L10 (the paper's numbering; L7 in DeMeo's
# 2012 thesis and in Tian's 2026 note) as a finite poset, and the two small
# routines the other L10 programs share: turning the cover list that GAP's
# IntermediateSubgroups returns into an order relation, and testing a
# seven-element poset for isomorphism with the target.
#
# The target is given as up-sets: FLR_L10_UPSETS[k] is the set of elements j
# with k <= j, elements numbered 1 (bottom) to 7 (top).  The numbering is that
# of Examples.Classical.Lattices.L7 in agda-algebras, shifted by one:
#
#     1 = bottom,  2 = (1,0),  3 = (0,1),  4 = x,  5 = (1,1),  6 = (0,2),  7 = top
#
# so L10 is the 2 x 3 grid {1,2,3,5,6,7} together with the doubly irreducible
# element 4, a complement of every other nontrivial element.  The covers are
# 1 < 2, 3, 4;  2, 3 < 5;  3 < 6;  4, 5, 6 < 7.
#
# A program that wants a different target sets FLR_TARGET (a list of up-sets
# in the same shape) before reading this file.

if not IsBoundGlobal("FLR_L10_UPSETS") then
  BindGlobal("FLR_L10_UPSETS",
    [ [1,2,3,4,5,6,7], [2,5,7], [3,5,6,7], [4,7], [5,7], [6,7], [7] ]);
fi;
if not IsBoundGlobal("FLR_TARGET") then
  FLR_TARGET := FLR_L10_UPSETS;
fi;
FLR_N := Length(FLR_TARGET);

# The up-sets of the poset on 1 .. size whose cover list is `covers`, given in
# the 0-based form IntermediateSubgroups uses: 0 is the bottom H, size - 1 is
# the top G, and [i, j] means node i is maximal in node j.
FLR_LeqFromCovers := function(size, covers)
  local leq, e, changed, i, j, k;
  leq := List([1 .. size], i -> [i]);
  for e in covers do
    AddSet(leq[e[1] + 1], e[2] + 1);
  od;
  changed := true;
  while changed do
    changed := false;
    for i in [1 .. size] do
      for j in ShallowCopy(leq[i]) do
        for k in leq[j] do
          if not k in leq[i] then
            AddSet(leq[i], k);
            changed := true;
          fi;
        od;
      od;
    od;
  od;
  return leq;
end;

# Is the poset with up-sets `leq` (1 = bottom, N = top) isomorphic to the
# target?  Brute force over the permutations of the interior elements, which
# is instant for the seven-element targets this is used on.
FLR_IsTarget := function(leq)
  local p, i, ok;
  if Length(leq) <> FLR_N then
    return false;
  fi;
  for p in SymmetricGroup([2 .. FLR_N - 1]) do
    ok := true;
    for i in [1 .. FLR_N] do
      if Set(List(leq[i], j -> j ^ p)) <> Set(FLR_TARGET[i ^ p]) then
        ok := false;
        break;
      fi;
    od;
    if ok then
      return true;
    fi;
  od;
  return false;
end;
