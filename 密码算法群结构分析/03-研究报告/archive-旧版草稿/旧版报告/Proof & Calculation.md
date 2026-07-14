---
title: "Proof & Calculation Checklist — Group Theory in Cryptographic Algorithms"
date: 2026-07-14
tags: [proof-checklist, cryptography, english]
---

# Proof & Calculation Checklist

> Every claim in the paper that requires mathematical justification, computation, or experimental verification, cross-referenced against the formal literature. Citations use the numbering from `crypto_literature_formal_EN.docx`.

---


## Reference Map

| Ref | Source | Topic Area | arXiv / Open Access | Cred. |
|:---:|:---|:---|:---|:---:|
| [1] | Blackburn, Cid, Mullan — Cambridge UP, 2011 | Group theory in cryptography (survey) | [arXiv:0906.5545](https://arxiv.org/abs/0906.5545) | **A** |
| [2] | IJFANS — open PDF | Applications of group theory in crypto | [ijfans.org/…/2a5dff61….pdf](https://www.ijfans.org/uploads/paper/2a5dff6130357d57bf484895d24b7a9a.pdf) | **C** |
| [3] | Myasnikov, Ushakov, Shpilrain — Birkhäuser, 2008 | Group-based cryptography (foundational monograph) | [doi:10.1007/978-3-7643-8827-0](https://doi.org/10.1007/978-3-7643-8827-0) (paywall) | **A** |
| [4] | Kahrobaei et al. — AMS Surveys 278, 2024 | Post-quantum group-based crypto (latest monograph) | [ams.org/books/surv/278](https://bookstore.ams.org/SURV/278) (endmatter free) | **A** |
| [5] | Kahrobaei, Flores, Noce — 2022 | Lighter survey in same direction | [arXiv:2202.05917](https://arxiv.org/abs/2202.05917) | **A** |
| [6] | Menezes, van Oorschot, Vanstone — CRC Press, 1996 | Handbook of Applied Cryptography (HAC) | [cacr.uwaterloo.ca/hac](https://cacr.uwaterloo.ca/hac/) (full open) | **A** |
| [7] | Stinson — CRC Press, 3rd/4th ed. | Cryptography: Theory and Practice | [archive.org/details/pdfy-eAEdqcELZKUUU733](https://archive.org/details/pdfy-eAEdqcELZKUUU733) | **A** |
| [8] | Koblitz — Springer GTM 114, 2nd ed. 1994 | Number theory, elliptic curves | [almuhammadi.com/…/Koblitz.2ndEd.pdf](http://almuhammadi.com/sultan/crypto_books/Koblitz.2ndEd.pdf) | **A** |
| [9] | Rosulek — "The Joy of Cryptography" (open) | RSA chapter | [joyofcryptography.com/rsa](https://joyofcryptography.com/rsa) | **B** |
| [10] | John D. Cook — blog, 2023 | RSA + Carmichael totient group theory | [johndcook.com/blog/…](https://www.johndcook.com/blog/2023/09/14/rsa-group-theory) (blog) | **D** |
| [11] | HAC Ch.3 (same as [6]) | DLP / DH | [cacr.uwaterloo.ca/hac/about/chap3.pdf](https://cacr.uwaterloo.ca/hac/about/chap3.pdf) | **A** |
| [12] | Stinson (same as [7]) | DH / ElGamal chapter | Same as [7] | **A** |
| [13] | NIST FIPS 186-5, 2023 | Digital Signature Standard (DSA, ECDSA) | [nvlpubs.nist.gov/…/fips.186-5.pdf](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.186-5.pdf) | **A** |
| [14] | NIST SP 800-131A Rev.2 | Algorithm transition / parameter guidance | [nvlpubs.nist.gov/…/SP.800-131Ar2.pdf](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-131Ar2.pdf) | **A** |
| [15] | Hankerson, Menezes, Vanstone — Springer, 2004 | Guide to Elliptic Curve Cryptography | [doi:10.1007/b97644](https://doi.org/10.1007/b97644) (paywall) | **A** |
| [16] | Blake, Seroussi, Smart — Cambridge UP, 1999 | Elliptic Curves in Cryptography | [doi:10.1017/CBO9781107360211](https://doi.org/10.1017/CBO9781107360211) (paywall) | **A** |
| [17] | Wikipedia — "Finite field arithmetic" | AES GF(2^8) and reduction polynomial | [wikipedia.org](https://en.wikipedia.org/wiki/Finite_field_arithmetic) | **D** |
| [18] | UAF CS 463/480 lecture notes, 2015 | AES byte ops in finite-field framework | [cs.uaf.edu/…/03_23_AES.html](https://www.cs.uaf.edu/2015/spring/cs463/lecture/03_23_AES.html) | **C** |
| [19] | Kaliski, Rivest, Sherman — J. Cryptology 1(1), 1988 | Is DES a group? | [doi:10.1007/BF00206323](https://doi.org/10.1007/BF00206323) (paywall) | **A** |
| [20] | Campbell, Wiener — CRYPTO'92, LNCS 740 | DES is not a group | [doi:10.1007/3-540-48071-4_36](https://doi.org/10.1007/3-540-48071-4_36) (paywall) | **A** |
| [DR] | Daemen & Rijmen — Springer, 2002 | The Design of Rijndael (official AES specification) | [doi:10.1007/978-3-662-04722-4](https://doi.org/10.1007/978-3-662-04722-4) (paywall) | **A** |
| [21] | Khalilov — Medium, 2023 | Accessible intro to modern crypto | [medium.com/@mahammadkhalilov/…](https://medium.com/@mahammadkhalilov/introduction-to-modern-cryptographic-algorithms-from-rsa-giants-to-elliptic-curve-elegance-e86cb334c3b0) (blog) | **D** |

**Credibility key:**
- **A** — Peer-reviewed journal, academic-publisher monograph, NIST standard, or established textbook. Cite freely as primary source.
- **B** — Open textbook by recognized academic; not peer-reviewed but authoritative. Cite with discretion for definitions and explanations.
- **C** — University course material or non-major-journal article. Cite for definitions; prefer A-level sources for core mathematical claims.
- **D** — Blog, Wikipedia, or self-published. Use only for background intuition or supplementary examples. Never cite as primary source for a proof.

> Notes: Refs [9]–[12], [14], [16]–[18], [21] are in the literature compilation but not directly cited for proofs below. DES refs [19][20] remain for background (DES is absent from the current paper per `Cipher Outline 1.docx`, but the group-theoretic proof methodology is relevant). The IJFANS journal [2] has no established impact factor — treat claims from [2] as C-level and cross-verify against [6] or [7] where possible.

---

## §1.1 Core Mathematical Problems

### §1.1.1 Abelian Groups — DHP and DLP

| #   | Item                                                                                                                                                                                                     | Type           |  Citation  | Notes                                                                                                                                 |
| :-- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------- | :--------: | :------------------------------------------------------------------------------------------------------------------------------------ |
| P1  | **DLP ⇒ DHP** (direction). Given $a = \log_g h$, compute $g^{ab} = (g^b)^a$. Trivial: solving DLP solves DHP. The converse is believed to hold in cyclic groups but unproven in general.                 | Proof          |  [6] §3.6  | One sentence. Reference [1] §2 for the DHP–DLP relationship.                                                                          |
| P2  | **$(\mathbb{Z}/p\mathbb{Z})^\times$ is cyclic**. Existence of primitive roots modulo prime $p$.                                                                                                          | Statement-only |  [8] §1.4  | Full proof requires Dirichlet characters; state as fact with reference.                                                               |
| P3  | **Pohlig–Hellman reduction**. If $\operatorname{ord}(g) = \prod p_i^{e_i}$, DLP decomposes into subproblems of size $p_i^{e_i}$. Prime-order $\operatorname{ord}(g) = q$ eliminates this reduction path. | Proof sketch   | [6] §3.6.4 | Describe the three-step decomposition (reduce → baby-step-giant-step per factor → CRT). Full derivation in [6]; sketch only in paper. |

### §1.1.2 Non-Abelian Groups — CSP and Key Exchange

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P4 | **CSP is trivial in abelian groups**. $g^{-1}xg = x$ for all $g, x$ in an abelian group → conjugacy search degenerates. | Proof | — | One sentence. Direct from commutativity. |
| P5 | **Braid group $B_n$ definition**. Generators $\sigma_1,\ldots,\sigma_{n-1}$, relations $\sigma_i\sigma_{i+1}\sigma_i = \sigma_{i+1}\sigma_i\sigma_{i+1}$, $\sigma_i\sigma_j = \sigma_j\sigma_i$ for $|i-j|>1$. | Definition | [4] §7.2 | Statement only. Reference [4] for full algebraic treatment. |
| P6 | **Ko–Lee key exchange principle**. Subgroups $A, B \subset B_n$ with $[A,B]=1$. Alice's secret $a \in A$, Bob's $b \in B$. Public: conjugates. Shared key from commutativity of $A$ and $B$. | Proof sketch | [4] §7.4; [1] §3 | The core algebraic step: $(b^{-1}a^{-1}b)a = b^{-1}(a^{-1}ba) = b^{-1}(a^{-1}(bab^{-1}))b$ — uses that $a,b$ come from commuting subgroups. |
| P7 | **AAG key exchange principle**. Alice publishes conjugates of her secret generators; Bob does the same. Both derive a shared key using the fact that each party's secret conjugates only their own set. | Proof sketch | [4] §7.4; [3] §4 | One paragraph. The algebra: message passing through individual conjugations preserves sufficient information for key extraction. |
| P8 | **Stickel key exchange**. Based on matrix groups with commuting subsets. | Proof sketch | [1] §4 | Brief mention; reference for details. |

---

## §1.2 Group-Based Cryptographic Algorithms

### §1.2.1 RSA

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P9 | **Decryption correctness**. $c^d \equiv (m^e)^d = m^{ed} = m^{1 + t\varphi(n)} \equiv m \pmod{n}$. | Proof | [6] §8.2; [7] §5 | Requires $ed \equiv 1 \pmod{\varphi(n)}$ and Euler's theorem $m^{\varphi(n)} \equiv 1 \pmod{n}$. Two lines. |
| P10 | **Group order**. $\varphi(n) = (p-1)(q-1)$ for $n=pq$. | Proof | [8] §2 | Multiplicativity of Euler's totient + $\varphi(p) = p-1$ for prime $p$. One line. |
| P11 | **Equivalence of $\varphi(n)$ and factorization**. Knowing $p,q$ → $\varphi(n)$. Knowing $\varphi(n)$ → solve $x^2 - (n-\varphi(n)+1)x + n = 0$ → $p,q$. | Proof | [6] §8.2.1 | Two lines. This is why $\varphi(n)$ is secret: it reveals the factorization. |

### §1.2.2 DH / ElGamal

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P12 | **DH key agreement consistency**. $A^b = (g^a)^b = g^{ab} = (g^b)^a = B^a$. | Proof | [6] §3.1; [1] §2 | Trivial from exponent laws. One line. |
| P13 | **ElGamal decryption correctness**. $c_2 \cdot (c_1^x)^{-1} = m \cdot h^y \cdot (g^{xy})^{-1} = m \cdot g^{xy} \cdot g^{-xy} = m$. | Proof | [7] §5.1; [2] §3 | Two lines. Uses $h = g^x$, $c_1 = g^y$. |

### §1.2.3 DSA

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P14 | **DSA verification correctness**. $g^{u_1} y^{u_2} = g^{H(m)s^{-1}} \cdot g^{x r s^{-1}} = g^{(H(m)+xr)s^{-1}}$. From $s = k^{-1}(H(m)+xr) \bmod q$ → $s^{-1} \equiv k(H(m)+xr)^{-1} \pmod{q}$ → $g^k \bmod p$ → $\bmod q = r$. | Proof | [13] §4; [2] §4 | Three-line algebraic expansion. |
| P15 | **Nonce reuse leaks $x$**. $s_1 - s_2 = k^{-1}(H(m_1)-H(m_2)) \bmod q$ → $k$ recoverable → $x = r^{-1}(ks - H(m)) \bmod q$. | Proof | [13] Appendix | Two lines. Demonstrates the strict uniqueness requirement for $k$. |

### §1.2.4 ECC

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P16 | **Point addition formula (Weierstrass, char ≠ 2,3)**. $\lambda = (y_2 - y_1)(x_2 - x_1)^{-1}$, substitute line $y = \lambda(x-x_1)+y_1$ into $y^2 = x^3+ax+b$ → cubic in $x$, Viète: $x_1+x_2+x_3' = \lambda^2$ → $x_3' = \lambda^2 - x_1 - x_2$, $x_3 = x_3'$, $y_3 = \lambda(x_1 - x_3) - y_1$. | Derivation | [15] §3.1; [8] §6 | Five to eight lines. This is the longest single derivation in the paper. Show the Viète step explicitly. |
| P17 | **Point doubling formula**. $\lambda = (3x_1^2 + a)(2y_1)^{-1}$ (tangent slope), formulas otherwise identical to addition. | Derivation | [15] §3.1 | Two lines. Derive tangent from implicit differentiation: $2y y' = 3x^2 + a$ → $y' = (3x^2+a)/(2y)$. |
| P18 | **Discriminant condition**. $\Delta = -16(4a^3 + 27b^2) \neq 0$ ensures non-singularity (no cusps or self-intersections). | Statement | [15] §3.1.1 | One sentence. The geometric meaning: three distinct roots of the cubic → smooth curve. |
| P19 | **Hasse's inequality**. $\bigl| |E(\mathbb{F}_q)| - (q+1) \bigr| \leq 2\sqrt{q}$. | Statement-only | [15] §3.4; [8] §6.1 | Full proof requires algebraic geometry (Hasse–Weil bound). State with reference. |

### §1.2.6 AES

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| P20 | **$\mathrm{GF}(2^8)$ field structure**. $\mathbb{F}_2[x]/(x^8+x^4+x^3+x+1)$; the polynomial $x^8+x^4+x^3+x+1$ is irreducible over $\mathbb{F}_2$. | Statement | [2] §4 | Irreducibility can be verified computationally (check no factor of degree ≤ 4). State as fact; reference [2] or the AES specification. |
| P21 | **$(\mathrm{GF}(2^8)^\times, \cdot)$ is cyclic of order 255**. Finite field multiplicative group is always cyclic (Gauss). Primitive element: 0x03. | Statement | [2] §4 | One sentence. The theorem is general; the specific primitive element 0x03 is from the Rijndael specification. |

---

## §2.1 Time Complexity

### RSA, DH, ElGamal

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C1 | **Square-and-multiply iteration count**. $k = \lfloor \log_2 d \rfloor + 1$ bits. MSB-first scan: $k-1$ squarings, expected $\sim (k-1)/2$ conditional multiplications. Total: $\frac{3}{2}k + O(1)$ mod-muls. | Calculation | [6] §14.6.1 | Derivation: each bit triggers one square; a '1' triggers an extra multiply. Expected ones = half the bits. |
| C2 | **Modular multiplication cost**. $b = \log_2 n$ bits. Schoolbook multiplication: $O(b^2)$. Modular reduction via division: $O(b^2)$. Total per mod-mul: $O((\log n)^2)$. | Calculation | [6] §14.1 | State the $O(b^2)$ bound; note that asymptotically faster algorithms exist (Karatsuba $O(b^{1.585})$) but schoolbook suffices for the analysis. |
| C3 | **RSA total time**. $T_{\text{RSA}} = O(\log n) \times O((\log n)^2) = O((\log n)^3)$. | Calculation | — | Product of iteration count and per-iteration cost. |
| C4 | **Encryption special case $e = 65537$**. 17 bits, 16 squarings + 1 conditional multiplication. $O((\log n)^2)$ — same asymptotic order but hundreds of times faster in practice. | Calculation | [6] §8.2 | One sentence. Important practical note. |

### DSA

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C5 | **DSA exponent vs modulus bit lengths**. Exponent $k \in \mathbb{F}_q$ ($\log q \approx 256$), modulus $p$ ($\log p \approx 2048$). Iterations: $O(\log q)$; mod-mul: $O((\log p)^2)$. Total: $O(\log q \cdot (\log p)^2)$. | Calculation | [13] §4 | . Since $\log q = O(\log p)$, this is $O((\log p)^3)$ asymptotically, but the constant factor is $\sim \frac{1}{8}$ of RSA's. |

### ECC

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C6 | **Double-and-add iteration count**. Analogous to square-and-multiply. $\frac{3}{2}\log_2 k$ point operations, $O(\log q)$. | Calculation | [15] §3.3 | Same binary expansion logic as RSA. |
| C7 | **Point operation cost (affine coordinates)**. Addition: 1 field inversion + 2 field multiplications. Doubling: 1 field inversion + 3 field multiplications. Field inversion $O((\log q)^2)$ via extended Euclidean. | Calculation | [15] §3.1.2 | Derive from the formulas in P16–P17. |
| C8 | **ECC total time**. $T_{\text{ECC}} = O(\log q) \times O((\log q)^2) = O((\log q)^3)$. | Calculation | — | Multiplication of iteration count and per-point cost. |
| C9 | **ECC vs RSA constant factors**. $(3072/256)^3 \approx 1728$ raw gap. Partially offset by $e=65537$ (RSA) and projective coordinates (ECC). Practical result: ECC ≈ 5–10× faster at equivalent security. | Calculation | [15] §5; [6] §8.4 | One paragraph explaining why the constant factor matters despite identical asymptotic order. |

### AES / Hash

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C10 | **AES per-block time**. Fixed round count (10/12/14) × fixed operations. $O(1)$ per block, $O(n)$ total. | Calculation | [2] §4 | Statement only. No derivation needed — round structure is described in §1.2.6. |
| C11 | **Hash per-block time (MD5, SHA-1, SHA-256)**. Merkle–Damgård with fixed step counts (64/80/64). $O(1)$ per block, $O(n)$ total. | Calculation | [6] §9 | Statement only. |

---

## §2.2 Security Complexity

### RSA / DH / DSA — Sub-Exponential Attacks

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C12 | **GNFS complexity for factorization**. $L_n[1/3, (64/9)^{1/3}] = \exp(1.923 (\ln n)^{1/3} (\ln \ln n)^{2/3})$. | Statement | [6] §3.2.7 | Define $L$-function notation: $L_n[\alpha, c] = \exp((c+o(1))(\ln n)^\alpha(\ln\ln n)^{1-\alpha})$. $\alpha=0$ → polynomial, $\alpha=1$ → exponential, $\alpha=1/3$ → sub-exponential. |
| C13 | **DLP-NFS**. Same $L_p[1/3, 1.923]$ complexity for DLP on $(\mathbb{Z}/p\mathbb{Z})^\times$. | Statement | [6] §3.6.5 | The GNFS variant for discrete logarithms. Same asymptotic form. |
| C14 | **Equivalent security: RSA/DH/DSA**. RSA-2048 ≈ 112 bits; RSA-3072 ≈ 128 bits (NIST SP 800-57). | Statement | [6] §8.2.2 | State the NIST equivalence. The exact mapping from $L_n$ to bits involves constant-factor estimates not derived in the paper. |

### ECC — Exponential Security

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C15 | **Pollard-$\rho$ for ECDLP**. $O(\sqrt{q})$ steps. Birthday paradox: in an $N$-element set, $\sqrt{N}$ random samples suffice for ≈ 1/2 collision probability. With $N = |E(\mathbb{F}_q)| \approx q$, security is $\frac{1}{2}\log_2 q$ bits. | Derivation | [15] §4.1.2 | Two paragraphs: (1) state the birthday bound $P \approx 1 - e^{-M^2/(2N)}$ → $M = \sqrt{N}$ gives $P \approx 0.39$; (2) Pollard-$\rho$ uses Floyd cycle detection → $O(1)$ space. The iterative function $f(X) = X + a_iP + b_iQ$ with three branches. |
| C16 | **MOV attack condition**. Supersingular curves ($q \mid q+1-|E|$) with small embedding degree $k \leq 6$ → ECDLP embeds into $\mathbb{F}_{q^k}^\times$ → GNFS sub-exponential. | Statement | [15] §4.2; [8] §6.4 | One paragraph. Standard curves (NIST, secp256k1) avoid supersingular parameters. |
| C17 | **Anomalous curve attack (Smart)**. $|E(\mathbb{F}_q)| = q$ → ECDLP solvable in polynomial time $O(\log^3 q)$ via $p$-adic lifting. | Statement | [8] §6.4; [15] §4.2 | One sentence. Reference for the $p$-adic number theory needed. Standard curves avoid this by parameter selection. |

### AES / Hash

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C18 | **Brute-force AES**. $O(2^k)$ for $k$-bit key. Biclique attack reduces AES-128 to $2^{126.1}$ (marginal). | Statement | [6] §7.2 | One sentence each. |
| C19 | **Birthday attack on hash functions**. $n$-bit output → collision in $\approx 2^{n/2}$ hashes. $P(\text{collision}) \approx 1 - e^{-M^2/(2N)}$, solve for $M = \sqrt{N}$. | Derivation | [6] §9.7.1 | Derive the birthday probability formula. Preimage resistance: $n$ bits (expect $2^n$ tries). Distinguish preimage from collision strength. |
| C20 | **MD5 broken** ($2^{39}$, Wang et al. EUROCRYPT 2005). **SHA-1 broken** ($2^{63}$, SHAttered 2017). **SHA-256 secure** ($2^{128}$, no known collision). | Statement | [6] §9.2; [7] §4 | Cite the published attacks by complexity number. No derivation of the attack methods. |

### Quantum Threat

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| C21 | **Shor's algorithm**. Solves integer factorization and DLP on abelian groups in polynomial quantum time. This unifies the threat to RSA, DH, ElGamal, DSA, and ECC. | Statement | [4] §6.2; [5] §6 | One paragraph. Frame this as the motivation for non-abelian group cryptography (§1.1.2). Reference [4] §6.2 for the HSP formulation and [5] for the accessible survey version. |
| C22 | **Grover's algorithm**. Halves effective key length: AES-256 → 128-bit quantum security. SHA-256 collision → 85-bit quantum security. | Statement | [4] §6.3 | One paragraph. Reference [4] and [5]. |
| C23 | **Non-abelian HSP**. CSP-based cryptography targets problems outside the scope of Shor's algorithm. The dihedral HSP (relevant to some lattice problems) has Kuperberg's sub-exponential algorithm, but general non-abelian HSP remains hard. | Statement | [4] §6.2–6.4 | One paragraph. Core message: non-abelian group cryptography is motivated by the quantum resistance of CSP. |

---

## §3 Experimental Testing

### §3.1 Hash Collision Demonstration

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| E1 | **MD4 collision generation**. Use public tool to produce $M_1 \neq M_2$ with $\text{MD4}(M_1) = \text{MD4}(M_2)$. Contrast with SHA-256 where the same messages produce different hashes. | Verification | — | Experimental. Describe the setup, report the hex hash values, note that the collision is known from the literature (Dobbertin 1996). |
| E2 | **SHA-1 collision (SHAttered)**. Reference the 2017 Google/CWI result: two distinct PDF files with identical SHA-1 hashes. Computational cost: $2^{63}$ SHA-1 compressions, ≈ 6500 CPU-years + 100 GPU-years. | Verification | [7] §9.2 | Statement only. Not reproduced in the paper — cited as evidence of SHA-1's practical break. |

### §3.2 Weak Parameter Attacks

| # | Item | Type | Citation | Notes |
|:--|:---|:---|:---:|:---|
| E3 | **Baby-step giant-step on small prime DLP**. Prime $p < 2^{20}$, generator $g$, target $h = g^a$. Baby steps: precompute $(g^j, j)$ for $j = 0,\ldots,m-1$ where $m = \lceil\sqrt{p}\rceil$. Giant steps: compute $h \cdot g^{-im}$ for $i = 0,\ldots,m-1$, table lookup for collision → $a = im + j$. | Verification | [6] §3.6.2 | Demonstrate numerically with e.g. $p = 100003$, $g=2$, a small $a$. Show that the attack succeeds in seconds; contrast with $p \approx 2^{2048}$ where $m \approx 2^{1024}$ → infeasible. |
| E4 | **Singular ECC curve attack**. $\Delta = 0$ → curve $y^2 = x^3$ (cusp) or $y^2 = x^2(x+a)$ (node). The ECDLP reduces to DLP in the additive or multiplicative group of $\mathbb{F}_q$. | Verification | [15] §4.2; [8] §6.4 | Demonstrate with a small singular curve. Show the isomorphism to $\mathbb{F}_q^+$ or $\mathbb{F}_q^\times$. One paragraph; formulas from [15] §4.2. |
| E5 | **Anomalous curve (Smart attack)**. $|E(\mathbb{F}_q)| = q$ → ECDLP solvable in $O(\log^3 q)$. | Statement | [8] §6.4 | Not reproduced — requires $p$-adic number theory. State the attack exists, reference [8], note that standard curves (NIST P-256, secp256k1) are verified non-anomalous. |

---

## §4 Conclusion

No new proofs. Summary only.

---

## Proofs Deferred to Literature (Not Reproduced in Paper)

These are too long or require background beyond the paper's scope. Stated as facts with citations.

| # | Claim | Reference | Reason |
|:--|:---|:---:|:---|
| D1 | Primitive root theorem: $(\mathbb{Z}/p\mathbb{Z})^\times$ cyclic of order $p-1$ | [8] §1.4 | Requires group theory / number theory beyond scope |
| D2 | ECC group law associativity (algebraic proof) | [15] §3.1.5 | ~150 lines of algebra; Bezout's theorem suffices for geometric intuition |
| D3 | Hasse's inequality full proof | [15] §3.4 | Requires algebraic geometry (Hasse–Weil bound) |
| D4 | GNFS algorithm details | [6] §3.2.7 | Entire monograph-length treatment |
| D5 | Pollard-$\rho$ rigorous complexity analysis | [6] §3.6.2 | Random walk + probabilistic analysis |
| D6 | MD5 collision attack (Wang's modular differential method) | [7] §9.2 | Attack-specific methodology, full paper required |
| D7 | SHA-1 SHAttered collision | Stevens et al. 2017 | Technical paper; reference only |
| D8 | Smart attack ($p$-adic lifting for anomalous curves) | [8] §6.4 | Requires $p$-adic number theory |
| D9 | MOV attack embedding-degree analysis | [15] §4.2 | Requires pairing-friendly curve theory |
| D10 | Shor's algorithm quantum circuit construction | [4] §6.2 | Quantum computing background beyond scope |
| D11 | Kuperberg's algorithm for dihedral HSP | [4] §6.3 | Quantum algorithm; reference only |
| D12 | AAG/Ko-Lee/Stickel complete security analysis | [4] §7.4; [3] §4 | Protocol-level cryptanalysis; full treatment in monographs |

---

## Summary: Items to Write into the Paper

| Section | Items | Nature |
|:---|---:|:---|
| §1.1.1 | P1, P3 | Proof sketch (DLP ⇒ DHP direction, Pohlig–Hellman decomposition) |
| §1.1.2 | P4–P8 | Proof sketches (CSP triviality, Ko-Lee/AAG/Stickel key derivation) |
| §1.2.1 RSA | P9, P11 | Proof (decryption correctness, $\varphi(n)$–factorization equivalence) |
| §1.2.2 DH/ElGamal | P12, P13 | Proof (key consistency, decryption correctness) |
| §1.2.3 DSA | P14, P15 | Proof (verification, nonce reuse leak) |
| §1.2.4 ECC | P16, P17 | Derivation (point addition, doubling formulas via Viète) |
| §1.2.6 AES | P20, P21 | Statement (GF(2^8) structure, cyclic multiplicative group) |
| §2.1 Time | C1–C11 | Calculation (iteration counts, mod-mul cost, total complexity) |
| §2.2 Security | C12–C23 | Derivation (birthday paradox for Pollard-$\rho$ + hash), Statement (GNFS, biclique, quantum) |
| §3 Testing | E1–E5 | Verification (collision demo, baby-step giant-step, singular curves) |

**Total: ~23 proof/calculation items to write, ~11 items deferred to external references.**
