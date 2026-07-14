---

title: "Proof Method Reference — Item-by-Item Guide"
date: 2026-07-14
---

# Proof Method Reference: Item-by-Item Guide

> Each item specifies the method for proof, derivation, or citation. Three-category labels follow the previous file: `[Derive]` / `[Sketch]` / `[Cite]`.

---

## §1.1.1 Abelian Groups — DHP / DLP

### P1 — DLP ⇒ DHP Direction `[Derive]`

**Method**: Assume $a = \log_g A$ is known (i.e., $g^a = A$). Given the public value $B = g^b$, compute the shared secret as $B^a = (g^b)^a = g^{ab}$. One line of algebra. The direction is "if DLP is solvable then DHP is solvable"; the converse is unproven but widely believed to hold in cyclic groups.

**Reference**: [6] §3.6 for the definition of DHP and its relationship to DLP.

---

### P2 — $(\mathbb{Z}/p\mathbb{Z})^\times$ Is Cyclic `[Cite]`

**Method**: State the conclusion: "The multiplicative group of a finite field is always cyclic; i.e., there exists a primitive root $g$ such that $(\mathbb{Z}/p\mathbb{Z})^\times = \{g^k : k = 0,\ldots,p-2\}$." Do not derive the primitive root theorem. Optionally state that the number of primitive roots is $\varphi(p-1)$.

**Reference**: [8] §1.4 (Koblitz, GTM 114 — proof of existence of primitive roots).

---

### P3 — Pohlig–Hellman Reduction `[Sketch]`

**Method**: Describe the three-step structure without full complexity analysis.

1. **Decompose**: Let $\operatorname{ord}(g) = \prod p_i^{e_i}$. Solve $a \bmod p_i^{e_i}$ independently for each prime-power factor.
2. **Reduce**: For each prime factor $p_i$, use $g^{|G|/p_i}$ to reduce the problem to a subgroup of order $p_i$, then solve via baby-step giant-step.
3. **Combine**: Reconstruct $a$ from the $a \bmod p_i^{e_i}$ via the Chinese Remainder Theorem.

Conclusion: If $\operatorname{ord}(g) = q$ is prime, step 1 solves directly on the full group with no reduction possible — complexity $O(\sqrt{q})$. This is the reason DH parameters require a prime-order subgroup.

**Reference**: [6] §3.6.4 for the complete algorithm and complexity analysis.

---

## §1.1.2 Non-Abelian Groups — CSP / Key Exchange

### P4 — CSP Is Trivial in Abelian Groups `[Derive]`

**Method**: If $G$ is abelian, then for all $g, x \in G$: $g^{-1}xg = g^{-1}gx = x$ (commutativity). Hence given $x$ and $y = g^{-1}xg$, we have $x = y$ — CSP is meaningless. Only in non-abelian groups, where $g^{-1}xg \neq x$ in general, does CSP constitute a search problem.

**Reference**: Direct derivation; no external reference needed.

---

### P5 — Braid Group $B_n$ Definition `[Derive]`

**Method**: State the generators $\sigma_1,\ldots,\sigma_{n-1}$ and the braid relations:
- $\sigma_i\sigma_j = \sigma_j\sigma_i$ for $|i-j| > 1$ (non-adjacent strands commute)
- $\sigma_i\sigma_{i+1}\sigma_i = \sigma_{i+1}\sigma_i\sigma_{i+1}$ for $|i-j| = 1$ (adjacent strands satisfy the braid relation)

Geometric intuition: $\sigma_i$ denotes crossing strand $i$ over strand $i+1$. The first relation states that separated crossings are independent; the second states that the order of adjacent crossings can "slide."

**Reference**: [4] §7.2 (full algebraic treatment of braid groups).

---

### P6 — Ko–Lee Key Exchange Principle `[Derive]`

**Method**: Choose two subgroups $A, B \subset B_n$ such that $[A,B] = 1$ ($ab = ba$ for all $a \in A, b \in B$). Publish a base element $w \in B_n$.

- Alice: secretly picks $a \in A$, sends $a^{-1}wa$
- Bob: secretly picks $b \in B$, sends $b^{-1}wb$
- Shared key: Alice computes $a^{-1}(b^{-1}wb)a$, Bob computes $b^{-1}(a^{-1}wa)b$

Because $a$ and $b$ come from mutually commuting subgroups: $a^{-1}b^{-1}wba = b^{-1}a^{-1}wab$ — both parties compute the same value. CSP assumption: from the public values $w$, $a^{-1}wa$, $b^{-1}wb$, an attacker cannot recover $a$ or $b$, and hence cannot derive the shared key.

**Reference**: [4] §7.4; [1] §3.

---

### P7 — AAG Key Exchange Principle `[Sketch]`

**Method**: Present a simplified two-generator version.

Alice secretly picks $a_1, a_2 \in B_n$, publishes $p_1 = a_1^{-1} w a_1$, $p_2 = a_2^{-1} w a_2$. Bob secretly picks $b_1, b_2$, publishes $q_1 = b_1^{-1} w b_1$, $q_2 = b_2^{-1} w b_2$.

Alice conjugates Bob's public values with her own secrets: $a_1^{-1} q_1 a_1$, $a_2^{-1} q_2 a_2$. Bob does the same with his set. Because each party's secret generators ($a_1,a_2$ vs $b_1,b_2$) belong to different freely-generated subsets (and the non-abelian nature of the braid group prevents cross-conjugation from commuting), both parties derive a shared element through their respective conjugation passes.

**Reference**: [4] §7.4 for the complete protocol and security analysis; [3] §4.

---

### P8 — Stickel Key Exchange `[Cite]`

**Method**: State the concept — a key exchange scheme based on specific commuting matrix pairs in a matrix group. Do not present protocol details.

**Reference**: [1] §4.

---

## §1.2.1 RSA

### P9 — Decryption Correctness `[Derive]`

**Method**:
1. Parameter relation: $e d \equiv 1 \pmod{\varphi(n)}$, i.e., there exists an integer $t$ with $ed = 1 + t\varphi(n)$.
2. Euler's theorem: $m^{\varphi(n)} \equiv 1 \pmod{n}$ (for $\gcd(m,n)=1$).
3. Substitute:
   $$c^d \equiv (m^e)^d = m^{ed} = m^{1 + t\varphi(n)} = m \cdot (m^{\varphi(n)})^t \equiv m \cdot 1^t = m \pmod{n}$$

**Reference**: [6] §8.2 (complete mathematical derivation of RSA); [7] §5.

---

### P10 — $\varphi(n) = (p-1)(q-1)$ `[Cite]`

**Method**: State the formula. The multiplicativity of Euler's totient ($\varphi(pq)=\varphi(p)\varphi(q)$ when $\gcd(p,q)=1$) and the prime value ($\varphi(p)=p-1$) can be given in one sentence, citing [8].

**Reference**: [8] §2 (basic properties of Euler's totient function).

---

### P11 — $\varphi(n)$–Factorization Equivalence `[Derive]`

**Method**: Given $n = pq$ and $\varphi(n) = (p-1)(q-1)$. Expand:
$$\varphi(n) = pq - p - q + 1 = n - (p+q) + 1$$
Solve for $p+q = n - \varphi(n) + 1$. Hence $p,q$ are the two roots of the quadratic $x^2 - (n - \varphi(n) + 1)x + n = 0$. Knowledge of $\varphi(n)$ → recover $p,q$ → factor $n$.

**Reference**: [6] §8.2.1.

---

## §1.2.2 DH / ElGamal

### P12 — DH Key Agreement Consistency `[Derive]`

**Method**: Alice computes $B^a = (g^b)^a = g^{ba}$. Bob computes $A^b = (g^a)^b = g^{ab}$. By commutativity of integer multiplication, $ab = ba$, hence $g^{ab} = g^{ba}$ — both parties obtain the same group element.

**Reference**: [6] §3.1 (definition of the DH protocol).

---

### P13 — ElGamal Decryption Correctness `[Derive]`

**Method**: Ciphertext $(c_1, c_2) = (g^y, m \cdot h^y)$, where $h = g^x$. Decryption:
$$c_2 \cdot (c_1^x)^{-1} = m \cdot h^y \cdot (g^{xy})^{-1} = m \cdot g^{xy} \cdot g^{-xy} = m$$
The cancellation of group elements relies on the exponent law $g^{xy} = (g^y)^x = (g^x)^y$.

**Reference**: [7] §5.1 (complete description of the ElGamal encryption scheme).

---

## §1.2.3 DSA

### P14 — DSA Verification Correctness `[Derive]`

**Method**: The verifier computes $u_1 = H(m)s^{-1} \bmod q$, $u_2 = rs^{-1} \bmod q$. Expand:
$$
g^{u_1} y^{u_2} = g^{H(m)s^{-1}} \cdot (g^x)^{rs^{-1}} = g^{(H(m) + xr)s^{-1}} \pmod{p}
$$
From the signing definition $s = k^{-1}(H(m) + xr) \bmod q$, we have $s^{-1} \equiv k(H(m) + xr)^{-1} \pmod{q}$. Substituting gives $g^{(H(m)+xr) \cdot k(H(m)+xr)^{-1}} = g^k \pmod{p}$. Reduction modulo $q$ yields $(g^k \bmod p) \bmod q = r$, matching the signature component.

**Reference**: [13] §4 (FIPS 186-5 verification procedure).

---

### P15 — Nonce Reuse Leaks the Private Key `[Derive]`

**Method**: Suppose two signatures $(r, s_1)$ (message $m_1$) and $(r, s_2)$ (message $m_2$) use the same $k$ (hence $r = (g^k \bmod p) \bmod q$ is identical). From the signing equations:
$$s_1 = k^{-1}(H(m_1) + xr) \bmod q, \quad s_2 = k^{-1}(H(m_2) + xr) \bmod q$$
Subtract: $s_1 - s_2 = k^{-1}(H(m_1) - H(m_2)) \bmod q$. Solve:
$$k = (H(m_1) - H(m_2))(s_1 - s_2)^{-1} \bmod q$$
After recovering $k$, extract $x$ from either signature equation: $x = r^{-1}(ks_1 - H(m_1)) \bmod q$.

**Reference**: [13] Appendix (FIPS 186-5 nonce requirements).

---

## §1.2.4 ECC

### P16 — Point Addition Formula Derivation `[Derive]`

**Method**: Curve $E: y^2 = x^3 + ax + b$ over $\mathbb{F}_q$ ($\operatorname{char} \neq 2, 3$). Let $P_1 = (x_1, y_1)$, $P_2 = (x_2, y_2)$, with $P_1 \neq \pm P_2$.

1. **Slope**: The line through the two points has slope $\lambda = (y_2 - y_1)(x_2 - x_1)^{-1}$.
2. **Line equation**: $y = \lambda(x - x_1) + y_1$.
3. **Substitute into the curve**:
   $$(\lambda(x - x_1) + y_1)^2 = x^3 + ax + b$$
   Expand: $\lambda^2(x-x_1)^2 + 2\lambda y_1(x-x_1) + y_1^2 = x^3 + ax + b$.
4. **Rearrange into a cubic in $x$**:
   $$x^3 - \lambda^2 x^2 + (a - 2\lambda^2 x_1 + 2\lambda y_1 - \cdots)x + \cdots = 0$$
   The three roots are $x_1, x_2, x_3'$ (where $x_3'$ is the $x$-coordinate of the third intersection).
5. **Viète's formula**: For a cubic $x^3 + Ax^2 + Bx + C = 0$, the sum of the three roots equals $-A$. Here $A = -\lambda^2$, so $x_1 + x_2 + x_3' = \lambda^2$. Hence $x_3' = \lambda^2 - x_1 - x_2$.
6. **$y$-coordinate**: $y_3' = \lambda(x_3' - x_1) + y_1$.
7. **Reflection**: $P_1 + P_2 = (x_3, y_3)$, where $x_3 = x_3'$ and $y_3 = \lambda(x_1 - x_3) - y_1$ (reflection across the $x$-axis: $y_3 = -y_3'$, simplified to this form).

**Reference**: [15] §3.1 (Hankerson–Menezes–Vanstone, complete derivation); [8] §6.1.

---

### P17 — Point Doubling Formula Derivation `[Derive]`

**Method**: When $P_1 = P_2$, replace the chord slope with the tangent slope. Implicit differentiation of $y^2 = x^3 + ax + b$:
$$2y \frac{dy}{dx} = 3x^2 + a \quad \Rightarrow \quad \frac{dy}{dx} = \frac{3x^2 + a}{2y}$$
Thus the tangent slope is $\lambda = (3x_1^2 + a)(2y_1)^{-1}$. The subsequent formulas match P16: $x_3 = \lambda^2 - 2x_1$, $y_3 = \lambda(x_1 - x_3) - y_1$.

**Reference**: [15] §3.1.2.

---

### P18 — Discriminant Condition `[Cite]`

**Method**: State $\Delta = -16(4a^3 + 27b^2)$. If $\Delta = 0$, the curve has a singularity (cusp or node) → ECDLP reduces to DLP in $\mathbb{F}_q^+$ or $\mathbb{F}_q^\times$. If $\Delta \neq 0$, the curve is non-singular and suitable for cryptography.

**Reference**: [15] §3.1.1 (geometric meaning of the discriminant).

---

### P19 — Hasse's Inequality `[Cite]`

**Method**: State the inequality: $| |E(\mathbb{F}_q)| - (q+1) | \leq 2\sqrt{q}$. Geometric meaning: the number of points on an elliptic curve over $\mathbb{F}_q$ is approximately $q+1$, with error bounded by $2\sqrt{q}$. Proved by Hasse (1936); requires algebraic geometry background.

**Reference**: [15] §3.4 (statement and application of the inequality); [8] §6.1 (Hasse–Weil bound).

---

## §1.2.6 AES

### P20 — $\mathrm{GF}(2^8)$ Field Structure `[Sketch]`

**Method**: The field is defined as $\mathbb{F}_2[x]/(m(x))$, where $m(x) = x^8 + x^4 + x^3 + x + 1$. State that $m(x)$ is irreducible over $\mathbb{F}_2$ (can be verified by checking all factors of degree $\leq 4$; do not show the verification). Field elements are polynomials with coefficients in $\mathbb{F}_2$ and degree $< 8$ (total $2^8 = 256$ elements). Addition is polynomial addition (bitwise XOR); multiplication is polynomial multiplication followed by reduction modulo $m(x)$.

**Reference**: Daemen & Rijmen, *The Design of Rijndael: AES — The Advanced Encryption Standard*, Springer, 2002, §3 (the official AES specification defining $\mathrm{GF}(2^8)$ and the irreducible polynomial). Also [6] §7.4 for a textbook treatment of AES finite-field arithmetic.

---

### P21 — $(\mathrm{GF}(2^8)^\times, \cdot)$ Is Cyclic of Order 255 `[Cite]`

**Method**: State Gauss's theorem: the multiplicative group of any finite field is cyclic. Hence $\mathrm{GF}(2^8)^\times$ is a cyclic group of order 255. The primitive element $\texttt{0x03}$ (corresponding to the polynomial $x+1$) generates the entire multiplicative group: $\{ \texttt{0x03}^k : k = 0,\ldots,254 \} = \mathrm{GF}(2^8)^\times$.

**Reference**: Cyclicity of finite field multiplicative groups — see any abstract algebra textbook; AES primitive element $\texttt{0x03}$ — see the Rijndael specification (Daemen & Rijmen 2002).

---

## §2.1 Time Complexity

### C1 — Square-and-Multiply Iteration Count `[Derive]`

**Method**: $d = (b_{k-1}\ldots b_1 b_0)_2$, $k = \lfloor \log_2 d \rfloor + 1$. The algorithm scans MSB to LSB:
- $b_{k-1}=1$ (MSB is always 1): initialize $R \leftarrow m$ (0 squarings, 1 multiplication).
- Remaining $k-1$ bits: each bit triggers $R \leftarrow R^2$ (1 squaring); if $b_i = 1$, then $R \leftarrow R \cdot m$ (conditional multiplication).
- Expected number of 1-bits: $\frac{k-1}{2}$. Total: $k-1$ squarings, $\frac{k-1}{2} + 1$ conditional multiplications. Sum: $\frac{3}{2}(k-1) + 1 \approx \frac{3}{2}k$ modular multiplications.

**Reference**: [6] §14.6.1 (description of square-and-multiply).

---

### C2 — Cost per Modular Multiplication `[Derive]`

**Method**: $b = \log_2 n$ bits. Schoolbook multiplication: $b$-bit $\times$ $b$-bit → $2b$-bit product, each of $b$ rows requires $b$ bit-multiplications → $b^2$ elementary operations. Modular reduction $\bmod n$: via division, same order (or Barrett/Montgomery reduction, also $O(b^2)$). Hence each modular multiplication costs $O((\log n)^2)$.

**Reference**: [6] §14.1 (complexity analysis of multi-precision arithmetic).

---

### C3 — RSA Total Time `[Derive]`

**Method**: $T_{\text{RSA}} = (\text{mod-mul count}) \times (\text{cost per mod-mul}) = O(\log n) \times O((\log n)^2) = O((\log n)^3)$.

**Reference**: Direct combination of C1 and C2.

---

### C4 — $e = 65537$ Special Case `[Derive]`

**Method**: $65537 = 2^{16} + 1$ (17 bits, binary `10000000000000001`). Square-and-multiply: 16 squarings (1 per bit) + 2 conditional multiplications (only two 1-bits). Approximately 18 modular multiplications — compared to $3k/2 \approx 3072$ for decryption ($k=2048$) — encryption is ~170× faster than decryption.

**Reference**: [6] §8.2 (discussion of public exponent selection).

---

### C5 — DSA Dual-Modulus Complexity `[Derive]`

**Method**: Exponents $k, u_1, u_2$ live in $\mathbb{F}_q$ ($\log_2 q \approx 256$). Square-and-multiply iteration count for the modular exponentiation is $O(\log q)$. However, each modular multiplication operates on $\log p$-bit integers ($\log_2 p \approx 2048$), costing $O((\log p)^2)$. Hence total time $O(\log q \cdot (\log p)^2)$. Since $\log q = O(\log p)$, the overall order is $O((\log p)^3)$, but the iteration count is only $\frac{1}{8}$ of RSA's.

**Reference**: [13] §4 (DSA parameter sizes).

---

### C6 — Double-and-Add Iteration Count `[Derive]`

**Method**: Scalar multiplication $Q = kP$ is fully analogous to square-and-multiply. $k = \sum b_i 2^i$, scan MSB→LSB, double at each bit ($R \leftarrow 2R$), conditionally add $P$ when the bit is 1 ($R \leftarrow R + P$). $\frac{3}{2}\log_2 k$ point operations, $O(\log q)$.

**Reference**: [15] §3.3 (double-and-add algorithm for scalar multiplication).

---

### C7 — Point Operation Cost (Affine Coordinates) `[Derive]`

**Method**: Count operations directly from the point addition and doubling formulas in P16–P17:
- Point addition (P16): computing $\lambda$ requires 1 field inversion + 1 field multiplication; computing $x_3, y_3$ requires 1 field multiplication. Total: 1 inversion + 2 field multiplications.
- Point doubling (P17): computing $\lambda$ requires 1 field inversion + 1 squaring (equivalent to a field multiplication); computing $x_3, y_3$ requires 1 field multiplication + 1 squaring. Total: 1 inversion + 3 field multiplications.
- Field multiplication cost: $O((\log q)^2)$ (same as integer multiplication in C2). Field inversion via extended Euclidean algorithm: also $O((\log q)^2)$.

**Reference**: [15] §3.1.2 (operation count analysis).

---

### C8 — ECC Total Time `[Derive]`

**Method**: $T_{\text{ECC}} = (\text{point operation count}) \times (\text{cost per point op}) = O(\log q) \times O((\log q)^2) = O((\log q)^3)$.

**Reference**: Direct combination of C6 and C7.

---

### C9 — ECC vs RSA Constant Factors `[Derive]`

**Method**: $(\frac{3072}{256})^3 \approx 1728$ is the raw $\log$-cubed ratio. The following factors narrow the gap:
- RSA encryption uses $e = 65537$ (17 bits, iteration count only $O((\log n)^2)$).
- ECC can use Jacobian projective coordinates to replace field inversions with multiplications (~10 field multiplications per point operation instead of 1 inversion).
- Practical benchmarks: [15] §5 reports ECC-256 signing approximately $5$–$10\times$ faster than RSA-3072 signing.

**Reference**: [15] §5 (ECC performance benchmarks); [6] §8.4 (RSA performance benchmarks).

---

### C10 — AES $O(1)$ per Block `[Derive]`

**Method**: Round count is fixed (AES-128: 10, AES-192: 12, AES-256: 14). Each round: SubBytes (16 S-box lookups) + ShiftRows (16-byte rearrangement) + MixColumns (16-byte GF multiplication) + AddRoundKey (16 XORs) — all fixed counts. $n$ blocks: $n \times O(1) = O(n)$.

**Reference**: Daemen & Rijmen, *The Design of Rijndael*, Springer, 2002, §4 (round structure and operation counts); [6] §7.4 (textbook complexity discussion for AES).

---

### C11 — Hash $O(1)$ per Block `[Derive]`

**Method**: MD5 (64 steps), SHA-1 (80 steps), SHA-256 (64 steps). Each step is a fixed operation (modular $2^{32}$ addition + bitwise ops + rotations). Blocks × steps per block × time per step → $O(n)$.

**Reference**: [6] §9.

---

## §2.2 Security Complexity

### C12 — GNFS Complexity `[Sketch]`

**Method**: Define the $L$-function: $L_n[\alpha, c] = \exp((c + o(1)) (\ln n)^\alpha (\ln \ln n)^{1-\alpha})$.
- $\alpha = 0$: $(\ln n)^c$ — polynomial time.
- $\alpha = 1/3$: $(\ln n)^{1/3} (\ln \ln n)^{2/3}$ — sub-exponential (faster than exponential, slower than polynomial).
- $\alpha = 1$: $c\ln n$ — exponential time $n^c$.

GNFS takes $\alpha = 1/3$, $c = (64/9)^{1/3} \approx 1.923$:
$$L_n[1/3, 1.923] = \exp(1.923 (\ln n)^{1/3} (\ln \ln n)^{2/3})$$

**Reference**: [6] §3.2.7 ($L$-function formulation of GNFS and constant derivation).

---

### C13 — DLP-NFS `[Cite]`

**Method**: State: DLP is also solvable via a GNFS variant (the NFS for discrete logarithms), with complexity $L_p[1/3, 1.923]$ (same sub-exponential order as factorization). Do not expand on the algorithmic differences.

**Reference**: [6] §3.6.5 (NFS variant for discrete logarithms).

---

### C14 — Equivalent Security Bits (NIST) `[Cite]`

**Method**: Directly cite the NIST SP 800-57 equivalent security mapping:
- RSA-2048 / DH-2048 / DSA-2048 → $\approx 112$ bits
- RSA-3072 → $128$ bits
- ECC-256 → $128$ bits

These are NIST's estimates based on the complexity of GNFS and Pollard-$\rho$, involving constant-factor estimation. Do not derive.

**Reference**: [6] §8.2.2 (key-length comparison table based on NIST SP 800-57).

---

### C15 — Pollard-$\rho$ + Birthday Paradox `[Derive]`

**Method**:

**Birthday paradox**: Drawing $M$ samples with replacement from a set of $N$ elements. Probability that all samples are distinct:
$$P(\text{all distinct}) = \prod_{i=1}^{M-1} \left(1 - \frac{i}{N}\right) \approx e^{-M^2/(2N)}$$
(Using $\ln(1-x) \approx -x$ and $\sum_{i=1}^{M-1} i = M(M-1)/2 \approx M^2/2$). Collision probability $P(\text{collision}) \approx 1 - e^{-M^2/(2N)}$. Setting $M = \sqrt{N}$ gives $P \approx 1 - e^{-1/2} \approx 0.39$. Exact value: $M \approx 1.18\sqrt{N}$ reaches $P = 1/2$.

**Pollard-$\rho$**: Construct an iteration function $f(X) = X + a_i P + b_i Q$ in the group $G$, where $(a_i, b_i)$ is selected from a few branches based on a few bits of $X$ (typically 3 branches). The random walk $X_0, X_1 = f(X_0), X_2 = f(X_1), \ldots$ collides $X_i = X_j$ after $\approx \sqrt{|G|}$ steps. Upon collision: $a_i P + b_i Q = a_j P + b_j Q$ → $(a_i - a_j)P = (b_j - b_i)Q = (b_j - b_i)kP$ → $k = (a_i - a_j)(b_j - b_i)^{-1} \bmod |G|$. Floyd's cycle-finding algorithm ($O(1)$ extra space) uses two pointers (speed ratio 1:2) to detect the cycle.

$|E(\mathbb{F}_q)| \approx q$ (Hasse, P19), so $T_{\text{Pollard-}\rho} = O(\sqrt{q})$. Security bits $= \frac{1}{2}\log_2 q$.

**Reference**: [15] §4.1.2 (Pollard-$\rho$ for ECDLP); [6] §3.6.2 (Pollard-$\rho$ for general DLP).

---

### C16 — MOV Attack `[Cite]`

**Method**: State the condition and conclusion. If $E(\mathbb{F}_q)$ is supersingular, the embedding degree $k \leq 6$. The MOV attack uses the Weil pairing to embed the ECDLP into a DLP on $\mathbb{F}_{q^k}^\times$, then solves via GNFS (sub-exponential $L_{q^k}[1/3, 1.923]$). Hence supersingular curves are unusable in cryptography. Standard curves (NIST P-256, secp256k1) are non-supersingular with large $k$ → MOV attack infeasible.

**Reference**: [15] §4.2 (MOV attack conditions and impact); [8] §6.4.

---

### C17 — Smart Attack (Anomalous Curves) `[Cite]`

**Method**: State the condition and conclusion. If $|E(\mathbb{F}_q)| = q$ (an anomalous curve), Smart's attack lifts the curve to the $p$-adic domain and converts the ECDLP into solving a linear equation, achievable in polynomial time $O(\log^3 q)$. Hence anomalous curves are unusable in cryptography. All standard curves are verified non-anomalous ($|E| \neq q$) through parameter selection.

**Reference**: [8] §6.4 (mathematical description of Smart's attack).

---

### C18 — AES Brute Force $O(2^k)$ `[Derive]`

**Method**: AES key length is $k$ bits ($k \in \{128, 192, 256\}$). Key space size is $2^k$. Exhaustive search in the worst case tries all $2^k$ keys → time $O(2^k)$. The Biclique attack exploits key-schedule structure to reduce AES-128 to $2^{126.1}$ (difference $< 2$ bits, negligible practical impact).

**Reference**: [6] §7.2 (symmetric key sizes and security strength comparison).

---

### C19 — Hash Birthday Attack Derivation `[Derive]`

**Method**: An $n$-bit hash output has a value space of size $N = 2^n$. From the birthday paradox derivation in C15, a collision requires $\approx \sqrt{N} = 2^{n/2}$ random attempts. Exhaustive preimage attack requires $\approx 2^n$ attempts (target hash value is fixed → expect one hit per $2^n$ tries). Hence an $n$-bit hash provides collision resistance $\leq n/2$ bits and preimage resistance $= n$ bits.

**Reference**: [6] §9.7.1 (birthday attack on hash functions).

---

### C20 — MD5 / SHA-1 / SHA-256 Status `[Cite]`

**Method**: Directly cite the published attack complexity numbers:
- MD5: collision at $2^{39}$ (Wang & Yu, EUROCRYPT 2005).
- SHA-1: collision at $2^{63}$ (SHAttered, Stevens et al. 2017).
- SHA-256: no known collision attack beating the birthday bound of $2^{128}$ → secure.

**Reference**: [7] §9.2 (attacks on MD5 and SHA-1); [6] §9.2 (security status of SHA-256).

---

### C21 — Shor's Algorithm `[Cite]`

**Method**: State the core conclusion without presenting quantum circuits or algorithmic details. Shor's algorithm (1994) uses the quantum Fourier transform to reduce integer factorization and DLP to instances of the Hidden Subgroup Problem (HSP) on abelian groups ($\mathbb{Z}$ and cyclic groups). Abelian HSP is solvable in polynomial quantum time. Consequently, all cryptosystems built on integer factorization or abelian-group DLP (RSA, DH, ElGamal, DSA, ECC) are insecure against a large-scale fault-tolerant quantum computer. This is the fundamental motivation for non-abelian group cryptography in §1.1.2.

**Reference**: [4] §6.2 (HSP framework and group-theoretic formulation of Shor's algorithm); [5] §6 (accessible survey of Shor's algorithm).

---

### C22 — Grover's Algorithm `[Cite]`

**Method**: State the conclusion. Grover's algorithm (1996) provides a quadratic speedup for unstructured search: finding a target element in a space of $N$ items reduces from classical $O(N)$ to quantum $O(\sqrt{N})$. Applied to cryptography:
- AES-256: classical brute force $2^{256}$ → quantum $2^{128}$ (still infeasible).
- SHA-256 collision: classical birthday $2^{128}$ → quantum $2^{85}$ (potentially concerning).

Grover does not provide an exponential speedup (unlike Shor), so AES-256 and SHA-256 retain partial security in the quantum era — but key/hash lengths must double to maintain equivalent security.

**Reference**: [4] §6.3 (impact of Grover's algorithm on cryptography); [5] §6.

---

### C23 — Non-Abelian HSP `[Cite]`

**Method**: State the core conclusions. The Hidden Subgroup Problem (HSP) is the intersection of group theory and quantum algorithms. Abelian HSP is efficiently solvable by Shor's algorithm → classical public-key cryptography is broken. The quantum complexity of non-abelian HSP is an open problem:
- The dihedral HSP admits Kuperberg's sub-exponential quantum algorithm.
- No polynomial quantum algorithm is known for general non-abelian groups.

The security of CSP and braid-group key exchange rests on the absence of a universal solver for non-abelian groups. This makes non-abelian group cryptography a candidate direction for post-quantum cryptography.

**Reference**: [4] §6.2–6.4 (transition from abelian to non-abelian HSP and current state); [5] §6.

---

## §3 Experimental Testing

### E1 — MD4 Collision Generation `[Derive]`

**Method**: Use a publicly available MD4 collision tool (implementing Wang's modular differential method). Input two distinct messages $M_1$ and $M_2$; MD4 compression produces identical hash values $H(M_1) = H(M_2)$ (display hex output). Run SHA-256 on the same message pair → outputs differ: $H'(M_1) \neq H'(M_2)$. Comparison table: MD4 (collision holds) vs SHA-256 (collision does not hold).

**Reference**: MD4 collisions were first demonstrated by Dobbertin (1996); public collision tools are based on Wang's method. SHA-256 comparison is verified by any standard implementation.

---

### E2 — SHA-1 SHAttered `[Cite]`

**Method**: Reference the SHAttered collision published by Stevens et al. (Google & CWI Amsterdam, 2017): two visually distinct PDF files (shattered-1.pdf and shattered-2.pdf) share the same SHA-1 hash. Computational cost: $2^{63}$ SHA-1 compressions, ≈ 6500 CPU-years + 100 GPU-years. Do not execute the attack.

**Reference**: Stevens, Bursztein, Karpman, Albertini, Markov — "The First Collision for Full SHA-1" (CRYPTO 2017).

---

### E3 — Baby-Step Giant-Step on Small Prime DLP `[Derive]`

**Method**:

**Parameters**: Select a small prime $p < 2^{20}$ (e.g., $p = 100003$), generator $g = 2$ (verify that $2$ is a primitive root modulo $p$), target $h = g^a \bmod p$ ($a$ unknown).

**Baby Steps**: Let $m = \lceil \sqrt{p} \rceil$. Precompute and store $(g^j \bmod p, j)$ for $j = 0, 1, \ldots, m-1$ in a hash table for $O(1)$ lookup.

**Giant Steps**: Compute $g^{-m} \bmod p$. For $i = 0, 1, \ldots, m-1$, compute $h \cdot (g^{-m})^i \bmod p$ and look up the result in the baby-step table. A collision occurs at $(i,j)$ satisfying $h \cdot g^{-im} = g^j$, i.e., $g^{a-im} = g^j$ → $a \equiv im + j \pmod{p-1}$.

**Complexity**: $O(m) = O(\sqrt{p})$ group operations and $O(\sqrt{p})$ space. $p \approx 10^5$ → $m \approx 317$ → solved in seconds. $p \approx 2^{2048}$ → $m \approx 2^{1024}$ → infeasible.

**Reference**: [6] §3.6.2 (description of the baby-step giant-step algorithm).

---

### E4 — Singular ECC Curve `[Sketch]`

**Method**: Select a singular curve $E: y^2 = x^3$ ($\Delta = 0$, cusp at $(0,0)$). The ECDLP on this curve is trivialized as follows:

In the cusp case, the map $(x,y) \mapsto x/y$ (for $y \neq 0$) gives an isomorphism $E \setminus \{(0,0)\} \cong \mathbb{F}_q^+$ (the additive group). Hence ECDLP translates to DLP in the additive group: given $P$ and $kP$, corresponding to $t$ and $kt$ in $\mathbb{F}_q^+$ → $k = kt / t$ (solvable in $\mathbb{F}_q$).

Use a small $q$ (e.g., $q = 101$) for demonstration: list curve points → show the isomorphism map → manually solve ECDLP with small parameters.

**Reference**: [15] §4.2 (reduction of ECDLP on singular curves); [8] §6.4.

---

### E5 — Smart Attack (Anomalous Curves) `[Cite]`

**Method**: State the definition of an anomalous curve ($|E(\mathbb{F}_q)| = q$) and the conclusion of Smart's attack: the ECDLP can be converted to a linear equation in $\mathbb{F}_q^+$ (by lifting the curve to the $p$-adic domain $\mathbb{Q}_q$, where the addition law degenerates to the logarithm map of a formal group), solvable in $O(\log^3 q)$ time. The principle of the attack involves $p$-adic analysis and formal group theory, beyond the scope of this paper. All standard curves are verified to satisfy $|E(\mathbb{F}_q)| \neq q$ during parameter selection.

**Reference**: [8] §6.4 (complete mathematical derivation of Smart's attack); [15] §4.2 (attack conditions and implications for standard curves).
