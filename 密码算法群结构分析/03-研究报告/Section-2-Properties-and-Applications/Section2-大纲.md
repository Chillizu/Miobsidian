---
title: "Section 2: Properties and Applications — 写作指导"
date: 2026-07-15
---

# Section 2: Properties and Applications — 写作指导

> 目标：~600 words。编号对应 docx：2) a) Properties → b) Applications → c) Cryptanalysis。
> 核心参考文献：[[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] p9-11、[[密码算法群结构分析/03-研究报告/AOGTICA-注释翻译]] p5-6、[[密码算法群结构分析/03-研究报告/证明与计算清单]] §2.1–2.2

---

## 本节逻辑总图

```
2) Section 2: Properties and Applications
│
├─ a) Properties（属性对比）
│   ├── 渐进复杂度如何比：不同算法的"快慢"从何来
│   └── 等效安全如何比：为什么 ECC 256-bit = RSA 3072-bit
│
├─ b) Applications（应用场景）
│   └── 每个算法用在哪 = 判断"我应该选哪个"
│
└─ c) Cryptanalysis（密码分析 = 攻击怎么看这些算法）
    ├── 经典攻击：哪些已破、哪些还没破
    └── 量子威胁：为什么 Shor 是结构性问题（回指 §1 a)2)）
```

**这是"比较分析"章——目的不是复述 §1 的公式，而是横着比。**

---

## 段落间的"缝合"方式

- 从 a) → b)：*"Performance and security are not abstract metrics—they translate directly into real-world suitability. Let us see where each algorithm is deployed."*
- 从 b) → c)：*"However, the widespread deployment of these algorithms does not mean they are invulnerable. The next subsection examines how they can be—and have been—attacked."*
- 从 c) → §3：*"So far, we have examined the mathematical principles and practical properties of these algorithms. But theory alone is not enough—let us put them to the test."*

---

## a) Properties（~200 words）

**要传达的概念**：不同算法的"快慢"和"安全" = 渐近复杂度 × 密钥长度。不能只看算法名字判断哪个快——要看群运算的代价。

**讲解顺序**：

1. **先讲复杂度表**（不要直接丢表——先引问题）：
   - "两个算法都说自己安全，为什么实际中一个比另一个快几十倍？"
   - 答案在渐近复杂度——这是给出表的前提

2. **表 1：渐进复杂度对比**

| 算法 | 核心运算 | 渐近复杂度 | 直觉解释 |
|:---|:---|:---:|:---|
| RSA | 平方-乘法模幂 | $O(\log^3 n)$ | $n$ 为 2048-bit |
| ElGamal | 2–3 次模幂 | $O(\log^3 p)$ | 约为 RSA 的 2× |
| DSA | 模幂（短指数 $q$） | $O(\log q \cdot \log^2 p)$ | $q$ 仅 256-bit → 比 RSA 快 |
| ECC | 倍点-加法标量乘 | $O(\log^3 q)$ | $\log q = 256 \ll \log n = 3072$ |
| AES | SPN 固定轮 | $O(n)$ | 10/12/14 轮，线性于消息长度 |
| MD5/SHA | Merkle–Damgård | $O(n)$ | 步数固定，线性于消息长度 |

3. **逐行解释表中的每一行**：
   - RSA/ElGamal/DSA 都是 $(\mathbb{Z}/p\mathbb{Z})^\times$ 中的模幂 → 复杂度同为 $\log$ 的三次方 → **量级相同但常数不同**
   - ECC 的关键优势：$\log q = 256$，而 RSA 的 $\log n = 3072$ → $256^3 \ll 3072^3$，差一个数量级 [Derive: C8]
   - AES/SHA 是线性时间 → 比非对称快多个数量级 → 这就是"握手用非对称，通信用对称"的根本原因 [Cite: C10, C11]

4. **过渡到安全表**："But speed is only half the story—a fast algorithm is useless if it is insecure."

5. **表 2：等效安全对比**

| 算法 | 密钥长 | 等效对称安全 | 解释 |
|:---|:---:|:---:|:---|
| RSA-2048 | 2048-bit | ~112 bits | NIST 2023 前可接受 |
| RSA-3072 | 3072-bit | 128 bits | 当前推荐 |
| ECC-256 | 256-bit | 128 bits | 等效于 RSA-3072 |
| ECC-384 | 384-bit | 256 bits | 等效于 RSA-15360 |
| AES-128 | 128-bit | 128 bits | 自身就是基准 |
| AES-256 | 256-bit | 256 bits | 配额级安全 |

6. **逐行解释**：
   - "等效对称安全" = 把该算法的破解难度换算成"暴力穷举多少 bit 的对称密钥"
   - ECC 用 256-bit 密钥达到 RSA 3072-bit 的安全等级 → ECC 成为主流的数学原因 [Sketch: C14]
   - 注意 RSA-2048 只有 112-bit → 建议迁移到 RSA-3072 或 ECC

**这段写完后读者应理解**：算法选型 = 安全等级 × 性能 → 需要综合考虑。ECC 在非对称密码中综合最优。对称密码比非对称块多个数量级——但两者安全等级接近时不冲突（各有用途）。

**引用**：
- GTIC p9-10（GNFS 攻击的复杂度）
- 证明清单 C1–C11（复杂度推导），C14（等效安全）

---

## b) Applications（~200 words）

**要传达的概念**：每个算法有典型用途——选算法不只是数学题，还是工程题。RSA→ECC 迁移进行中，MD5/SHA-1 已不可用。

**讲解顺序**：

1. **先引问题**："If ECC is faster and more secure than RSA, why do we still use RSA?"
   - 答案：历史原因 + 兼容性 + 标准迁移慢
   - RSA 至今仍在 TLS 证书和传统 PKI 中占重要位置

2. **表 3：应用场景**

| 算法 | 典型应用 | 角色 |
|:---|:---|:---:|
| RSA | TLS 证书、传统 PKI、密钥传输 | 身份认证 / 密钥封装 |
| ElGamal | PGP/GnuPG 加密（非默认）| 公钥加密 |
| DSA | 美国政府数字签名标准（FIPS 186）| 签名 |
| ECC (ECDH/ECDSA) | TLS 1.3、Bitcoin（secp256k1）、iOS/Android 安全区 | 密钥协商 / 签名 |
| AES | 文件加密、磁盘加密、TLS 对称会话 | 对称加密 |
| MD5 | 仅校验和（已禁用签名用途）| 完整性（弱）|
| SHA-256 | Bitcoin PoW、TLS 证书签名、软件完整性验证 | 哈希 |

3. **逐行解释**：
   - RSA 正在被 ECC 取代——TLS 1.3 默认使用 ECDHE（密钥协商）+ ECDSA（证书签名），RSA 仅作备选
   - Bitcoin 使用 ECDSA（secp256k1 曲线）——是 ECC 最大规模的单例部署
   - DSA 本质上是 ElGamal 的签名变体——只在签名场景使用

4. **postquantum.com 引用**（docx 要求）：
   - 在 b) 段末尾引用 postquantum.com 关于 ECC 在 TLS 和区块链中的部署说明
   - 样式："For a detailed overview of how ECC secures modern digital infrastructure, see the analysis at [postquantum.com]..."

**这段写完后读者应理解**：用户每天在用这些算法——打开网页（TLS=ECC+RSA）、发消息（AES）、查比特币（SHA-256+ECC）——检测不到它们的存在正是密码学成功的标志。

**引用**：
- postquantum.com（docx 指定）
- AOGTICA p5-6（安全属性讨论，参考框架）

---

## c) Cryptanalysis（~200 words）

**要传达的概念**：两个层面的威胁——经典算法攻击（亚指数/指数/已破）和量子攻击（结构性的）。阿贝尔群密码在量子前统一脆弱。

**讲解顺序**：

1. **经典攻击表**

| 算法 | 最优经典攻击 | 复杂度等级 | 风险状态 |
|:---|:---|:---:|:---:|
| RSA | GNFS 分解 [Sketch: C12] | 亚指数 | 密钥 > 2048-bit 仍安全 |
| DLP (Zp) | GNFS-DLP [Cite: C13] | 亚指数 | 密钥 > 2048-bit 仍安全 |
| ECDLP | Pollard-$\rho$ [Derive: C16] | 指数 $O(\sqrt{q})$ | 密钥 > 256-bit 仍安全 |
| AES | Biclique / 穷举 [Cite: C18] | $2^{126.1}$ | 安全 |
| MD5 | 差分碰撞 [Cite: C19] | $2^{39}$ | 已破（见 §3）|
| SHA-1 | 差分碰撞 [Cite: C20] | $2^{63}$ | 已破（见 §3）|
| SHA-256 | 生日攻击 [Derive: C17] | $2^{128}$ | 安全 |

2. **逐行解释**：
   - "亚指数" = $L_n[1/3, 1.923]$：比多项式慢、比指数快——这意味着 RSA 需要超大密钥来补偿
   - "指数" = $O(\sqrt{q})$：增长速度让 ECC 用短密钥就够
   - "已破"（MD5/SHA-1）= 已产生实际碰撞，在 §3 实验验证

3. **量子威胁表**

| 量子攻击 | 影响对象 | 效果 |
|:---|:---|:---|
| Shor 算法 [Sketch: C21] | RSA / DH / DSA / ECC | 多项式时间破解——结构性的 |
| Grover 算法 [Cite: C22] | AES / SHA | 平方根加速（AES-256 → 128-bit）|
| 非阿贝尔 HSP [Cite: C23] | 非阿贝尔群密码 | 无通用多项式量子算法 |

4. **三段论**（这是 c) 的核心论点——连接 §1 a)2) 非阿贝尔群动机）：
   - 前提 1：Shor 算法利用阿贝尔群的隐藏子群结构来破解 DLP 和分解 [Sketch: C21]
   - 前提 2：非阿贝尔群的 HSP 没有通用多项式量子算法
   - 结论：非阿贝尔群密码（CSP/Ko-Lee/AAG/Stickel）是后量子方向之一——但尚未成熟
   - 这也是 §1 a)2) 中引入 CSP 的根本动机

**这段写完后读者应理解**：经典攻击可以靠大密钥对抗——但量子攻击是结构性的。"把 RSA 密钥翻倍"对 Shor 没帮助。这就是 §1 a)2) 非阿贝尔群密码和后量子密码研究的根本原因。

**引用**：
- GTIC p9-10（辫群密码分析），p10-11（Stickel/MST 分析）
- 证明清单 C12–C23（安全复杂度全部条目）

---

## 过渡到 §3

*"So far, we have examined the mathematical principles and practical properties of these algorithms. But theory alone is not enough—let us put them to the test."*

---

## 交叉引用

| 参考 | 用途 |
|:---|:---|
| [[密码算法群结构分析/03-研究报告/03-论文结构大纲]] | 总大纲 |
| [[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] p9-11 | 密码分析详情（GNFS、辫群攻击、MST 分析）|
| [[密码算法群结构分析/03-研究报告/AOGTICA-注释翻译]] p5-6 | 安全属性框架（参考框架）|
| [[密码算法群结构分析/03-研究报告/Section-1-Cryptographic-Algorithms]] §a)2) | 非阿贝尔群动机——被 c) 三段论引用 |
| [[密码算法群结构分析/03-研究报告/Section-3-Testing]] | 实验验证——MD5/SHA-1 碰撞验证 c) 的"已破"声明 |
| [[密码算法群结构分析/03-研究报告/Conclusion]] | 量子威胁 → 后量子密码展望 |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] §2.1 | 复杂度条目 C1–C11 |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] §2.2 | 安全条目 C12–C23 |
