---
title: "Chapter 3 — Cryptography Algorithm Classification"
date: 2026-07-14
tags: [cryptography, group-theory, classification, paper-draft]
---

# Chapter 3 — Cryptography Algorithm Classification

> This chapter classifies 11 cryptographic algorithms into three categories based on group structure proof status, presenting the core formula, group structure, and main applications for each.

---

## 3.1 Algorithms with a Proven Group Structure

### 3.1.1 RSA

RSA is one of the earliest public-key encryption schemes, named after Rivest, Shamir, and Adleman. Its security rests on the difficulty of integer factorization. RSA supports both encryption and digital signatures — a signature is a modular exponentiation of the message hash with the private key $d$, verified by the public key $e$.

Encryption $c = m^e \bmod n$ and decryption $m = c^d \bmod n$ take place in the multiplicative group $(\mathbb{Z}/n\mathbb{Z})^\times$, where $n = pq$ is the product of two large primes $p$ and $q$. The parameters satisfy $ed \equiv 1 \pmod{\varphi(n)}$, where $\varphi(n) = (p-1)(q-1)$ is the group order. $\varphi(n)$ is unknown to anyone except the key holder — if known, $d$ is directly computable from $e$. Used for digital signatures, key transport, and HTTPS/TLS certificates.

### 3.1.2 Diffie–Hellman (DH)

DH was proposed by Diffie and Hellman in 1976 as the first public-key protocol. It solves the key distribution problem for symmetric encryption: two parties negotiate a shared secret over an insecure channel.

The protocol proceeds as follows. Both parties agree on a large prime $p$ and a generator $g$. Alice chooses $a$ and computes $A = g^a \bmod p$; Bob chooses $b$ and computes $B = g^b \bmod p$. Both compute $K = g^{ab} \bmod p$ as their shared secret<sup>[14]</sup>.

The group structure is a prime-order cyclic subgroup $\langle g \rangle$ of $(\mathbb{Z}/p\mathbb{Z})^\times$. The generator $g$ must have prime order $q$ (with $q \mid (p-1)$) to preclude Pohlig–Hellman reduction — if the order contained small factors, the discrete logarithm problem could be decomposed into smaller subgroups. Unlike RSA, DH's group order $q$ is a public parameter. Used for key exchange and TLS handshake.

### 3.1.3 ElGamal

ElGamal was proposed by Taher ElGamal in 1985, extending DH key exchange into a public-key encryption scheme. The public key is $h = g^x$, with private key $x$. Encryption selects a random $y$ and outputs $(c_1, c_2) = (g^y,\; m \cdot h^y)$; decryption recovers $m = c_2 \cdot c_1^{-x}$<sup>[2]</sup>.

The group structure is identical to DH: $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$. The key difference from DH is that each encryption uses a different random $y$ — the same plaintext produces different ciphertexts each time. This property, called randomized encryption, prevents attackers from inferring plaintext content by comparing ciphertexts.

### 3.1.4 DSA

DSA (Digital Signature Algorithm) is one of the most widely used digital signature standards, specified by NIST. DSA is for signatures only, not encryption.

The signature $(r, s)$ is given by $r = (g^k \bmod p) \bmod q$ and $s = k^{-1}(H(m) + xr) \bmod q$<sup>[10]</sup>. The group setting is the same as DH: $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$ of order $q$. DSA employs a dual-modulus design — $p$ ($2048$ bits) for group operations, $q$ ($256$ bits) for signature component reduction. The signature equation involves both modular exponentiation in $(\mathbb{Z}/p\mathbb{Z})^\times$ and modular arithmetic in $\mathbb{F}_q$. The random nonce $k$ must be unique per signature — reuse leaks the private key $x$.

### 3.1.5 ECC (ECDH / ECDSA)

ECC was independently proposed by Miller (1985) and Koblitz (1987), replacing the finite-field multiplicative group with the elliptic curve point group. Its primary advantage is drastically shorter key lengths at equivalent security levels.

The group structure is the elliptic curve point set $E(\mathbb{F}_q)$ over a finite field $\mathbb{F}_q$, forming a finite Abelian group under the chord-and-tangent addition law. The curve equation is $E: y^2 = x^3 + ax + b$ ($a,b \in \mathbb{F}_q$, discriminant $\Delta = -16(4a^3 + 27b^2) \neq 0$ ensuring non-singularity). Point addition $P + Q = R$ follows the chord-and-tangent rule: draw a line through $P$ and $Q$, intersect the curve at a third point, and reflect about the $x$-axis. Scalar multiplication $Q = kP$ (adding $P$ to itself $k$ times) is the core group operation<sup>[16][17]</sup>. The group order satisfies Hasse's inequality $| |E(\mathbb{F}_q)| - (q+1) | \leq 2\sqrt{q}$, approximately $q$.

$256$-bit ECC provides $128$-bit equivalent security where RSA requires $3072$ bits. Used for ECDH key exchange, ECDSA signatures, blockchain wallets, and IoT encryption.

### 3.1.6 AES

AES was designed by Daemen and Rijmen, adopted by NIST in 2001 as the symmetric encryption standard, replacing DES. AES processes $128$-bit data blocks with key sizes of $128$, $192$, or $256$ bits.

AES operates at the byte level using two groups over $\mathrm{GF}(2^8) \cong \mathbb{F}_2[x]/(x^8 + x^4 + x^3 + x + 1)$. The additive group $(\mathrm{GF}(2^8), +)$ is an elementary Abelian $2$-group of order $256$, corresponding to bitwise XOR. The multiplicative group $(\mathrm{GF}(2^8)^\times, \cdot)$ is a cyclic group of order $255$ with generator 0x03<sup>[13]</sup>. Each round executes four steps: SubBytes (S-box lookup, constructed from the multiplicative inverse in $\mathrm{GF}(2^8)$), ShiftRows (row rotation), MixColumns ($\mathrm{GF}(2^8)$ matrix multiplication), and AddRoundKey (XOR). The $128$-bit state is a composition of linear/affine transformations over $(\mathrm{GF}(2^8))^{16}$.

AES security does not reduce to any hard problem on these groups — it derives from the confusion and diffusion principles of the SPN structure. The groups serve only the computation layer, distinguishing AES from the public-key algorithms above. Used for file encryption, disk encryption, and TLS symmetric session encryption.

---

## 3.2 Algorithms Proven Not to Form a Group

### 3.2.1 DES

DES was adopted by NIST in 1977 as the symmetric encryption standard, based on the Feistel network structure. It dominated symmetric encryption for nearly three decades. DES uses a $56$-bit key to encrypt $64$-bit blocks through $16$ rounds.

The Feistel network is structured as $L_i = R_{i-1}$, $R_i = L_{i-1} \oplus F(R_{i-1}, K_i)$, where each key $K$ defines a permutation $\pi_K$ on $64$-bit space<sup>[1]</sup>. A fundamental question in cryptographic history was whether the full set of $2^{56}$ DES key permutations forms a group under composition. Kaliski, Rivest, and Sherman (1988) provided statistical evidence through cycling experiments — tracking fixed-point distributions after composing random permutations — that DES is not a group<sup>[19]</sup>. Campbell and Wiener (1992) gave a rigorous proof: the $2^{56}$ permutations are not closed under composition, with the generated subgroup estimated at size $> 10^{2499}$<sup>[18]</sup>.

If DES were a group, $E_{k_1}(E_{k_2}(m)) = E_{k_3}(m)$ would hold for some $k_3$, and multi-layer DES would collapse to single DES. The non-group proof eliminated this possibility, providing the theoretical basis for 3DES. Now deprecated, used only for legacy system compatibility.

### 3.2.2 3DES (TDEA)

3DES cascades three DES operations in EDE (Encrypt-Decrypt-Encrypt) mode: $c = E_{k_1}(D_{k_2}(E_{k_3}(m)))$, with three independent keys $k_1, k_2, k_3$ for a total key length of $168$ bits<sup>[1]</sup>. Since DES is not a group, 3DES's permutation set is also not a group. Meet-in-the-Middle attacks reduce effective security to $112$ bits — the attacker precomputes all possible intermediate states $D_{k_2}(E_{k_3}(m))$ and matches from the other end. Used in payment systems and legacy financial systems; NIST SP 800-131A mandates phase-out.

---

## 3.3 Algorithms Without a Direct Group Structure

### 3.3.1 MD5

MD5 was designed by Rivest in 1991, using the Merkle–Damgård iterative construction $H_i = f(H_{i-1}, M_i)$ to compress arbitrary-length messages into a $128$-bit hash value<sup>[1]</sup>. The compression function $f$ consists of $4$ rounds $\times 16$ steps = $64$ steps of nonlinear operations, each including modular $2^{32}$ addition, left rotation, nonlinear bitwise functions, and S-box lookups. Not based on any group structure.

In 2004 Wang et al. broke collision resistance at $2^{39}$ complexity<sup>[21]</sup>. Prohibited for digital signatures; used only for checksums and cache keys.

### 3.3.2 SHA-1

SHA-1 was designed by NSA, published in 1995. Merkle–Damgård construction with a $160$-bit output and $80$ compression rounds<sup>[1][7]</sup>. Its structure mirrors MD5 in the Merkle–Damgård framework, but with longer output, more rounds, and $5$ different nonlinear functions. Not based on any group structure. Collision resistance broken at $2^{63}$ complexity, demonstrated in practice. NIST began phasing out SHA-1 in 2010.

### 3.3.3 SHA-256

SHA-256 belongs to the SHA-2 family, designed by NSA in 2001. Merkle–Damgård construction, $256$-bit output, $64$ rounds with message expansion<sup>[1][7]</sup>. Each round uses $6$ bitwise operations ($\Sigma_0$, $\Sigma_1$, $\sigma_0$, $\sigma_1$, Maj, Ch) and $2$ modular $2^{32}$ additions. The message expansion extends the $16$-word input block to $64$ words. Not based on any group structure. Collision resistance at $2^{128}$, currently secure. Used for Bitcoin mining and address generation, TLS certificate signatures, and integrity verification.

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
