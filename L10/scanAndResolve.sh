#!/usr/bin/env bash
# File: L10/scanAndResolve.sh
# Author: William DeMeo
# Date: 2026.09.17
#
# Runs L10/tomScan.g over all of TomLib from the marks alone, then recomputes
# every table that produced a HIT or an AMBIGUOUS line in its own GAP process,
# several at a time, each under a time limit.  Outputs go under L10/results/:
# tomScan.txt for the scan, resolve/<table>.txt per table, and a one-line
# summary per explicit recomputation at the end.
#
# Run from the repository root.  GAP is taken from $GAP (default: gap), so a
# wrapped GAP can be supplied, as follows:
#
#     GAP="nix develop /path/to/agda-algebras#gap --command gap" L10/scanAndResolve.sh
#
# JOBS (default 4) is the number of parallel GAP processes and LIMIT (default
# 1800) the seconds allowed per table; a table that exceeds it is reported as
# TIMEOUT.
set -u
GAP=${GAP:-gap}
JOBS=${JOBS:-4}
LIMIT=${LIMIT:-1800}
OUT=L10/results
mkdir -p "$OUT/resolve"

echo "scan (marks only) ..."
$GAP -A -q -c 'FLR_RESOLVE_BOUND := 0;;' -b L10/tomScan.g > "$OUT/tomScan.txt" 2>&1
grep -E '^(HIT|AMBIGUOUS) ' "$OUT/tomScan.txt" | awk '{print $2}' | sort -u > "$OUT/resolve/tables.txt"
echo "$(wc -l < "$OUT/resolve/tables.txt") table(s) to recompute explicitly"

# Distinct TomLib names can sanitize to the same filename: 2^4:A8 and 2^4`A8
# differ only in a character that is not allowed in a filename, and without
# this the second run silently overwrites the first.  The suffix is assigned
# here, in the sequential part, so parallel jobs cannot race for it.
declare -A used=()
while IFS= read -r name; do
  base=$(printf '%s' "$name" | tr -c 'A-Za-z0-9._-' '_')
  if [[ -n ${used[$base]:-} ]]; then
    used[$base]=$(( used[$base] + 1 ))
    base="${base}_${used[$base]}"
  else
    used[$base]=1
  fi
  while (( $(jobs -rp | wc -l) >= JOBS )); do sleep 1; done
  (
    file="$OUT/resolve/$base.txt"
    timeout "$LIMIT" $GAP -A -q -o 6g \
      -c "FLR_TABLES := [\"$name\"];; FLR_RESOLVE_BOUND := 10^12;;" \
      -b L10/tomScan.g > "$file" 2>&1
    status=$?
    if (( status == 124 )); then echo "TIMEOUT after ${LIMIT}s: $name" >> "$file"; fi
    echo "done: $name (exit $status)"
  ) &
done < "$OUT/resolve/tables.txt"
wait

echo
echo "summary of the explicit recomputations:"
grep -h -o -E '^EXPLICIT [^:]+: \|G\| = [0-9]+ \|H\| = [0-9]+ \([^)]*\) index [0-9]+ core-free [a-z]+|target: [a-z]+|^TIMEOUT.*' "$OUT"/resolve/*.txt \
  | paste -d ' ' - - 2>/dev/null | sed 's/^EXPLICIT //'
