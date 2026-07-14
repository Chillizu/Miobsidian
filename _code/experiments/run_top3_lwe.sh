#!/usr/bin/env bash
set -uo pipefail
BASE="$HOME/Projects/Mioom/essay"
OUTDIR="$BASE/experiments/TOP3_LWE_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[TOP3] LWE Parameter Space Search (via Sage)"
echo "=============================================="

# Use Sage's Python for lattice-estimator (needs Sage for math deps)
SAGE_PYTHON="sage -python"
SAGE_PIP="sage -pip"

# Install deps via Sage's pip
$SAGE_PIP install -q matplotlib numpy 2>/dev/null || true
$SAGE_PIP install -q git+https://github.com/malb/lattice-estimator.git 2>&1

echo "Running LWE parameter search..."
SAGE_NUM_THREADS=4 $SAGE_PYTHON "$BASE/experiments/lwe_search_standalone.py" "$OUTDIR" 2>&1 | tee top3_run.log

echo "[TOP3] Complete in $OUTDIR"
