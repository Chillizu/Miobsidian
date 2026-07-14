#!/usr/bin/env bash
# ============================================================================
# Master Scheduler — 4 Experiments Runner
# ============================================================================
# Parallel strategy:
#   TOP1 (DES, CPU-bound)   + TOP2 (ECC, I/O-bound) — 并行
#   TOP3 (LWE, CPU-light)   + TOP4 (Shor, CPU-light) — 单独依次跑
# ============================================================================
set -uo pipefail

BASE="$HOME/Projects/Mioom/essay"
SCRIPTS_DIR="$BASE/experiments"

echo "================================================================"
echo " 4-Experiment Overnight Runner"
echo " Date: $(date)"
echo " CPU: $(nproc) cores"
echo " Parallel: TOP1 + TOP2 (parallel), then TOP3 + TOP4 (sequential)"
echo "================================================================"
echo ""

START_TIME=$(date +%s)

# ---- Check scripts exist ----
for script in run_top1_des.sh run_top2_ecc.sh run_top3_lwe.sh run_top4_shor.sh; do
    if [ ! -f "$SCRIPTS_DIR/$script" ]; then
        echo "[ERROR] $script not found in $SCRIPTS_DIR"
        exit 1
    fi
done

# ---- Phase 1: TOP1 + TOP2 in parallel ----
echo "[Phase 1] Starting TOP1 (DES) + TOP2 (ECC) in parallel..."
echo ""

echo "  [TOP1] bash $SCRIPTS_DIR/run_top1_des.sh"
echo "  [TOP2] bash $SCRIPTS_DIR/run_top2_ecc.sh"
echo ""

# Start both in background
bash "$SCRIPTS_DIR/run_top1_des.sh" > "$SCRIPTS_DIR/top1_parallel.log" 2>&1 &
TOP1_PID=$!

bash "$SCRIPTS_DIR/run_top2_ecc.sh" > "$SCRIPTS_DIR/top2_parallel.log" 2>&1 &
TOP2_PID=$!

echo "  TOP1 PID: $TOP1_PID"
echo "  TOP2 PID: $TOP2_PID"
echo ""
echo "  Waiting for both to complete..."

# Wait for both
wait $TOP1_PID $TOP2_PID
TOP1_EXIT=$?
TOP2_EXIT=$?

echo ""
echo "  [DONE] TOP1 exit code: $TOP1_EXIT"
echo "  [DONE] TOP2 exit code: $TOP2_EXIT"
echo ""

PHASE1_END=$(date +%s)
echo "  Phase 1 took: $(( (PHASE1_END - START_TIME) / 60 )) minutes"
echo ""

# ---- Phase 2: TOP3 sequentially ----
echo "[Phase 2] Starting TOP3 (LWE)..."
bash "$SCRIPTS_DIR/run_top3_lwe.sh" > "$SCRIPTS_DIR/top3_seq.log" 2>&1
TOP3_EXIT=$?
echo "  [DONE] TOP3 exit code: $TOP3_EXIT"
echo ""

# ---- Phase 3: TOP4 sequentially ----
echo "[Phase 3] Starting TOP4 (Shor)..."
bash "$SCRIPTS_DIR/run_top4_shor.sh" > "$SCRIPTS_DIR/top4_seq.log" 2>&1
TOP4_EXIT=$?
echo "  [DONE] TOP4 exit code: $TOP4_EXIT"
echo ""

# ---- Summary ----
END_TIME=$(date +%s)
TOTAL_MIN=$(( (END_TIME - START_TIME) / 60 ))

echo "================================================================"
echo " ALL EXPERIMENTS COMPLETE"
echo " Total time: $TOTAL_MIN minutes"
echo ""
echo " Experiment results:"
echo "   TOP1-DES:  $SCRIPTS_DIR/TOP1_DES_*/SUMMARY.md"
echo "   TOP2-ECC:  $SCRIPTS_DIR/TOP2_ECC_*/SUMMARY.md"
echo "   TOP3-LWE:  $SCRIPTS_DIR/TOP3_LWE_*/SUMMARY.md"
echo "   TOP4-SHOR: $SCRIPTS_DIR/TOP4_SHOR_*/SUMMARY.md"
echo ""
echo " Individual logs:"
echo "   top1_parallel.log / top2_parallel.log"
echo "   top3_seq.log / top4_seq.log"
echo "================================================================"
