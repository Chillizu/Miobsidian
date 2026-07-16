## Hash Collisions in the MD4 and SHA-1 Constructions

A significant class of non-group-based cryptographic primitives follows the ARX design paradigm, which exclusively uses modular addition, bitwise rotation, and XOR. Hash functions such as MD4, MD5, SHA-1, and SHA-2 all belong to this family.

### MD4 collision

For a secure $n$-bit hash function, the birthday bound dictates that a collision can be found in $2^{n/2}$ trials. This serves as the baseline against which any practical attack must be measured.

Unlike group-based cryptosystems whose security rests on the hidden order of a finite abelian group (e.g., RSA-like schemes), MD4 operates on a 32-bit long binary data using bitwise AND, OR, XOR, bit rotations and integer addition modulo $2^{32}$. Its security relies entirely on these bitwise operations and modular carries — a chaotic ecosystem that proved weakness against precise differential manipulation at last.

The problem is that addition modulo $2^{32}$ has a fully deterministic difference propagation:
$$\Delta(x+y)\equiv\Delta x+\Delta y\pmod{2^{32}},$$
where $\Delta$ denotes the integer difference modulo $2^{32}$. This means when two numbers are added, the extra bits from each position always move one step up to the next higher position, and this movement is predictable — we can calculate exactly where they go. So the difference of the sum is always just the sum of the differences — a linear structure.

In a sound design, Boolean operations (AND/OR/XOR) would break this linear structure and create an unpredictable avalanche effect. In MD4, however, they fail to do so — they can only set local bit conditions, but cannot remove the linear backbone. Once an attacker satisfies those conditions, the compression function reduces to a linear system over the abelian group, and collisions can be constructed directly.[^1]

### SHA-1 collision

SHA-1 uses the same ARX pattern as MD4, but with an 80-step compression function and a more complex message expansion. Despite these added complexities, the best known collision attack still only costs $2^{63.1}$ — far below the $2^{80}$ birthday bound for a 160-bit hash.

This large gap is consistent with the MD4 analysis: the extra rounds and message expansion did not fix the real problem. The Boolean layer remains too weak to break the linear structure of addition, so the vulnerability stays.[^2]

## Use Inappropriate Parameters to Test Asymmetric Ciphers

### Small primes (DLP)

The discrete logarithm problem (DLP) underlies cryptographic systems such as Diffie–Hellman key exchange[^3]. The problem can be stated as follows: given a prime $p$, a base element $g$, and a number $h$, find an integer $x$ such that
$$g^x\equiv h\pmod p.$$
For sufficiently large $p$, the computational infeasibility of this problem underpins the security of the corresponding protocols.

However, how hard DLP is depends entirely on the prime $p$ you pick — how big it is and how $p-1$ factors into smaller primes. If a small prime is chosen (e.g., 32 bits), the problem can be solved almost instantly using algorithms such as baby-step giant-step ($O(\sqrt{p})$) or, if $p-1$ is smooth, the Pohlig–Hellman algorithm[^4][^5]. This demonstrates that the security of DLP is not an intrinsic property of the problem itself, but rather a consequence of parameter selection.

### Weak ECC curves (anomalous)

Elliptic curve cryptography (ECC) is based on the elliptic curve discrete logarithm problem (ECDLP): given two points $P$ and $Q$ on a curve, find $m$ such that $Q=mP$. For properly chosen curves, this is computationally infeasible.

However, the security of ECC depends critically on the choice of curve parameters. A curve is called anomalous if it has exactly $p$ points — a case that looks safe at first because standard attacks are too slow for large $p$. But Smart showed that these curves can be broken almost instantly, no matter how large $p$ is. This is another example of the same principle: security depends on choosing the right parameters, not on the problem itself.[^6]


---
## References
[^1]: [Cryptanalysis of the Hash Functions MD4 and RIPEMD](https://iacr.org/archive/eurocrypt2005/34940001/34940001.pdf)
[^2]: [The first collision for full SHA-1](https://shattered.io/static/shattered.pdf)
[^3]: [New directions in cryptography](https://doi.org/10.1109/TIT.1976.1055638)
[^4]: [Optimized baby step-giant step methods](https://zbmath.org/1122.11086)
[^5]: [An improved algorithm for computing logarithms overGF(p)and its cryptographic significance](https://doi.org/10.1109/TIT.1978.1055817)
[^6]: [The Discrete Logarithm Problem on Elliptic Curves of Trace One](https://doi.org/10.1007/s001459900052)
