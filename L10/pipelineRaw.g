# File: L10/pipelineRaw.g
# Author: William DeMeo
# Date: 2026.09.17
#
# Description: cross-checks the two L10 intervals with the isomorphism test of
# the agda-algebras FLRP campaign, whose GAP engine (scripts/gap/flrp/ in that
# repository) writes an interval as a deterministic JSON record and whose
# Python stage (scripts/python/flrp/gap_search.py) re-derives the meet and
# join tables and tests them against a target lattice.  This program writes
# the raw search report for the PSL(2,64)/S3 and Sp(6,2)/7:6 intervals; the
# confirmation is the Python command in the comment below.
#
# It needs a checkout of agda-algebras (https://github.com/ualib/agda-algebras),
# because it reads that repository's engine files.  Run from the repository
# root of fin-lat-rep-gap, as follows:
#
#     gap -A -q -c 'FLR_AGDA_ALGEBRAS := "/path/to/agda-algebras";; FLR_OUT := "L10/results/l10.raw.json";;' -b L10/pipelineRaw.g
#     cd /path/to/agda-algebras && python3 scripts/python/flrp/gap_search.py \
#         /path/to/fin-lat-rep-gap/L10/results/l10.raw.json \
#         --target scripts/python/flrp/inputs/l7_lattice.json \
#         --out /path/to/fin-lat-rep-gap/L10/results/l10.search.json --date 2026-09-17
#
# Set FLR_COSET_ACTION := true to include the coset-action tables (the unary
# algebra itself, one permutation of the cosets per generator of G) in the
# record; they are the certificate route's input in agda-algebras but make the
# file about three megabytes at these indices, so the committed report omits
# them.
#
# Result (2026.09.17): L10/results/l10.search.json, verdict "positive" with an
# isomorphism witness for each of the two intervals.

if not IsBoundGlobal("FLR_AGDA_ALGEBRAS") or not IsBoundGlobal("FLR_OUT") then
  Print("FAIL: set FLR_AGDA_ALGEBRAS (the agda-algebras checkout) and FLR_OUT with gap -c\n");
  QUIT_GAP(1);
fi;
if not IsBoundGlobal("FLR_COSET_ACTION") then
  FLR_COSET_ACTION := false;
fi;
for f in ["json.g", "provenance.g", "interval.g", "cosets.g"] do
  Read(Concatenation(FLR_AGDA_ALGEBRAS, "/scripts/gap/flrp/lib/", f));
od;
if LoadPackage("tomlib") <> true then
  Print("FAIL: the tomlib package is not available\n");
  QUIT_GAP(1);
fi;

F := GF(64);
z := Zero(F);
o := One(F);
u := ImmutableMatrix(F, [[o,o],[z,o]]);
v := ImmutableMatrix(F, [[z,o],[o,z]]);
G1 := SL(2,64);
H1 := Subgroup(G1, [u,v]);
rec1 := FLRP_IntervalRecord(rec(source := "SL", id := [2, 64]), G1, H1);

tom := TableOfMarks("S6(2)");
G2 := UnderlyingGroup(tom);
ords := OrdersTom(tom);
cls := First([1 .. Length(ords)], i -> ords[i] = 42 and
         Sum(List([1 .. Length(ords)], j -> ContainingTom(tom, i, j))) = 7);
H2 := RepresentativeTom(tom, cls);
rec2 := FLRP_IntervalRecord(rec(source := "TomLib", id := ["S6(2)", cls]), G2, H2);

if FLR_COSET_ACTION then
  rec1.cosetAction := FLRP_CosetAction(G1, H1);
  rec2.cosetAction := FLRP_CosetAction(G2, H2);
fi;
out := rec( format := "flrp-gap-search-raw v1",
            engine := FLRP_Provenance(),
            config := rec( mode := "single-group-interval",
                           source := "Tian 2026 (SL(2,64)) and TomLib S6(2)", id := [],
                           targetSize := 7, indexFilter := 0 ),
            scanned := rec( groups := 2 ),
            sizeHistogram := rec( ("7") := 2 ),
            candidates := [rec1, rec2] );
JSON_WriteFile(FLR_OUT, out);
Print("wrote ", FLR_OUT, "\n");
QUIT_GAP(0);
