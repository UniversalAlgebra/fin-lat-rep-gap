# obsolete

## `Install_new_IntermediateSubgroups_method.gap`

This file installs a method for GAP's `IntermediateSubgroups` operation that
finds the subgroups between `U` and `G` by working down through maximal
subgroups.  It is much faster than the coset-blocks method GAP used by default
at the time, and the computations in [`PJ11.gap`](../PJ11.gap) and
[`PJ17.gap`](../PJ17.gap) were done with it installed.

**It is no longer needed.**  The same method now ships with GAP itself, in
`lib/grplatt.gi`, as

    InstallMethod(IntermediateSubgroups, "using maximal subgroups",
      IsIdenticalObj, [IsGroup, IsGroup], 1, ...

It is absent from GAP 4.8.10 and present in GAP 4.9.1, so it entered the
library in **GAP 4.9** (2018).  The paper was written against GAP 4.8.3, which
is why the method had to be installed by hand.  The library version has since
been improved well beyond the copy kept here: it filters candidate maximal
subgroups by orbit lengths, uses `ContainingConjugates` instead of walking a
right transversal, and falls back cleanly when the maximal subgroups cannot be
computed.

So on any GAP from 4.9 onward, do not read this file.  Just call
`IntermediateSubgroups(G, U)` and GAP will select the fast method on its own.

The file is kept only so that the computations in the paper can be reproduced
on the GAP version they were run on.

## License

This file is an early version of GAP library code contributed by Alexander
Hulpke, and it is covered by GAP's license, the GNU General Public License
version 2 or later.  The MIT license in [`LICENSE.txt`](../LICENSE.txt) does
not apply to it.
