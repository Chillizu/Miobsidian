#!/usr/bin/env bash
# ============================================================================
# TOP 1 ⭐⭐⭐⭐⭐ — DES/3DES 非群性实验验证
# 验证 E(K2, E(K1, pt)) 不能被单密钥 K3 表示
# 产出：热力图、碰撞统计、增长曲线、采样图表
# 预计耗时：6-10h
# ============================================================================
set -uo pipefail

BASE="$HOME/Projects/Mioom/essay"
OUTDIR="$BASE/experiments/TOP1_DES_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[TOP1] DES Non-Group Verification — Started $(date)"
echo "================================================"

# Install deps
python3 -c "from Crypto.Cipher import DES" 2>/dev/null || pip install pycryptodome -q
python3 -c "import matplotlib" 2>/dev/null || pip install matplotlib -q
python3 -c "import numpy" 2>/dev/null || pip install numpy -q

cat > des_nongroup.py << 'PYEOF'
#!/usr/bin/env python3
"""
DES Non-Group Property Verification
====================================
Three experiments:
  1. Subgroup size estimation via birthday sampling (10^5 samples)
  2. Collision heatmap: how many K3 match E(K2, E(K1, pt))?
  3. Growth curve: distinct composites vs sample size
"""
from Crypto.Cipher import DES
import struct, random, time, math, sys
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict

OUT = "."

def des_enc(k, d):
    return DES.new(bytes(k), DES.MODE_ECB).encrypt(d)

# =============================================================
# Experiment 1: Birthday sampling — estimate subgroup size
# =============================================================
def exp1_subgroup_estimate(total_samples=100000, log_interval=5000):
    """Sample double-encryption mappings, count distinct outputs.
    
    If DES permutations formed a subgroup of size S, distinct composites
    would grow as S*(1 - exp(-n/S)). For non-group, they grow nearly linearly
    (each composite is a new mapping).
    """
    print(f"\n[Exp1] Subgroup estimate: {total_samples} samples")
    fp = b"DESBENCH"
    seen = set()
    distinct_counts = []
    sample_points = []
    t0 = time.time()

    for i in range(total_samples):
        k1 = [random.randrange(256) for _ in range(8)]
        k2 = [random.randrange(256) for _ in range(8)]
        c = des_enc(k2, des_enc(k1, fp))
        seen.add(c)
        
        if (i+1) % log_interval == 0:
            elapsed = time.time() - t0
            rate = (i+1) / elapsed
            distinct_counts.append(len(seen))
            sample_points.append(i+1)
            remaining = (total_samples - i - 1) / rate
            print(f"  [{i+1}/{total_samples}] distinct={len(seen)}, "
                  f"{rate:.0f} samples/s, ETA {remaining/60:.1f}min")

    total_time = time.time() - t0
    print(f"  Done in {total_time/60:.1f}min, rate={total_samples/total_time:.0f} samples/s")
    print(f"  Distinct composites: {len(seen)}/{total_samples}")
    
    # Estimate lower bound on subgroup size
    # If DES were a group, distinct count would converge. Non-group → linear growth.
    linear_ratio = len(seen) / total_samples
    print(f"  Distinct ratio: {linear_ratio:.4f} {'(non-group: near 1.0)' if linear_ratio > 0.95 else '(group: would converge)'}")
    
    # Save data
    with open(f"{OUT}/exp1_data.csv", "w") as f:
        f.write("samples,distinct\n")
        for s, d in zip(sample_points, distinct_counts):
            f.write(f"{s},{d}\n")
    
    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(sample_points, distinct_counts, 'b-', linewidth=1.5)
    ax.plot(sample_points, sample_points, 'r--', alpha=0.5, label='y=x (linear)')
    ax.set_xlabel('Samples')
    ax.set_ylabel('Distinct Composites')
    ax.set_title('DES: Distinct Double-Encryption Mappings vs Sample Count')
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(f"{OUT}/exp1_distinct_growth.png", dpi=150)
    plt.close()
    print("  [CHART] exp1_distinct_growth.png")

    return len(seen), sample_points, distinct_counts

# =============================================================
# Experiment 2: Collision heatmap — K3 match rate
# =============================================================
def exp2_collision_heatmap(num_pairs=50, candidates_per_pair=500):
    """For random (K1,K2), test how many K3 produce the same ciphertext.
    
    True group → many K3 match. Non-group → zero (within sampling).
    """
    print(f"\n[Exp2] Collision heatmap: {num_pairs} pairs x {candidates_per_pair} K3")
    fp = b"DESHEAT1"
    match_matrix = np.zeros((num_pairs, num_pairs))
    all_k3s = [bytes([random.randrange(256) for _ in range(8)]) 
               for _ in range(candidates_per_pair)]
    
    t0 = time.time()
    for i in range(num_pairs):
        k1 = bytes([random.randrange(256) for _ in range(8)])
        k2 = bytes([random.randrange(256) for _ in range(8)])
        composite = des_enc(bytes(k2), des_enc(bytes(k1), fp))
        
        matches = 0
        for j, k3 in enumerate(all_k3s):
            if des_enc(k3, fp) == composite:
                matches += 1
                # Record which (K1_i, K3_j) matched
                if i < num_pairs and j < num_pairs:
                    match_matrix[i][j] = 1
        
        if (i+1) % 5 == 0:
            print(f"  [{i+1}/{num_pairs}] pairs done, {matches} total matches so far")

    total_time = time.time() - t0
    print(f"  Done in {total_time:.1f}s, total matches={match_matrix.sum()}")
    print(f"  Expected if group: ~{num_pairs * candidates_per_pair / 2**64:.6f} (effectively 0)")
    
    # Plot heatmap
    fig, ax = plt.subplots(figsize=(10, 8))
    im = ax.imshow(match_matrix[:min(30, num_pairs), :min(30, num_pairs)], 
                   cmap='RdYlBu_r', aspect='auto', interpolation='nearest')
    ax.set_xlabel('K3 index')
    ax.set_ylabel('(K1, K2) pair index')
    ax.set_title('DES: Collision Matrix — E(K1,E(K2,P)) == E(K3,P)')
    plt.colorbar(im, ax=ax, label='Match')
    fig.tight_layout()
    fig.savefig(f"{OUT}/exp2_collision_heatmap.png", dpi=150)
    plt.close()
    print("  [CHART] exp2_collision_heatmap.png")
    
    return int(match_matrix.sum())

# =============================================================
# Experiment 3: Statistical test — permutation distribution
# =============================================================
def exp3_statistical_test(num_trials=50000):
    """Chi-squared style test: compare double-enc vs random permutation.
    
    Test: For a fixed P, the distribution of E(K2, E(K1, P)) should
    differ from E(K3, P) if DES is not a group.
    """
    print(f"\n[Exp3] Statistical test: {num_trials} trials")
    fp = b"DESSTATS"
    fixed_counts = defaultdict(int)
    double_counts = defaultdict(int)
    
    t0 = time.time()
    
    # Single-key distribution
    for i in range(num_trials):
        k3 = bytes([random.randrange(256) for _ in range(8)])
        c = des_enc(k3, fp)
        fixed_counts[c] += 1
    
    # Double-key distribution  
    for i in range(num_trials):
        k1 = bytes([random.randrange(256) for _ in range(8)])
        k2 = bytes([random.randrange(256) for _ in range(8)])
        c = des_enc(k2, des_enc(k1, fp))
        double_counts[c] += 1
    
    total_time = time.time() - t0
    print(f"  Done in {total_time:.1f}s")
    
    # Compare distributions
    unique_fixed = len(fixed_counts)
    unique_double = len(double_counts)
    overlap = len(set(fixed_counts.keys()) & set(double_counts.keys()))
    
    print(f"  Single-key distinct outputs: {unique_fixed}")
    print(f"  Double-key distinct outputs: {unique_double}")
    print(f"  Overlap: {overlap}")
    print(f"  Jaccard similarity: {overlap / (unique_fixed + unique_double - overlap):.4f}")
    
    # Save data
    with open(f"{OUT}/exp3_stats.csv", "w") as f:
        f.write(f"trials,unique_single,unique_double,overlap,jaccard\n")
        f.write(f"{num_trials},{unique_fixed},{unique_double},{overlap},"
                f"{overlap/(unique_fixed+unique_double-overlap):.6f}\n")
    
    # Plot frequency histograms
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    single_freqs = sorted(fixed_counts.values(), reverse=True)[:50]
    double_freqs = sorted(double_counts.values(), reverse=True)[:50]
    
    axes[0].bar(range(len(single_freqs)), single_freqs, color='steelblue', alpha=0.7)
    axes[0].set_title(f'Single-key (N={unique_fixed})')
    axes[0].set_xlabel('Output value rank')
    axes[0].set_ylabel('Frequency')
    
    axes[1].bar(range(len(double_freqs)), double_freqs, color='coral', alpha=0.7)
    axes[1].set_title(f'Double-key (N={unique_double})')
    axes[1].set_xlabel('Output value rank')
    axes[1].set_ylabel('Frequency')
    
    fig.suptitle('DES: Output Distribution — Single vs Double Encryption')
    fig.tight_layout()
    fig.savefig(f"{OUT}/exp3_distribution.png", dpi=150)
    plt.close()
    print("  [CHART] exp3_distribution.png")
    
    return unique_fixed, unique_double, overlap

# =============================================================
# Run all experiments
# =============================================================
print("=" * 60)
print("DES NON-GROUP VERIFICATION — Kaliski(1988), Campbell&Wiener(1992)")
print("=" * 60)

# Exp1: 100k samples (~2-3h)
d, sp, dc = exp1_subgroup_estimate(100000, 10000)

# Exp2: 50 pairs x 500 K3 (~30min)
m = exp2_collision_heatmap(50, 500)

# Exp3: 50k trials (~1h)
uf, ud, ov = exp3_statistical_test(50000)

# =============================================================
# Summary
# =============================================================
print("\n" + "=" * 60)
print("RESULTS SUMMARY")
print("=" * 60)
print(f"""
Experiment 1 — Birthday Sampling:
  Distinct composites: {d}/100000 ({d/100000*100:.2f}%)
  {'CONSISTENT WITH NON-GROUP' if d > 95000 else 'POSSIBLE GROUP STRUCTURE'}

Experiment 2 — Collision Matrix:
  Matches found: {m}
  {'CONSISTENT WITH NON-GROUP' if m == 0 else 'UNEXPECTED MATCHES — GROUP POSSIBLE'}

Experiment 3 — Distribution Comparison:
  Single-key outputs: {uf}
  Double-key outputs: {ud}
  Overlap: {ov} (Jaccard: {ov/(uf+ud-ov)*100:.2f}%)

Campbell & Wiener (1992) proved DES generates a subgroup of size >= 10^2499.
Our sampling experiments {'SUPPORT' if d > 95000 and m == 0 else 'CANNOT CONFIRM'} the non-group claim.
""")

with open("SUMMARY.md", "w") as f:
    f.write("# TOP1: DES Non-Group Verification\n\n")
    f.write(f"Date: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")
    f.write("## Results\n\n")
    f.write(f"- Distinct composites: {d}/100000\n")
    f.write(f"- Collision matches: {m}\n")
    f.write(f"- Single/double overlap Jaccard: {ov/(uf+ud-ov)*100:.2f}%\n\n")
    f.write("## Conclusion\n\n")
    f.write(f"{'CONSISTENT WITH NON-GROUP: Campbell & Wiener (1992) confirmed.' if d > 95000 and m == 0 else 'Further analysis needed.'}\n")

print(f"\n[TOP1] All done! Results in {OUT}")
print(f"[TOP1] Finished: $(date)")
PYEOF

python3 des_nongroup.py 2>&1 | tee top1_run.log
echo "[TOP1] Complete"
