
import csv, math
import matplotlib; matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

data = []
with open('bench_data.csv') as f:
    for row in csv.reader(f):
        if len(row) >= 5: data.append(row)

# Group by algo
by_algo = {}
for r in data:
    if r[3] == 'ops_per_s':
        key = f"{r[1]}-{r[2]}"
        try: by_algo[key] = float(r[4])
        except: pass

names = list(by_algo.keys())
vals = list(by_algo.values())
colors = ['#3498db','#2980b9','#2ecc71','#27ae60','#e74c3c','#c0392b','#f39c12']

# Throughput bar chart
fig, ax = plt.subplots(figsize=(12,6))
bars = ax.bar(range(len(names)), vals, color=colors[:len(names)], width=0.6)
ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=45, ha='right')
ax.set_ylabel('Operations / Second')
ax.set_title('ECC: Throughput by Curve')
for br,v in zip(bars,vals):
    ax.text(br.get_x()+br.get_width()/2, br.get_height(), f'{v:.0f}',
            ha='center', va='bottom', fontsize=8)
fig.tight_layout(); fig.savefig('chart_ecc_throughput.png', dpi=150); plt.close()
print('throughput.png')

# Time bar chart
fig, ax = plt.subplots(figsize=(12,6))
times = [1e6/v for v in vals]
bars = ax.bar(range(len(names)), times, color=colors[:len(names)], width=0.6)
ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=45, ha='right')
ax.set_ylabel('Time per Operation (us)')
ax.set_title('ECC: Operation Time by Curve')
for br,v in zip(bars,times):
    ax.text(br.get_x()+br.get_width()/2, br.get_height(), f'{v:.1f}us',
            ha='center', va='bottom', fontsize=8)
fig.tight_layout(); fig.savefig('chart_ecc_time.png', dpi=150); plt.close()
print('time.png')

# Security vs Performance
sec_map = {'ecdh-P-256':128,'secp256k1-kgen':128,'x25519-kgen':128,
           'ecdh-P-384':192,'ecdh-P-521':256}
fig, ax = plt.subplots(figsize=(10,6))
for i, name in enumerate(names):
    sec = sec_map.get(name, 128)
    t = 1e6/vals[i]
    ax.scatter(sec, t, s=150, color=colors[i%len(colors)], zorder=5)
    ax.annotate(name, (sec, t), fontsize=9, ha='center', va='bottom', rotation=30)
ax.set_xlabel('Security Level (bits)'); ax.set_ylabel('Time (us)')
ax.set_title('ECC: Security vs Performance'); ax.grid(True, alpha=0.3)
fig.tight_layout(); fig.savefig('chart_ecc_security_perf.png', dpi=150); plt.close()
print('security_perf.png')

# Write summary
with open('SUMMARY.md', 'w') as f:
    f.write('# TOP2: ECC Multi-Curve Performance

')
    f.write('| Curve | Ops/s | Time/us | Security |
|---|---|---|---|
')
    for name in sorted(names):
        t = f"{1e6/vals[names.index(name)]:.1f}"
        sec = sec_map.get(name, '?')
        f.write(f'| {name} | {vals[names.index(name)]:.0f} | {t} | {sec} |
')
    f.write(f'
{len(names)} curves benchmarked
')

print('summary written')
