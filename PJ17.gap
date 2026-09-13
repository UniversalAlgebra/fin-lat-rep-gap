# Some GAP commands which show that lattice 17 (= L_17 of the paper) is an
# interval in the subgroup lattice of (A4 x A4) : C2 = SmallGroup(288,1025);
#
# Verified on GAP 4.15.1, 2026.09.13: the covering relations below are
# reproduced exactly.  (A current GAP prints the structure description of this
# group as (C2 x C2 x C2 x C2) : (C3 x S3), which is the same group written
# another way.)

g:=SmallGroup(288,1025);;
cc:=ConjugacyClassesSubgroups(g);;
h:=Representative(cc[15]);;
inthg:=IntermediateSubgroups(g,h);

# This returns the covering relations
# [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 0, 4 ], [ 1, 6 ], [ 2, 5 ], [ 3, 5 ], [ 4, 5 ], [ 5, 6 ] ]
# so we see this is, indeed, lattice 17.  Here 0 denotes h and 6 denotes g,
# and the index [g:h] is 48.

Print("order of h: ", Size(h), ",  index [g:h] = ", Index(g,h), "\n");
Print("covers: ", inthg.inclusions, "\n");

# To draw the interval in XGAP (this part needs the XGAP package and a display,
# so it is skipped when XGAP is not loaded):
if IsBoundGlobal("GraphicSubgroupLattice") then
    l:=GraphicSubgroupLattice(g);;
    InsertVertex(l,h);
    for k in [1..Size(inthg.subgroups)] do
        InsertVertex(l,inthg.subgroups[k]);
    od;
fi;
