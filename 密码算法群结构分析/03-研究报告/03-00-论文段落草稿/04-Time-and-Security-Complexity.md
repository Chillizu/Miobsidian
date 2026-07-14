---
title: "Chapter 4 — Time Complexity and Security Complexity"
date: 2026-07-14
tags: [cryptography, group-theory, complexity, paper-draft]
---

# Chapter 4 — Time Complexity and Security Complexity

> From a group-theoretic perspective, this chapter categorizes time complexity by the type of group operation and analyzes the security strength of each algorithm under known optimal attacks.

---

## 4.1 Time Complexity Analysis

Classical encryption algorithms fall into three types based on their core group operations<sup>[1][2]</sup>.

**Modular exponentiation $O(\log^3 p)$** — RSA, DH, ElGamal, and DSA all operate within finite field multiplicative groups (RSA in $(\mathbb{Z}/n\mathbb{Z})^\times$, DH/DSA in a subgroup $\langle g \rangle$ of $(\mathbb{Z}/p\mathbb{Z})^\times$)<sup>[15][16]</sup>. The core computation $g^a \bmod p$ is implemented via square-and-multiply<sup>[1]</sup>, yielding complexity $O((\log p)^3)$. RSA requires one exponentiation for encryption and one for decryption; DH requires one per party; DSA requires one for signing and two for verification<sup>[10]</sup>.

**Scalar multiplication $O(\log^3 q)$** — ECC (ECDH, ECDSA) performs scalar multiplication $kP$ on the elliptic curve Abel group $E(\mathbb{F}_q)$<sup>[17][18]</sup> via double-and-add<sup>[4]</sup>, with complexity $O((\log q)^3)$. The key advantage: a $256$-bit ECC key provides $128$-bit equivalent security, while RSA requires $3072$ bits for the same level, and ECC runs $5\text{--}10\times$ faster<sup>[5]</sup>.

**Linear operations $O(n)$** — AES operates within the $\mathrm{GF}(2^8)$ additive group (XOR) and multiplicative group (MixColumns)<sup>[13]</sup>, using $10\text{--}14$ SPN rounds with constant-time per block. DES employs a $16$-round Feistel network; its full set of key permutations has been proven not to form a group under composition<sup>[19][20]</sup>. MD5 and SHA-256 use Merkle–Damgård iterative compression with no direct group structure<sup>[1][7]</sup>. All these algorithms exhibit $O(n)$ complexity, independent of key size.

---

## 4.2 Security Complexity

Different group structures lead to fundamentally different security landscapes.

**Public-key cryptography based on group hard problems**: RSA relies on integer factorization over $(\mathbb{Z}/n\mathbb{Z})^\times$, while DH/DSA rely on the Discrete Logarithm Problem (DLP) over $(\mathbb{Z}/p\mathbb{Z})^\times$<sup>[15][16]</sup>. The best classical attack for both is the General Number Field Sieve (GNFS), which runs in sub-exponential time<sup>[8][9]</sup>. RSA-2048 provides only $112$-bit equivalent security; NIST recommends $3072$-bit keys or larger<sup>[6]</sup>. ECC, by contrast, relies on the Elliptic Curve DLP (ECDLP) over $E(\mathbb{F}_q)$<sup>[17][18]</sup> — for general curves, no sub-exponential attack is known. The best attack, Pollard's $\rho$ algorithm<sup>[12]</sup>, runs in exponential time $O(\sqrt{q})$. This is the fundamental reason ECC achieves far better key efficiency than RSA/DH. Special curves require caution: supersingular curves are vulnerable to the MOV attack<sup>[24]</sup>, and anomalous curves can be solved in polynomial time<sup>[3]</sup>; standard curves avoid both conditions.

**Symmetric ciphers and hashes without group hard problems**: AES derives its security from the confusion and diffusion properties of the SPN structure<sup>[21]</sup>, with brute-force complexity $O(2^k)$ ($k\in\{128,192,256\}$). The best known attack, Biclique<sup>[11]</sup>, only reduces this to $2^{126.1}$ — a negligible improvement. Although AES uses $\mathrm{GF}(2^8)$ groups for byte-level operations, its security does not reduce to any group-based hard problem — this distinction between "group structure for computation" and "group structure for security reduction" is crucial. DES, with its $56$-bit key, was brute-forced in $56$ hours by the EFF Deep Crack machine in 1998<sup>[23]</sup>. Its proven non-group property<sup>[19][20]</sup> ensures that multi-layer encryption genuinely adds security. MD5 was broken by Wang et al. with a $2^{39}$ collision attack<sup>[22]</sup>; SHA-256 maintains $2^{128}$ collision resistance and remains secure<sup>[1][7]</sup>.

---

## 4.3 Chapter Summary

1. **Three complexity categories**: Modular exponentiation ($(\mathbb{Z}/n\mathbb{Z})^\times$ type groups, $O(\log^3 p)$), scalar multiplication ($E(\mathbb{F}_q)$ point groups, $O(\log^3 q)$), and linear operations ($\mathrm{GF}(2^8)$ field operations / iterative structures, $O(n)$).
2. **Security gap**: RSA/DH/DSA face sub-exponential GNFS attacks; ECC provides exponential-grade security; symmetric ciphers without group-based assumptions (AES) exhibit a $1:1$ linear relationship between key size and security strength.
3. **Dual role of group structures**: In public-key cryptography, hard problems on groups serve as the **direct foundation of security**. In symmetric ciphers and hashing, group structures only support the **computation layer** (AES's $\mathrm{GF}(2^8)$, DES's permutation set) — security derives from diffusion and confusion rather than group hard problems.

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
