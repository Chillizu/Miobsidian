---
title: "Chapter 4 — Time Complexity and Security Complexity"
date: 2026-07-14
tags: [cryptography, group-theory, complexity, paper-draft]
---

# Chapter 4 — Time Complexity and Security Complexity

> Building on the group structures established in Chapter 3, this chapter breaks down each algorithm into its core computational steps, derives time complexity, and analyzes security complexity.

---

## 4.1 Time Complexity Analysis

### 4.1.1 RSA

As described in Chapter 3, RSA operates in the multiplicative group $(\mathbb{Z}/n\mathbb{Z})^\times$. The decryption exponent $d$ is on the order of $n$ ($d \approx 2^{2048}$ for $2048$-bit RSA); computing $m^d$ directly would require $d-1$ multiplications, which is infeasible. The public exponent $e$ in standard implementations is a small fixed value (typically $e = 65537 = 2^{16}+1$), making encryption much faster — the following analysis addresses the worst-case (decryption).

The square-and-multiply algorithm exploits the binary representation of $d$: $d = \sum_{i=0}^{k-1} b_i 2^i$ with $b_i \in \{0,1\}$ and $k = \log_2 d$. Then:

$$
m^d = m^{\sum b_i 2^i} = \prod_{i=0}^{k-1} (m^{2^i})^{b_i}
$$

The value $m^{2^i}$ is obtained by repeated squaring. The algorithm scans from the most significant bit: at each step it squares the accumulator, and if the current bit is $1$, it additionally multiplies by $m$. Scanning $k$ bits requires $k$ squarings and $\frac{k}{2}$ conditional multiplications on average — approximately $\frac{3}{2}k$ modular multiplications. With $k = \log_2 d \approx \log_2 n$, the operation count is $O(\log n)$.

Each modular multiplication multiplies two $\log n$-bit integers and reduces modulo $n$, costing $O((\log n)^2)$. Hence:

$$
T_{\text{RSA}} = O(\log n) \times O((\log n)^2) = O((\log n)^3)
$$

Encryption and decryption both have modular exponentiation as the core operation, with the same asymptotic complexity $O((\log n)^3)$; encryption with small $e$ runs far faster in practice.

### 4.1.2 DH

As described in Chapter 3, DH operates in the prime-order subgroup $\langle g \rangle$ of $(\mathbb{Z}/p\mathbb{Z})^\times$. Each party computes $g^a \bmod p$<sup>[14]</sup> via square-and-multiply with $O(\log p)$ operations. Modular multiplication cost depends on bit length ($O(b^2)$ for $b$-bit operands), not on whether the modulus is prime.

$$
T_{\text{DH}} = O(\log p) \times O((\log p)^2) = O((\log p)^3)
$$

### 4.1.3 ElGamal

ElGamal shares the same group structure as DH (Chapter 3). Encryption requires two modular exponentiations ($g^y$, $h^y$) and one modular multiplication ($m \cdot h^y$); decryption requires one exponentiation ($c_1^{-x}$) and one modular inverse. Total workload is $2$ to $3$ exponentiations.

$$
T_{\text{ElGamal}} = O((\log p)^3)
$$

### 4.1.4 DSA

DSA uses the same group as DH (Chapter 3): $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$ of order $q$, with $p \approx 2048$ bits and $q \approx 256$ bits<sup>[10]</sup>. Signing computes $g^k \bmod p$ (one exponentiation); verification computes $g^{u_1} y^{u_2} \bmod p$ (two exponentiations). The exponents $k, u_1, u_2$ are in $\mathbb{F}_q$ ($256$ bits), so the iteration count is $O(\log q)$; each modular multiplication costs $O((\log p)^2)$. The overall complexity is $O(\log q \cdot (\log p)^2)$, which is $O((\log p)^3)$ in the asymptotic sense since $\log q = O(\log p)$.

$$
T_{\text{DSA}} = O(\log q \cdot (\log p)^2)
$$

### 4.1.5 ECC

As described in Chapter 3, the elliptic curve point group $E(\mathbb{F}_q)$ is a finite Abelian group under the chord-and-tangent addition law. Scalar multiplication $Q = kP$ is the core operation<sup>[16][17]</sup>. $k \approx 2^{256}$; direct iteration is infeasible.

The double-and-add algorithm expands $k$ in binary: $kP = \sum b_i (2^i P)$. Scanning from the most significant bit, it doubles the accumulator at each step and conditionally adds $P$. This requires $\frac{3}{2}\log_2 k$ point operations, $O(\log q)$.

Under affine Weierstrass coordinates<sup>[4]</sup>, a point addition costs $2$ $\mathbb{F}_q$ field multiplications and $1$ field inversion; a doubling costs $3$ field multiplications and $1$ field inversion. $\mathbb{F}_q$ multiplication costs $O((\log q)^2)$; inversion costs $O((\log q)^2)$. Each point operation costs $O((\log q)^2)$.

$$
T_{\text{ECC}} = O(\log q) \times O((\log q)^2) = O((\log q)^3)
$$

ECC's $\log q$ is far smaller than RSA's $\log n$ — $256$-bit ECC provides $128$-bit equivalent security where RSA requires $3072$ bits. At equivalent security levels, ECC runs roughly $5$ to $10$ times faster<sup>[5]</sup>.

### 4.1.6 AES

AES uses the additive and multiplicative groups of $\mathrm{GF}(2^8)$ (Chapter 3), processing $128$-bit blocks through $10$ to $14$ SPN rounds ($10$ for $128$-bit keys, $12$ for $192$-bit, $14$ for $256$-bit)<sup>[13]</sup>. Each round: SubBytes ($\mathrm{GF}(2^8)$ S-box lookup, $16$ lookups), ShiftRows, MixColumns, AddRoundKey (XOR, $16$ operations). All operation counts are fixed by round count, which is fixed by key size. $O(1)$ per block, $O(n)$ overall.

### 4.1.7 DES

DES is a $16$-round Feistel network (the non-group property is discussed in Chapter 3)<sup>[1]</sup>. $F$ comprises expansion permutation, subkey XOR, $8$ S-boxes, and P-permutation — all bit manipulations with fixed counts. $O(1)$ per block, $O(n)$ overall.

### 4.1.8 MD5 / SHA-1 / SHA-256

All three use the Merkle–Damgård construction (Chapter 3), with no group structure<sup>[1][7]</sup>. All have fixed step counts. $O(1)$ per block, $O(n)$ overall.

---

```candidate
## 4.2 Security Complexity Analysis (candidate)

RSA reduces to integer factorization. The best classical attack, GNFS, runs in sub-exponential time $L_n[1/3, (64/9)^{1/3}] \approx \exp(1.923 (\ln n)^{1/3} (\ln \ln n)^{2/3})$<sup>[8]</sup>. RSA-2048 provides approximately $112$-bit equivalent security; NIST requires $3072$-bit for the $128$-bit baseline<sup>[6]</sup>. DH, ElGamal, and DSA reduce to DLP on $(\mathbb{Z}/p\mathbb{Z})^\times$<sup>[14]</sup>, with GNFS-based attack complexity $L_p[1/3, 1.923]$<sup>[9]</sup>.

ECC reduces to ECDLP on $E(\mathbb{F}_q)$<sup>[16][17]</sup>. No sub-exponential attack exists for general curves; Pollard's $\rho$ runs in $O(\sqrt{q})$ — exponential time<sup>[12]</sup>. A $256$-bit curve provides $128$-bit security. Supersingular curves are vulnerable to the MOV attack<sup>[23]</sup>; anomalous curves are solvable in polynomial time<sup>[3]</sup>. Standard curves avoid both.

AES derives security from SPN confusion and diffusion<sup>[20]</sup>, brute-force $O(2^k)$. Biclique reduces this to $2^{126.1}$<sup>[11]</sup>. DES's $56$-bit key was brute-forced by EFF Deep Crack<sup>[22]</sup>. MD5 collision: $2^{39}$<sup>[21]</sup>; SHA-1: $2^{63}$; SHA-256: $2^{128}$ (secure)<sup>[1][7]</sup>.
```

---

## 4.3 Chapter Summary

1. RSA, DH, ElGamal, DSA, and ECC all have core operation complexity $O(\log^3\cdot)$. ECC's $\log q$ is far smaller than RSA/DH's $\log n$, yielding $5$ to $10\times$ speed at equivalent security. ElGamal requires $2$ to $3$ times more exponentiations.

2. AES, DES, and MD5/SHA-1/SHA-256 have constant per-block time, $O(n)$ overall. DES, MD5, and SHA-1 have been practically broken.

```candidate
3. RSA/DH/DSA face sub-exponential GNFS attacks; ECC enjoys exponential-grade security.
4. In public-key crypto, group hard problems are the direct source of security. In symmetric ciphers and hashing, group structures only serve the computation layer.
```

---

## References

[1] Menezes et al. *Handbook of Applied Cryptography*. CRC Press, 1996.
[2] Stinson. *Cryptography: Theory and Practice* (4th ed.). CRC Press, 2018.
[3] Koblitz. *Number Theory and Cryptography*. Springer, 1994.
[4] Hankerson et al. *Guide to ECC*. Springer, 2004.
[5] NIST SP 800-57. *Key Management*. 2020.
[6] NIST SP 800-131A. *Algorithm Transition*. 2019.
[7] NIST FIPS 180-4. *Secure Hash Standard*. 2015.
[8] Buhler et al. "GNFS." LNM 1554, 1993.
[9] Gordon. "DLP with NFS." *SIAM J. Discrete Math.* 6:124, 1993.
[10] NIST FIPS 186-5. *DSS*. 2023.
[11] Bogdanov et al. "Biclique AES." *ASIACRYPT 2011*, LNCS 7073.
[12] Pollard. "Monte Carlo for index comp." *Math. Comp.* 32:918, 1978.
[13] Daemen & Rijmen. *Design of Rijndael*. Springer, 2002.
[14] Diffie & Hellman. "New directions." *IEEE TIT* 22:644, 1976.
[15] Rivest et al. "RSA." *CACM* 21:120, 1978.
[16] Miller. "Elliptic curves in crypto." *CRYPTO'85*, LNCS 218, 1986.
[17] Koblitz. "Elliptic curve cryptosystems." *Math. Comp.* 48:203, 1987.
[18] Campbell & Wiener. "DES is not a Group." *CRYPTO'92*, LNCS 740.
[19] Kaliski et al. "Is DES a group?" *J. Cryptology* 1:3, 1988.
[20] Shannon. "Secrecy systems." *BSTJ* 28:656, 1949.
[21] Wang & Yu. "Break MD5." *EUROCRYPT 2005*, LNCS 3494.
[22] EFF. *Cracking DES*. O'Reilly, 1998.
[23] Menezes et al. "MOV attack." *IEEE TIT* 39:1639, 1993.
