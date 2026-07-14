---
title: "Chapter 4 — Time Complexity and Security Complexity"
date: 2026-07-14
tags: [cryptography, group-theory, complexity, paper-draft]
---

# Chapter 4 — Time Complexity and Security Complexity

> Building on the formulas and group structures established in Chapter 3, this chapter decomposes each algorithm into its core computational steps, derives time complexity, and analyzes security complexity.

---

## 4.1 Time Complexity Analysis

Classical encryption algorithms fall into three types based on their core group operations<sup>[1][2]</sup>.

### 4.1.1 Modular Exponentiation: $O(\log^3 p)$

RSA encryption $c = m^e \bmod n$<sup>[16]</sup>, DH key exchange $g^a \bmod p$<sup>[15]</sup>, and DSA signing and verification<sup>[10]</sup> all rely on modular exponentiation $g^a \bmod p$. Naively computing this requires $a$ multiplications — $a$ is on the same order as the modulus, e.g., $a \approx 2^{2048}$ for $2048$-bit keys — which is infeasible.

The square-and-multiply algorithm expands the exponent $a$ in binary, producing $\log a$ bits. Each bit requires one squaring, and when the bit is $1$, one additional multiplication. Hence the total number of modular multiplications is $O(\log a)$. For a $2048$-bit exponent, this is roughly $2048$ squarings and $1024$ multiplications. Each operation multiplies two $\log n$-bit integers, costing $O((\log n)^2)$ bit operations. Total complexity:

$$
T_{\text{mod-exp}} = O(\log a) \times O((\log n)^2) = O((\log n)^3)
$$

RSA requires one exponentiation to encrypt and one to decrypt; DH one per party; ElGamal two to encrypt and one to decrypt; DSA one to sign and two to verify.

### 4.1.2 Scalar Multiplication: $O(\log^3 q)$

ECC's core operation is $Q = kP$ over $P \in E(\mathbb{F}_q)$<sup>[17][18]</sup>, adding point $P$ to itself $k$ times in the elliptic curve group. Direct computation requires $k$ point additions — $k \approx 2^{256}$, infeasible.

The double-and-add algorithm expands $k$ in binary, producing $\log k$ bits. Each bit triggers one point doubling (adding a point to itself), and when the bit is $1$, one additional general point addition. The total is $O(\log k) = O(\log q)$ point operations. Each point operation requires several $\mathbb{F}_q$ field multiplications (cost $O((\log q)^2)$ — multiplying two $\log q$-bit numbers) plus one field inversion (also $O((\log q)^2)$). Total complexity:

$$
T_{\text{ECC}} = O(\log q) \times O((\log q)^2) = O((\log q)^3)
$$

A $256$-bit ECC key provides $128$-bit equivalent security, matching a $3072$-bit RSA key. Since $\log q = 256$ is much smaller than $\log n = 3072$, ECC runs $5\text{--}10\times$ faster in practice<sup>[5]</sup>.

### 4.1.3 Linear Operations: $O(n)$

AES processes $128$-bit blocks through $10\text{--}14$ SPN rounds. Each round comprises SubBytes ($\mathrm{GF}(2^8)$ table lookup), ShiftRows (rotation), MixColumns ($\mathrm{GF}(2^8)$ matrix multiplication), and AddRoundKey (XOR)<sup>[13]</sup>. All operations have fixed cost per block — $16$ byte lookups, one rotation, one matrix multiplication, and one XOR — independent of key size, with no iteration or exponentiation. Hence $O(1)$ per block and $O(n)$ total for an $n$-byte message. DES uses a $16$-round Feistel network with the same $O(n)$ complexity; its $2^{56}$ key permutations have been proven not to form a group under composition<sup>[19][20]</sup>. MD5 and SHA-256 use Merkle–Damgård iterative compression<sup>[1][7]</sup>: messages are split into $512$-bit blocks, each processed by a compression function executing $64$ steps (MD5) or $64$ rounds (SHA-256) of bitwise operations and modular $2^{32}$ addition — all fixed-count, yielding $O(1)$ per block and $O(n)$ total.

---

```candidate
## 4.2 Security Complexity Analysis (candidate)

Security complexity measures the optimal cost of attacking an algorithm. Different group structures lead to different security profiles.

RSA reduces to integer factorization on $(\mathbb{Z}/n\mathbb{Z})^\times$; DH/DSA reduce to DLP on $(\mathbb{Z}/p\mathbb{Z})^\times$<sup>[15][16]</sup>. The best attack, GNFS<sup>[8][9]</sup>, runs in sub-exponential time $L_n[1/3, 1.923]$. RSA-2048 provides only $112$-bit equivalent security; NIST requires $3072$-bit to reach the $128$-bit baseline<sup>[6]</sup>.

ECC reduces to ECDLP on $E(\mathbb{F}_q)$<sup>[17][18]</sup>. For general curves, no sub-exponential attack exists; the best attack, Pollard's $\rho$<sup>[12]</sup>, runs in exponential time $O(\sqrt{q})$ — the fundamental reason ECC outperforms RSA/DH in key efficiency. Supersingular curves are vulnerable to the MOV attack<sup>[24]</sup>; anomalous curves can be solved in polynomial time<sup>[3]</sup>. Standard curves avoid both.

AES derives its security from SPN confusion and diffusion<sup>[21]</sup>, with brute-force cost $O(2^k)$. The Biclique attack<sup>[11]</sup> only reduces this to $2^{126.1}$, a negligible improvement. DES's $56$-bit key was brute-forced in $56$ hours by the EFF Deep Crack<sup>[23]</sup>; its non-group property<sup>[19][20]</sup> ensures multi-layer encryption adds real security. MD5 was broken by Wang et al. with a $2^{39}$ collision attack<sup>[22]</sup>; SHA-256 maintains $2^{128}$ collision resistance and remains secure<sup>[1][7]</sup>.
```

---

## 4.3 Chapter Summary

1. **Three complexity categories**: Modular exponentiation ($(\mathbb{Z}/n\mathbb{Z})^\times$ type groups, $O(\log^3 p)$), scalar multiplication ($E(\mathbb{F}_q)$ point groups, $O(\log^3 q)$), and linear operations ($\mathrm{GF}(2^8)$ field ops / iterative structures, $O(n)$).

```candidate
2. **Security complexity gap**: Algorithms on finite field multiplicative groups face sub-exponential GNFS attacks; ECC on elliptic curve point groups provides exponential-grade security; symmetric ciphers without group hard problems (AES) show a $1:1$ ratio between key size and security.
3. **Dual role of group structures**: In public-key crypto, group hard problems are the direct source of security. In symmetric ciphers and hashing, group structures only serve the computation layer — security comes from diffusion and confusion.
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
