#!/usr/bin/env bash
# File: L10/summarizeResolve.sh
# Author: William DeMeo
# Date: 2026.09.17
#
# Prints one line per explicit recomputation found under L10/results/resolve/,
# with the group, the class, |H|, the index, core-freeness and the verdict, and
# one line per table that hit the time limit.  L10/scanAndResolve.sh runs it
# at the end; run it by hand from the repository root to look at a partial run.
set -u
OUT=${OUT:-L10/results/resolve}
for f in "$OUT"/*.txt; do
  sed -n 's/^EXPLICIT \(.*\) class \([0-9]*\): \(|G| = [0-9]*\) |H| = \([0-9]*\) (\(.*\)) index \([0-9]*\) core-free \([a-z]*\); interval size \([0-9]*\).*target: \([a-z]*\).*/\1 class \2: \3, |H| = \4 (\5), index \6, core-free \7, interval size \8, target: \9/p' "$f"
  grep -h '^TIMEOUT' "$f"
# LC_ALL=C and the whole line as a secondary key: 17 of the index values are
# shared by two or more tables, and without a total, locale-independent order
# the committed summary is reordered by a rerun under a different locale.
done | LC_ALL=C sort -t, -k4.8n -k1,1
