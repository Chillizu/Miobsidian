---
title: "Section 1: Cryptographic Algorithms — 写作指导"
date: 2026-07-15
---

# Section 1: Cryptographic Algorithms — 写作指导

> 目标：~2000 words。核心章节。
> 编号对应 docx：1) a) The Principles → b) Group-based Algorithms → c) More Algorithms → d) More Practices
>
> 核心参考文献：[[密码算法群结构分析/03-研究报告/GTIC-注释翻译]]、[[密码算法群结构分析/03-研究报告/AOGTICA-注释翻译]]

---

## 本节逻辑总图

```
1) Section 1: Cryptographic Algorithms
│
├─ a) The Principles（群论困难问题）
│   ├─ 1) Cyclic Groups → DHP → DLP
│   └─ 2) Non-Abelian Groups → CSP → Ko-Lee / AAG / Stickel
│
├─ b) Group-based Algorithms（经典群基算法）
│   ├─ 1) Asymmetric: RSA / ElGamal / DSA
│   └─ 2) Symmetric: PGM（对数签名）
│
├─ c) More Algorithms（更多算法）
│   ├─ 1) Encryption: AES（GF(2^8) 群结构）
│   ├─ 2) Signature: ECC（椭圆曲线点群）
│   └─ 3) Hash Functions: MD4→MD5 / SHA-1→SHA-256
│
└─ d) More Cryptographic Practices
    ├─ 1) Padding
    └─ 2) KDF
```

---

## 段落间的"缝合"方式

每个子节结束时的过渡句模板（填入即可）：

- 从 a) → b)：*"The above principles—DHP, DLP, and CSP on non-abelian groups—form the theoretical foundation. We now turn to concrete algorithms built upon these ideas."*
- 从 b) → c)：*"Not all group-based algorithms fit neatly into the RSA–ElGamal–DSA mold. The following algorithms also rely on group structures, but in distinct ways."*
- 从 c) → d)：*"Knowing which algorithm to use is only part of the story. In practice, cryptographic systems also rely on auxiliary techniques that ensure the algorithms are used correctly."*

---

## a) The Principles（~700 words）

### a)1) Cyclic Groups — DHP（~200 words）

**概念**：Diffie–Hellman 问题——给定 $g^a, g^b$ 求 $g^{ab}$。

**讲解顺序**：
1. 用 DH 密钥交换协议引出问题：
   - Alice 选 $a$，发 $g^a$；Bob 选 $b$，发 $g^b$
   - 双方算 $g^{ab}$，窃听者不能
2. 为什么正确？$(g^b)^a = g^{ab} = (g^a)^b$
3. 为什么困难？"指数提取"是单向函数
4. [Derive] 推导正确性

**GTIC 参考**：p3 四步 DH 协议

**理解检查**：DHP 是 DH 协议从数学上可行的原因

**过渡到 DLP**：*"The difficulty of DHP depends on a more fundamental problem: given $g$ and $g^a$, can we find $a$?"*

### a)1) Cyclic Groups — DLP（~150 words）

**概念**：离散对数——给定 $g$ 和 $h = g^a$ 求 $a$。

**讲解顺序**：
1. 定义：实数对数易算，离散版本难
2. DHP 与 DLP 的关系：DLP ⇒ DHP（如果会求 $a$ 就能算 $g^{ab}$）
3. 哪些群上的 DLP 困难：$(\mathbb{Z}/p\mathbb{Z})^\times$（大 $p$）和 $E(\mathbb{F}_q)$

**GTIC 参考**：p3-4，DLP 难度与群的表示方式有关

**理解检查**：DLP 是比 DHP 更强的基础问题。ElGamal 和 DSA 的安全建在此上。

**过渡到 a)2)**：*"Both DHP and DLP are defined on abelian (commutative) groups. What if the group is non-abelian?"*

### a)2) Non-Abelian Groups — CSP（~150 words）

**概念**：共轭搜索问题——给定 $x$ 和 $y = g^{-1}xg$ 求 $g$。

**讲解顺序**：
1. 非阿贝尔群的定义回顾：不满足交换律
2. CSP 是 DLP 在非阿贝尔群中的类比：
   - DLP：$g^a$ 指数
   - CSP：$g^{-1}xg$ 共轭
   - 在阿贝尔群中 $g^{-1}xg = x$ → CSP 平凡
3. 量子动机：Shor 算法破解阿贝尔群上的 DLP，但非阿贝尔群不直接受 Shor 威胁

**GTIC 参考**：p4 "conjugation might be used instead of exponentiation"

**理解检查**：CSP 在非阿贝尔群中才有意义，是后量子密码的一个方向。

### a)2) Non-Abelian Groups — 三种协议（~200 words）

**概念**：Ko-Lee / AAG / Stickel——都是 DH 协议的非阿贝尔移植。

**讲解顺序**：

**Ko-Lee**（GTIC p5）：
- 需可交换子群 $A, B$（$ab = ba$ 对所有 $a \in A, b \in B$）
- 共享密钥 $k = a^{-1}b^{-1}gba$
- 平台群：辫群 $B_n$

**AAG**（GTIC p6）：
- 更灵活——无需预选子群
- 计算换位子 $[x,y] = x^{-1}y^{-1}xy$ 作为密钥

**Stickel**（GTIC p6-7）：
- $\mathrm{GL}(n, \mathbb{F}_q)$ 矩阵群
- $a^{l+r} g b^{m+s}$ 两侧乘
- 简单但已被 Shpilrain 攻击破解

**理解检查**：三种协议展示 DH 思想如何在非阿贝尔世界中变形。

**过渡到 b)**：*"These principles—DHP, DLP, and CSP on non-abelian groups—form the theoretical foundation. We now turn to concrete algorithms built upon these ideas."*

---

## b) Group-based Algorithms（~400 words）

### b)1) Asymmetric Key Cryptography（~300 words）

**总体说明**：每个算法三段式——群结构 + 核心公式 + 安全归约。复杂度留给 §2。

#### RSA（~100 words）[Derive]

1. 群结构：$(\mathbb{Z}/n\mathbb{Z})^\times$，$n = pq$
2. 公式：$c = m^e \bmod n$，$m = c^d \bmod n$，$ed \equiv 1 \pmod{\varphi(n)}$
3. [Derive] 推 $c^d \equiv m^{ed} \equiv m \pmod{n}$（Euler 定理）
4. 安全归约：分解 $n$ → 破解 RSA，逆向未证明但广泛相信等价

**AOGTICA 参考**：p2-3（但 AOGTICA 说 RSA 不用群论——不准确，$(\mathbb{Z}/n\mathbb{Z})^\times$ 就是乘法群）

#### ElGamal（~100 words）[Derive]

1. 群结构：循环群 $\langle g \rangle \subset (\mathbb{Z}/p\mathbb{Z})^\times$
2. 公式：$y = g^x$，$c_1 = g^k$, $c_2 = m \cdot y^k$，$m = c_2 \cdot (c_1^x)^{-1}$
3. [Derive] 推导正确性：$m \cdot g^{xk} \cdot (g^{kx})^{-1} = m$
4. 特点：随机化加密（$k$ 随机 → 同一明文不同密文）

**AOGTICA 参考**：p3 三步描述

#### DSA（~100 words）[Derive]

1. 参数：素数 $p$，大素因子 $q \mid p-1$，$g$ 阶为 $q$
2. 签名：$r = (g^k \bmod p) \bmod q$，$s = k^{-1}(H(m) + xr) \bmod q$
3. 验证：$u_1 = H(m) \cdot s^{-1}$，$u_2 = r \cdot s^{-1}$，$v = (g^{u_1}y^{u_2} \bmod p) \bmod q$，检查 $v = r$
4. [Derive] 推导验证正确性
5. 与 ElGamal 结构类似，但用更小的子群（$q$ 通常 256-bit）

**AOGTICA 参考**：p5 流程描述

### b)2) Symmetric Cryptography — PGM（~100 words）[Cite]

**概念**：对数签名是 DLP 的推广，用于构造 PGM（置换群映射）对称密码。

**讲解顺序**：
1. 对数签名：对有限群 $G$ 选序列 $\alpha = [A_1, \ldots, A_s]$，每个元素唯一表示为每个 $A_i$ 中选一个的乘积
2. PGM = 直接用对数签名构造的对称密码
3. [Cite] 细节引用 Magliveras [53] 或 GTIC p7-8

**GTIC 参考**：p7-8 对数签名正式定义

**过渡到 c)**：*"Not all group-based algorithms fit neatly into the RSA–ElGamal–DSA–PGM mold. The following algorithms also rely on group structures, but in distinct ways."*

---

## c) More Algorithms（~500 words）

### c)1) Encryption — AES（~150 words）[Derive]

**概念**：AES 使用 $\mathrm{GF}(2^8)$ 上的加法群和乘法群。

**讲解顺序**：
1. 有限域 $\mathrm{GF}(2^8)$：字节 = 域元素
2. 两个群结构：
   - $(\mathrm{GF}(2^8), +)$：初等阿贝尔 $2$-群，阶 $256$
   - $(\mathrm{GF}(2^8)^\times, \cdot)$：循环群，阶 $255$
3. [Derive] S-box：在 $\mathrm{GF}(2^8)$ 中求逆 → $\mathbb{F}_2^8$ 上仿射变换
4. 安全来源：混淆 + 扩散，不归约到群困难问题

**AOGTICA 参考**：p4（AES 群论分析较浅，建议结合 GTIC p8 置换群结构）

### c)2) Signature — ECC（~150 words）[Sketch]

**概念**：ECC 使用椭圆曲线上的点群，安全基于 ECDLP。

**讲解顺序**：
1. 曲线方程 $y^2 = x^3 + ax + b$（$\mathbb{F}_q$ 上）
2. 群结构 $E(\mathbb{F}_q) = \{(x,y) : y^2 = x^3 + ax + b\} \cup \{\mathcal{O}\}$
3. 群运算（弦切群律）：
   - 点加 $P+Q$ 和倍点 $2P$
   - [Sketch] 几何描述即可，完整推导引用标准教材
4. ECDLP：给定 $P$ 和 $Q = kP$ 求 $k$
5. 优势：256-bit ECC ≈ 3072-bit RSA

**注意**：ECC 在 docx 中放在 c)2) Signature 下，不是 b)1) Asymmetric！

**AOGTICA 参考**：p4（密钥生成/加密/解密三步结构，但群结构代数细节不够）

### c)3) Hash Functions — MD4→MD5 / SHA-1→SHA-256（~200 words）

**概念**：哈希函数的迭代构造与其群论载体。

**讲解顺序**：
1. Merkle–Damgård：输入分块 → 压缩函数迭代
2. MD4（1990）→ MD5（1991）：更多轮数、更复杂非线性函数
3. SHA-1（1995）→ SHA-256（2002）：160→256-bit，结构更复杂
4. 群结构：$(\mathbb{Z}/2^{32}\mathbb{Z}, +)$ — 运算的载体但不构成安全假设
5. 安全来自混淆 + 扩散，不来自困难问题

**理解检查**：哈希函数在群论中参与较浅——它们使用群运算作为基本构件，但安全性不归约到群上的困难问题。

**过渡到 d)**：*"Knowing which algorithm to use is only part of the story. In practice, cryptographic systems also rely on auxiliary techniques that ensure the algorithms are used correctly."*

---

## d) More Cryptographic Practices（~400 words）

### d)1) Padding（~200 words）

**概念**：填充确保明文长度符合算法要求，同时防止某些攻击。

**讲解顺序**：
1. **为什么需要填充**：
   - RSA：教科书 RSA 是确定性加密 → 选择明文攻击可区分密文
   - 消息长度必须小于 $n$（RSA）或对齐块大小（AES）
2. **几种填充方案**：
   - **PKCS#1 v1.5**：RSA 传统填充——但存在 Bleichenbacher 攻击（1998，填充预言攻击）
   - **OAEP**（Optimal Asymmetric Encryption Padding）：RSA 的安全填充——Feige–Fiat–Shamir 范式，可证明安全（随机预言模型）
   - **PKCS#7**：AES 等对称密码的块对齐填充
3. [Cite] OAEP 可证明安全性引用 Bellare–Rogaway 1994

**GTIC 参考**：p9-10 关于 Bleichenbacher 攻击的讨论

### d)2) KDF（Key Derivation Functions）（~200 words）

**概念**：KDF 从共享秘密导出会话密钥。

**讲解顺序**：
1. **为什么需要 KDF**：
   - DH 协商出的 $g^{ab}$ 是一个群元素，不是适合直接用作对称密钥的均匀随机比特串
   - 需要从"群元素"映射到"密钥"
2. **典型构造**：
   - **HKDF**（RFC 5869）：提取-扩展（extract-then-expand）两阶段
     - 提取阶段：HMAC 将输入熵浓缩为固定长度伪随机密钥
     - 扩展阶段：伪随机密钥通过迭代 HMAC 产生所需长度的输出
   - 哈希函数在 KDF 中起核心作用——连接"群协议输出"和"对称密钥"
3. [Cite] HKDF 细节引用 Krawczyk–Eronen 2010（RFC 5869）

**理解检查**：Padding 和 KDF 不是加密算法本身，但它们是加密系统正确运作的必备组件——缺少它们，即使是 RSA 或 AES 也可能被攻破。

---

## 过渡到 §2

*"This section has surveyed the group-theoretic foundations and concrete algorithms that form the backbone of modern cryptography. However, knowing the formulas is not enough. The next section examines the properties of these algorithms—their time complexity, security levels, and practical applications—to provide a basis for comparison."*

---

## 交叉引用

| 参考 | 用途 |
|:---|:---|
| [[密码算法群结构分析/03-研究报告/03-论文结构大纲]] | 总大纲 |
| [[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] | DHP p3 / DLP p3-4 / CSP p4 / Ko-Lee p5 / AAG p6 / Stickel p6-7 / PGM p7-8 / Bleichenbacher p9-10 |
| [[密码算法群结构分析/03-研究报告/AOGTICA-注释翻译]] | RSA p2-3 / ElGamal p3 / DSA p5 / AES p4 / ECC p4 |
| [[密码算法群结构分析/03-研究报告/Section-2-Properties-and-Applications]] | 复杂度与安全分析（本节不展开） |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] | 证明条目索引 |
| [[密码算法群结构分析/03-研究报告/证明方法细则]] | Derive/Sketch 实现细节 |
