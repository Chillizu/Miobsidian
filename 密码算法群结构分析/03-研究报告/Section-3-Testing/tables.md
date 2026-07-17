# Experimental Result Tables

This file contains the three result tables from Section 3 in a format that is easy to copy into Word and apply a consistent table style.

## Table 1. MD4 collision results over three independent runs

| Run | Common digest | Time | Differential attempts |
|:---:|:---|:---:|:---:|
| 1 | `0xb4839472c739b9a4755b1c8103878148` | 5.21 s | 43 610 |
| 2 | `0x2bd44b90e0eb7282e07bfb3756ae4393` | 3.81 s | 32 048 |
| 3 | `0x1c455be1d334acff9313d0547317005a` | 0.84 s | 7 016 |

## Table 2. DLP recovery over three independent secrets

| Run | Secret $x$ | BSGS time | PH time | Recovered correctly |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 843 874 404 | 12.33 ms | 24.72 ms | YES |
| 2 | 41 089 194 | 9.39 ms | 24.35 ms | YES |
| 3 | 2 058 367 755 | 15.05 ms | 21.43 ms | YES |

## Table 3. Smart's p-adic lift attack over three anomalous curves

| Curve | $p$ | Runs | Smart time (avg) | Brute-force time (avg) | All correct |
|:---|:---:|:---:|:---:|:---:|:---:|
| $y^2 = x^3 + x + 6$ | 13 | 3 | 3.01 ms | 0.05 ms | YES |
| $y^2 = x^3 + x + 26$ | 211 | 3 | 1.08 ms | 0.78 ms | YES |
| $y^2 = x^3 + x + 79$ | 1009 | 3 | 1.26 ms | — | YES |
