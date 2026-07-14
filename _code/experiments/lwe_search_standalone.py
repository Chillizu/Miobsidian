#!/usr/bin/env python3
"""LWE Parameter Space Search (via lattice-estimator)"""
import sys, os, json, time, math
import numpy as np

try:
    import matplotlib; matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    os.system("pip install --break-system-packages matplotlib -q 2>/dev/null")
    import matplotlib; matplotlib.use('Agg')
    import matplotlib.pyplot as plt

from estimator import LWE, nd

OUT = sys.argv[1] if len(sys.argv) > 1 else "."

def estimate_security(n, q, sigma):
    """Estimate LWE security via primal and dual attacks."""
    X = nd.DiscreteGaussian(sigma)
    params = LWE.Parameters(n=n, q=q, Xs=X, Xe=X)
    sec = math.inf
    try:
        cost = LWE.primal_usvp(params)
        if cost and 'rop' in cost:
            sec = min(sec, math.log2(float(cost['rop'])))
    except: pass
    try:
        cost = LWE.dual(params)
        if cost and 'rop' in cost:
            sec = min(sec, math.log2(float(cost['rop'])))
    except: pass
    if math.isinf(sec): sec = 0
    
    eff = math.log2(n * n * math.log2(q)) if n > 0 and q > 1 else 0
    return {'n': n, 'q': q, 'sigma': sigma, 'security': sec, 'efficiency': eff, 'success': sec > 0}

# Parameter grid
params_list = [(n, q, 1.0) for n in range(64, 1025, 64) for q in [256, 1024, 4096, 16384, 65536]]
params_list += [(n, q, 3.0) for n in range(64, 1025, 64) for q in [256, 1024, 4096, 16384, 65536]]
params_list += [(256, 3329, 2.0), (256, 3329, 2.0), (256, 3329, 2.0)]  # Kyber-like
params_list += [(256, 8380417, 2.0), (256, 8380417, 4.0)]  # Dilithium-like
params_list = list(set(params_list))

print(f"Parameter sets: {len(params_list)}")

# Quick test
print("Testing n=256, q=3329, sigma=2...")
t = estimate_security(256, 3329, 2.0)
print(f"  Security: {t['security']:.1f} bits")

# Run all
all_results = []
t0 = time.time()
for i, (n, q, s) in enumerate(params_list):
    result = estimate_security(n, q, s)
    all_results.append(result)
    if (i+1) % 20 == 0:
        elapsed = time.time() - t0
        rate = (i+1) / elapsed
        rem = (len(params_list) - i - 1) / rate
        ok = sum(1 for r in all_results if r['success'])
        print(f"  [{i+1}/{len(params_list)}] {ok} ok, {rate:.1f}/s, ETA {rem/60:.1f}min")

tot = time.time() - t0
print(f"Done in {tot/60:.1f}min")
valid = [r for r in all_results if r['success']]
print(f"Successful: {len(valid)}/{len(all_results)}")

# Save CSV
with open(f"{OUT}/lwe_data.csv", "w") as f:
    f.write("n,q,sigma,security,efficiency\n")
    for r in valid:
        f.write(f"{r['n']},{r['q']},{r['sigma']},{r['security']:.2f},{r['efficiency']:.2f}\n")

with open(f"{OUT}/lwe_results.json", "w") as f:
    json.dump(all_results, f)

# Charts
if valid:
    ns = np.array([r['n'] for r in valid])
    qs = np.array([r['q'] for r in valid])
    secs = np.array([r['security'] for r in valid])
    
    # 1. Pareto
    fig, ax = plt.subplots(figsize=(10, 7))
    sc = ax.scatter([r['efficiency'] for r in valid], secs,
                    c=np.log2(qs.clip(1)), s=20, alpha=0.6, cmap='viridis')
    plt.colorbar(sc, ax=ax, label='log2(q)')
    ax.set_xlabel('Efficiency (lower = faster)'); ax.set_ylabel('Security (bits)')
    ax.set_title('LWE: Security vs Efficiency (Pareto)'); ax.grid(True, alpha=0.3)
    fig.tight_layout(); fig.savefig(f"{OUT}/chart_lwe_pareto.png", dpi=150); plt.close()
    print("[CHART] chart_lwe_pareto.png")
    
    # 2. Histogram
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.hist(secs, bins=30, color='steelblue', edgecolor='white', alpha=0.7)
    for t, c in [(128, 'red'), (192, 'orange'), (256, 'green')]:
        ax.axvline(x=t, linestyle='--', color=c, alpha=0.7, label=f'{t}-bit')
    ax.legend(); ax.set_xlabel('Security (bits)'); ax.set_ylabel('Count')
    ax.set_title('LWE: Security Distribution')
    fig.tight_layout(); fig.savefig(f"{OUT}/chart_lwe_histogram.png", dpi=150); plt.close()
    print("[CHART] chart_lwe_histogram.png")

# Summary
with open(f"{OUT}/SUMMARY.md", "w") as f:
    f.write("# TOP3: LWE Parameter Search\n\n")
    f.write(f"Parameters: {len(params_list)}, OK: {len(valid)}\n")
    if valid:
        f.write(f"Mean security: {secs.mean():.1f} bits, Median: {np.median(secs):.1f}\n")
        f.write(f"Min: {secs.min():.1f}, Max: {secs.max():.1f}\n")

print(f"\nResults in {OUT}")
