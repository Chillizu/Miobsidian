Main Body

1)  Section 1: Cryptographic Algorithms (~2000 words)

	a)  The Principles

	1)  Using Cyclic Groups

		A)  DHP, the Diffie–Hellman problem.

		The Diffie–Hellman key agreement protocol, also the principle of many of the algorithms below (See [Group Theory In Cryptography](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 3)

		B)  DLP, discrete logarithm problem.

		This is related to DHP. ([GTIC](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 3)

	2)  Using Non-Abelian Groups

		A)  Conjugacy Search Problem

		An analogue to the DLP

		B)  The Ko–Lee–Cheon–Han–Kang–Park key agreement protocol

		An analogue of the Diffie–Hellman key agreement protocol ([GTIC](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 5)

		C)  Anshel–Anshel–Goldfeld key agreement protocol ([GTIC](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 6)

		D)  The Stickel key agreement protocol ([GTIC](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 6)

	b)  Group-based Algorithms

	1)  Asymmetric Key Cryptography (Public and Private Key Pair, Used for Signature)

		A)  RSA based on DHP (Group)

		B)  The ElGamal encryption algorithm based on the DLP (Group) ([APPLICATIONS OF GROUP THEORY IN CRYPTOGRAPHIC ALGORITHMS](https://www.ijfans.org/uploads/paper/2a5dff6130357d57bf484895d24b7a9a.pdf) Page 3)

		C)  DSA, Digital Signature Algorithm, based on DLP, similar to ElGamal (Group) ([AOGTICA](https://www.ijfans.org/uploads/paper/2a5dff6130357d57bf484895d24b7a9a.pdf) Page 5)

	2)  Symmetric Cryptography (Single Key, Used for Encryption)

		A)  Logarithmic signatures, a “generalisation of the DLP” ([GTIC](https://web.williams.edu/Mathematics/sjmiller/public_html/crypto/handouts/BlackburnCidMullan_GroupThInCrypto.pdf) Page 7). This is used to construct the PGM, Permutation Group Mappings, a symmetric cipher (Group)

	c)  More Algorithms

	1)  Encryption

		A)  AES, Advanced Encryption Standard ([AOGTICA](https://www.ijfans.org/uploads/paper/2a5dff6130357d57bf484895d24b7a9a.pdf) Page 4)

	2)  Signature

		A)  ECC based on “the algebraic structure of elliptic curves over finite fields” ([AOGTICA](https://www.ijfans.org/uploads/paper/2a5dff6130357d57bf484895d24b7a9a.pdf) Page 4)

	3)  Hash Functions

		A)  MD5 and its weaker predecessor MD4

		B)  SHA-2 and its weaker predecessor SHA-1

	d)  More Cryptographic Practices

	1)  Padding

	2)  KDF

2)  Section 2: Properties and Applications of the Introduced Algorithms (~600 words)

	a)  Properties

	b)  Applications

		See [https://postquantum.com/post-quantum/shor-rsa-ecc-diffie-hellman/#ecc-the-invisible-backbone-of-modern-infrastructure](https://postquantum.com/post-quantum/shor-rsa-ecc-diffie-hellman/) for applications.

	c)  Cryptanalysis

		See GTIC, AOGTICA

3)  Section 3: Testing of Algorithms (~600 words)

	a)  Hash Collision in Weak MD4 and SHA-1

		1)  MD4 collision

			MD4 collision via Wang et al. (2005) differential attack at ~2^39 complexity. (Wang et al. 2005, Eurocrypt)

		2)  SHA-1 collision

			First practical SHA-1 collision at ~2^63 complexity (~110 GPU-years), two different PDFs with identical hash. (SHAttered 2017, Google & CWI)

	b)  Use Inappropriate Parameters to Test Asymmetric Ciphers

		1)  Small primes (DLP)

			DLP on a 32-bit prime group solved in seconds via baby-step giant-step or Pohlig–Hellman decomposition. Demonstrates that DLP difficulty depends on the size and structure of the group.

		2)  Weak ECC curves (anomalous)

			Anomalous curves ($|E(\mathbb{F}_p)| = p$) allow ECDLP to be solved in $O(\log p)$ time via Smart's $p$-adic lift. Demonstrates that ECC security depends on correct curve parameter selection.

Conclusion: Summarise the contents covered so far and provide a glimpse of future cryptography. (~150 words)