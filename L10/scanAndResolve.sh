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
# TIMEOUT.  The driver exits nonzero if the scan fails or if any recomputation
# does, so a partial run cannot be mistaken for a completed one.
#
# SLOW is the list of tables for which StructureDescription is turned off.
# Naming a subgroup is a display convenience, not part of the test, and on
# these two it runs for over half an hour after a verdict reached in about a
# second, which is longer than LIMIT allows; with it off they finish at once.
# The lines for those tables report subgroup orders in place of names.
set -u
GAP=${GAP:-gap}
JOBS=${JOBS:-4}
LIMIT=${LIMIT:-1800}
SLOW=${SLOW:-'2^6:U4(2) G2(4)'}
OUT=L10/results
mkdir -p "$OUT/resolve"

echo "scan (marks only) ..."
$GAP -A -q -c 'FLR_RESOLVE_BOUND := 0;;' -b L10/tomScan.g > "$OUT/tomScan.txt" 2>&1
scan_status=$?
# Without this the next command would turn a failed scan (no GAP, no tomlib, an
# abort part way through) into an empty table list, and the driver would finish
# looking like a completed search that found nothing.
if (( scan_status != 0 )) || ! grep -q '^scanned ' "$OUT/tomScan.txt"; then
  echo "FAILED: the marks scan exited $scan_status and did not finish; see $OUT/tomScan.txt" >&2
  exit 1
fi
# LC_ALL=C: this order decides which of two tables whose names sanitize alike
# gets the disambiguating suffix below, so it must not vary with the locale.
# Clear the previous run's per-table reports.  summarizeResolve.sh summarises
# every .txt in this directory, so a report left behind by an earlier run with
# a different candidate set would be folded into a summary that claims to
# describe this one.  Done after the scan has succeeded, so a failed scan
# leaves the previous results intact.
rm -f "$OUT/resolve"/*.txt

grep -E '^(HIT|AMBIGUOUS) ' "$OUT/tomScan.txt" | awk '{print $2}' | LC_ALL=C sort -u > "$OUT/resolve/tables.txt"
echo "$(wc -l < "$OUT/resolve/tables.txt") table(s) to recompute explicitly"

# Distinct TomLib names can sanitize to the same filename: 2^4:A8 and 2^4`A8
# differ only in a character that is not allowed in a filename, and without
# this the second run silently overwrites the first.  The suffix is assigned
# here, in the sequential part, so parallel jobs cannot race for it.
declare -A used=()
pids=()
names=()
while IFS= read -r name; do
  base=$(printf '%s' "$name" | tr -c 'A-Za-z0-9._-' '_')
  if [[ -n ${used[$base]:-} ]]; then
    used[$base]=$(( used[$base] + 1 ))
    base="${base}_${used[$base]}"
  else
    used[$base]=1
  fi
  structure=true
  for slow in $SLOW; do
    if [[ $name == "$slow" ]]; then structure=false; fi
  done
  while (( $(jobs -rp | wc -l) >= JOBS )); do sleep 1; done
  (
    file="$OUT/resolve/$base.txt"
    timeout "$LIMIT" $GAP -A -q -o 6g \
      -c "FLR_TABLES := [\"$name\"];; FLR_RESOLVE_BOUND := 10^12;; FLR_STRUCTURE := $structure;;" \
      -b L10/tomScan.g > "$file" 2>&1
    status=$?
    if (( status == 124 )); then
      echo "TIMEOUT after ${LIMIT}s: $name" >> "$file"
    elif (( status != 0 )); then
      echo "FAILED: $name exited $status" >> "$file"
    fi
    echo "done: $name (exit $status)"
    # The subshell must carry the child's status out; ending on `echo` would
    # report success for every table and make the wait below blind.
    exit $status
  ) &
  pids+=("$!")
  names+=("$name")
done < "$OUT/resolve/tables.txt"

failed=0
for i in "${!pids[@]}"; do
  if ! wait "${pids[$i]}"; then
    echo "FAILED: ${names[$i]} did not complete" >&2
    failed=$(( failed + 1 ))
  fi
done

echo
echo "summary of the explicit recomputations:"
# Delegated rather than inlined: the inline version used to match the group name
# with [^:]+, which cannot span a TomLib name containing a colon, so most
# EXPLICIT lines fell through to the bare `target:` alternative and `paste`
# joined unrelated records.  summarizeResolve.sh anchors on the whole line.
bash L10/summarizeResolve.sh | tee "$OUT/resolveSummary.txt"

if (( failed > 0 )); then
  echo >&2
  echo "FAILED: $failed table(s) did not complete; the summary above is partial" >&2
  exit 1
fi
