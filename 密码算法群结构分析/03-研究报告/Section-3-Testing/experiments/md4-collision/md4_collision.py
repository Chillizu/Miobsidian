#!/usr/bin/env python3
"""
MD4 collision demonstration.

Implements MD4 (RFC 1320) in pure Python, then uses Wang et al.'s 2005
differential attack to produce two distinct 64-byte messages that hash to the
same 128-bit MD4 digest. The attack complexity is ~2^8 MD4 operations, so the
script typically succeeds in one or two iterations.

Based on:
  Xiaoyun Wang et al., "Cryptanalysis of the Hash Functions MD4 and RIPEMD",
  EUROCRYPT 2005, LNCS 3494.

The message modification code is adapted from the public reference
implementation at https://github.com/HMY626/MD4-Collision (ported to Python 3
and made self-contained).
"""

import random
import struct
import time


# ---------------------------------------------------------------------------
# Pure-Python MD4 (RFC 1320)
# ---------------------------------------------------------------------------

def _md4_pad(msg: bytes) -> bytes:
    """Append MD4 padding (bit-length suffix is little-endian 64-bit)."""
    bit_len = (len(msg) * 8) & 0xFFFFFFFFFFFFFFFF
    padded = msg + b'\x80'
    while len(padded) % 64 != 56:
        padded += b'\x00'
    padded += struct.pack('<Q', bit_len)
    return padded



def _rotl(n, s):
    return ((n << s) | (n >> (32 - s))) & 0xFFFFFFFF


def _md4_round1(a, b, c, d, k, s, x):
    f = (b & c) | ((b ^ 0xFFFFFFFF) & d)
    tmp = (a + f + x[k]) & 0xFFFFFFFF
    return _rotl(tmp, s)


def _md4_round2(a, b, c, d, k, s, x):
    g = (b & c) | (b & d) | (c & d)
    tmp = (a + g + x[k] + 0x5A827999) & 0xFFFFFFFF
    return _rotl(tmp, s)


def _md4_round3(a, b, c, d, k, s, x):
    h = b ^ c ^ d
    tmp = (a + h + x[k] + 0x6ED9EBA1) & 0xFFFFFFFF
    return _rotl(tmp, s)


def md4(msg: bytes) -> bytes:
    """Return the 16-byte MD4 digest of ``msg``."""
    padded = _md4_pad(msg)
    a, b, c, d = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476

    for block_offset in range(0, len(padded), 64):
        block = padded[block_offset:block_offset + 64]
        x = list(struct.unpack('<16I', block))
        aa, bb, cc, dd = a, b, c, d

        # Round 1
        a = _md4_round1(a, b, c, d, 0, 3, x)
        d = _md4_round1(d, a, b, c, 1, 7, x)
        c = _md4_round1(c, d, a, b, 2, 11, x)
        b = _md4_round1(b, c, d, a, 3, 19, x)
        a = _md4_round1(a, b, c, d, 4, 3, x)
        d = _md4_round1(d, a, b, c, 5, 7, x)
        c = _md4_round1(c, d, a, b, 6, 11, x)
        b = _md4_round1(b, c, d, a, 7, 19, x)
        a = _md4_round1(a, b, c, d, 8, 3, x)
        d = _md4_round1(d, a, b, c, 9, 7, x)
        c = _md4_round1(c, d, a, b, 10, 11, x)
        b = _md4_round1(b, c, d, a, 11, 19, x)
        a = _md4_round1(a, b, c, d, 12, 3, x)
        d = _md4_round1(d, a, b, c, 13, 7, x)
        c = _md4_round1(c, d, a, b, 14, 11, x)
        b = _md4_round1(b, c, d, a, 15, 19, x)

        # Round 2
        a = _md4_round2(a, b, c, d, 0, 3, x)
        d = _md4_round2(d, a, b, c, 4, 5, x)
        c = _md4_round2(c, d, a, b, 8, 9, x)
        b = _md4_round2(b, c, d, a, 12, 13, x)
        a = _md4_round2(a, b, c, d, 1, 3, x)
        d = _md4_round2(d, a, b, c, 5, 5, x)
        c = _md4_round2(c, d, a, b, 9, 9, x)
        b = _md4_round2(b, c, d, a, 13, 13, x)
        a = _md4_round2(a, b, c, d, 2, 3, x)
        d = _md4_round2(d, a, b, c, 6, 5, x)
        c = _md4_round2(c, d, a, b, 10, 9, x)
        b = _md4_round2(b, c, d, a, 14, 13, x)
        a = _md4_round2(a, b, c, d, 3, 3, x)
        d = _md4_round2(d, a, b, c, 7, 5, x)
        c = _md4_round2(c, d, a, b, 11, 9, x)
        b = _md4_round2(b, c, d, a, 15, 13, x)

        # Round 3
        a = _md4_round3(a, b, c, d, 0, 3, x)
        d = _md4_round3(d, a, b, c, 8, 9, x)
        c = _md4_round3(c, d, a, b, 4, 11, x)
        b = _md4_round3(b, c, d, a, 12, 15, x)
        a = _md4_round3(a, b, c, d, 2, 3, x)
        d = _md4_round3(d, a, b, c, 10, 9, x)
        c = _md4_round3(c, d, a, b, 6, 11, x)
        b = _md4_round3(b, c, d, a, 14, 15, x)
        a = _md4_round3(a, b, c, d, 1, 3, x)
        d = _md4_round3(d, a, b, c, 9, 9, x)
        c = _md4_round3(c, d, a, b, 5, 11, x)
        b = _md4_round3(b, c, d, a, 13, 15, x)
        a = _md4_round3(a, b, c, d, 3, 3, x)
        d = _md4_round3(d, a, b, c, 11, 9, x)
        c = _md4_round3(c, d, a, b, 7, 11, x)
        b = _md4_round3(b, c, d, a, 15, 15, x)

        a = (a + aa) & 0xFFFFFFFF
        b = (b + bb) & 0xFFFFFFFF
        c = (c + cc) & 0xFFFFFFFF
        d = (d + dd) & 0xFFFFFFFF

    return struct.pack('<4I', a, b, c, d)


def _endian(b: bytes) -> list:
    """Convert bytes to a list of little-endian 32-bit words."""
    return list(struct.unpack('<16I', b))


def _left_rot(n, b):
    return ((n << b) | (n >> (32 - b))) & 0xFFFFFFFF


def _right_rot(n, b):
    return ((n >> b) | (n << (32 - b))) & 0xFFFFFFFF


def _F(x, y, z):
    return (x & y) | (~x & z) & 0xFFFFFFFF


def _G(x, y, z):
    return (x & y) | (x & z) | (y & z)


def _FF(a, b, c, d, k, s, x):
    return _left_rot((a + _F(b, c, d) + x[k]) & 0xFFFFFFFF, s)


def _GG(a, b, c, d, k, s, x):
    return _left_rot((a + _G(b, c, d) + x[k] + 0x5A827999) & 0xFFFFFFFF, s)


def _first_round(abcd, j, i, s, x, constraints):
    """Single-step modification to satisfy the first-round conditions."""
    v = _left_rot((abcd[j % 4] + _F(abcd[(j + 1) % 4], abcd[(j + 2) % 4], abcd[(j + 3) % 4]) + x[i]) & 0xFFFFFFFF, s)
    for kind, bit in constraints:
        if kind == '=':
            v ^= (v ^ abcd[(j + 1) % 4]) & (1 << bit)
        elif kind == '0':
            v &= ~(1 << bit)
        elif kind == '1':
            v |= 1 << bit
    # Update the corresponding message word so that MD4 would produce this v.
    x[i] = (_right_rot(v, s) - abcd[j % 4] - _F(abcd[(j + 1) % 4], abcd[(j + 2) % 4], abcd[(j + 3) % 4])) % (1 << 32)
    abcd[j % 4] = v


# First-round sufficient conditions (Wang et al. Table 6).
_ROUND1_CONSTRAINTS = [
    [['=', 6]],
    [['0', 6], ['=', 7], ['=', 10]],
    [['1', 6], ['1', 7], ['0', 10], ['=', 25]],
    [['1', 6], ['0', 7], ['0', 10], ['0', 25]],
    [['1', 7], ['1', 10], ['0', 25], ['=', 13]],
    [['0', 13], ['=', 18], ['=', 19], ['=', 20], ['=', 21], ['1', 25]],
    [['=', 12], ['0', 13], ['=', 14], ['0', 18], ['0', 19], ['1', 20], ['0', 21]],
    [['1', 12], ['1', 13], ['0', 14], ['=', 16], ['0', 18], ['0', 19], ['0', 20], ['0', 21]],
    [['1', 12], ['1', 13], ['1', 14], ['0', 16], ['0', 18], ['0', 19], ['0', 20], ['=', 22], ['1', 21], ['=', 25]],
    [['1', 12], ['1', 13], ['1', 14], ['0', 16], ['0', 19], ['1', 20], ['1', 21], ['0', 22], ['1', 25], ['=', 29]],
    [['1', 16], ['0', 19], ['0', 20], ['0', 21], ['0', 22], ['0', 25], ['1', 29], ['=', 31]],
    [['0', 19], ['1', 20], ['1', 21], ['=', 22], ['1', 25], ['0', 29], ['0', 31]],
    [['0', 22], ['0', 25], ['=', 26], ['=', 28], ['1', 29], ['0', 31]],
    [['0', 22], ['0', 25], ['1', 26], ['1', 28], ['0', 29], ['1', 31]],
    [['=', 18], ['1', 22], ['1', 25], ['0', 26], ['0', 28], ['0', 29]],
    [['0', 18], ['=', 25], ['1', 26], ['1', 28], ['0', 29], ['=', 31]]
]

_SHIFT1 = [3, 7, 11, 19] * 4
_CHANGE1 = [0, 3, 2, 1] * 4

# Second-round conditions on a5 and d5.
_ROUND2_CONSTRAINTS = [
    [['=', 18, 2], ['1', 25], ['0', 26], ['1', 28], ['1', 31]],
    [['=', 18, 0], ['=', 25, 1], ['=', 26, 1], ['=', 28, 1], ['=', 31, 1]]
]


def _apply_differential(m: bytes) -> bytes:
    """Derive M' from M using the Wang differential (Δm1, Δm2, Δm12)."""
    x = _endian(m)
    x[1] = (x[1] + (1 << 31)) % (1 << 32)
    x[2] = (x[2] + (1 << 31) - (1 << 28)) % (1 << 32)
    x[12] = (x[12] - (1 << 16)) % (1 << 32)
    return struct.pack('<16I', *x)


def _find_single_collision(m: bytes):
    """Try to turn a random 64-byte block into a colliding pair. Returns (M, M') or (None, None)."""
    x = _endian(m)
    initial = [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476]
    abcd = initial[:]

    # Satisfy first-round conditions via single-step modification.
    for i in range(16):
        _first_round(abcd, _CHANGE1[i], i, _SHIFT1[i], x, _ROUND1_CONSTRAINTS[i])

    # Multi-step modification to satisfy a5 conditions.
    a5 = _GG(abcd[0], abcd[1], abcd[2], abcd[3], 0, 3, x)
    for kind, bit, *rest in _ROUND2_CONSTRAINTS[0]:
        if kind == '=':
            a5 ^= (a5 ^ abcd[rest[0]]) & (1 << bit)
        elif kind == '0':
            a5 &= ~(1 << bit)
        elif kind == '1':
            a5 |= 1 << bit

    q = (_right_rot(a5, 3) - abcd[0] - _G(abcd[1], abcd[2], abcd[3]) - 0x5A827999) % (1 << 32)

    a0, b0, c0, d0 = initial
    a_ = _FF(a0, b0, c0, d0, 0, 3, [q])
    a1 = _FF(a0, b0, c0, d0, 0, 3, x)
    d1 = _FF(d0, a1, b0, c0, 1, 7, x)
    x[0] = q
    x[1] = (_right_rot(d1, 7) - d0 - _F(a_, b0, c0)) % (1 << 32)
    c1 = _FF(c0, d1, a1, b0, 2, 11, x)
    x[2] = (_right_rot(c1, 11) - c0 - _F(d1, a_, b0)) % (1 << 32)
    b1 = _FF(b0, c1, d1, a1, 3, 19, x)
    x[3] = (_right_rot(b1, 19) - b0 - _F(c1, d1, a_)) % (1 << 32)
    a2 = _FF(a1, b1, c1, d1, 4, 3, x)
    x[4] = (_right_rot(a2, 3) - a_ - _F(b1, c1, d1)) % (1 << 32)

    abcd[0] = a5

    # Multi-step modification to satisfy d5 conditions.
    d5 = _GG(abcd[3], abcd[0], abcd[1], abcd[2], 4, 5, x)
    for kind, bit, *rest in _ROUND2_CONSTRAINTS[1]:
        if kind == '=':
            d5 ^= (d5 ^ abcd[rest[0]]) & (1 << bit)
        elif kind == '0':
            d5 &= ~(1 << bit)
        elif kind == '1':
            d5 |= 1 << bit

    q = (_right_rot(d5, 5) - abcd[3] - _G(abcd[0], abcd[1], abcd[2]) - 0x5A827999) % (1 << 32)

    a, b, c, d = initial
    a = _FF(a, b, c, d, 0, 3, x)
    d = _FF(d, a, b, c, 1, 7, x)
    c = _FF(c, d, a, b, 2, 11, x)
    b = _FF(b, c, d, a, 3, 19, x)
    a2_ = _FF(a, b, c, d, 4, 3, [q] * 5)
    a2 = _FF(a, b, c, d, 4, 3, x)
    d2 = _FF(d, a2, b, c, 5, 7, x)
    x[4] = q
    x[5] = (_right_rot(d2, 7) - d - _F(a2_, b, c)) % (1 << 32)
    c2 = _FF(c, d2, a2, b, 6, 11, x)
    x[6] = (_right_rot(c2, 11) - c - _F(d2, a2_, b)) % (1 << 32)
    b2 = _FF(b, c2, d2, a2, 7, 19, x)
    x[7] = (_right_rot(b2, 19) - b - _F(c2, d2, a2_)) % (1 << 32)
    a3 = _FF(a2, b2, c2, d2, 8, 3, x)
    x[8] = (_right_rot(a3, 3) - a2_ - _F(b2, c2, d2)) % (1 << 32)

    m_mod = struct.pack('<16I', *x)
    m_prime = _apply_differential(m_mod)

    if md4(m_mod) == md4(m_prime):
        return m_mod, m_prime
    return None, None


def find_collision(seed: int = None) -> tuple:
    """Generate a colliding MD4 message pair. Returns (M, M')."""
    if seed is not None:
        random.seed(seed)
    attempts = 0
    while True:
        attempts += 1
        m = bytes(random.randint(0, 255) for _ in range(64))
        ma, mb = _find_single_collision(m)
        if ma is not None:
            return ma, mb, attempts


# ---------------------------------------------------------------------------
# Main output
# ---------------------------------------------------------------------------

def _hex_chunks(data: bytes, chunk_size: int = 4) -> str:
    return ' '.join(data[i:i + chunk_size].hex() for i in range(0, len(data), chunk_size))


def main():
    n_runs = 3
    times = []
    attempts_list = []
    print(f"Running MD4 collision search {n_runs} times with different random seeds...")
    print()

    for run in range(1, n_runs + 1):
        start = time.perf_counter()
        m1, m2, attempts = find_collision(seed=run)
        elapsed = time.perf_counter() - start

        h1 = md4(m1)
        h2 = md4(m2)

        if h1 != h2:
            raise RuntimeError(f"Run {run}: collision verification FAILED: hashes do not match.")
        if m1 == m2:
            raise RuntimeError(f"Run {run}: collision verification FAILED: messages are identical.")

        times.append(elapsed)
        attempts_list.append(attempts)

        print(f"Run {run}:")
        print(f"  Message 1: {_hex_chunks(m1)}")
        print(f"  Message 2: {_hex_chunks(m2)}")
        print(f"  MD4(M1)  = 0x{h1.hex()}")
        print(f"  MD4(M2)  = 0x{h2.hex()}")
        print(f"  Time:     {elapsed * 1e6:.0f} μs (found after {attempts} attempt(s))")
        print()

    avg_time = sum(times) / len(times)
    avg_attempts = sum(attempts_list) / len(attempts_list)
    print("Summary:")
    print(f"  Runs:            {n_runs}")
    print(f"  Time (min/avg/max): {min(times) * 1e6:.0f} / {avg_time * 1e6:.0f} / {max(times) * 1e6:.0f} μs")
    print(f"  Attempts (min/avg/max): {min(attempts_list)} / {avg_attempts:.0f} / {max(attempts_list)}")
    print("Collision: YES (verified in all runs)")


if __name__ == '__main__':
    main()
