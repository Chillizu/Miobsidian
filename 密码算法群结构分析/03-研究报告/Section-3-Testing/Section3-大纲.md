---
title: "Section 3: Testing — 写作指导"
date: 2026-07-15
---

# Section 3: Testing — 写作指导

> 目标：~600 words。编号对应 docx：3) a) Hash Collision → b) Inappropriate Parameters。
> 风格：实验报告——设置 → 执行 → 结果 → 分析。不写代码——陈述实验设计和结论。
>
> 核心参考文献：[[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] p8（哈希背景），[[密码算法群结构分析/03-研究报告/证明与计算清单]] §3（实验条目），Wang et al. 2005，SHAttered 2017

---

## 本节逻辑总图

```
3) Section 3: Testing
│
├─ a) Hash Collision in Weak MD4 and SHA-1
│   ├── MD4 碰撞：128-bit, 3 轮 → Wang 2005
│   └── SHA-1 碰撞：160-bit, 80 轮 → SHAttered 2017
│   （梯度展示：从极弱到中等弱，安全哈希不碰）
│
└─ b) Use Inappropriate Parameters to Test Asymmetric Ciphers
    ├── 小素数 DLP：Pohlig–Hellman / baby-step giant-step
    └── 弱 ECC 曲线（anomalous curve）：Smart 攻击
    （梯度展示：从参数太小到参数特殊，安全参数不受影响）
```

**统一主题**：理论说"这个算法安全"——实验验证：什么条件下它不安全？什么条件下它安全？

---

## 段落间的"缝合"方式

- 从 a) → b)：*"Hash collisions demonstrate the consequences of design flaws. A similar principle applies to asymmetric ciphers—incorrect parameter choices can render a mathematically sound algorithm insecure."*
- 从 b) → Conclusion：*"All experiments above demonstrate classical attacks. Under quantum threats, even correctly parameterized RSA, DH, DSA, and ECC become insecure—leading us to the need for post-quantum cryptography."*

---

## a) Hash Collision in Weak MD4 and SHA-1（~300 words）

**要传达的概念**：哈希碰撞不是理论可能性——对弱哈希（MD4、SHA-1），它是实际可操作的攻击。安全哈希（SHA-256）不受影响。

**讲解顺序（通用结构）**：

每个实验三步：
1. **设置**：这是什么哈希？输出多长？多少轮？
2. **结果**：碰撞已产生。对照实验（SHA-256 不碰撞）作为对比。
3. **分析**：为什么这个哈希被碰了？差分路径控制。SAR-256 为什么抵抗？

---

### a)1) MD4 碰撞（~150 words）

**实验目标**：展示极弱哈希如何被碰撞——MD4 的碰撞现在是几秒钟的事。

**讲解顺序**：

1. **设置**：
   - MD4（Rivest, 1990）：128-bit 输出，3 轮，每轮 16 步
   - Wang et al.（2005）差分攻击：分析消息差异如何在压缩函数中传播
   - [Cite: C19] 引用实际碰撞结果——不展示消息对（太长）

2. **结果**：
   - 两个视觉上完全不同的输入，MD4 哈希值完全相同
   - 对照：同样的输入用 SHA-256 计算 → 哈希值不同，无碰撞
   - MD4 碰撞复杂度：$2^{39}$——现代 CPU 几秒到几分钟 [Cite: C19]

3. **分析**：
   - 碰撞根源：**差分路径控制**——攻击者"引导"消息差异在压缩过程中相互抵消 [Derive: C19 底层思想]
   - MD4 只有 3 轮，非线性函数简单——差分路径容易构造
   - SHA-256 抵抗的原因：消息扩展（16→64 words）放大微小差异 + 6 种非线性函数混合更充分
   - 教训：不是轮数多就安全——轮数和函数需要精心设计才能抵抗差分分析

**这段写完后读者应理解**：MD4 已不可用。几秒就能碰撞。下次看到 MD4 签名 = 不安全。

---

### a)2) SHA-1 碰撞（~150 words）

**实验目标**：展示曾经是安全标准的 SHA-1 现已被攻破——160-bit 输出、80 轮也不够。

**讲解顺序**：

1. **设置**：
   - SHA-1（NIST, 1995）：160-bit 输出，80 轮
   - SHAttered（2017, Google + CWI）：生成两个不同 PDF，SHA-1 值相同
   - 碰撞复杂度：~$2^{63}$——约 110 GPU-年 [Cite: C20]

2. **结果**：
   - 碰撞存在——两 PDF（不同内容）的 SHA-1 完全相同
   - 不是理论攻击——Google 实际生成了碰撞对并公开（可引用不展示）

3. **分析**：
   - SHA-1 比 MD4 更难碰的原因：80 vs 3 轮、160 vs 128-bit
   - 但终究被碰 → 对 Git（SHA-1 作 commit id）的影响：理论有风险，实践中极难利用（需匹配 Git 对象格式）
   - SHA-256（$2^{128}$ 碰撞复杂度）是目前安全下限

**这段写完后读者应理解**：SHA-1 不应再被视为安全。碰撞成本远高于 MD4，但对有资源的攻击者可行。

**过渡到 b)**：*"Hash collisions demonstrate the consequences of design flaws. A similar principle applies to asymmetric ciphers—incorrect parameter choices can render a mathematically sound algorithm insecure."*

---

## b) Use Inappropriate Parameters to Test Asymmetric Ciphers（~300 words）

**要传达的概念**：安全算法 ≠ 任何参数下都安全。参数不当时，RSA/DH/ECC 不安全。正确参数时安全。

**讲解顺序（通用结构）**：

每个实验三步：
1. **设置**：使用"错误"的参数（小素数 / 异常曲线）
2. **执行**：攻击算法利用参数弱点
3. **结果 + 分析**：攻击成功。对比安全参数下的情况。

---

### b)1) 小素数 DLP（~150 words）

**实验目标**：展示 DLP 在不恰当的参数下不再困难——群太小 = DLP 容易。

**讲解顺序**：

1. **设置**：
   - 使用小素数 $p = 2^{32} - 5$（约 32-bit）
   - 选择生成元 $g$，公开 $g^a$
   - 目标：求 $a$
   - [Derive: 背景] DLP 的复杂度是 $O(\sqrt{p})$——32-bit 时 $2^{16}$ 次操作 = 几秒

2. **执行**（两种攻击方式选一即可）：
   - **Baby-step giant-step**：$O(\sqrt{p})$ 时间 + $O(\sqrt{p})$ 空间 [Derive: C3 变体]
   - **Pohlig–Hellman**（如果 $p-1$ 是平滑数）：分解 DLP 为多个小阶子群中的 DLP [Sketch: C15]

3. **结果**：
   - DLP 在 32-bit 素数的群中可在几秒内求解
   - 对比：2048-bit 素数的标准参数需 $2^{112}$ 次操作——当前不可行

4. **分析**：
   - DLP 的难度 = 群的大小（$p$ 的 bit 长度）× 群的结构（$p-1$ 是否有大素因子）
   - 即使大 $p$，如果 $p-1$ 是小素因子之积，Pohlig–Hellman 也大大降低难度
   - 实践要求：$p$ 至少 2048-bit，$p-1$ 至少有一个大素因子

**这段写完后读者应理解**：DLP 不是"数学上困难"——而是"在适当参数下计算上困难"。"困难"依赖参数选择，不是数学性质。

**过渡到 b)2)**：*"A similar parameter-dependence problem affects elliptic curve cryptography—but in a more subtle way. The curve itself can be the weakness."*

---

### b)2) 弱 ECC 曲线（~150 words）

**实验目标**：展示如果椭圆曲线选择不当（异常曲线），ECDLP 不再困难。

**讲解顺序**：

1. **设置**：
   - 选择一条异常曲线（anomalous curve）：$E(\mathbb{F}_p)$ 的阶等于 $p$
   - 正常情况下，Hasse 不等式：$|E(\mathbb{F}_q)|$ 在 $q+1 \pm 2\sqrt{q}$ 范围内
   - 阶等于 $p$ 是特殊情况——概率约 $1/\sqrt{p}$

2. **执行**：
   - Smart 攻击：将 $\mathbb{F}_p$ 上的椭圆曲线提升到 $p$-adic 数 $\mathbb{Q}_p$
   - ECDLP 映射到加法群 $\mathbb{F}_p^+$ 上的 DLP
   - 加法群上 DLP 的解是平凡的（$kP$ 就是 $k$ 次加法）[Derive: 群同态映射思想]

3. **结果**：
   - ECDLP 在异常曲线上可在 $O(\log p)$ 时间内求解——**多项式时间！**
   - 对比正常 ECDLP 需 $O(\sqrt{p})$（指数时间）

4. **分析**：
   - 该攻击对随机曲线无效——曲线阶等于 $p$ 的概率极低
   - 教训：ECC 安全依赖于曲线参数必须精心选择
   - 实践含义：使用 NIST 标准曲线（P-256/P-384）或 Curve25519——不要用未知来源的曲线

**这段写完后读者应理解**：ECC 安全前提是曲线正确。不能随便画条曲线就认为安全。

---

## 与整篇论文的连接

**a) 哈希碰撞 → §2 c) Cryptanalysis 安全表的验证**：
- §2 c) 写明 MD5 碰撞 $2^{39}$、SHA-1 $2^{63}$
- 实验实际产生了这些碰撞——验证了理论边界
- 对照：SHA-256 不碰撞 → 验证了 §2 表中 SHA-256 安全的说法

**b)1) 小素数 DLP → §1 a)1) DLP 理论的验证**：
- §1 a)1) 说 DLP 在哪些群上困难
- 实验展示"不良群"上的 DLP 容易（反向验证）

**b)2) 弱 ECC 曲线 → §1 c)2) ECC 理论的验证**：
- §1 c)2) 说 ECDLP 是 ECC 的安全基础
- 实验展示曲线参数的选择至关重要——不是所有 ECC 都安全

**a)+b) → Conclusion 量子威胁的引子**：
- 所有实验使用经典计算攻击
- 量子威胁下，即使是正确参数的 RSA/DH/ECC 也不安全
- 自然引出后量子密码的必要性

---

## 交叉引用

| 参考 | 用途 |
|:---|:---|
| [[密码算法群结构分析/03-研究报告/03-论文结构大纲]] | 总大纲 |
| [[密码算法群结构分析/03-研究报告/GTIC-注释翻译]] p8 | 哈希函数群论背景 |
| [[密码算法群结构分析/03-研究报告/Section-1-Cryptographic-Algorithms]] §a)1) | DLP 理论 → b)1) 小素数 DLP 实验验证 |
| [[密码算法群结构分析/03-研究报告/Section-1-Cryptographic-Algorithms]] §c)2) | ECC 理论 → b)2) 弱 ECC 曲线实验验证 |
| [[密码算法群结构分析/03-研究报告/Section-2-Properties-and-Applications]] §c) | 安全表 → a) 实验验证哈希碰撞声明 |
| [[密码算法群结构分析/03-研究报告/Conclusion]] | 实验 → 量子威胁 → 后量子密码 |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] §3.1 | 哈希碰撞实验条目 C19–C20 |
| [[密码算法群结构分析/03-研究报告/证明与计算清单]] §3.2 | 参数测试实验条目 C24–C26 |
