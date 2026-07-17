#!/usr/bin/env sage
"""
ECC Anomalous Curve — Smart's p-adic lift attack.

Demonstrates the ECDLP vulnerability on anomalous curves (|E(F_p)| = p).
For such curves, Smart's p-adic lift attack solves the ECDLP in O(log p)
time by lifting the curve to Q_p and using the formal group logarithm.

Reference:
  Smart, N. P. (1999). The discrete logarithm problem on elliptic curves
  of trace one. Journal of Cryptology, 12(3), 193-196.

Implementation note:
  We lift points to a *perturbed* p-adic curve
      y^2 = x^3 + (a4 + p*13)x + (a6 + p*37)
  rather than to the same-curve lift.  This is the standard formulation
  used in reference implementations (e.g. elikaski/ECC_Attacks) and
  avoids the torsion subtleties that make the same-curve lift fail for
  very small primes.

Parameter note:
  The plan file suggests y^2 = x^3 + 3x + 5 over F_13 as an anomalous
  curve.  That curve actually has order 9, not 13.  We use the correct
  anomalous examples
      y^2 = x^3 + x + 6   over F_13  (order 13)
      y^2 = x^3 + x + 26  over F_211 (order 211)
  which are the standard Smart-attack demonstration curves.
"""

import time
import sys


# Perturbation constants for the p-adic lift.  Any non-zero multiples of p
# keep the curve non-singular (discriminant unchanged mod p) and place the
# lifted point in the generic formal group.
PERT_A = 13
PERT_B = 37


def smart_attack(E, P, Q, p):
    """
    Smart's p-adic lift attack on anomalous elliptic curves.

    Given E/F_p with |E(F_p)| = p and Q = k*P, returns k.
    """
    assert E.order() == p, "Curve must be anomalous (|E(F_p)| = p)"

    # Lift to a perturbed curve over Q_p.
    Qp_p = Qp(p, prec=64)
    a4_lift = Qp_p(Integer(E.a4()) + p * PERT_A)
    a6_lift = Qp_p(Integer(E.a6()) + p * PERT_B)
    E_Qp = EllipticCurve(Qp_p, [a4_lift, a6_lift])

    def _lift(pt):
        """Lift pt in E(F_p) to E_Qp(Q_p) preserving y mod p."""
        x0 = Integer(pt[0])
        y0 = Integer(pt[1])
        lifts = E_Qp.lift_x(Qp_p(x0), all=True)
        for L in lifts:
            if Integer(L[1].residue()) == y0:
                return L
        return lifts[0]

    P_hat = _lift(P)
    Q_hat = _lift(Q)

    # Since |E(F_p)| = p, p*P = O over F_p.  Hence p*P_hat and p*Q_hat lie
    # in the kernel of reduction E_1(Q_p), which is isomorphic to the
    # additive group Z_p via the formal group logarithm.
    pP = p * P_hat
    pQ = p * Q_hat

    # The formal logarithm phi satisfies phi(p*Q) = k * phi(p*P).
    # For points in E_1, phi(R) is congruent to -x(R)/y(R) modulo higher
    # order terms; the ratio of these approximations recovers k mod p.
    tP = -pP[0] / pP[1]
    tQ = -pQ[0] / pQ[1]
    k = Integer((tQ / tP).residue())
    return k


def brute_force(E, P, Q, p):
    """Brute-force search for k in [0, p-1] such that Q = k*P."""
    R = E(0)
    for k in range(p):
        if R == Q:
            return k
        R = R + P
    return None


def run_demo(p, a4, a6, n_runs=3):
    """Run the demonstration for a single anomalous curve, n_runs times."""
    print(f'\n{"=" * 56}')
    print(f'Anomalous curve: y^2 = x^3 + {a4}x + {a6}  over F_{p}')
    print(f'{"=" * 56}')

    F = GF(p)
    E = EllipticCurve(F, [a4, a6])
    order = E.order()

    print(f'p           = {p}')
    print(f'|E(F_{p})|   = {order}')

    if order != p:
        print(f'[FAIL] Curve is NOT anomalous (order={order}, expected {p})')
        return False

    print('[OK] Anomalous curve confirmed (|E(F_p)| = p).')

    # Every non-identity point generates the group of prime order p.
    P = E.gens()[0]
    if P == E(0):
        P = E.points()[1]

    print(f'Generator P = {P.xy()}')

    smart_times = []
    brute_times = []
    all_correct = True

    for run in range(1, n_runs + 1):
        k_secret = randint(1, p - 2)
        Q = k_secret * P

        print(f'\nRun {run}:')
        print(f'  Secret k = {k_secret}')
        print(f'  Q = k*P  = {Q.xy()}')

        t0 = time.time()
        try:
            k_recovered = smart_attack(E, P, Q, p)
            t_smart = (time.time() - t0) * 1000
            smart_times.append(t_smart)
            correct = (k_recovered == k_secret)
            all_correct = all_correct and correct
            print(f'  Smart:  k_recovered = {k_recovered}, time = {t_smart:.2f} ms, correct = {"YES" if correct else "NO"}')
        except Exception as e:
            print(f'  [ERROR] Smart attack failed: {e}')
            all_correct = False

        if p < 500:
            t0 = time.time()
            k_brute = brute_force(E, P, Q, p)
            t_brute = (time.time() - t0) * 1000
            brute_times.append(t_brute)
            correct = (k_brute == k_secret)
            all_correct = all_correct and correct
            print(f'  Brute:  k_recovered = {k_brute}, time = {t_brute:.2f} ms, correct = {"YES" if correct else "NO"}')

    print(f'\nSummary for F_{p}:')
    if smart_times:
        print(f'  Smart attack time (min/avg/max): {min(smart_times):.2f} / {sum(smart_times)/len(smart_times):.2f} / {max(smart_times):.2f} ms')
    if brute_times:
        print(f'  Brute-force time  (min/avg/max): {min(brute_times):.2f} / {sum(brute_times)/len(brute_times):.2f} / {max(brute_times):.2f} ms')
    print(f'  Result: {"PASSED" if all_correct else "FAILED"} — all recovered k match secret')
    return all_correct


def main():
    # Demo 1: tiny anomalous curve over F_13.
    ok1 = run_demo(p=13, a4=1, a6=6)

    # Demo 2: medium anomalous curve over F_211.
    ok2 = run_demo(p=211, a4=1, a6=26)

    # Demo 3: larger anomalous curve over F_1009 (brute-force still feasible).
    ok3 = run_demo(p=1009, a4=1, a6=79)

    print(f'\n{"=" * 56}')
    print('Conclusion: Smart\'s p-adic lift solves the ECDLP on anomalous')
    print('curves in polynomial time, not exponential time.')
    print(f'{"=" * 56}')

    return 0 if (ok1 and ok2 and ok3) else 1


main()
