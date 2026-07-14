---
title: "Section 2: Properties and Applications — 写作指导"
date: 2026-07-15
---

# Section 2: Properties and Applications — 写作指导

> 目标：~600 words。编号对应 docx：2) a) Properties → b) Applications → c) Cryptanalysis。
> 不做逐步推导——仅给结论和关键推理线索。

---

## 本节逻辑

```
2) Section 2: Properties and Applications
│
├─ a) Properties（算法属性对比）
│   ├── 复杂度对比表
│   └── 安全等级对比表
│
├─ b) Applications（应用场景）
│   └── 各算法实际用途表 + postquantum.com 引用
│
└─ c) Cryptanalysis（密码分析）
    ├── 阿贝尔群统一脆弱性（回指 §1 a)2) 非阿贝尔群动机）
    └── 量子威胁：Shor vs Grover
```

---

## a) Properties（~200 words）

**要传达的核心信息**：不同算法的"快慢"和"安全等级"取决于其群运算的渐近复杂度和密钥长度。

**讲解顺序**：

1. **时间复杂度对比表**

| 算法 | 核心运算 | 渐近复杂度 | 直觉解释 |
|:---|:---|:---:|:---|
| RSA | 平方-乘法模幂 | $O(\log^3 n)$ | $n$ 为 2048-bit |
| ElGamal | 2–3 次模幂 | $O(\log^3 p)$ | 约为 RSA 的 2× |
| DSA | 模幂（短指数） | $O(\log q \cdot \log^2 p)$ | $q$ 仅 256-bit → 更快 |
| ECC | 点乘标量乘 | $O(\log^3 q)$ | $\log q = 256 \ll \log n = 3072$ |
| AES | SPN 固定轮 | $O(n)$ | 10/12/14 轮，线性于消息长度 |
| MD5/SHA | Merkle–Damgård | $O(n)$ | 步数固定，线性于消息长度 |

2. **关键解释**：
   - RSA 和 ECC 都是 $\log$ 的多项式，但系数差一个数量级（256 vs 3072）
   - 对称密码（AES）和非对称密码（RSA）差多个数量级 → "握手用非对称，通信用对称"
   - 不展开 GNFS $L_n[1/3, 1.923]$ 的公式——只说"亚指数时间"并引用 GNFS 标准文献

3. **等效安全对比**（跨算法比较）

| 算法 | 密钥长 | 等效对称安全 |
|:---|:---:|:---:|
| RSA-2048 | 2048-bit | ~112 bits |
| RSA-3072 | 3072-bit | 128 bits |
| ECC-256 | 256-bit | 128 bits |
| ECC-384 | 384-bit | 256 bits |
| AES-128 | 128-bit | 128 bits |
| AES-256 | 256-bit | 256 bits |

**解释**：ECC 用 256-bit 达到 RSA 3072-bit 的安全等级——这是它成为主流的原因。

**过渡到 b)**：*"Performance and security are not abstract metrics—they translate directly into real-world suitability. Let us see where each algorithm is deployed."*

---

## b) Applications（~200 words）

**要传达的核心信息**：每个算法有典型用途。RSA 正在被 ECC 取代，SHA-256 是当前最低安全标准。

**讲解顺序**：

1. **应用场景表**

| 算法 | 典型应用 |
|:---|:---|
| RSA | TLS 证书、传统 PKI、密钥传输 |
| ElGamal | PGP/GnuPG 加密（非默认）|
| DSA | 美国政府数字签名标准（旧） |
| ECC (ECDH/ECDSA) | TLS 1.3、Bitcoin（secp256k1）、iOS/Android 安全区 |
| AES | 文件加密、磁盘加密（BitLocker/FileVault）、TLS 对称会话 |
| MD5 | 仅校验和（已禁用签名用途） |
| SHA-256 | Bitcoin PoW、TLS 证书签名、软件完整性验证 |

2. **关键趋势**：
   - RSA → ECC 迁移：TLS 1.3 默认 ECDHE + ECDSA
   - MD5 已弃用 → SHA-1 弃用中 → SHA-256 最低安全标准

3. **postquantum.com 引用**（docx 要求）：
   引用 postquantum.com 上关于 ECC 在 TLS 和区块链中的应用说明
   *"For a detailed overview of how ECC secures modern digital infrastructure, see [postquantum.com]..."*

**过渡到 c)**：*"However, the widespread deployment of these algorithms does not mean they are invulnerable. The next subsection examines how they can be—and have been—attacked."*

---

## c) Cryptanalysis（~200 words）

**要传达的核心信息**：阿贝尔群密码在量子计算机前统一脆弱。非阿贝尔群密码是应对方向之一，但尚未成熟。

**讲解顺序**：

1. **经典攻击**

| 算法 | 最优攻击 | 复杂度 |
|:---|:---|:---:|
| RSA | GNFS 分解 | 亚指数 $L_n[1/3, 1.923]$ |
| DLP (Zp) | GNFS-DLP | 亚指数 |
| ECDLP | Pollard-$\rho$ | 指数 $O(\sqrt{q})$ |
| AES | Biclique / 穷举 | $2^{126.1}$（AES-128）|
| MD5 | 差分碰撞 | $2^{39}$（已破）|
| SHA-1 | 差分碰撞 | $2^{63}$（已破）|
| SHA-256 | 生日攻击 | $2^{128}$ |

2. **量子威胁**

| 量子攻击 | 影响对象 | 效果 |
|:---|:---|:---|
| Shor 算法 | RSA / DH / DSA / ECC | 多项式时间破解 |
| Grover 算法 | AES / SHA | 平方根加速（AES-256 → 128-bit）|

3. **核心论点**（连接 §1 a)2)）：
   - Shor 利用了阿贝尔群的隐藏子群结构
   - 非阿贝尔群密码（CSP/Ko-Lee/AAG/Stickel）的设计动机之一就是逃避 Shor
   - 但非阿贝尔群密码尚未成熟——需要更多研究

**GTIC 参考**：p9-10 辫群密码分析（长度攻击、线性代数攻击），p10-11 Stickel 和 MST 系列分析

**理解检查**：阿贝尔群密码在量子时代集体失效。对称密码受影响小。非阿贝尔群密码是方向之一。

**过渡到 §3**：*"So far, we have examined the mathematical principles and practical properties of these algorithms. But theory alone is not enough—let us put them to the test."*

---

## 交叉引用

| 参考 | 用途 |
|:---|:---|
| [[密码算法群结构分析/03-研究报告/03-论文结构大纲]] | 总大纲 |
| [[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] p9-11 | 密码分析详情 |
| [[密码算法群结构分析/03-研究报告/AOGTICA-注释翻译]] p5-6 | 安全属性框架 |
| [[密码算法群结构分析/03-研究报告/Section-1-Cryptographic-Algorithms]] §a)2) | 非阿贝尔群动机 |
| [[密码算法群结构分析/03-研究报告/Section-3-Testing]] | 实验验证理论 |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] | 复杂度与安全分析索引 |
