# GAP code to check that Palfy's example in [1] p. 477 is a hexagon.
#
# [1] Palfy, "On Feit's Examples of Intervals in Subgroup Lattices" J. Algebra, 116 (1988).
#
# williamdemeo@gmail.com
# 2012.10.27
#
# 2026.09.13: the subgroups below used to be picked out by their position in
# the list MaximalSubgroupClassReps returns.  Those positions changed between
# GAP versions, so on a current GAP the script selected the wrong subgroups and
# the argument collapsed.  They are now selected by order instead, which is
# what actually identifies them.  Verified on GAP 4.15.1.

G:=AlternatingGroup(11);;
ccms:=ConjugacyClassesMaximalSubgroups(G);;  # there are 7

# Two of the classes of maximal subgroups consist of copies of M11 (order 7920).
m11classes:=Filtered([1..Length(ccms)], i -> Size(Representative(ccms[i])) = 7920);;
Print("classes of maximal subgroups isomorphic to M11: ", m11classes, "\n");

M11:=Representative(ccms[m11classes[1]]);;
K1:=First(MaximalSubgroupClassReps(M11), x -> Size(x) = 660);;   # PSL(2,11)
H:=First(MaximalSubgroupClassReps(K1), x -> Size(x) = 55);;      # C11 : C5
Print("K1 = ", StructureDescription(K1), " of order ", Size(K1), "\n");
Print("H  = ", StructureDescription(H), " of order ", Size(H), "\n");

# Now find another M11 maximal subgroup of G that contains H.

# There are only two maximal subgroups of G containing H.
# Proof:
count:=0;;
for MC in ccms do
    for M in MC do
        if IsSubgroup(M,H) then
            count:=count+1;
        fi;
    od;
od;
Print("There are ", count, " maximal subgroups of A11 containing H.\n");

# The other maximal subgroup containing H is an M11 in the other
# conjugacy class of maximal subgroups isomorphic to M11.
M11Other:=First(ccms[m11classes[2]], M -> IsSubgroup(M,H));;

# Check that M11 and M11Other meet at H:
Print("M11 meets M11Other at H: ", H = Intersection(M11,M11Other), "\n");

# Check that the intervals [H,M11] and [H,M11Other] are 3 element chains:
Print("[H,M11]      covers: ", IntermediateSubgroups(M11,H).inclusions, "\n");
Print("[H,M11Other] covers: ", IntermediateSubgroups(M11Other,H).inclusions, "\n");

# and that [H,G] is therefore the hexagon, on a set of size 9! = 362880.
Print("[H,A11]      covers: ", IntermediateSubgroups(G,H).inclusions, "\n");
Print("index [A11:H] = ", Index(G,H), "\n");
