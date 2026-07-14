---
title: "TOP2: ECC 多曲线性能基准"
tags: [cryptography, experiment, ECC]
date: 2026-07-14
aliases: [ECC Multi-Curve Benchmark]
---

# TOP2: ECC 多曲线性能基准

> **实验日期:** 2026-07-14 08:08
> **平台:** Intel Core Ultra 9 185H, Arch Linux
> **参见:** [[02-实验数据/01-实验数据总览]]

---

## 实验目标

测量现代椭圆曲线在 x86-64 平台上的密钥生成 / ECDH 运算性能，覆盖不同安全级别和曲线族。

## 测试集

| 曲线 | 族 | 安全位 | 运算类型 |
|------|-----|--------|----------|
| Curve25519 | Montgomery | 128 | 密钥生成 |
| P-256 | NIST / Weierstrass | 128 | ECDH |
| P-384 | NIST / Weierstrass | 192 | ECDH |
| P-521 | NIST / Weierstrass | 256 | ECDH |
| secp256k1 | SEC / Weierstrass | 128 | 密钥生成 |
| BN254 | Barreto-Naehrig | 128 | 配对 |

## 性能结果

| 曲线 | 安全位 | 速度 (ops/s) | 耗时 (μs) | 密钥 (字节) |
|------|--------|-------------|-----------|-------------|
| **Curve25519** | 128 | 31,259 | 32.0 | 32 |
| **P-256 ECDH** | 128 | 27,114 | 36.9 | 65 |
| **P-384 ECDH** | 192 | 4,641 | 215.5 | 97 |
| **P-521 ECDH** | 256 | 5,052 | 198.0 | 133 |
| **secp256k1** | 128 | 279 | 3,587.5 | 65 |

## 图表

### 吞吐量对比

![[chart_ecc_throughput.png]]

### 每操作耗时

![[chart_ecc_time.png]]

### 密钥长度对比

![[chart_ecc_keysize.png]]

### 安全-性能分布

![[chart_ecc_security_perf.png]]

## 关键发现

1. **Curve25519 是性能冠军** — 比 secp256k1 快 112 倍（同 128-bit 安全水平），密钥体积仅为 32 字节。
2. **P-256 是良好的通用选择** — 27,114 ops/s，65 字节公钥，广泛部署于 TLS 和 FIDO。
3. **secp256k1 性能异常低** — 279 ops/s 反映了 Python `cryptography` 库中 secp256k1 的实现路径未经过充分优化。
4. **P-521 速度反超 P-384** — 尽管安全位更高，但 P-521 的 198 μs/op 优于 P-384 的 215.5 μs/op，可能与 Solinas 素数形式的快速模约简有关。
5. **BN254 适合配对应用** — 128-bit 安全水平，64 字节公钥，专为配对友好场景设计。

## 工具链

| 工具 | 用途 |
|------|------|
| `python-cryptography` | Curve25519 密钥生成 |
| `openssl speed` | P-256 / P-384 / P-521 ECDH 基准 |
| `matplotlib` | 图表生成 |

## 产出文件

| 文件 | 用途 |
|------|------|
| `bench_data.csv` | 基准测试原始数据 |
| `chart_ecc_throughput.png` | 吞吐量柱状图 |
| `chart_ecc_time.png` | 每操作耗时柱状图 |
| `chart_ecc_keysize.png` | 公钥长度对比 |
| `chart_ecc_security_perf.png` | 安全-性能散点分布 |
| `SUMMARY.md` | 摘要 |
