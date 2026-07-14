---
title: "Chapter 2 — Cryptographic Algorithms and Their Group Structures"
date: 2026-07-14
tags: [cryptography, group-theory, proof, paper-draft]
---

# Chapter 2 — Cryptographic Algorithms and Their Group Structures

> This chapter establishes the group structures of 11 cryptographic algorithms. For group-based algorithms, group axioms are verified one by one. For non-group constructions, proofs are given. For hash functions without group structure, the construction framework is described. All group-theoretic concepts are defined at first use.

---

## 2.1 Public-Key Algorithms Based on Abelian Groups

**Definition 2.1 (Group).** A set $G$ equipped with a binary operation $\cdot$ forms a group if: (i) closure: $\forall a,b \in G$, $a \cdot b \in G$; (ii) associativity: $(a \cdot b) \cdot c = a \cdot (b \cdot c)$; (iii) identity: $\exists e \in G$ such that $\forall a \in G$, $e \cdot a = a \cdot e = a$; (iv) inverses: $\forall a \in G$, $\exists a^{-1} \in G$ such that $a \cdot a^{-1} = a^{-1} \cdot a = e$. If the operation is commutative ($\forall a,b$, $a \cdot b = b \cdot a$), then $G$ is an Abelian group.

### 2.1.1 RSA

RSA was proposed by Rivest, Shamir, and Adleman in 1978 as one of the earliest public-key encryption schemes<sup>[15]</sup>. Its security rests on the difficulty of integer factorization; it supports both encryption and digital signatures.

Encryption $c = m^e \bmod n$ and decryption $m = c^d \bmod n$ operate in the multiplicative group of units modulo $n$:

$$
(\mathbb{Z}/n\mathbb{Z})^\times = \{a \in \{1,2,\ldots,n-1\} : \gcd(a, n) = 1\}
$$

where $n = pq$ for large primes $p,q$. This set forms an Abelian group under multiplication modulo $n$. We verify the four axioms.

**(1) Closure.** If $\gcd(a,n)=\gcd(b,n)=1$, then $\gcd(ab,n)=1$. Suppose otherwise: some prime $r \mid \gcd(ab,n)$. From $r \mid n$ and $r \mid ab$, we have $r \mid a$ or $r \mid b$, contradicting $\gcd(a,n)=\gcd(b,n)=1$. Hence $ab \bmod n \in (\mathbb{Z}/n\mathbb{Z})^\times$.

**(2) Associativity.** Modular multiplication inherits associativity from integer multiplication: $(ab)c \equiv a(bc) \pmod{n}$, since $(ab)c = a(bc)$ over the integers and reduction does not affect this.

**(3) Identity.** $1 \in (\mathbb{Z}/n\mathbb{Z})^\times$ since $\gcd(1,n)=1$, and $\forall a$, $1 \cdot a \equiv a \cdot 1 \equiv a \pmod{n}$.

**(4) Inverses.** By the extended Euclidean algorithm, if $\gcd(a,n)=1$ then there exist integers $x, y$ with $ax + ny = 1$. Modulo $n$, $a \cdot x \equiv 1 \pmod{n}$, so $a^{-1} \equiv x \pmod{n}$. We may take $0 < x < n$ (otherwise replace $x$ with $x \bmod n$); to verify $x$ lies in the group, note that $ax + ny = 1$ implies $\gcd(x,n)=1$ — otherwise $\gcd(x,n) > 1$ would divide $ax+ny=1$, a contradiction.

Commutativity follows from the commutativity of integer multiplication. Hence $(\mathbb{Z}/n\mathbb{Z})^\times$ is an Abelian group of order $\varphi(n) = (p-1)(q-1)$.

RSA parameters satisfy $ed \equiv 1 \pmod{\varphi(n)}$, i.e., there exists an integer $t$ such that $ed = 1 + t\varphi(n)$. By Euler's theorem $a^{\varphi(n)} \equiv 1 \pmod{n}$ for all $a \in (\mathbb{Z}/n\mathbb{Z})^\times$, correctness follows:

$$
c^d \equiv (m^e)^d = m^{ed} = m^{1 + t\varphi(n)} = m \cdot (m^{\varphi(n)})^t \equiv m \pmod{n}
$$

The value $\varphi(n)$ is equivalent to the factorization of $n$: knowing $p,q$ gives $\varphi(n)$ immediately, and knowing $\varphi(n)$ recovers $p,q$ via a quadratic equation. Hence $\varphi(n)$ is kept secret from non-key-holders — the secrecy of the group order is the foundation of RSA security.

Digital signatures reuse the same group: the signer computes $s = H(m)^d \bmod n$, and the verifier checks $H(m) \equiv s^e \pmod{n}$. Used for TLS certificates, key transport, and digital signatures.

### 2.1.2 Diffie–Hellman (DH)

DH was proposed by Diffie and Hellman in 1976 as the first public-key protocol<sup>[14]</sup>. Its core insight: two parties exchange partial information over a public channel, each independently computes the same shared secret, and an eavesdropper cannot reconstruct it.

Protocol flow: both parties agree on a large prime $p$ and a generator $g$. Alice chooses private key $a$ and sends $A = g^a \bmod p$; Bob chooses private key $b$ and sends $B = g^b \bmod p$. Both compute $K = g^{ab} \bmod p$ as the shared secret — Alice via $B^a$, Bob via $A^b$, yielding identical results.

**Definition 2.2 (Cyclic Group).** A group $G$ is cyclic if there exists $g \in G$ such that $G = \{g^k : k \in \mathbb{Z}\}$; $g$ is called a generator. The order $\operatorname{ord}(g)$ is the smallest positive integer $k$ with $g^k = e$.

DH uses the prime-order cyclic subgroup $\langle g \rangle$ of $(\mathbb{Z}/p\mathbb{Z})^\times$. A fundamental result of finite field theory: the multiplicative group of any finite field is cyclic. Specifically, if $p$ is prime, then $\mathbb{F}_p^\times = (\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic of order $p-1$; primitive roots $g$ (with $\operatorname{ord}(g) = p-1$) exist, and their number is $\varphi(p-1)$. DH selects a power of a primitive root, or directly a prime-order generator: $\langle g \rangle = \{g^0, g^1, g^2, \ldots, g^{q-1}\}$ where $q = \operatorname{ord}(g)$.

The generator's order must be prime. Let $\operatorname{ord}(g) = \prod p_i^{e_i}$. The Pohlig–Hellman attack proceeds in three steps: (1) for each $p_i^{e_i}$, reduce the target exponent $a$ to the subgroup of order $p_i^{e_i}$ — solving $a \bmod p_i^{e_i}$; (2) for each prime factor $p_i$, reduce the problem to a $p_i$-order subgroup (using $g^{\prod_{j \neq i} p_j^{e_j}}$ to shrink the group), then apply baby-step giant-step at total cost $O(\sum e_i(\sqrt{p_i} + \log|G|))$; (3) combine the prime-power solutions via the Chinese Remainder Theorem. If $\operatorname{ord}(g) = q$ is prime, only the $q$-order group requires solving in a single step, complexity $O(\sqrt{q})$ — no reduction possible. Unlike RSA, DH's group order $q$ is public. Used for TLS handshake and key exchange protocols.

### 2.1.3 ElGamal

ElGamal was proposed by Taher ElGamal in 1985, extending DH key exchange into a public-key encryption scheme<sup>[2]</sup>. Key generation: private key $x$, public key $h = g^x$. Encryption selects a one-time random $y$:

$$
(c_1, c_2) = (g^y,\; m \cdot h^y)
$$

Decryption:

$$
m = c_2 \cdot (c_1^x)^{-1} = m \cdot g^{xy} \cdot g^{-xy}
$$

The group structure is identical to DH: $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$. The key distinction from DH is randomization: each encryption uses a different $y$, so the same plaintext yields different ciphertext pairs $(c_1, c_2)$ across encryptions. This property — randomized encryption — prevents an eavesdropper from comparing ciphertexts to infer plaintext content, even when the set of candidate plaintexts is known.

### 2.1.4 DSA

DSA (Digital Signature Algorithm) is specified by NIST as the federal digital signature standard (FIPS 186)<sup>[10]</sup>. DSA is for signatures only, not encryption. Key generation: private key $x \in \mathbb{F}_q^\times$, public key $y = g^x \bmod p$.

To sign, choose a one-time random nonce $k \in \mathbb{F}_q^\times$:

$$
r = (g^k \bmod p) \bmod q, \quad s = k^{-1}(H(m) + xr) \bmod q
$$

To verify, compute $u_1 = H(m)s^{-1} \bmod q$, $u_2 = rs^{-1} \bmod q$, and check $(g^{u_1} y^{u_2} \bmod p) \bmod q = r$.

Verification correctness follows from the consistency of the signature equation. Expand the verification expression:

$$
g^{u_1} y^{u_2} = g^{H(m)s^{-1}} \cdot g^{xrs^{-1}} = g^{(H(m)+xr)s^{-1}}
$$

From the signature definition $s = k^{-1}(H(m)+xr) \bmod q$, we have $s^{-1} \equiv k(H(m)+xr)^{-1} \pmod{q}$. Substituting yields $g^{u_1} y^{u_2} \equiv g^k \pmod{p}$. Reducing modulo $q$ gives $(g^k \bmod p) \bmod q = r$ — matching the $r$ from the signature.

The group structure is identical to DH: $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$, order $q$. DSA employs a dual-modulus design — $p$ (typically $2048$ bits) hosts group operations, $q$ (typically $256$ bits) reduces signature components. The signature equation simultaneously involves two algebraic structures: modular exponentiation in $\langle g \rangle$ and field arithmetic in $\mathbb{F}_q$. The nonce $k$ has a strict one-time requirement: if two signatures reuse the same $k$ for different messages $m_1 \neq m_2$, then

$$
k = (H(m_1) - H(m_2)) \cdot (s_1 - s_2)^{-1} \bmod q
$$

The attacker recovers $k$, and hence $x = r^{-1}(ks - H(m)) \bmod q$.

### 2.1.5 ECC

ECC was independently proposed by Miller and Koblitz in 1985–1987, replacing the finite-field multiplicative group with the elliptic curve point group<sup>[16][17]</sup>. Over a finite field $\mathbb{F}_q$ of characteristic $\neq 2,3$, the Weierstrass equation

$$
E: y^2 = x^3 + ax + b \quad (a, b \in \mathbb{F}_q)
$$

defines an elliptic curve, with discriminant $\Delta = -16(4a^3 + 27b^2) \neq 0$ ensuring non-singularity (no cusps or self-intersections). The point set

$$
E(\mathbb{F}_q) = \{(x, y) \in \mathbb{F}_q^2 : y^2 = x^3 + ax + b\} \cup \{\mathcal{O}\}
$$

forms a finite Abelian group under the chord-and-tangent addition law, with $\mathcal{O}$ (the point at infinity) serving as the identity. The group operation is defined as follows.

**Inverse.** The inverse of $P = (x, y)$ is $-P = (x, -y)$. The line through $P$ and $-P$ (the vertical line $x = x_0$) intersects the curve at exactly $P$ and $-P$, with the third intersection being $\mathcal{O}$ (by Bezout's theorem), so $P + (-P) = \mathcal{O}$.

**Point addition** ($P \neq \pm Q$). Let $P = (x_1, y_1)$, $Q = (x_2, y_2)$. The line through $P$ and $Q$ has slope $\lambda = (y_2 - y_1)(x_2 - x_1)^{-1}$ and equation $y = \lambda(x - x_1) + y_1$. Substitute into $y^2 = x^3 + ax + b$ to eliminate $y$:

$$
(\lambda(x - x_1) + y_1)^2 = x^3 + ax + b
$$

Expanding: $\lambda^2(x-x_1)^2 + 2\lambda y_1(x-x_1) + y_1^2 = x^3 + ax + b$. Moving terms, the cubic in $x$ is $x^3 - \lambda^2 x^2 + \cdots = 0$. Let the three roots be $x_1, x_2, x_3'$. By Viète's formula, $x_1 + x_2 + x_3' = \lambda^2$, so the third intersection has $x$-coordinate $x_3' = \lambda^2 - x_1 - x_2$ and $y_3' = \lambda(x_3' - x_1) + y_1$. Reflecting across the $x$-axis yields $P + Q = R = (x_3, y_3)$ with

$$
x_3 = \lambda^2 - x_1 - x_2, \quad y_3 = \lambda(x_1 - x_3) - y_1
$$

**Point doubling** ($P = Q$). Replace the chord slope by the tangent slope $\lambda = (3x_1^2 + a)(2y_1)^{-1}$; the formulas are otherwise identical.

These formulas verify closure (the sum lies on the curve), existence of inverses, and commutativity (the formulas are symmetric in $P$ and $Q$). Associativity is more difficult: $(P+Q)+R$ and $P+(Q+R)$ require computations between different point pairs, each path involving different chord/tangent selections. Bezout's theorem guarantees that a cubic curve and a line intersect at three points (counting multiplicities), but the algebraic verification requires expanding a nine-term polynomial — Silverman (1986) gives a proof approximately 150 lines long. We state associativity as holding; the full verification is in [4]. The group order is bounded by Hasse's inequality:

$$
\bigl| |E(\mathbb{F}_q)| - (q+1) \bigr| \leq 2\sqrt{q}
$$

i.e., the group order is approximately $q$ (deviation $\leq 2\sqrt{q}$). The core operation is scalar multiplication $Q = kP$ ($P$ added to itself $k$ times). $256$-bit curves provide $128$-bit equivalent security and run $5$–$10\times$ faster than RSA at comparable security. Used for ECDH key exchange, ECDSA signatures, and blockchain wallets.

### 2.1.6 AES

AES was designed by Daemen and Rijmen, adopted by NIST in 2001 as the symmetric encryption standard to replace DES<sup>[13]</sup>. AES processes $128$-bit data blocks and supports key sizes of $128$, $192$, and $256$ bits.

AES operates over the finite field $\mathrm{GF}(2^8)$ — the set of polynomials with coefficients in $\mathbb{F}_2$ and degree less than $8$, modulo the irreducible polynomial $x^8 + x^4 + x^3 + x + 1$:

$$
\mathrm{GF}(2^8) \cong \mathbb{F}_2[x] / (x^8 + x^4 + x^3 + x + 1)
$$

This field carries two groups. The additive group $(\mathrm{GF}(2^8), +)$: each non-zero element has order $2$ ($a + a = 0$), making it an elementary Abelian $2$-group of order $256$. The operation corresponds to bytewise XOR. The multiplicative group $(\mathrm{GF}(2^8)^\times, \cdot)$: all $255$ non-zero elements form a cyclic group — the multiplicative group of any finite field is cyclic (Gauss' theorem), and the primitive element $\texttt{0x03}$ satisfies $\{\texttt{0x03}^i : i = 0,\ldots,254\} = \mathrm{GF}(2^8)^\times$.

The AES state is a $4 \times 4$ byte matrix, an element of $(\mathrm{GF}(2^8))^{16}$. Each round executes four steps. The SubBytes S-box is constructed in two steps: (1) multiplicative inversion $x \mapsto x^{-1}$ in $\mathrm{GF}(2^8)^\times$ (with the convention $0^{-1} = 0$); (2) an affine transformation $b \mapsto A \cdot b \oplus c$, where $A$ is an $8 \times 8$ $\mathrm{GF}(2)$ matrix with a cyclic-left-shift structure and $c = \texttt{0x63}$. The cyclic construction of $A$ ensures the S-box has no fixed points ($\forall x, S(x) \neq x$) and no opposite fixed points ($\forall x, S(x) \neq \lnot x$) — two properties that resist differential and linear attacks. ShiftRows performs row-wise cyclic shifts, providing inter-byte diffusion. MixColumns uses an MDS matrix over $\mathrm{GF}(2^8)$:

$$
\begin{bmatrix} 02 & 03 & 01 & 01 \\ 01 & 02 & 03 & 01 \\ 01 & 01 & 02 & 03 \\ 03 & 01 & 01 & 02 \end{bmatrix}
$$

with branch number $5$ — changing $k$ bytes in a column changes at least $5-k$ bytes in the output column. AddRoundKey is bytewise XOR with the round key (addition in $(\mathrm{GF}(2^8), +)$). The round count is $10$ (AES-128), $12$ (AES-192), or $14$ (AES-256).

A critical distinction: AES security does not reduce to any hard problem on these groups — it derives from Shannon's principles of confusion and diffusion. The two groups serve only the SPN computation layer. This distinguishes AES fundamentally from the public-key algorithms above: in public-key cryptography, the hard problem on the group *is* the source of security; in AES, the groups are the safe *execution vehicle* for security, not its premise.

---

## 2.2 Constructions Proven Not to Form a Group

### 2.2.1 DES

DES was adopted by NIST in 1977 and dominated symmetric encryption for nearly three decades<sup>[1]</sup>. DES is a Feistel network — it splits a $64$-bit data block into $L_0, R_0$ ($32$ bits each) and iterates $16$ rounds:

$$
L_i = R_{i-1}, \quad R_i = L_{i-1} \oplus F(R_{i-1}, K_i)
$$

where $K_i$ is a $48$-bit round key (derived from the $56$-bit master key) and $F$ is the round function (expansion permutation, subkey XOR, $8$ S-boxes of $6 \times 4$, and P-permutation).

Each $56$-bit key $K$ defines a permutation $\pi_K$ on $\{0,1\}^{64}$. A fundamental question in cryptographic history is whether the full set $G_{\text{DES}} = \{\pi_K : K \in \{0,1\}^{56}\}$ forms a group under composition. Kaliski, Rivest, and Sherman (1988) provided negative statistical evidence<sup>[19]</sup>. Their method: randomly select $\pi_{K_1}, \pi_{K_2}$, compute $\pi_{K_1} \circ \pi_{K_2}$, and track the fixed-point distribution of the composite permutation. If $G_{\text{DES}}$ were a group, this distribution should resemble that of a random permutation; experimental deviation indicated non-closure.

Campbell and Wiener (1992) settled the question with a rigorous mathematical proof<sup>[18]</sup>. Their method — the cycling closure test — selects a small set of DES key permutations $\pi_{K_1}, \ldots, \pi_{K_t}$ (with $t = 2$ or $3$) and computes all reachable permutations in $\langle \pi_{K_1}, \ldots, \pi_{K_t} \rangle$. If $G_{\text{DES}}$ were a group, the subgroup generated by a few elements would be bounded by $2^{56}$; however, experiments with $t = 2$ already yielded generated subgroups of size $> 10^{2499}$ (far exceeding the number of atoms in the observable universe) — impossible under group closure. The technical approach included tracking cycle structures of composite permutations (each permutation decomposes into cycles); if $G_{\text{DES}}$ were a group, cycle lengths would satisfy group-theoretic constraints. The observed cycle distributions could not be explained by any group model. A subtlety of the proof: even though DES's key schedule has collisions (different master keys producing identical round keys), the diversity of composite permutations far exceeds $2^{56}$.

This result has direct security implications: if DES were a group, then $\exists k_3$ such that $E_{k_1}(E_{k_2}(m)) = E_{k_3}(m)$, collapsing multi-layer DES into single DES. The non-group proof eliminates this degeneracy, providing the theoretical basis for 3DES's multi-encryption strategy. DES was deprecated in 2005; used only for legacy system compatibility.

### 2.2.2 3DES

3DES (TDEA) cascades three DES operations in EDE mode<sup>[1]</sup>:

$$
c = E_{k_1}(D_{k_2}(E_{k_3}(m)))
$$

using three independent keys $k_1, k_2, k_3$ for a nominal key length of $168$ bits. The middle step uses decryption ($D_{k_2}$) rather than encryption solely for backward compatibility — when $k_1 = k_2 = k_3$, 3DES degenerates to single DES.

The non-group property of DES (§2.2.1) directly justifies 3DES's security: since $G_{\text{DES}}$ is not closed under composition, two or three compositions of DES permutations cannot be substituted by a single DES permutation. However, the Meet-in-the-Middle attack (Diffie & Hellman, 1977) reduces effective security to $112$ bits — the attacker precomputes $\{D_{k_2}(c) : k_2 \in \{0,1\}^{56}\}$, searches $\{E_{k_3}^{-1}(E_{k_1}^{-1}(c)) : k_1,k_3 \in \{0,1\}^{56}\}$ for matches, with time $O(2^{112})$ and space $O(2^{56})$. NIST SP 800-131A mandates phase-out after 2023.

---

## 2.3 Hash Functions Without a Direct Group Structure

### 2.3.1 MD5

MD5 was designed by Rivest in 1991, using the Merkle–Damgård iterative construction<sup>[1]</sup>. The message $M$ is padded and split into $512$-bit blocks $M_0, M_1, \ldots, M_{t-1}$, with the recurrence $H_0 = \mathrm{IV}$ (fixed initial vector) and $H_i = f(H_{i-1}, M_{i-1})$, outputting $H_t$ ($128$ bits).

The compression function $f$ runs $4$ rounds $\times 16$ steps $= 64$ steps, each of the form $A = B + ((A + g(B,C,D) + M[k] + T[i]) \lll s)$ where $g$ is a round-specific nonlinear function ($F, G, H, I$). Operations involve modular $2^{32}$ addition ($(\mathbb{Z}/2^{32}\mathbb{Z}, +)$ as a computational vehicle only — it does not form a security assumption), left rotation, and bitwise operations. Not based on any group structure. In 2004, Wang et al. achieved collisions at $2^{39}$ complexity<sup>[21]</sup>; MD5 is prohibited for digital signatures.

### 2.3.2 SHA-1

SHA-1 was designed by the NSA, published in 1995<sup>[7]</sup>. Merkle–Damgård construction, $512$-bit message blocks, $160$-bit output, $80$ compression rounds. The construction framework mirrors MD5, with a longer output, more rounds, and $5$ different nonlinear functions for enhanced confusion. No group structure. Collision attacks reached $2^{63}$ (SHAttered, 2017); NIST has required migration to SHA-2 since 2010.

### 2.3.3 SHA-256

SHA-256 belongs to the SHA-2 family, designed by the NSA in 2001<sup>[7]</sup>. Merkle–Damgård construction, $256$-bit output, $64$ compression rounds. Each round uses $6$ bitwise operations — $\Sigma_0, \Sigma_1, \sigma_0, \sigma_1$ (rotation-shift combinations), $\mathrm{Maj}$ (majority function), $\mathrm{Ch}$ (choice function) — and $2$ modular $2^{32}$ additions. The message schedule expands $16$ words to $64$ words. No group structure. Exhaustive collision complexity is $2^{128}$, preimage $2^{256}$; currently secure. Used for Bitcoin proof-of-work, TLS certificate signatures, and software integrity verification.

---

## 2.4 Chapter Summary

The 11 algorithms analyzed fall into three tiers under the group-theoretic lens. Tier 1 (RSA, DH, ElGamal, DSA, ECC): hard problems on Abelian groups directly constitute the security assumption. Tier 2 (AES): group structure objectively exists but serves only the computation layer — security derives from elsewhere. Tier 3: DES and 3DES, whose permutation sets are proven non-groups (a fact with direct security implications), and MD5, SHA-1, SHA-256, whose construction frameworks do not rely on any group structure. The subsequent chapter builds on these group structures for quantitative complexity analysis.

---

## References

[1] Menezes et al. *Handbook of Applied Cryptography*. CRC Press, 1996.
[2] Stinson. *Cryptography: Theory and Practice* (4th ed.). CRC Press, 2018.
[3] Koblitz. *Number Theory and Cryptography*. Springer, 1994.
[4] Hankerson et al. *Guide to ECC*. Springer, 2004.
[5] NIST SP 800-57. *Key Management*. 2020.
[6] NIST SP 800-131A. *Algorithm Transition*. 2019.
[7] NIST FIPS 180-4. *Secure Hash Standard*. 2015.
[10] NIST FIPS 186-5. *DSS*. 2023.
[13] Daemen & Rijmen. *Design of Rijndael*. Springer, 2002.
[14] Diffie & Hellman. "New directions." *IEEE TIT* 22:644, 1976.
[15] Rivest et al. "RSA." *CACM* 21:120, 1978.
[16] Miller. "Elliptic curves in crypto." *CRYPTO'85*, LNCS 218, 1986.
[17] Koblitz. "Elliptic curve cryptosystems." *Math. Comp.* 48:203, 1987.
[18] Campbell & Wiener. "DES is not a Group." *CRYPTO'92*, LNCS 740.
[19] Kaliski et al. "Is DES a group?" *J. Cryptology* 1:3, 1988.
[21] Wang & Yu. "Break MD5." *EUROCRYPT 2005*, LNCS 3494.
