---
title: "Chapter 3 — Time Complexity and Security Complexity"
date: 2026-07-14
tags: [cryptography, group-theory, complexity, paper-draft]
---

# Chapter 3 — Time Complexity and Security Complexity

> Building on the group structures established in Chapter 2, this chapter decomposes each algorithm into its core computational steps, estimates per-step cost, derives total time complexity, and analyzes the complexity of the best known attacks along with equivalent security strength.

---

## 3.1 Time Complexity

### 3.1.1 RSA

As described in Chapter 2, RSA performs modular exponentiation $m^d \bmod n$ in $(\mathbb{Z}/n\mathbb{Z})^\times$<sup>[15]</sup>. The decryption exponent $d$ is on the order of $n$ ($d \approx 2^{2048}$ for $2048$-bit RSA); computing $m^d$ directly would require $d-1$ modular multiplications — infeasible. The square-and-multiply algorithm expands the exponent in binary to reduce the iteration count.

**Algorithm** (Square-and-Multiply, MSB-first). Input: $m, d = (b_{k-1}\ldots b_1 b_0)_2$. Output: $m^d \bmod n$.

```
R ← 1
for i = k−1 downto 0:
    R ← R^2 mod n
    if b_i = 1: R ← R·m mod n
return R
```

Trace for $d = 13 = 1101_2$ ($k=4$): $b_3=1$→$R=m$; $b_2=1$→square to $R=m^2$, multiply by $m$ → $R=m^3$; $b_1=0$→square to $R=m^6$; $b_0=1$→square to $R=m^{12}$, multiply by $m$ → $R=m^{13}$. Total: $3$ squarings and $3$ conditional multiplications, i.e., $\frac{3}{2} \times 4 = 6$ modular multiplications.

General analysis: $k = \lfloor\log_2 d\rfloor + 1$ bits. The MSB $b_{k-1}=1$ performs $0$ squarings (initialization only) then multiplies by $m$. The remaining $k-1$ bits each perform $1$ squaring, with an additional multiplication when the bit is $1$. The expected number of $1$ bits is $\frac{k-1}{2}$, giving $k-1$ squarings and $\frac{k-1}{2}+1$ conditional multiplications. Total: $\approx \frac{3}{2}(k-1) + 1 = O(k)$ mod-muls. With $k = O(\log n)$, iterations are $O(\log n)$.

A single modular multiplication: multiply two $\log n$-bit integers → $2\log n$-bit product → reduce modulo $n$. Schoolbook multiplication costs $O((\log n)^2)$; modular reduction costs the same order. Hence total:

$$
T_{\text{RSA}} = O(\log n) \times O((\log n)^2) = O((\log n)^3)
$$

Encryption uses $e = 65537 = 2^{16} + 1$ ($17$ bits). Square-and-multiply requires only $16$ squarings and $1$ conditional multiplication, $O((\log n)^2)$ — same asymptotic order as decryption but hundreds of times faster in practice.

### 3.1.2 DH

As described in Chapter 2, DH runs in $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$, with each party computing one modular exponentiation $g^a \bmod p$<sup>[14]</sup>. The exponent $a$ is on the order of $p$, square-and-multiply iterates $O(\log p)$ times, and modular multiplication costs $O((\log p)^2)$. The derivation mirrors RSA:

$$
T_{\text{DH}} = O(\log p) \times O((\log p)^2) = O((\log p)^3)
$$

Both parties perform one exponentiation each; total computation is $2 \times O((\log p)^3) = O((\log p)^3)$.

### 3.1.3 ElGamal

ElGamal shares DH's group structure (Chapter 2)<sup>[2]</sup>. Encryption computes $g^y \bmod p$ and $h^y \bmod p$ (two exponentiations) plus one modular multiplication $m \cdot h^y$ ($O((\log p)^2)$, negligible). Decryption computes $c_1^{-x} = (g^y)^{-x} = g^{-xy} \bmod p$ (one exponentiation). Total workload is $2$–$3$ exponentiations:

$$
T_{\text{ElGamal}} = O((\log p)^3)
$$

Encryption is roughly twice as expensive as DH or RSA, but the asymptotic order is unchanged.

### 3.1.4 DSA

As described in Chapter 2, DSA operates in the order-$q$ subgroup of $(\mathbb{Z}/p\mathbb{Z})^\times$, with $p \approx 2048$ bits and $q \approx 256$ bits<sup>[10]</sup>. Signing requires one exponentiation $g^k \bmod p$; verification requires two ($g^{u_1} y^{u_2} \bmod p$).

We distinguish the exponent bit length from the modulus bit length. The exponents $k, u_1, u_2$ live in $\mathbb{F}_q$ ($256$ bits), so square-and-multiply iterates $O(\log q)$ times. Each modular multiplication operates on $\log p$-bit integers, costing $O((\log p)^2)$. Hence:

$$
T_{\text{DSA}} = O(\log q) \times O((\log p)^2) = O(\log q \cdot (\log p)^2)
$$

Since $\log q = O(\log p)$, the overall order is $O((\log p)^3)$. Compared to RSA/DH, the exponent bit length is only $\frac{1}{8}$ of the modulus bit length, substantially reducing the actual iteration count.

### 3.1.5 ECC

As described in Chapter 2, ECC's core operation is scalar multiplication $Q = kP$ on $E(\mathbb{F}_q)$<sup>[16][17]</sup>, with $k \approx 2^{256}$. The double-and-add algorithm (the point-group analog of square-and-multiply) expands $k$ in binary, scanning from MSB to LSB, doubling the accumulator at each step and conditionally adding $P$. This requires $\frac{3}{2}\log_2 k$ point operations, $O(\log q)$.

Under affine Weierstrass coordinates (cf. Chapter 2, §2.1.5)<sup>[4]</sup>: point addition costs $1$ field inversion $+$ $2$ field multiplications; point doubling costs $1$ field inversion $+$ $3$ field multiplications. Field multiplication and inversion in $\mathbb{F}_q$ each cost $O((\log q)^2)$ (inversion via extended Euclidean algorithm is on par with multiplication).

Practical implementations use projective coordinates to eliminate expensive field inversions. Jacobian coordinates represent an affine point $(x,y)$ as $(X,Y,Z)$ with $x = X/Z^2$, $y = Y/Z^3$. Under these coordinates, point addition requires only $11$ field multiplications (no inversions), and doubling requires $5$ field multiplications and $4$ squarings (no inversions). A single field inversion is performed only when converting back to affine coordinates. For $N = \log_2 q \approx 256$, one inversion costs roughly $80$–$100$ multiplications — projective coordinates trade the per-point-operation inversion for a few multiplications, substantially reducing the constant factor. The asymptotic order is unchanged:

$$
T_{\text{ECC}} = O(\log q) \times O((\log q)^2) = O((\log q)^3)
$$

The asymptotic order matches RSA — both $O(\log^3{\cdot})$ — but ECC's $\log q$ ($256$) is far smaller than RSA's $\log n$ ($2048$–$3072$). At equivalent security ($128$ bits), ECC-256 is roughly $5$–$10\times$ faster than RSA-3072<sup>[5]</sup> — the difference stems from the raw factor $(\frac{3072}{256})^3 \approx 1728$, partially offset by RSA's ability to use a small public exponent $e = 65537$ and other implementation factors.

### 3.1.6 AES

AES processes $128$-bit blocks, with the round count determined by key size ($128$→$10$, $192$→$12$, $256$→$14$)<sup>[13]</sup>. Per-round operations are fixed: SubBytes ($16$ S-box lookups), ShiftRows, MixColumns (omitted in the final round), AddRoundKey ($16$ byte XORs). The round count $r$ and per-round operations are constants. $O(1)$ per block, $O(n)$ for $n$ blocks.

### 3.1.7 DES and 3DES

DES is a $16$-round Feistel network<sup>[1]</sup>; each round's $F$-function comprises expansion permutation, subkey XOR, $8$ S-box lookups, and P-permutation — all fixed-count bit operations. $O(1)$ per block, $O(n)$ for $n$ blocks. 3DES triples the round count but remains $O(n)$. The Meet-in-the-Middle analysis for 3DES is given in §3.2.5.

### 3.1.8 MD5 / SHA-1 / SHA-256

All three use the Merkle–Damgård construction with fixed step counts<sup>[1][7]</sup>: MD5 at $64$ steps, SHA-1 at $80$ steps, SHA-256 at $64$ steps (including message schedule). Per-block operations are fixed; $O(1)$ per block, $O(n)$ overall.

### 3.1.9 Complexity Comparison

| Algorithm | Core Operation | Time (per invocation) | Asymptotic |
|:---|:---|---:|:---:|
| RSA | Square-and-multiply exponentiation | $\frac{3}{2}\log n$ mod-muls | $O(\log^3 n)$ |
| DH | Square-and-multiply exponentiation | $\frac{3}{2}\log p$ mod-muls | $O(\log^3 p)$ |
| ElGamal | 2–3 exponentiations | $3\log p$–$\frac{9}{2}\log p$ mod-muls | $O(\log^3 p)$ |
| DSA | Exponentiation (short exponent) | $\frac{3}{2}\log q$ mod-muls | $O(\log q \cdot (\log p)^2)$ |
| ECC | Double-and-add scalar multiplication | $\frac{3}{2}\log q$ point ops | $O(\log^3 q)$ |
| AES | SPN rounds | Fixed rounds × fixed steps | $O(n)$ |
| DES/3DES | Feistel rounds | Fixed | $O(n)$ |
| MD5/SHA-1/SHA-256 | Merkle–Damgård | Fixed steps | $O(n)$ |

Public-key algorithms uniformly fall in $O(\log^3{\cdot})$ — the differences lie in constant factors. Symmetric and hash algorithms are uniformly $O(n)$ — encryption time is linear in message length.

---

## 3.2 Security Complexity

### 3.2.1 RSA

RSA reduces to integer factorization of $n = pq$<sup>[15]</sup>. Recovering $p,q$ from $n$ yields $\varphi(n)$ and hence the private key $d$. The best classical attack is the General Number Field Sieve (GNFS)<sup>[8]</sup>, with sub-exponential complexity expressed in $L$-notation:

$$
L_n[\alpha, c] = \exp\left((c + o(1))(\ln n)^\alpha (\ln \ln n)^{1-\alpha}\right)
$$

The parameter $\alpha$ determines the growth regime. $\alpha = 0$ is polynomial ($(\ln n)^c$) — polynomial time. $\alpha = 1$ is exponential ($c \ln n$) — exponential time $2^{c\log_2 n} \approx n^c$. $\alpha = 1/3$ lies between — growth faster than any $\log^k n$ but slower than any $n^\varepsilon$, hence sub-exponential. Concretely, doubling $n$ from $1024$ to $2048$ bits increases a polynomial algorithm's cost linearly or quadratically, but GNFS cost grows by approximately $2^{30}\times$.

For RSA integers, GNFS takes $\alpha = 1/3$, $c = (64/9)^{1/3} \approx 1.923$:

$$
L_n\!\left[\frac{1}{3}, \left(\frac{64}{9}\right)^{1/3}\right] = \exp\!\left(1.923\,(\ln n)^{1/3}(\ln\ln n)^{2/3}\right)
$$

Under this model, RSA-2048 provides approximately $112$ bits of equivalent security; NIST SP 800-57 requires $3072$-bit moduli for the $128$-bit security baseline<sup>[5][6]</sup>.

### 3.2.2 DH / ElGamal / DSA

All three reduce to the Discrete Logarithm Problem (DLP) on $(\mathbb{Z}/p\mathbb{Z})^\times$<sup>[14]</sup>: given $g$ and $h = g^a$, find $a$. DSA and ElGamal break immediately if DLP is solvable — the attacker recovers the private key $x$. DLP is solvable via a GNFS variant (DLP-NFS)<sup>[9]</sup> with the same complexity $L_p[1/3, 1.923]$. DH, ElGamal, and DSA therefore share the same security strength as RSA at equal modulus sizes.

### 3.2.3 ECC

ECC reduces to the Elliptic Curve Discrete Logarithm Problem (ECDLP) on $E(\mathbb{F}_q)$<sup>[16][17]</sup>: given $P$ and $Q = kP$, find $k$.

The best generic attack is Pollard's $\rho$ algorithm<sup>[12]</sup>. The core idea: an iteration function $f$ generates a pseudo-random sequence $X_0, X_1 = f(X_0), X_2 = f(X_1), \ldots$ in the finite group $G$. Since $G$ is finite, a collision $X_i = X_j$ ($i < j$) occurs after $O(\sqrt{|G|})$ steps. The collision bound $\sqrt{N}$ follows from the birthday paradox: selecting $M$ random elements from a set of $N$, the probability that any two are equal approaches $1/2$ when $M \approx \sqrt{N}$. For a random mapping, the expected collision step count is $\sqrt{\pi N/2} \approx 1.25\sqrt{N}$.

For ECDLP, the random walk is typically defined as $f(X) = X + a_i P + b_i Q$, where $(a_i, b_i)$ is chosen from three branches based on a few bits of $X$. Once a collision $X_i = X_j$ is detected (via Floyd's cycle-finding with $O(1)$ extra space), we have $a_i P + b_i Q = a_j P + b_j Q$, giving $(a_i - a_j)P = (b_j - b_i)Q = (b_j - b_i)kP$, hence $k \equiv (a_i - a_j)(b_j - b_i)^{-1} \pmod{|G|}$ — solving for $k$. For general curves over $\mathbb{F}_q$, $|E(\mathbb{F}_q)| \approx q$ (Hasse's inequality, §2.1.5), giving:

$$
T_{\text{Pollard-}\rho} = O(\sqrt{q})
$$

This is exponential time — security bits equal $\frac{1}{2}\log_2 q$. A $256$-bit curve provides $128$-bit equivalent security.

Two degenerate curve classes require attention. Supersingular curves ($q \mid (q+1 - |E(\mathbb{F}_q)|)$) are vulnerable to the MOV attack<sup>[23]</sup>, which embeds the ECDLP into a DLP on the extension field $\mathbb{F}_{q^k}^\times$ and then applies GNFS (sub-exponential for $k \leq 6$, where small embedding degree is fatal). Anomalous curves ($|E(\mathbb{F}_q)| = q$) are solvable in polynomial time $O(\log^3 q)$ via Smart's attack<sup>[3]</sup>. Standard curves (NIST P-256, secp256k1, etc.) avoid both degenerate cases through parameter selection.

### 3.2.4 AES

AES security does not reduce to a group hard problem — it derives directly from exhaustive key search: key space size $2^k$ ($k = 128, 192, 256$)<sup>[13][20]</sup>. Naive brute force costs $O(2^k)$. The Biclique attack<sup>[11]</sup> exploits key-schedule structure to reduce AES-128 to $2^{126.1}$ (marginal improvement, $<2$ bits); AES-256 is reduced to $2^{254.4}$. Grover's quantum algorithm reduces brute force to $O(2^{k/2})$; AES-256 retains $128$-bit security in the quantum model.

### 3.2.5 DES / 3DES

The $56$-bit key space of $2^{56}$ is within reach of exhaustive search<sup>[1]</sup>. In 1998, the EFF's Deep Crack custom hardware completed the first public DES key exhaustion in under $3$ days<sup>[22]</sup>.

3DES has a nominal security of $168$ bits ($3 \times 56$), but the Meet-in-the-Middle (MITM) attack reduces effective security to $112$ bits. The MITM idea: for a known plaintext-ciphertext pair $(P, C)$, rewrite $C = E_{k_1}(D_{k_2}(E_{k_3}(P)))$ as $D_{k_2}(C) = E_{k_3}(P)$. Precompute the right-hand side: for all $2^{56}$ values of $k_3$, store $(E_{k_3}(P), k_3)$ in a hash table (space $O(2^{56})$). Enumerate the left-hand side: for all $2^{56}$ values of $k_2$, compute $D_{k_2}(C)$ and look up the table. A collision yields a candidate $(k_2, k_3)$ pair. Time: $O(2^{56})$ enumeration $+$ $O(2^{56})$ table construction $= O(2^{56})$. This attack recovers $k_2, k_3$ only; a second MITM or brute-force step recovers $k_1$. Total complexity: $O(2^{112})$.

### 3.2.6 MD5 / SHA-1 / SHA-256

Hash function security is measured by collision resistance. The birthday attack is a generic collision search: for an $n$-bit output, generating approximately $2^{n/2}$ random message hashes, the probability of any two colliding approaches $1/2$ by the birthday paradox. Hence an $n$-bit hash provides at most $n/2$ bits of collision resistance. Preimage resistance is $n$ bits — given a target hash value $y$, one expects to try $2^n$ random inputs to find $x$ with $H(x) = y$.

Practical results:
- **MD5**: $n=128$, birthday bound $2^{64}$. Wang et al. (EUROCRYPT 2005) constructed collision paths using modular differential methods at actual complexity $2^{39}$<sup>[21]</sup> — far below the birthday bound. MD5 is completely unfit for security-sensitive use.
- **SHA-1**: $n=160$, birthday bound $2^{80}$. Collision attacks reached $2^{63}$ (SHAttered, 2017), confirming theoretical vulnerability.
- **SHA-256**: $n=256$, birthday bound $2^{128}$. No known collision attack beats the birthday bound; preimage resistance at $2^{256}$ also holds — secure<sup>[7]</sup>.

### 3.2.7 Security Complexity Comparison

| Algorithm (parameters) | Reduces to | Best Attack | Attack Cost | Eq. Security (bits) |
|:---|:---|:---|---:|:---:|
| RSA-2048 | Integer factorization | GNFS | $L_n[1/3, 1.923]$ | $\sim 112$ |
| RSA-3072 | Integer factorization | GNFS | $L_n[1/3, 1.923]$ | $128$ |
| DH-2048 | DLP on $(\mathbb{Z}/p\mathbb{Z})^\times$ | DLP-NFS | $L_p[1/3, 1.923]$ | $\sim 112$ |
| DSA-2048 | DLP on $\langle g \rangle$ | DLP-NFS | $L_p[1/3, 1.923]$ | $\sim 112$ |
| ECC-256 | ECDLP on $E(\mathbb{F}_q)$ | Pollard-$\rho$ | $O(2^{128})$ | $128$ |
| AES-128 | — | Biclique | $2^{126.1}$ | $\sim 126$ |
| AES-256 | — | Brute force | $2^{256}$ | $256$ |
| DES-56 | — | Brute force | $2^{56}$ | $56$ |
| 3DES | — | Meet-in-the-Middle | $O(2^{112})$ | $112$ |
| MD5 | — | Collision | $2^{39}$ | — |
| SHA-1 | — | Collision | $2^{63}$ | — |
| SHA-256 | — | Birthday | $2^{128}$ | $128$ |

---

## 3.3 Chapter Summary

Public-key algorithms (RSA, DH, ElGamal, DSA, ECC) uniformly run at $O(\log^3{\cdot})$ — differences lie in constant factors. ECC achieves $5$–$10\times$ the speed of RSA-3072 at equivalent security with only $256$-bit parameters. ElGamal encryption costs $2$–$3\times$ that of DH, asymptotically unchanged. DSA signing and verification exploit the short $256$-bit exponents, reducing iterations to $\frac{1}{8}$ of RSA's.

Symmetric and hash algorithms (AES, DES, MD5/SHA-1/SHA-256) have constant per-block time, $O(n)$ overall. On the security side, RSA/DH/DSA face sub-exponential GNFS attacks — $2048$-bit parameters approach the safety margin. ECC enjoys exponential-grade security; $256$-bit curves remain viable long-term. DES ($56$ bits), 3DES ($112$ bits via MITM), MD5, and SHA-1 have been practically broken.

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
