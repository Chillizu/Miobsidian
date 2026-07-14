# The Distribution of Prime Numbers

> **A Mathematical Essay on Primes, Spirals & π**

---

## 1. Introduction

**What is a prime number?**

A *prime number* is an integer greater than one that has exactly two factors: **1 and itself**.

> **Examples:** 2, 3, 5, 7 — these numbers are only divisible by 1 and themselves.

### Euclid's Theorem: There Are Infinitely Many Primes

One of the most elegant results in mathematics is **Euclid's theorem**, which proves that there are infinitely many prime numbers. Here is the classic proof by contradiction:

1. Imagine there are only finitely many primes: $p_1, p_2, p_3, \ldots, p_n$.
2. Multiply them all together to get $q = p_1 \times p_2 \times p_3 \times \cdots \times p_n$.
3. Consider $q + 1$.
   - If $q + 1$ were composite, then some $p_i$ would divide it — but every $p_i$ divides $q$, so none can divide $q + 1$.
4. Therefore $q + 1$ must be **a new prime**, or divisible by a new prime not in our list.

This creates a paradox: assuming finitely many primes leads to the existence of yet another prime. Hence, **there are infinite primes.** ∎

---

## 2. A Special Coordinate System

In this exploration, we introduce a **special polar coordinate system** where:

- **x-coordinate** ($r$) = radial distance from the origin  
- **y-coordinate** = angle measured in **radians** (in terms of $\pi$)

That is, we plot each positive integer $n$ at polar coordinates $(r, \theta) = (n,\ n)$.

![Figure A: Polar coordinate concept](prime_extract/figs/fig00_polar_concept.png)
*Figure A: The polar coordinate system on a black grid — $r$ is the radial distance from the center, $\theta$ is the angle measured counter-clockwise from the positive x-axis in radians. Here we see an example point at $(3.00,\ 0.52)$.*

![Figure 1: Coordinate system with labeled points](prime_extract/figs/fig01_coordinate_system.png)
*Figure 1: Plotting small integers $(n,n)$ using this system. Concentric circles represent constant radius; red points are primes, gray points are composites. Each point sits at distance equal to its value, at an angle equal to its value in radians.*

When we input prime numbers into this system — plotting points such as $(2,2)$, $(3,3)$, $(5,5)$, $(7,7)$, etc. — something remarkable emerges:

- **Blue/red coordinates**: prime numbers  
- **White/gray coordinates**: composite numbers  

The point $(1,1)$ lies at distance 1 from the origin, with an angle of **1 radian**. This means the arc length along the circle equals the length of the radial line — the yellow line equals the pink arc. The point $(2,2)$ has twice the radius and twice the angle. This pattern continues for all positive integers.

![Figure 2: All positive integers form an Archimedean spiral](prime_extract/figs/fig02_all_44arms.png)
*Figure 2: Plotting all positive integers $(n,n)$ in this coordinate system produces the famous **Archimedean spiral**. At sufficient scale, **44 distinct spiral arms become visible**.*

---

## 3. Prime Numbers: From Chaos to Order

When we **remove all composite numbers** and keep only the primes, the pattern initially appears **chaotic and random** — because prime numbers are notoriously difficult to predict:

![Figure 3: Primes at small scale appear random](prime_extract/figs/fig03_primes_random.png)
*Figure 3: Prime numbers alone, viewed at small scale, seem scattered without obvious structure.*

**However, the truth is far more beautiful.** When we zoom out dramatically, prime numbers reveal a stunning hidden pattern — what looks like **galactic spirals**:

![Figure 4: Zoomed-out primes — P1: 20 spiral arms](prime_extract/figs/fig04_primes_20arms.png)
*Figure 4: As we zoom out, prime numbers organize into **20 distinct spiral arms** (labeled **P1**). These rays commonly group in sets of 4, with occasional exceptions.*

![Figure 5: Further zoom — P2: 280 lines](prime_extract/figs/fig05_primes_280lines.png)
*Figure 5: Continuing to zoom out reveals an even finer structure: **280 lines** (labeled **P2**) emerging from the prime distribution.*

This raises the central question:

> **Where do these numbers come from? And why would such regular patterns arise from primes?**

---

## 4. Proving the Pattern: Dirichlet's Theory

### Step 1: All Numbers → 6 Residue Classes

If we add all composite numbers back in, the pattern becomes **perfectly regular spirals**. To understand the underlying structure, let us first look at how integers distribute when grouped by their remainder upon division by 6:

![Figure 6: 6 residue classes mod 6 on a unit circle](prime_extract/figs/fig06_six_points.png)
*Figure 6: Six representative integers (one per mod-6 residue class) plotted via the $(n,n)$ algorithm onto a unit circle. Each class ($6k$, $6k+1$, ..., $6k+5$) maps to a distinct direction. Notice how the points are nearly evenly spaced — because **6 ≈ $2\pi$** (~6.283...), so counting by 6 completes almost one full turn.*

**Why 6?** Because in radian measure, **6 is close to $2\pi$** (~6.283...). So counting by 6 completes almost one full turn each time — just slightly less. When we filter out non-coprime residues from these 6 spirals, only **2 remain** (corresponding to $6k \pm 1$), since 6 is only coprime with 1 and 5. This is why all primes greater than 3 take the form $6k \pm 1$.

### Step 2: Why 44?

Now let us examine why **44** is special:

$$\frac{44}{2\pi} = 7.00281750\ldots \approx 7$$

This means $\frac{44}{7}$ approximates $2\pi$, and consequently $\frac{22}{7}$ approximates $\pi$. So when counting in steps of 44, **each point has nearly the same angle as the last one** — just slightly larger. Over many turns, this produces **44 visible spiral arms** for all integers.

### Step 3: From 44 Arms to 20 Arms (Primes Only)

Now, if we delete all even-numbered arms among the 44 (removing 22 arms), and also remove arms numbered 11 and 33 (since 11 is a factor of 44), we are left with **exactly 20 arms**. This explains why the prime spiral shows **P1: 20 spiral arms**.

![Figure 7: Numbers coprime to 44 highlighted](prime_extract/figs/fig07_coprime_44.png)
*Figure 7: Of the numbers 1–43 arranged around a circle, those sharing no common factor with 44 are highlighted in blue. There are **20 such numbers**.*

We call these remaining numbers **coprime** (or **relatively prime**) to 44. For instance:
- **44 and 25 are coprime** ✓ (no shared factors)
- **44 and 33 are NOT coprime** ✗ (share factor 11)

There are **20 numbers coprime to 44**, which we denote using **Euler's totient function**:

$$\Phi(44) = 20$$

where **Euler's totient function** $\Phi(n)$ counts the integers from 1 up to $n$ which are coprime to $n$.

However, 44 still produces some gaps between the lines. For a more precise picture, we need a larger scale.

---

## 5. The Larger Scale: 710 and π

The number **710** is remarkably close to an integer multiple of $2\pi$:

$$\frac{710}{2\pi} = 113.00000959\ldots \approx 113$$

This means $\frac{355}{113}$ is an exceptionally good approximation for $\pi$ — in fact, it is accurate to **6 decimal places**! When we advance the shape forward by a scale of 710, the angular offset between consecutive turns is vanishingly small:

![Figure 8: Scale 710 — primes form 280 lines](prime_extract/figs/fig08_scale_710.png)
*Figure 8: At the scale of 710, prime numbers organize into **280 distinct lines** (Φ(710) = 280). The approximation 355/113 ≈ π makes the spiral nearly perfect.*

**Proof of Φ(710) = 280:**

Factorize 710:

$$710 = 71 \times 5 \times 2$$

To find how many residue classes contain primes (i.e., are coprime to 710):

| Factor | Count removed | Reasoning |
|--------|--------------|-----------|
| 2 | **355** | Half of all numbers are even |
| 5 | **71** | Among odd numbers, 1 in 5 is a multiple of 5 (e.g., 15, 25, 35…) — this creates groups of 4 |
| 71 | **4** | Multiples of 71: 71, 213, 497, 639 — causes some groups to have 3 instead of 4 |

$$710 - 355 - 71 - 4 = \mathbf{280}$$

Thus **Φ(710) = 280** — there are 280 lines of primes visible at this scale.

---

## 6. Conclusion

This paper explores the deep and unexpected connections between **prime numbers**, **spiral geometry**, and **π**. What begins as a seemingly chaotic scatterplot of primes gradually resolves into breathtaking galactic spirals — revealing that beneath the apparent randomness lies profound mathematical order.

The key findings are summarized below:

| Scale | Spiral arms (all integers) | Spiral arms (primes only) | Connection |
|-------|--------------------------|--------------------------|------------|
| 6 | 6 | 2 | $6 \approx 2\pi$ (rough) |
| 44 | 44 | 20 | $22/7 \approx \pi$ |
| 710 | 710 | 280 | $355/113 \approx \pi$ |

Each transition follows the same principle: **the number of prime arms equals Euler's totient function evaluated at the step size**, $\Phi(n)$, which counts the residue classes coprime to $n$. This is precisely what Dirichlet's theorem predicts about the distribution of primes across arithmetic progressions.

This beautiful interplay between number theory and geometry is what draws me most deeply into mathematics — the sense that even in the most unpredictable corners of the number universe, elegant patterns are always waiting to be discovered.

---

## References

- **Video source:** [Prime Spirals — Numberphile / 3Blue1Brown](https://www.youtube.com/watch?v=EK32jo7i5LQ&t=1100s)
- **Further reading:** [Euler's Totient Function — GeeksforGeeks](https://www.geeksforgeeks.org/dsa/eulers-totient-function/)
- **Key theorems:** Euclid's theorem (infinitude of primes); Dirichlet's theorem (primes in arithmetic progressions)

---

*All mathematical figures in this document are generated programmatically to illustrate the concepts described above.*
