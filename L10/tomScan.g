# File: L10/tomScan.g
# Author: William DeMeo
# Date: 2026.09.17
#
# Description: hunts a target lattice as an upper interval [H, G] across every
# table of marks in GAP's TomLib, which stores the complete subgroup class
# structure of 414 almost simple and related groups.  The default target is
# L10 (the paper's numbering; L7 in DeMeo's thesis and in Tian's note); any
# other finite lattice can be given as FLR_TARGET, in the up-set form that
# L10/latticeTests.g documents.
#
# Method.  For a fixed representative H of subgroup class i, the number of
# class-j subgroups containing H is
#
#     mark(j, i) * |K_j| * (number of conjugates of K_j) / |G|,
#
# so the marks give the size of [H, G] and the classes it meets without
# touching the group.  When every class meets the interval once, the poset is
# determined by the marks as well: the unique class-j member lies in the unique
# class-k member iff some class-k subgroup contains some class-j subgroup
# (ContainingTom), because a class-k subgroup containing the class-j member
# contains H.  Such intervals are tested exactly and reported as HIT.  When a
# class meets the interval twice the marks do not determine the poset, but the
# number of members above each member is still exact, so the multiset of these
# up-counts is compared with the target's; a match is reported as AMBIGUOUS and
# then recomputed explicitly with IntermediateSubgroups on the table's own
# permutation group, if |G| is at most FLR_RESOLVE_BOUND.  Marks-exact hits
# within the bound are recomputed explicitly too, as a check on the tables.
#
# Run from the repository root, with a GAP that has the tomlib package:
#
#     gap -A -q -b L10/tomScan.g
#
# Optional globals, set with gap's -c before the file is read:
#
#     FLR_TARGET         the target's up-sets (default: L10)
#     FLR_TABLES         the TomLib names to scan (default: all of them)
#     FLR_RESOLVE_BOUND  explicit recomputation for |G| at most this
#                        (default 20000000; 0 skips the explicit pass)
#     FLR_STRUCTURE      name the intermediate subgroups with
#                        StructureDescription (default true)
#
# A warning about FLR_STRUCTURE.  Naming a subgroup is a convenience, not part
# of the test, and on some tables it costs far more than the interval does:
# the verdict for 2^6:U4(2) and for G2(4) is reached in a second or two, and
# StructureDescription of the resulting subgroups of order 30000 to 60000 then
# runs for over half an hour.  Set FLR_STRUCTURE := false to print the orders
# alone when a table is slow to finish.
#
# For example, to recompute a single table's cases explicitly however large the
# group (several of the resolutions need this), as follows:
#
#     gap -A -q -o 8g -c 'FLR_TABLES := ["S6(2)"];; FLR_RESOLVE_BOUND := 10^12;;' -b L10/tomScan.g
#
# L10/scanAndResolve.sh runs the whole scan and then one such process per
# table in parallel.
#
# Result (GAP 4.15.1, TomLib 1.2.11), for the default target over all 414
# tables: 3936 size-7 upper intervals, 6 marks-exact hits (L2(64), S6(2),
# 2.S6(2), McL, McL.2, Co3) and 61 ambiguous cases, every one of which was
# recomputed explicitly and found to be a different lattice.
#
# The committed L10/results/tomScan.txt is the marks-only pass, which takes
# about 40 s.  That is NOT what the command above produces: the default bound
# recomputes every candidate group of order at most 20000000 as well, which
# takes far longer.  The marks-only pass is
#
#     gap -A -q -c 'FLR_RESOLVE_BOUND := 0;;' -b L10/tomScan.g
#
# which is how L10/scanAndResolve.sh invokes it before recomputing each
# candidate in its own process; those recomputations are under
# L10/results/resolve/.

SetPrintFormattingStatus("*stdout*", false);
Read("L10/latticeTests.g");

if not IsBoundGlobal("FLR_RESOLVE_BOUND") then
  FLR_RESOLVE_BOUND := 20000000;
fi;
if not IsBoundGlobal("FLR_STRUCTURE") then
  FLR_STRUCTURE := true;
fi;
if LoadPackage("tomlib") <> true then
  Print("FAIL: the tomlib package is not available\n");
  QUIT_GAP(1);
fi;
if not IsBoundGlobal("FLR_TABLES") then
  FLR_TABLES := AllLibTomNames();
fi;

FLR_TargetUpProfile := SortedList(List(FLR_TARGET, Length));

# The name of a subgroup, or just its order when FLR_STRUCTURE is off.
FLR_Describe := function(K)
  if FLR_STRUCTURE then
    return StructureDescription(K);
  fi;
  return Concatenation("order ", String(Size(K)));
end;

# Recompute [H, G] explicitly for class `class` of table `name`, test it, and
# report the structures, the covers, the index and core-freeness.
FLR_VerifyTomInterval := function(name, class)
  local tom, G, H, t, r, size, leq, ok;
  tom := TableOfMarks(name);
  G := UnderlyingGroup(tom);
  H := RepresentativeTom(tom, class);
  t := Runtime();
  r := IntermediateSubgroups(G, H);
  size := Length(r.subgroups) + 2;
  leq := FLR_LeqFromCovers(size, r.inclusions);
  ok := size = FLR_N and FLR_IsTarget(leq);
  # The verdict `ok` is settled above; everything below is description, and on
  # some tables StructureDescription is far more expensive than the interval.
  Print("EXPLICIT ", name, " class ", class, ": |G| = ", Size(G), " |H| = ", Size(H),
        " (", FLR_Describe(H), ") index ", Index(G, H),
        " core-free ", Size(Core(G, H)) = 1, "; interval size ", size,
        " orders ", List(r.subgroups, Size),
        " structures ", List(r.subgroups, FLR_Describe),
        " covers ", r.inclusions, "; target: ", ok, " (", Runtime() - t, " ms)\n");
  return ok;
end;

hits := [];
surv := [];
nsize := 0;
ntables := 0;
# Bound before the loop so that the lambdas below parse without warnings.
tom := fail;
ords := [];
over := [];
for name in FLR_TABLES do
  tom := TableOfMarks(name);
  if tom = fail then
    Print("skip ", name, "\n");
    continue;
  fi;
  ntables := ntables + 1;
  ords := OrdersTom(tom);
  n := Length(ords);
  lens := LengthsTom(tom);
  subs := SubsTom(tom);
  marks := MarksTom(tom);
  sizeG := ords[n];
  # m[i]: the pairs [j, multiplicity] of overgroup classes of a fixed class-i subgroup.
  m := List([1 .. n], i -> []);
  for j in [1 .. n] do
    for k in [1 .. Length(subs[j])] do
      i := subs[j][k];
      mult := marks[j][k] * ords[j] * lens[j] / sizeG;
      if mult > 0 then
        Add(m[i], [j, mult]);
      fi;
    od;
  od;
  for i in [1 .. n - 1] do
    if Sum(List(m[i], x -> x[2])) <> FLR_N then
      continue;
    fi;
    nsize := nsize + 1;
    over := List(m[i], x -> x[1]);
    up := [];
    for x in m[i] do
      cnt := Sum(List(over, k -> ContainingTom(tom, x[1], k)));
      for c in [1 .. x[2]] do
        Add(up, cnt);
      od;
    od;
    Sort(up);
    if up <> FLR_TargetUpProfile then
      continue;
    fi;
    if ForAll(m[i], x -> x[2] = 1) then
      SortBy(over, j -> ords[j]);
      leq := List(over, j -> Filtered([1 .. FLR_N], t -> ContainingTom(tom, j, over[t]) > 0));
      if FLR_IsTarget(leq) then
        Add(hits, rec(name := name, class := i, sizeG := sizeG));
        Print("HIT ", name, " |G|=", sizeG, " class ", i, " |H|=", ords[i],
              " index ", sizeG / ords[i], " interval orders ", List(over, j -> ords[j]), "\n");
      fi;
    else
      Add(surv, rec(name := name, class := i, sizeG := sizeG));
      Print("AMBIGUOUS ", name, " |G|=", sizeG, " class ", i, " |H|=", ords[i],
            " index ", sizeG / ords[i], " multiplicities ", m[i], "\n");
    fi;
  od;
od;
Print("scanned ", ntables, " tables; size-", FLR_N, " upper intervals: ", nsize,
      "; marks-exact hits: ", Length(hits), "; ambiguous cases: ", Length(surv), "\n");
todo := Concatenation(hits, surv);
SortBy(todo, s -> s.sizeG);
for s in todo do
  if s.sizeG <= FLR_RESOLVE_BOUND then
    FLR_VerifyTomInterval(s.name, s.class);
  else
    Print("UNRESOLVED (|G| = ", s.sizeG, " above FLR_RESOLVE_BOUND) ", s.name, " class ", s.class, "\n");
  fi;
od;
QUIT_GAP(0);
