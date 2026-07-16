1)c)2) Hash Functions

Hash functions are cryptographic primitives that map an input of arbitrary length to a fixed-length output. Their core operations rely on the group $(\mathbb{Z}/2^{32}\mathbb{Z}, +)$ for modular addition, along with bitwise rotations and XOR. Unlike group-based algorithms, however, this group structure does not constitute a security assumption.

Several hash functions have been developed since the early 1990s. MD4, first proposed in 1990, produces a 128-bit digest but was quickly found to be vulnerable to differential cryptanalysis. Its successor MD5 appeared in 1991 with additional rounds and more complex nonlinear functions, yet practical collision attacks have since been demonstrated. SHA-1, standardized in 1995, extended the digest length to 160 bits with a more elaborate message expansion. However, it has also been shown vulnerable to collision attacks at a cost far below the birthday bound. The current standard, SHA-256, introduced in 2002, produces a 256-bit digest and remains resistant to all known attacks.

Unlike group-based cryptosystems whose security rests on hard problems such as integer factorization or the discrete logarithm, hash functions derive their security from confusion and diffusion, i.e., the mixing and spreading of input bits through iterated Boolean and arithmetic operations. The difficulty of finding collisions is bounded by the birthday paradox rather than by any group-theoretic hard problem. For an $n$-bit hash, a collision can be found in at most $2^{n/2}$ trials.

Hashing alone is insufficient for secure communication. Additional techniques such as padding and key derivation are required to ensure cryptographic algorithms are used correctly in practice.
