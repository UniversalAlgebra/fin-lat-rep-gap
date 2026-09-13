# The following commands show that the lattice PJ11 (= L_11 of the paper)
# occurs as the union of a filter and ideal in a subgroup lattice of a finite
# group.  They are the computation written out in Section 3 of the paper,
# in the discussion following Figure "L11".
#
# Verified on GAP 4.15.1, 2026.09.13.  Everything below reproduces, with one
# repair: M1 and M2 used to be picked out as Representative(ccsgB[2]) and
# Representative(ccsgB[4]), and on a current GAP the second of those is no
# longer a subgroup of H.  They are now selected as what the argument actually
# needs, namely the two nontrivial proper subgroups of H.

G:=SmallGroup(216,153);    
ccsg:=ConjugacyClassesSubgroups(G);;
H:=Representative(ccsg[8]);
intHG:=IntermediateSubgroups(G,H);
# returns
#   rec( subgroups := [ Group([ f1, f4, f5*f6 ]), Group([ f1, f2, f3*f4, f4 ]), 
#        Group([ f1, f4, f5, f6 ]) ], 
#    inclusions := [ [ 0, 1 ], [ 0, 2 ], [ 1, 3 ], [ 2, 4 ], [ 3, 4 ] ] )
# which proves the interval [H, G] is a pentagon.

A:=intHG.subgroups[1];  B:=intHG.subgroups[3];  C:=intHG.subgroups[2];
# A < B are the comparable generators of the pentagon
# C is the incomparable generator

ccsgB:=ConjugacyClassesSubgroups(B);;
# By looking at the subgroup lattice in XGAP, we notice that 
# there is a conjugacy class of subgroups of B containing six
# subgroups each of index 72 in G (order 3), and the subgroups
# in this class are not subgroups of A or C.
# We need to identify this conjugacy class of subgroups.
# To do so, we first check the size of the conjugacy classes 
# of subgroups of B.
List(ccsgB, x->Size((x)));
# returns [ 1, 9, 1, 3, 3, 6, 3, 9, 9, 1, 1, 2, 1, 3, 1, 1 ]
# Thus there is only one conjugacy class of size 6,
K:=Representative(ccsgB[6]);
# and the subgroups of this class have order 3:
Order(K); # returns 3
# Note that K is a minimal subgroup since |K|=3.  

# Finally, check that K is a subgroup of B, and not a subgroup of A or C:
IsSubgroup(A,K);  # returns false
IsSubgroup(B,K);  # returns true
IsSubgroup(C,K);  # returns false
# This shows lattice PJ11 is representable on a set of size 216.

# In this example, where [H,G] is the pentagon, the index is [G:H]=36.  
# There might be a nontrivial subgroup M < H such that in the 
# interval [M, G] there is a filter+ideal that is isomorphic to PJ11.
# This would give us PJ11 on a smaller set than 216.

# H is cyclic of order 6, so it has exactly two nontrivial proper subgroups,
# one of order 2 and one of order 3.
subsH:=Filtered(List(ConjugacyClassesSubgroups(H), Representative),
                x -> Size(x) > 1 and Size(x) < Size(H));
M1:=First(subsH, x -> Size(x) = 2);
M2:=First(subsH, x -> Size(x) = 3);
IsSubgroup(H,M1);  # returns true
IsSubgroup(H,M2);  # returns true
# We need to find a subgroup that covers one of these two subgroups
# and is not below A or C.
intM1B:=IntermediateSubgroups(B,M1);
# returns 
#  rec( subgroups := [ Group([ f4, f5 ]), Group([ f4, f6 ]), Group([ f1^2, f4 ]), 
#        Group([ f4, f5*f6 ]), Group([ f4, f5^2*f6 ]), Group([ f4, f5, f6 ]), 
#        Group([ f1^2, f4, f5*f6 ]) ], 
#    inclusions := [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 0, 4 ], [ 0, 5 ], [ 1, 6 ], [ 2, 6 ], 
#        [ 3, 7 ], [ 4, 6 ], [ 4, 7 ], [ 5, 6 ], [ 6, 8 ], [ 7, 8 ] ] )
#
# M1 is maximal in the intermediate subgroups 1, 2, 3, 4, and 5.
# Check whether these are subgroups of A or C.
IsSubgroup(A,intM1B.subgroups[1]);   # returns false
IsSubgroup(B,intM1B.subgroups[1]);   # returns true (of course)
IsSubgroup(C,intM1B.subgroups[1]);   # returns false
# So PJ11 is the union of [M1, intM1B.subgroups[1]] and [H, G]
Index(G,M1);  # returns 108
# so we have a representation of PJ11 on 108 elements.

# Next consider M2.
Index(G,M2);  # returns 72
intM2B:=IntermediateSubgroups(B,M2);
# returns 
#  rec( subgroups := [ Group([ f1, f4 ]), Group([ f1, f4*f5*f6 ]), Group([ f1, f4*f5^2*f6^2 ]), 
#        Group([ f1, f5*f6 ]), Group([ f1, f4, f5*f6 ]), Group([ f1, f4*f5, f5^2*f6^2 ]), 
#        Group([ f1, f4*f6, f5*f6 ]), Group([ f1, f5, f6 ]) ], 
#    inclusions := [ [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 0, 4 ], [ 1, 5 ], [ 2, 5 ], [ 3, 5 ], 
#        [ 4, 5 ], [ 4, 6 ], [ 4, 7 ], [ 4, 8 ], [ 5, 9 ], [ 6, 9 ], [ 7, 9 ], [ 8, 9 ] ] )
#
# so M2 is maximal in the intermediate subgroups 1, 2, 3, and 4.
# Check whether one of these is not a subgroup of A or C:
IsSubgroup(A,intM2B.subgroups[1]);   # returns true
IsSubgroup(C,intM2B.subgroups[1]);   # returns true

IsSubgroup(A,intM2B.subgroups[2]);   # returns true
IsSubgroup(C,intM2B.subgroups[2]);   # returns false

IsSubgroup(A,intM2B.subgroups[3]);   # returns true
IsSubgroup(C,intM2B.subgroups[3]);   # returns false

IsSubgroup(A,intM2B.subgroups[3]);   # returns true
IsSubgroup(C,intM2B.subgroups[3]);   # returns false
#
# So, using this method and this group, the smallest set on 
# which we can represent PJ11 is 108.
