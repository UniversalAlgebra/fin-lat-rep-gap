# File: twistedWreathHexagon.g
# Author: William DeMeo
# Date: 2026.09.18
#
# Description: computes the sizes of the two twisted wreath product
# representations of the hexagon, Aschbacher's and Palfy's, and verifies that
# each interval really is the hexagon.  Section 1 of the article quotes the
# sizes.
#
#   [1] M. Aschbacher, On intervals in subgroup lattices of finite groups,
#       J. Amer. Math. Soc. 21 (2008), 809-830.  Section 7 constructs G(tau);
#       (7.1) and (8.4) identify the interval; Example 8.5 is the hexagon.
#   [2] P. P. Palfy, The finite congruence lattice problem, lectures at the
#       Summer School on General Algebra and Ordered Sets, Stara Lesna, 2009.
#       The twisted wreath product formulation used below is his.
#
# The twisted wreath product of (B, H, A, alpha), where A <= H and
# alpha : A -> Aut(B), is G = HU with
#
#     U = { u : H -> B  |  u(xa) = u(x)^alpha(a) for all x in H, a in A },
#
# a group isomorphic to B^[H:A], on which H acts by (u^h)(x) = u(hx).  So the
# size of the representation is
#
#     [G : H] = |U| = |B|^[H:A].
#
# The interval is identified without building G, which is far too large to
# build: by Aschbacher's theorem, in the form Palfy states it, Int(H; HU) is
# the dual of the poset of all extensions beta : T -> Aut(B) of alpha to
# subgroups A <= T <= H, ordered by restriction, with a largest element added;
# and an extension is determined by its kernel.  So the program enumerates the
# subgroups T between A and H, and for each T the normal subgroups K of T with
# K /\ A = 1 and T/K isomorphic to a subgroup of Aut(B) containing alpha(A),
# constructs beta explicitly and checks that it extends alpha, assembles the
# poset, and tests it against the hexagon's covering relation by brute force
# over relabelings.
#
# Both examples have B = A5, with Aut(A5) = S5 and alpha the natural map
# (a,a) -> a from the diagonal A = {(a,a) : a in A5} onto Inn(A5) = A5.
#
#   Aschbacher, Example 8.5:  H = A6 x A6.   [H:A] = 2160.   [G:H] = 60^2160.
#   Palfy, 2009 lectures:     H = S5 x A5.   [H:A] = 120.    [G:H] = 60^120.
#
# Result (GAP 4.15.1, 2026.09.18), the output of this program:
#
#   A5-invariant subgroups of A6, by order: [ 1, 60, 360 ]   (so I_{A6}(A5) = {1, A5, A6}, as Example 8.5 says)
#   == Aschbacher (A5, A6 x A6, diag A5): |H| = 129600, |A| = 60, [H:A] = 2160
#      [G:H] = |A5|^[H:A] = 60^2160, a number of 3841 decimal digits
#      subgroups strictly between A and H: 4 = [ "A6", "A5 x A5", "A5 x A6", "A6 x A5" ]
#      T = A5 (order 60): 1 extension(s) of alpha, kernels [ "1" ]
#      T = A6 (order 360): 0 extension(s) of alpha, kernels [  ]
#      T = A5 x A5 (order 3600): 2 extension(s) of alpha, kernels [ "A5", "A5" ]
#      T = A5 x A6 (order 21600): 1 extension(s) of alpha, kernels [ "A6" ]
#      T = A6 x A5 (order 21600): 1 extension(s) of alpha, kernels [ "A6" ]
#      T = A6 x A6 (order 129600): 0 extension(s) of alpha, kernels [  ]
#      extension poset with a top added: 6 elements, covers [ [ 0, 1 ], [ 0, 2 ], [ 1, 3 ], [ 2, 4 ], [ 3, 5 ], [ 4, 5 ] ]
#      ... is the hexagon: true;  its dual Int(H;HU) is the hexagon: true
#   == Palfy (A5, S5 x A5, diag A5): |H| = 7200, |A| = 60, [H:A] = 120
#      [G:H] = |A5|^[H:A] = 60^120, a number of 214 decimal digits
#      subgroups strictly between A and H: 1 = [ "A5 x A5" ]
#      T = A5 (order 60): 1 extension(s) of alpha, kernels [ "1" ]
#      T = A5 x A5 (order 3600): 2 extension(s) of alpha, kernels [ "A5", "A5" ]
#      T = A5 x S5 (order 7200): 2 extension(s) of alpha, kernels [ "S5", "A5" ]
#      extension poset with a top added: 6 elements, covers [ [ 0, 1 ], [ 0, 2 ], [ 1, 4 ], [ 2, 3 ], [ 3, 5 ], [ 4, 5 ] ]
#      ... is the hexagon: true;  its dual Int(H;HU) is the hexagon: true
#
# One detail differs from Palfy's slide, which lists the subgroups of A6 x A6
# containing A as A < A5 x A5 < A6 x A5, A5 x A6 < A6 x A6.  There is a fifth,
# the diagonal A6 = {(x,x) : x in A6}.  It admits no extension of alpha, since
# A6 does not embed in S5, so the hexagon is unaffected; the program lists it
# so that the enumeration is seen to be complete.
#
# Runs in a few seconds.

SizeScreen([256,]);

S5 := SymmetricGroup(5);;
A5 := AlternatingGroup(5);;      # Aut(A5) = S5 and Inn(A5) = A5, acting on {1..5}

# The hexagon's covering relation: 0 the bottom, 5 the top, two 3-chains.
hexTarget := Set([[0,1],[1,2],[2,5],[0,3],[3,4],[4,5]]);

# Is a covering relation on {0, 1, ..., m+1}, with 0 the bottom and m+1 the
# top, the hexagon?  Brute force over the 4! relabelings of the middle.
isHexagonCovers := function(m, covers)
    local top, perms, f, mapped;
    if m <> 4 then return false; fi;
    top := m + 1;
    for perms in PermutationsList([1..m]) do
        f := function(x)
            if x = 0 then return 0;
            elif x = top then return 5;
            else return perms[x]; fi;
        end;
        mapped := Set(covers, e -> [ f(e[1]), f(e[2]) ]);
        if mapped = hexTarget then return true; fi;
    od;
    return false;
end;

# H = H1 x H2 with embeddings e1, e2, where each Hi contains A5 acting on
# {1..5}; A = {(a,a) : a in A5} and alpha((a,a)) = a.  Enumerates the
# extensions of alpha, assembles their poset, and tests it.  Returns the
# extensions as records (T, K, beta).
signalizerLattice := function(name, H, e1, e2)
    local gensA5, A, r, Ts, exts, T, K, q, Q, target, psi0, imgs, s, gensT,
          betaImgs, beta, n, leq, covers, i, j, idx, inter, m, f, dual;
    gensA5 := GeneratorsOfGroup(A5);
    A := Subgroup(H, List(gensA5, a -> Image(e1,a) * Image(e2,a)));
    Print("== ", name, ": |H| = ", Size(H), ", |A| = ", Size(A),
          ", [H:A] = ", Index(H,A), "\n");
    Print("   [G:H] = |A5|^[H:A] = 60^", Index(H,A), ", a number of ",
          Length(String(60^Index(H,A))), " decimal digits\n");
    r := IntermediateSubgroups(H, A);
    Print("   subgroups strictly between A and H: ", Length(r.subgroups),
          " = ", List(r.subgroups, StructureDescription), "\n");
    Ts := Concatenation([A], r.subgroups, [H]);

    # The extensions.  beta(T) contains alpha(A) = Inn(A5) = A5 and lies in
    # Aut(A5) = S5, so T/K is A5 or S5.  A first isomorphism psi0 : T/K -> A5
    # or S5 restricts on A to alpha composed with an automorphism of A5;
    # every automorphism of A5 is conjugation by an element s of S5, so
    # composing with conjugation by s^-1 gives the extension.  beta is then
    # built as a homomorphism and checked on every generator of A.
    exts := [];
    for T in Ts do
      for K in NormalSubgroups(T) do
        if Size(Intersection(K, A)) = 1 then
          q := NaturalHomomorphismByNormalSubgroup(T, K);
          Q := Image(q);
          if Size(Q) = 60 then target := A5;
          elif Size(Q) = 120 then target := S5;
          else continue; fi;
          psi0 := IsomorphismGroups(Q, target);
          if psi0 = fail then continue; fi;
          imgs := List(gensA5, a -> Image(psi0, Image(q, Image(e1,a) * Image(e2,a))));
          s := RepresentativeAction(S5, imgs, gensA5, OnTuples);
          if s = fail then Error("an automorphism of A5 that is not inner in S5?"); fi;
          gensT := GeneratorsOfGroup(T);
          betaImgs := List(gensT, t -> Image(psi0, Image(q, t))^s);
          beta := GroupHomomorphismByImages(T, S5, gensT, betaImgs);
          if beta = fail then Error("beta is not a homomorphism?"); fi;
          if not ForAll(gensA5, a -> Image(beta, Image(e1,a) * Image(e2,a)) = a) then
            Error("beta does not extend alpha");
          fi;
          Add(exts, rec(T := T, K := K, beta := beta));
        fi;
      od;
    od;
    for T in Ts do
      Print("   T = ", StructureDescription(T), " (order ", Size(T), "): ",
            Number(exts, e -> e.T = T), " extension(s) of alpha, kernels ",
            List(Filtered(exts, e -> e.T = T), e -> StructureDescription(e.K)), "\n");
    od;

    # The poset: (T1,K1) <= (T2,K2) iff T1 <= T2 and K2 /\ T1 = K1, that is,
    # beta2 restricts to beta1.  Element n+1 is the added top.
    n := Length(exts);
    leq := function(i, j)
        if j = n+1 then return true; fi;
        if i = n+1 then return false; fi;
        return IsSubgroup(exts[j].T, exts[i].T)
               and Intersection(exts[j].K, exts[i].T) = exts[i].K;
    end;
    covers := [];
    for i in [1..n+1] do
      for j in [1..n+1] do
        if i <> j and leq(i,j)
           and not ForAny([1..n+1], k -> k <> i and k <> j and leq(i,k) and leq(k,j)) then
          Add(covers, [i,j]);
        fi;
      od;
    od;
    # Relabel: (A, 1, alpha) is 0, the added top is m+1, the rest 1..m.
    idx := PositionProperty(exts, e -> e.T = A);
    inter := Filtered([1..n], i -> i <> idx);
    m := Length(inter);
    f := function(x)
        if x = idx then return 0;
        elif x = n+1 then return m+1;
        else return Position(inter, x); fi;
    end;
    covers := Set(covers, e -> [f(e[1]), f(e[2])]);
    dual := Set(covers, e -> [m+1-e[2], m+1-e[1]]);
    Print("   extension poset with a top added: ", n+1, " elements, covers ", covers, "\n");
    Print("   ... is the hexagon: ", isHexagonCovers(m, covers),
          ";  its dual Int(H;HU) is the hexagon: ", isHexagonCovers(m, dual), "\n");
    return exts;
end;

# Aschbacher's Example 8.5: L = A5, H1 = H2 = A6, K_i = A5, N_H the diagonal.
# The example rests on I_{A6}(A5) = {1, A5, A6}: the only subgroups of A6
# normalised by a point stabiliser A5 are 1, A5 and A6.
A6 := AlternatingGroup(6);;
Print("A5-invariant subgroups of A6, by order: ",
      List(Filtered(Concatenation(List(ConjugacyClassesSubgroups(A6), AsList)),
                    W -> IsSubgroup(Normalizer(A6, W), A5)), Size),
      "   (so I_{A6}(A5) = {1, A5, A6}, as Example 8.5 says)\n");
HA := DirectProduct(A6, A6);;
aschbacher := signalizerLattice("Aschbacher (A5, A6 x A6, diag A5)", HA, Embedding(HA,1), Embedding(HA,2));;

# Palfy's own example from the 2009 lectures: B = A5, H = S5 x A5, A the diagonal.
HP := DirectProduct(S5, A5);;
palfy := signalizerLattice("Palfy (A5, S5 x A5, diag A5)", HP, Embedding(HP,1), Embedding(HP,2));;
