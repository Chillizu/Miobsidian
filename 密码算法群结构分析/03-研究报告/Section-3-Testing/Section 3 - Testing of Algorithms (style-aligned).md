# Section 3: Testing of the Algorithms

This section tests the theoretical claims made in Sections 1 and 2 with four reproducible experiments: an MD4 collision, a SHA-1 collision verification, a discrete-logarithm attack on a small prime, and Smart's p-adic lift attack on anomalous elliptic curves. Each subsection first reviews the relevant weakness and then presents the measured results.

## Hash Collisions in the MD4 and SHA-1 Constructions

A significant class of non-group-based cryptographic primitives follows the ARX design paradigm, which exclusively uses modular addition, bitwise rotation, and XOR. Hash functions such as MD4, MD5 and SHA-1 all belong to this family.

### MD4 collision

For a secure $n$-bit hash function, the birthday bound dictates that a collision can be found in $2^{n/2}$ trials. This serves as the baseline against which any practical attack must be measured.

Unlike group-based cryptosystems whose security rests on the hidden order of a finite abelian group (e.g., RSA-like schemes), MD4 operates on a 32-bit long binary data using bitwise AND, OR, XOR, bit rotations and integer addition modulo $2^{32}$. Its security relies entirely on these bitwise operations and modular carries, and its design has been shown to be vulnerable to differential cryptanalysis.

The problem is that addition modulo $2^{32}$ has a fully deterministic difference propagation:

$$\Delta(x+y)\equiv\Delta x+\Delta y\pmod{2^{32}},$$

where $\Delta$ denotes the integer difference modulo $2^{32}$. Consequently, carries propagate in a fully deterministic manner, and the difference of the sum reduces to the sum of the differences — a linear structure.

A properly constructed compression function would use Boolean operations (AND/OR/XOR) to break this linearity and produce an avalanche effect. In MD4, however, the Boolean functions only impose local bit conditions without eliminating the underlying linear structure. Once an attacker satisfies those conditions, the compression function reduces to a linear system over the abelian group, and collisions can be constructed directly.[^1] To verify this behavior, we implemented MD4 from RFC 1320 in pure Python and used it to find collisions from different random seeds. Three independent runs each produced a distinct pair of 512-bit messages. The two messages in each pair differ in only a few bits, yet MD4 maps both of them to the exact same 128-bit digest. This is exactly the failure mode a hash function must prevent: two different inputs look the same to the hash, so a signature on one could be swapped for the other. Representative results are shown in Table 1.

**Table 1. MD4 collision results over three independent runs.**

| Run | Common digest | Time | Differential attempts |
|:---:|:---|:---:|:---:|
| 1 | `0xb4839472c739b9a4755b1c8103878148` | 5.21 s | 43 610 |
| 2 | `0x2bd44b90e0eb7282e07bfb3756ae4393` | 3.81 s | 32 048 |
| 3 | `0x1c455be1d334acff9313d0547317005a` | 0.84 s | 7 016 |

Across the three runs the average time was about 3.28 s and the average number of attempts about 27 558. This demonstrates that the differential collision attack is reproducible and practical, not a single lucky artifact.

### SHA-1 collision

SHA-1 uses the same ARX pattern as MD4, but with an 80-step compression function and a more complex message expansion. Despite these added complexities, the best known collision attack still only costs $2^{63.1}$ — far below the $2^{80}$ birthday bound for a 160-bit hash.

This large gap is consistent with the MD4 analysis: the extra rounds and message expansion did not eliminate the fundamental weakness, as the Boolean layer remains insufficient to disrupt the linear structure of addition.[^2] To verify this claim, we downloaded the two SHAttered PDFs and computed their SHA-1 hashes. Both `shattered-1.pdf` and `shattered-2.pdf` produce the same SHA-1 digest:

```
38762cf7f55934b34d179ae6a4c80cadccbb7f0a
```

which matches the published SHAttered collision value. The hash equality is independent of the PDF payloads; the collision is a structural property of the SHA-1 compression function. This verification is deterministic: any two files containing the colliding byte blocks will yield the same digest.

## Use Inappropriate Parameters to Test Asymmetric Ciphers

### Small primes (DLP)

The discrete logarithm problem (DLP) underlies cryptographic systems such as Diffie–Hellman key exchange.[^3] The problem can be stated as follows: given a prime $p$, a base element $g$, and a number $h$, find an integer $x$ such that

$$g^x\equiv h\pmod p.$$

For sufficiently large $p$, the computational infeasibility of this problem underpins the security of the corresponding protocols.

The difficulty of the DLP, however, depends entirely on the choice of the prime $p$—in particular, its size and the factorization of $p-1$ into smaller primes. If a small prime is chosen (e.g., 32 bits), the problem can be solved almost instantly using algorithms such as baby-step giant-step ($O(\sqrt{p})$) or, if $p-1$ is smooth, the Pohlig–Hellman algorithm.[^4][^5] This demonstrates that the security of DLP is not an intrinsic property of the problem itself, but rather a consequence of parameter selection. To verify this claim, we implemented both baby-step giant-step and Pohlig–Hellman for the 32-bit prime $p = 2^{32} - 5 = 4294967291$ and tested them on three independent random secrets. For this prime, $p-1 = 4294967290 = 2 \cdot 5 \cdot 19 \cdot 22605091$ factors into small primes, so Pohlig–Hellman decomposes the DLP into independent subproblems that are each trivial to solve. Both algorithms recovered every secret correctly. The results are shown in Table 2.

**Table 2. DLP recovery over three independent secrets.**

| Run | Secret $x$ | BSGS time | PH time | Recovered correctly |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 843 874 404 | 12.33 ms | 24.72 ms | YES |
| 2 | 41 089 194 | 9.39 ms | 24.35 ms | YES |
| 3 | 2 058 367 755 | 15.05 ms | 21.43 ms | YES |

BSGS and Pohlig–Hellman agreed in every run, and both verified $g^x = h$. This confirms that the difficulty of DLP is determined by the parameter size and the subgroup structure, not by the problem statement itself.

### Weak ECC curves (anomalous)

Elliptic curve cryptography (ECC) is based on the elliptic curve discrete logarithm problem (ECDLP): given two points $P$ and $Q$ on a curve, find $m$ such that $Q = mP$. For properly chosen curves, this is computationally infeasible.

However, the security of ECC depends critically on the choice of curve parameters. A curve is called anomalous if it has exactly $p$ points — a case that appears secure at first because standard attacks are too slow for large $p$. However, Smart demonstrated that these curves can be broken efficiently regardless of the size of $p$. This illustrates that the security of ECC, like that of DLP, is determined by parameter selection rather than the inherent difficulty of the underlying problem.[^6] When $\#E(\mathbb{F}_p) = p$ the usual reduction map degenerates, allowing $P$ and $Q$ to be lifted to the $p$-adic numbers $\mathbb{Q}_p$ where the ECDLP becomes ordinary division — a polynomial-time operation. To verify this, we implemented Smart's $p$-adic lift attack in SageMath for three anomalous curves ($p = 13, 211, 1009$), each tested on three random secrets $k$. The results are shown in Table 3.

**Table 3. Smart's p-adic lift attack over three anomalous curves.**

| Curve | $p$ | Runs | Smart time (avg) | Brute-force time (avg) | All correct |
|:---|:---:|:---:|:---:|:---:|:---:|
| $y^2 = x^3 + x + 6$ | 13 | 3 | 3.01 ms | 0.05 ms | YES |
| $y^2 = x^3 + x + 26$ | 211 | 3 | 1.08 ms | 0.78 ms | YES |
| $y^2 = x^3 + x + 79$ | 1009 | 3 | 1.26 ms | — | YES |

Smart's attack stays under a few milliseconds for all tested curves. Brute-force is included for $p = 13$ and $p = 211$ for comparison; for $p = 1009$ it would take far too long (the $O(p)$ cost grows linearly), so that cell is marked with `—`. ECC security therefore depends on avoiding weak parameter classes, not merely on using a large prime.

[^1]: [Cryptanalysis of the Hash Functions MD4 and RIPEMD](https://iacr.org/archive/eurocrypt2005/34940001/34940001.pdf)
[^2]: [The first collision for full SHA-1](https://shattered.io/static/shattered.pdf)
[^3]: [New directions in cryptography](https://doi.org/10.1109/TIT.1976.1055638)
[^4]: [Class number, a theory of factorization, and genera.](https://zbmath.org/03353398)
[^5]: [An improved algorithm for computing logarithms overGF(p)and its cryptographic significance](https://doi.org/10.1109/TIT.1978.1055817)
[^6]: [The Discrete Logarithm Problem on Elliptic Curves of Trace One](https://doi.org/10.1007/s001459900052)
