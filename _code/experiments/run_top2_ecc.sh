#!/usr/bin/env bash
# ============================================================================
# TOP 2 ⭐⭐⭐⭐ — ECC Multi-Curve Performance Benchmark (v2)
# 使用 openssl speed 原生基准 + 少量 Python
# 预计耗时: 15-20 min
# ============================================================================
set -uo pipefail

BASE="$HOME/Projects/Mioom/essay"
OUTDIR="$BASE/experiments/TOP2_ECC_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[TOP2] ECC Multi-Curve Benchmark (v2) — Started $(date)"
echo "================================================"

python3 -c "import matplotlib" 2>/dev/null || pip install matplotlib -q -q
python3 -c "import numpy" 2>/dev/null || pip install numpy -q -q

# =============================================================
# 1. OpenSSL speed — NIST P-256/P-384/P-521 (ECDH + ECDSA)
# =============================================================
echo "[1] NIST curves via openssl speed..." | tee -a results.txt

for algo in ecdhp256 ecdhp384 ecdhp521 ecdsap256 ecdsap384 ecdsap521; do
    echo "  $algo..." | tee -a results.txt
    openssl speed "$algo" -seconds 10 2>&1 > "speed_${algo}.txt"
done

# Parse results
echo "" >> results.txt
echo "--- Parsed ECDH results ---" >> results.txt
python3 -c "
import re
for curve, label in [('256','P-256'),('384','P-384'),('521','P-521')]:
    with open(f'speed_ecdhp{curve}.txt') as f:
        t = f.read()
    m = re.search(r'(\d+)\s+''?${curve}''?\s+bits\s+ecdh ops', t)
    if m:
        n = int(m.group(1))
        print(f'  ECDH {label}: {n} ops/s')
        with open('bench_data.csv','a') as f:
            f.write(f'ecc,ecdh,{label},ops_per_s,{n}\n')
    else:
        print(f'  ECDH {label}: parse error')
" 2>&1 | tee -a results.txt

# =============================================================
# 2. secp256k1 via OpenSSL genpkey timing (limited trials)
# =============================================================
echo "[2] secp256k1 keygen..." | tee -a results.txt

for trial in 1 2 3; do
    t0=$(date +%s.%N)
    for i in $(seq 1 1000); do
        openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:secp256k1 2>/dev/null > /dev/null
    done
    t1=$(date +%s.%N)
    avg=$(echo "($t1 - $t0) / 1000 * 1000000" | bc -l)
    ops=$(echo "1000 / ($t1 - $t0)" | bc -l)
    echo "  Trial $trial: ${avg}us/op, ${ops} ops/s" | tee -a results.txt
    python3 -c "open('bench_data.csv','a').write(f'ecc,secp256k1,kgen,ops_per_s,{ops}\n')"
done

# =============================================================
# 3. Curve25519 via cryptography library
# =============================================================
echo "[3] Curve25519 keygen (via cryptography)..." | tee -a results.txt
python3 -c "
from cryptography.hazmat.primitives.asymmetric.x25519 import X25519PrivateKey
import time, csv, statistics

trials = 1000
times = []
for _ in range(trials):
    t0 = time.time()
    k = X25519PrivateKey.generate()
    times.append(time.time() - t0)
avg = statistics.mean(times) * 1e6
ops = trials / sum(times)
print(f'  Curve25519: {avg:.1f}us/op, {ops:.0f} ops/s')
with open('bench_data.csv','a') as f:
    f.write(f'ecc,x25519,kgen,ops_per_s,{ops}\n')
    f.write(f'ecc,x25519,kgen,mean_us,{avg}\n')
" 2>&1 | tee -a results.txt

# =============================================================
# 4. BN254 via py_ecc (if available)
# =============================================================
echo "[4] BN254 scalar mult (via py_ecc)..." | tee -a results.txt
python3 -c "
try:
    from py_ecc.bn128 import bn128_curve as bn
    import time, statistics
    G = (bn.BN128FQ(1), bn.BN128FQ(2), bn.BN128FQ(3))
    trials = 500
    times = []
    for i in range(trials):
        t0 = time.time()
        _ = bn.multiply(G, i+1)
        times.append(time.time() - t0)
    avg = statistics.mean(times) * 1e6
    ops = trials / sum(times)
    print(f'  BN254: {avg:.1f}us/op, {ops:.0f} ops/s')
    with open('bench_data.csv','a') as f:
        f.write(f'ecc,bn254,scalar_mult,ops_per_s,{ops}\n')
        f.write(f'ecc,bn254,scalar_mult,mean_us,{avg}\n')
except ImportError:
    print('  py_ecc not installed: pip install py_ecc')
    print('  BN254 skipped')
" 2>&1 | tee -a results.txt

# =============================================================
# 5. Key sizes for comparison
# =============================================================
echo "[5] Key size comparison..." | tee -a results.txt
python3 -c "
print()
print('--- Key Size Comparison ---')
print(f'{\"Curve\":<15} {\"Pub key bytes\":<15} {\"Security bits\":<15}')
curves = [
    ('P-256', 65, 128),
    ('P-384', 97, 192),
    ('P-521', 133, 256),
    ('secp256k1', 65, 128),
    ('X25519', 32, 128),
    ('BN254', 64, 128),
]
for name, sz, sec in curves:
    print(f'{name:<15} {sz:<15} {sec:<15}')
    with open('bench_data.csv','a') as f:
        f.write(f'ecc,{name},pubkey_bytes,,{sz}\n')
        f.write(f'ecc,{name},security_bits,,{sec}\n')
" 2>&1 | tee -a results.txt

# =============================================================
# 6. Generate charts
# =============================================================
echo "[6] Generating charts..." | tee -a results.txt

python3 << 'PYEOF'
import csv, re
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Read data
data = []
with open('bench_data.csv') as f:
    for row in csv.reader(f):
        if len(row) >= 5: data.append((row[0],row[1],row[2],row[3],row[4]))

by_algo = {}
for r in data:
    if r[3] == 'ops_per_s':
        key = f"{r[1]}-{r[2]}"
        try: by_algo[key] = float(r[4])
        except: pass

charts = []

if by_algo:
    # 1. Operations per second bar chart
    fig, ax = plt.subplots(figsize=(12, 6))
    names = list(by_algo.keys())
    vals = list(by_algo.values())
    colors = ['#3498db','#2980b9','#2ecc71','#27ae60','#e74c3c','#c0392b','#f39c12','#9b59b6']
    bars = ax.bar(range(len(names)), vals, color=colors[:len(names)], width=0.6)
    ax.set_xticks(range(len(names)))
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=10)
    ax.set_ylabel('Operations / Second')
    ax.set_title('ECC: Throughput by Curve (higher = better)')
    for bar, v in zip(bars, vals):
        ax.text(bar.get_x()+bar.get_width()/2, bar.get_height(),
                f'{v:.0f}', ha='center', va='bottom', fontsize=9)
    fig.tight_layout()
    fig.savefig('chart_ecc_throughput.png', dpi=150)
    plt.close()
    charts.append('chart_ecc_throughput.png')
    print('  [CHART] chart_ecc_throughput.png')

    # 2. Mean time bar chart
    fig, ax = plt.subplots(figsize=(12, 6))
    means_us = [1e6/v for v in vals]
    ax.bar(range(len(names)), means_us, color=colors[:len(names)], width=0.6)
    ax.set_xticks(range(len(names)))
    ax.set_xticklabels(names, rotation=45, ha='right', fontsize=10)
    ax.set_ylabel('Mean Time (μs)')
    ax.set_title('ECC: Operation Time by Curve (lower = faster)')
    for bar, v in zip(bars, means_us):
        ax.text(bar.get_x()+bar.get_width()/2, bar.get_height(),
                f'{v:.1f}μs', ha='center', va='bottom', fontsize=9)
    fig.tight_layout()
    fig.savefig('chart_ecc_time.png', dpi=150)
    plt.close()
    charts.append('chart_ecc_time.png')
    print('  [CHART] chart_ecc_time.png')

    # 3. Security vs Performance scatter
    sec_map = {'ecdh-P-256':128,'ecdsa-P-256':128,'secp256k1-kgen':128,
               'x25519-kgen':128,'bn254-scalar_mult':128,
               'ecdh-P-384':192,'ecdsa-P-384':192,
               'ecdh-P-521':256,'ecdsa-P-521':256}
    fig, ax = plt.subplots(figsize=(10, 6))
    for name in names:
        if name in sec_map:
            sec = sec_map[name]
            t_us = 1e6 / by_algo[name]
            idx = names.index(name)
            ax.scatter(sec, t_us, s=150, color=colors[idx % len(colors)], zorder=5)
            ax.annotate(name, (sec, t_us), fontsize=9, ha='center', va='bottom', rotation=30)
    ax.set_xlabel('Security Level (bits)')
    ax.set_ylabel('Time (μs)')
    ax.set_title('ECC: Security Level vs Performance')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('chart_ecc_security_perf.png', dpi=150)
    plt.close()
    charts.append('chart_ecc_security_perf.png')
    print('  [CHART] chart_ecc_security_perf.png')

# 4. Key size comparison
fig, ax = plt.subplots(figsize=(8, 5))
key_sizes = [('P-256', 65, 128), ('P-384', 97, 192), ('P-521', 133, 256),
             ('secp256k1', 65, 128), ('X25519', 32, 128), ('BN254', 64, 128)]
names = [k[0] for k in key_sizes]
bytes_sz = [k[1] for k in key_sizes]
sec_bits = [k[2] for k in key_sizes]
x = np.arange(len(names)); w = 0.35
ax.bar(x - w/2, bytes_sz, w, label='Public Key Size (bytes)', color='steelblue')
ax2 = ax.twinx()
ax2.bar(x + w/2, sec_bits, w, label='Security Level (bits)', color='coral')
ax.set_xticks(x); ax.set_xticklabels(names, rotation=45, ha='right')
ax.set_ylabel('Public Key Bytes')
ax2.set_ylabel('Security Bits')
fig.suptitle('ECC: Key Size vs Security Level')
lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1+lines2, labels1+labels2, loc='upper left')
fig.tight_layout()
fig.savefig('chart_ecc_keysize.png', dpi=150)
plt.close()
charts.append('chart_ecc_keysize.png')
print('  [CHART] chart_ecc_keysize.png')

# Summary
with open("SUMMARY.md", "w") as f:
    f.write("# TOP2: ECC Multi-Curve Performance Benchmark\n\n")
    f.write("| Curve | Operations/s | Time/op (μs) | Security (bits) |\n|---|---|---|---|\n")
    for name in names:
        if name in [k[0] for k in key_sizes]:
            sec = dict(key_sizes)[name]
        ops = by_algo.get(name, 0)
        t_us = 1e6/ops if ops > 0 else 0
        sec_val = dict(sec_bits_map if 'sec_bits_map' in dir() else {}).get(name, '?')
        # Actually get from key_sizes
        for kn, kb, ks in key_sizes:
            if kn.lower() in name.lower() or name.lower() in kn.lower():
                sec_val = ks
                break
        f.write(f"| {name} | {ops:.0f} | {t_us:.1f} | {sec_val} |\n")
    f.write(f"\nCharts: {', '.join(charts)}\n")

print(f"\n[DONE] {len(charts)} charts")
PYEOF

# =============================================================
# Summary
# =============================================================
echo "" | tee -a results.txt
echo "========================================" | tee -a results.txt
echo " ALL RESULTS" | tee -a results.txt
echo "========================================" | tee -a results.txt
cat bench_data.csv 2>/dev/null | tee -a results.txt
echo "" | tee -a results.txt
echo "[TOP2] Complete in $OUTDIR" | tee -a results.txt
