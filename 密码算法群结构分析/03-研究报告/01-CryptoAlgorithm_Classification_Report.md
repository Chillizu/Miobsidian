---
title: Cryptographic Algorithm Group Structure Classification Report
tags: [cryptography, group-theory, report]
date: 2026-07-13
aliases: [Crypto Algorithm Classification Report]
---

# Cryptographic Algorithm Group Structure Classification Report

> Classified by group structure proof status — covering subgroup types, time complexity, security complexity, and multi-dimensional comparative analysis.

---

## 1. Classification Overview

Based on the algebraic structures underlying each algorithm and the mathematical conclusion of whether they "form a group," the **10 cryptographic algorithms** discussed herein are classified into three categories:

| Category | Count | Core Characteristic |
|:---|:---:|:---|
| **Proven Group** | 6 | RSA, DH, ElGamal, DSA, ECC, AES — operations are directly defined on a known group structure; security is reducible to a hard problem on that group |
| **Proven Not a Group** | 2 | DES, 3DES — the full set of key permutations is **not closed** under composition; rigorously proven not to form a group |
| **No Direct Group Structure** | 2 | MD5, SHA-256 — built on iterative compression functions; do not rely on any group-based hard problem assumption |

---

## 2. Proven Group (6 Algorithms)

The algorithms in this category have operations directly defined on an explicit group. Group-theoretic language is the natural framework for expressing their security reductions.

### 2.1 RSA — Multiplicative Group $(\mathbb{Z}/n\mathbb{Z})^\times$

- **Subgroup Type**: The multiplicative group $G = (\mathbb{Z}/n\mathbb{Z})^\times$ where $n = p \cdot q$ is the product of two large primes. This is a finite Abelian group of order $\varphi(n) = (p-1)(q-1)$. RSA encryption/decryption is essentially exponentiation in $G$: encryption is $c = m^e \pmod{n}$, and decryption relies on Euler's theorem with $ed \equiv 1 \pmod{\lambda(n)}$ guaranteeing $m^{ed} \equiv m \pmod{n}$.

- **Time Complexity**: $O(\log^3 n)$. Dominated by modular exponentiation via repeated squaring. Typical $n = 2048$ bits, requiring approximately 2048 modular multiplications per encryption/decryption operation.

- **Security Complexity**: Integer factorization (sub-exponential time). The best classical algorithm is the **General Number Field Sieve (GNFS)**: $L_n[1/3, (64/9)^{1/3}] \approx \exp\left((1.923+o(1))(\ln n)^{1/3}(\ln\ln n)^{2/3}\right)$. Shor's quantum algorithm solves factorization in polynomial time, so RSA is not post-quantum secure.

- **Key Insight**: If $\varphi(n)$ were known (equivalent to knowing $p$ and $q$), inversion in $G$ would be trivial — the unknown group order IS the security foundation.

![[RSA_GroupStructure_2026-07-13.png]]

- **References**: Menezes, A. J., van Oorschot, P. C., Vanstone, S. A. *Handbook of Applied Cryptography (HAC)*, CRC Press, 1996, Ch.8; Rosulek, M. *The Joy of Cryptography*, Ch.15; Cook, D. (2023).

### 2.2 Diffie–Hellman (DH) — Prime-Order Subgroups of $(\mathbb{Z}/p\mathbb{Z})^\times$

- **Subgroup Type**: Choose a large prime $p$; work in a subgroup $\langle g \rangle$ of order $q$ (where $q \mid (p-1)$, and $q$ itself is a large prime) within $G = (\mathbb{Z}/p\mathbb{Z})^\times$. Practical protocols (e.g., FFDHE in TLS) require that the order of $g$ is exactly the prime $q$ to prevent Pohlig–Hellman degradation attacks. Each party computes $g^a \bmod p$ and $g^b \bmod p$, sharing the secret key $g^{ab} \bmod p$.

- **Time Complexity**: $O(\log^3 p)$ modular exponentiation per party. Computational cost is comparable to RSA.

- **Security Complexity**: Based on the **Discrete Logarithm Problem (DLP)** on $(\mathbb{Z}/p\mathbb{Z})^\times$. The best classical attack is **Index Calculus** at sub-exponential complexity $L_p[1/3, c]$. Security relies on the **Computational Diffie–Hellman (CDH)** and **Decisional Diffie–Hellman (DDH)** assumptions. Shor's algorithm also solves this in polynomial time.

![[DH_KeyExchange_GroupFlow_2026-07-13.png]]

- **References**: Menezes et al., *HAC*, Ch.3; NIST FIPS 186-4/186-5; RFC 7919.

### 2.3 ElGamal — Prime-Order Subgroups of $(\mathbb{Z}/p\mathbb{Z})^\times$

- **Subgroup Type**: Same as DH: operating on the prime-order subgroup $\langle g \rangle$ of $(\mathbb{Z}/p\mathbb{Z})^\times$. ElGamal extends the DH key exchange to a public-key encryption scheme: the ciphertext is $(g^k,\; m \cdot h^k)$, where $h = g^x$ is the public key and $k$ is a random value.

- **Time Complexity**: $O(\log^3 p)$. Encryption requires two modular exponentiations; decryption requires one exponentiation plus one modular inverse — slightly heavier than DH.

- **Security Complexity**: Security is based on the **CDH assumption** (semantic security additionally requires DDH to hold). ElGamal is provably **IND-CPA secure** in the Random Oracle Model. Attack complexity is the same as DH (sub-exponential, via Index Calculus).

- **References**: Stinson, D. R. *Cryptography: Theory and Practice*, CRC Press; Menezes et al., *HAC*, Ch.3.

### 2.4 DSA — Prime-Order Subgroups of $(\mathbb{Z}/p\mathbb{Z})^\times$

- **Subgroup Type**: The group setting is the same as DH, selecting a subgroup $\langle g \rangle$ of order $q$ within $(\mathbb{Z}/p\mathbb{Z})^\times$ (with $p \approx 2048$ bits, $q \approx 256$ bits). DSA's innovation lies in the signing equation: $r = (g^k \;\mathrm{mod}\; p) \;\mathrm{mod}\; q$, $s = k^{-1}(H(m) + xr) \;\mathrm{mod}\; q$, which combines the message hash with group operations in a specific way.

- **Time Complexity**: $O(\log^3 p)$. One modular exponentiation is needed for signing ($g^k \;\mathrm{mod}\; p$), and two for verification. Final operations are reduced modulo $q$ (256-bit).

- **Security Complexity**: Security reduces to the **DLP** on $(\mathbb{Z}/p\mathbb{Z})^\times$. NIST SP 800-131A Rev.2 specifies minimum security thresholds for DSA parameters. **CRITICAL**: The random nonce $k$ MUST be different for each signature — reuse of $k$ allows recovery of the private key from two signatures (the Sony PS3 incident of 2010 is a textbook example of this failure).

- **References**: NIST FIPS 186-4/186-5; Menezes et al., *HAC*; Stinson, D. R.

### 2.5 ECC (ECDH/ECDSA) — Elliptic Curve Point Group $E(\mathbb{F}_q)$

- **Subgroup Type**: The rational point set $E(\mathbb{F}_q)$ of an elliptic curve over a finite field $\mathbb{F}_q$, which forms a finite **Abelian group** under the **chord-and-tangent addition law**. The Elliptic Curve Discrete Logarithm Problem (ECDLP): given $P$ and $Q = kP$, find $k$. Unlike the DLP in $(\mathbb{Z}/p\mathbb{Z})^\times$, no sub-exponential algorithm is known for ECDLP.

- **Time Complexity**: $O(\log^2 q)$ scalar multiplication (double-and-add chains). The key advantage of ECC: **a 256-bit ECC key provides equivalent security to a 3072-bit RSA key** — dramatically shorter keys for the same security level.

- **Security Complexity**: The best classical attack on ECDLP is **Pollard-$\rho$**: $O(\sqrt{q})$ — **exponential time**. A 256-bit curve provides approximately 128-bit symmetric security strength. Note that special curves (supersingular curves) are vulnerable to the **Mov attack** (which reduces ECDLP to finite field DLP), so standard curves all avoid supersingular cases.

- **Quantum**: Shor's algorithm also solves ECDLP in polynomial time — ECC is **NOT** post-quantum secure.

![[EllipticCurve_PointAddition_2026-07-13.png]]

- **References**: Hankerson, D., Menezes, A., Vanstone, S. *Guide to Elliptic Curve Cryptography*, Springer, 2004; Blake, I. F., Seroussi, G., Smart, N. P. *Elliptic Curves in Cryptography*, Cambridge University Press, 1999; NASA NAS-03-012.

### 2.6 AES — Finite Field $\mathrm{GF}(2^8)$ Groups

- **Subgroup Type**: AES operates at the byte level over the finite field $F = \mathrm{GF}(2^8)$ with irreducible polynomial $x^8 + x^4 + x^3 + x + 1$:
  - $(F, +)$: **Additive group** — bitwise XOR, essentially an 8-dimensional vector space (an elementary Abelian 2-group of order $2^8 = 256$). Used in AddRoundKey and ShiftRows.
  - $(F^\times, \cdot)$: **Multiplicative group** — a cyclic group of order 255 with generator 0x03. Used in MixColumns (matrix multiplication over $\mathrm{GF}(2^8)$).
  - The entire 128-bit state is viewed as linear/affine transformations over $(\mathrm{GF}(2^8))^4$.

- **Time Complexity**: $O(n)$ where $n = 128$ bits (fixed block size). Each round consists of SubBytes (S-box lookup), ShiftRows, MixColumns, and AddRoundKey. Hardware AES-NI achieves $< 1$ cycle/byte.

- **Security Complexity**: AES security **does NOT rely on any group hard problem**. Security derives from the **Confusion and Diffusion** principles of the SPN (Substitution-Permutation Network) structure. The best attacks (impossible differential, integral) are far weaker than brute force for full AES-256. Grover's quantum search reduces the security level from 256 to 128 bits.

![[AES_GF28_Structure_2026-07-13.png]]

- **References**: Menezes et al., *HAC* (symmetric cryptography sections); UAF CS 463 lecture notes.

---

## 3. Proven Not a Group (2 Algorithms)

### 3.1 DES — Key Permutation Set Not Closed

- **Subgroup Type**: Each key $k$ defines a permutation $\pi_k: \{0,1\}^{64} \to \{0,1\}^{64}$. The fundamental question: do all $2^{56}$ key permutations form a group under composition $\circ$?
  - **Kaliski, Rivest, Sherman (1988)**: Cycling experiments provided strong statistical evidence that DES is not a group.
  - **Campbell & Wiener (CRYPTO'92)**: **Rigorous mathematical proof** that the full DES permutation set is **not closed** under composition, with the generated subgroup estimated at size $> 10^{2499}$.

- **Time Complexity**: $O(n)$, 16-round Feistel network, 64-bit blocks. Hardware implementation speed was excellent, but the 56-bit key is trivially brute-forceable.

- **Security Complexity**: **INSECURE**. The 56-bit key space was cracked by EFF's Deep Crack in 56 hours (1998). The massive generated subgroup size ($> 10^{2499}$) rules out "small subgroup" attacks, but also proves that multiple encryption is **NOT equivalent** to single encryption (if DES were a group, multiple encryption could be reduced to a single encryption).

![[DES_NotAGroup_Proof_2026-07-13.png]]

- **References**: Kaliski, B. S. Jr., Rivest, R. L., Sherman, A. T. "Is the Data Encryption Standard a group?", *J. Cryptology* 1(1):3–36, 1988; Campbell, K. W., Wiener, M. J. "DES is not a Group", *CRYPTO'92* (LNCS 740), 1993.

### 3.2 3DES — Composite Permutations (Not a Group)

- **Subgroup Type**: Triple DES (TDEA) applies DES in Encrypt-Decrypt-Encrypt (EDE) mode with three independent keys $k_1, k_2, k_3$. Since DES itself has been proven not to be a group, 3DES's permutation set is also not a group. In essence, this is a 48-round Feistel network ($3 \times 16$).

- **Time Complexity**: $O(n)$, equivalent to 48 rounds of Feistel ($3 \times 16$), approximately $3\times$ the overhead of single DES.

- **Security Complexity**: Effective key space of $2^{112}$ (three-key variant) or $2^{80}$ (two-key variant). The primary threat is the **Meet-in-the-Middle attack**: by precomputing intermediate state tables, the search space is reduced from $2^{168}$ to $O(2^{112})$. NIST SP 800-131A requires phasing out 3DES in favor of AES.

---

## 4. No Direct Group Structure (2 Algorithms)

### 4.1 MD5 — Iterative Compression, No Group Structure

- **Subgroup Type**: MD5 uses an **iterative compression function** + **Merkle–Damgård construction** to produce a 128-bit hash. Its internal operations (4 rounds × 16 steps of modular addition + bitwise operations + S-box lookup) do **NOT** rely on any group hard problem.

- **Time Complexity**: $O(n)$, processing 512-bit blocks sequentially with approximately 64 operations per block. Software implementation is extremely fast.

- **Security Complexity**: **INSECURE**. Wang et al. (2004) demonstrated efficient collision attacks; collisions can now be constructed in approximately 1 minute on a consumer PC. NIST prohibits MD5 for digital signatures. Still usable for non-security purposes (e.g., checksums, cache keys).

- **References**: Menezes et al., *HAC*, Ch.9; Wang, X., Yu, H. "How to Break MD5 and Other Hash Functions", *EUROCRYPT'05*, 2005.

### 4.2 SHA-256 — Iterative Compression, No Group Structure

- **Subgroup Type**: Same Merkle–Damgård construction as MD5, but with a more complex compression function (64 rounds, message expansion, modular addition + bitwise operations). SHA-256 outputs a 256-bit hash value and is part of the SHA-2 family.

- **Time Complexity**: $O(n)$, 512-bit block processing with 64 rounds per block. Hardware-accelerated via Intel SHA Extensions.

- **Security Complexity**: Currently considered **SECURE**. The best attack is brute force (preimage/2nd-preimage: $2^{256}$, collision: $2^{128}$). Grover's quantum search reduces preimage/2nd-preimage complexity to $2^{128}$ and collision to $2^{85}$ (classical collision is already $2^{128}$), which is still considered secure for the foreseeable future. SHA-3/Keccak (FIPS 202) is available as a backup standard.

- **References**: NIST FIPS 180-4 (SHA-2); NIST FIPS 202 (SHA-3/Keccak).

---

## 5. Multi-Dimensional Comparative Analysis

### 5.1 Equivalent Security Strength Comparison

The chart below uses **symmetric security strength (bits)** as a unified metric, showing the security level of each algorithm under typical parameters. The 128-bit level is the current NIST-recommended minimum security baseline.

![[BarChart_SecurityBits_2026-07-13.png]]

**Key observations**:
- AES-256 leads with 256-bit security strength, the gold standard for symmetric encryption.
- ECC-256 achieves 128-bit symmetric security with only a 256-bit key — extremely efficient.
- RSA-2048 and DH-2048 provide only 112-bit equivalent security (below the 128-bit baseline); upgrading to 3072-bit is required to reach 128 bits.
- DES's 56-bit key is trivially breakable under modern computing power ($< 24$ hours exhaustive search).
- MD5 collisions have been practically constructed; effective security strength is 0.

### 5.2 Computational Cost Comparison

![[GroupedBar_ComputationalCost_2026-07-13.png]]

**Key observations**:
- AES has the lowest encryption/decryption cost (thanks to hardware AES-NI instructions and $O(n)$ linear complexity).
- Hash functions (MD5/SHA-256) are similarly fast because they are pure iterative structures with no modular exponentiation.
- RSA/DH/ElGamal/DSA modular exponentiation is the primary bottleneck; cost increases with key length.
- ECC scalar multiplication ($O(\log^2 q)$) is significantly faster than RSA/DH modular exponentiation ($O(\log^3 n)$) — a key reason for ECC's widespread practical adoption.
- For key generation, RSA/DH/ElGamal/DSA require large prime generation (the most time-consuming step), while AES/DES keys can be randomly selected.

### 5.3 Multi-Dimensional Radar Chart

![[Radar_MultiDimension_2026-07-13.png]]

**Scoring dimensions** (1–10 scale, higher is better unless noted):
- **Security Strength**: Resistance to known attacks at current parameter sizes
- **Computational Efficiency**: Speed of a single operation
- **Key Length (shorter = better)**: Key size required to achieve equivalent security
- **Quantum Resistance**: Resistance to Shor/Grover quantum algorithms
- **Implementation Complexity (lower = better)**: Engineering difficulty of implementation
- **Standardization Level**: NIST/IETF/RFC standardization and ecosystem support

**Key observations**:
- AES-256 scores highest in both security strength and computational efficiency — the overall best symmetric encryption algorithm.
- ECC-256 significantly outperforms RSA in key length and efficiency, but scores only 1 on quantum resistance (Shor's algorithm threat).
- SHA-256 is the only algorithm scoring reasonably on quantum resistance (5 points — Grover only halves the security).
- DES scores near-zero on security strength and is no longer recommended.

### 5.4 Algorithm Property Matrix Heatmap

![[Heatmap_PropertyMatrix_2026-07-13.png]]

**Property descriptions**:
- **Based on Group Hard Problem**: Whether security is reducible to a computational hard problem on a group
- **Symmetric/Asymmetric**: 0 = asymmetric, 0.5 = hybrid (hash), 1 = symmetric
- **Quantum Resistant (Shor)**: Whether the algorithm can resist Shor's polynomial-time quantum algorithm
- **Quantum Resistant (Grover)**: Whether the algorithm can resist Grover's quadratic-speedup quantum search
- **NIST Standardized**: Whether the algorithm is an official NIST standard
- **Still in Secure Use**: Whether currently recommended by the security community
- **Group Structure Proven**: Whether mathematically proven to be based on a group or proven not to be a group

**Key observations**:
- All algorithms based on group hard problems (RSA, DH, ElGamal, DSA, ECC) are vulnerable to Shor's algorithm — this is the **core motivation for post-quantum cryptography (PQC)**.
- AES and SHA-256 score near maximum on "Still in Secure Use" — the most widely deployed algorithms in current practice.
- Hash functions (MD5, SHA-256) occupy a middle position on "Symmetric/Asymmetric" because they are neither symmetric encryption nor public-key encryption, but cryptographic primitives.

### 5.5 Key Size vs Security Strength Curves

![[LineChart_KeySize_vs_Security_2026-07-13.png]]

**Key observations**:
- ECC's curve slope is dramatically better than RSA/DH — a 256-bit ECC key provides the same security as a 15,360-bit RSA key (approximately a $60\times$ key length difference).
- AES has a 1:1 linear relationship between key length and security strength (128-bit key = 128-bit security).
- This comparison directly explains why ECC has largely replaced RSA in resource-constrained environments (IoT, embedded systems, blockchain signatures).

---

## 6. Summary and Recommendations

| Use Case | Recommended Algorithm | Rationale |
|:---|:---|:---|
| Asymmetric encryption | ECC (ECDH/ECDSA) | Short keys, high efficiency, widely standardized |
| Symmetric encryption | AES-256 | Highest security strength, hardware acceleration mature |
| Digital signatures | ECDSA / EdDSA | Short signatures, fast verification |
| Hash / integrity | SHA-256 / SHA-3 | Collision-secure, Grover-resistant (halving only) |
| Long-term archival | AES-256 + SHA-3 + PQC | Multi-layer defense for the quantum era |

**Core Conclusion**: Group theory provides a unified mathematical framework for understanding classical public-key cryptography (RSA, DH, ECC) — RSA security reduces to integer factorization on $(\mathbb{Z}/n\mathbb{Z})^\times$, DH/ElGamal/DSA reduce to DLP on $(\mathbb{Z}/p\mathbb{Z})^\times$, and ECC reduces to ECDLP on $E(\mathbb{F}_q)$ — but these algorithms are universally vulnerable to Shor's quantum algorithm, since Shor can solve discrete logarithm and factorization problems on all these groups in polynomial time. Post-quantum group-based cryptography (e.g., schemes based on braid groups, Thompson groups) remains in the research phase (Kahrobaei et al., AMS Math. Surveys & Monographs 278, 2024) and has not yet reached standardization level. Current best practice: adopt **hybrid schemes** (classical + post-quantum) while monitoring the NIST PQC standardization process (CRYSTALS-Kyber, CRYSTALS-Dilithium, etc.).

---

## References

1. Blackburn, S. R., Cid, C., Mullan, C. "Group theory in cryptography", *Groups St Andrews 2009 in Bath*, Cambridge University Press, 2011.
2. Myasnikov, A., Ushakov, A., Shpilrain, V. *Group-based Cryptography*, Birkhäuser/Springer, 2008.
3. Kahrobaei, D., Flores, R., Noce, M., et al. *Applications of Group Theory in Cryptography: Post-quantum Group-based Cryptography*, AMS Math. Surveys & Monographs 278, 2024.
4. Menezes, A. J., van Oorschot, P. C., Vanstone, S. A. *Handbook of Applied Cryptography (HAC)*, CRC Press, 1996.
5. Koblitz, N. *A Course in Number Theory and Cryptography* (GTM 114), Springer, 2nd ed., 1994.
6. Stinson, D. R. *Cryptography: Theory and Practice*, CRC Press.
7. Hankerson, D., Menezes, A., Vanstone, S. *Guide to Elliptic Curve Cryptography*, Springer, 2004.
8. Kaliski, B. S. Jr., Rivest, R. L., Sherman, A. T. "Is the Data Encryption Standard a group?", *J. Cryptology* 1(1):3–36, 1988.
9. Campbell, K. W., Wiener, M. J. "DES is not a Group", *CRYPTO'92* (LNCS 740), Springer, 1993.
10. NIST FIPS 186-4/186-5, *Digital Signature Standard*, National Institute of Standards and Technology.
11. NIST SP 800-131A Rev. 2, *Transitioning the Use of Cryptographic Algorithms and Key Lengths*, National Institute of Standards and Technology.