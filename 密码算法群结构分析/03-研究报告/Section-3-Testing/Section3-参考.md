---
title: "Section 3: Testing — 完整参考"
date: 2026-07-15
---

# Section 3: Testing — 完整参考

> 本节包含两个实验方向，四个攻击实例。以下按概念、参数、攻击方法、关键数据、引用顺序列出所有必要信息。

---

## 一、结构总览

```
Section 3: Testing
│
├─ a) Hash Collision
│   ├── 1) MD4 collision (Wang 2005)
│   └── 2) SHA-1 collision (SHAttered 2017)
│
└─ b) Inappropriate Parameters
    ├── 1) Small-prime DLP (baby-step GS / Pohlig–Hellman)
    └── 2) Anomalous ECC curve (Smart's p-adic lift)
```

---

## 二、关键概念速查

### a) 哈希碰撞

| 术语 | 定义 | 关联实验 |
|:---|:---|---:|
| 碰撞 (collision) | $H(x) = H(y)$ 且 $x \neq y$ | a)1) MD4, a)2) SHA-1 |
| 差分攻击 (differential) | 分析输入差异 → 输出差异的传播路径 | a)1) Wang 2005 |
| 差分路径 (differential path) | 精确描述差异如何穿过每轮压缩函数 | a)1), a)2) |
| 消息扩展 (message schedule) | 将 16 words → 64/80 words 放大微小差异 | 解释 SHA-256 抵抗原因 |
| Merkle–Damgård | 迭代哈希构造：$H_i = f(H_{i-1}, M_{i-1})$ | MD4, SHA-1, SHA-256 共用 |

### b) 参数不当攻击

| 术语 | 定义 | 关联实验 |
|:---|:---|---:|
| Baby-step giant-step | DLP 求解：$O(\sqrt{p})$ 时间 + $O(\sqrt{p})$ 空间 | b)1) |
| Pohlig–Hellman | 利用 $p-1$ 的平滑分解 → 多个小子群 DLP | b)1) |
| 异常曲线 (anomalous) | $|E(\mathbb{F}_p)| = p$ 的特殊椭圆曲线 | b)2) |
| $p$-adic lift | 将 $\mathbb{F}_p$ 上的曲线提升到 $\mathbb{Q}_p$ 上的形式群 | b)2) Smart 攻击 |
| Hasse 不等式 | $| |E(\mathbb{F}_q)| - (q+1) | \leq 2\sqrt{q}$ | b)2) 对比正常范围 |

---

## 三、算法参数速查

| 算法 | 输出 | 轮数 | 状态 | 碰撞复杂度 | 引用 |
|:---|:---:|:---:|:---:|:---:|:---:|
| MD4 | 128-bit | 3 轮, 48 步 | **已破** | $2^{39}$ | Wang 2005 |
| MD5 | 128-bit | 4 轮, 64 步 | **已破** | $2^{39}$ (2004) / $2^{16}$ (chosen-prefix) | Wang 2004, Stevens 2009 |
| SHA-1 | 160-bit | 80 轮 | **已破** | $2^{63}$ | SHAttered 2017 |
| SHA-256 | 256-bit | 64 轮 | 安全 | $2^{128}$ (生日) | — |

| 系统 | 安全参数 | 攻击参数 | 破解时间 | 引用 |
|:---|:---:|:---:|:---:|:---:|
| DLP in $(\mathbb{Z}/p\mathbb{Z})^\times$ | $p \geq 2048$-bit | $p = 32$-bit | 秒级 | HAC Ch.3 |
| ECDLP on $E(\mathbb{F}_q)$ | 标准曲线 (P-256) | 异常曲线 ($|E|=p$) | $O(\log p)$ | Smart 1999 |

---

## 四、攻击详解

### a)1) MD4 碰撞 — Wang et al. 2005

**论文**：Wang, Lai, Feng, Chen, Yu. "Cryptanalysis of the Hash Functions MD4 and RIPEMD". EUROCRYPT 2005 (Best Paper Award).

**核心思想**：
1. 构造差分路径：选择 $M$ 和 $M'$ 的消息差异 $\Delta m_1 = 2^{31}$, $\Delta m_2 = 2^{31} - 2^{28}$, $\Delta m_{12} = -2^{16}$
2. 推导充分条件集（共 122 个比特条件）确保差分路径成立
3. 使用消息修改技术（单步 + 多步）将成功率从 $2^{-122}$ 提升到 $2^{-2} \sim 2^{-6}$

**关键突破**：首次将"精确差分"概念引入哈希分析——不仅追踪差异，还追踪具体的比特值。这种方法后来被用于破解 MD5、SHA-0、SHA-1。

**对照实验**：SHA-256 对同一组消息不产生碰撞 → 消息扩展和复杂非线性函数提供足够抵抗。

### a)2) SHA-1 碰撞 — SHAttered 2017

**论文**：Stevens, Bursztein, Karpman, Albertini, Markov. "The first collision for full SHA-1". CRYPTO 2017.

**计算投入**：
- ~$2^{63.1}$ SHA-1 压缩函数调用
- ≈ 6500 CPU-years + 100 GPU-years
- 约 $US$ 75K–110K（按 AWS spot pricing）

**攻击流程**：
1. 选择扰动向量 (Disturbance Vector) II(52,0)
2. 构建非线性差分路径（前 16 步连接初始链接值差和线性部分）
3. 使用联合局部碰撞分析 (JLCA) 最大化线性部分成功率
4. 大规模 GPU 分布式搜索
5. 两个近碰撞块对完成全部碰撞

**影响**：
- Git 使用 SHA-1 作为 commit id → 理论上可伪造 commit，实践中极难
- TLS 证书 → CABForum 禁止新发 SHA-1 证书（2017 起）
- PDF 碰撞 → 可制作两份视觉不同但哈希相同的 PDF

### b)1) 小素数 DLP

**两种攻击算法**：

| 算法 | 时间 | 空间 | 条件 |
|:---|:---:|:---:|:---|
| Baby-step giant-step | $O(\sqrt{p})$ | $O(\sqrt{p})$ | 无 |
| Pohlig–Hellman | $O(\sum e_i(\log p + \sqrt{p_i}))$ | $O(\log p)$ | $p-1$ 平滑可分解 |

**实验设计**：
- 目标群：$(\mathbb{Z}/p\mathbb{Z})^\times$，$p = 2^{32} - 5$（32-bit）
- 目标计算：给定 $g, g^a$，求 $a$
- 使用 baby-step giant-step → $2^{16}$ 次群运算 ≈ 几秒
- 对比：$p = 2^{2048}$ → $2^{1024}$ 次群运算 → 不可行

**安全含义**：
- DLP 的"困难"是计算层面的，不是数学层面的
- 安全参数：$p \geq 2048$-bit，且 $p-1$ 至少有一个大素因子

### b)2) 异常曲线攻击 — Smart 1999

**论文**：Smart, N. P. "The Discrete Logarithm Problem on Elliptic Curves of Trace One". Journal of Cryptology 12(3), 1999.

**攻击条件**：$E(\mathbb{F}_p)$ 是异常曲线，即 $\#E(\mathbb{F}_p) = p$（Hasse 不等式边界情况）。

**攻击步骤**：
1. 将 $\mathbb{F}_p$ 上的椭圆曲线提升到 $p$-adic 数 $\mathbb{Q}_p$ 上的形式群
2. 构造群同态：$E(\mathbb{F}_p)_{\text{anom}} \to \mathbb{F}_p^+$
3. 在该同态下，ECDLP 变为加法群中的 DLP
4. 加法群中求解：$k = Q \cdot P^{-1} \pmod{p}$

**复杂度**：$O(\log p)$（多项式时间）vs 正常 ECDLP $O(\sqrt{p})$（指数时间）。

**防御**：选择非异常曲线——概率 $1/\sqrt{p}$，NIST P-256/P-384、Curve25519 等标准曲线均受保护。

---

## 五、论文引用表

| # | 引用 | 链接 | 提及位置 |
|:---|:---|---|:---:|
| C19 | Wang et al. 2005, MD4 collision | [iacr.org](https://iacr.org/archive/eurocrypt2005/34940001/34940001.pdf) | a)1) |
| C20 | SHAttered 2017, SHA-1 collision | [shattered.io](https://shattered.io/static/shattered.pdf) | a)2) |
| C24 | HAC Ch.3 — DLP algorithms | [cacr.uwaterloo.ca](https://cacr.uwaterloo.ca/hac/about/chap3.pdf) | b)1) |
| C25 | Smart 1999, anomalous curve attack | [doi:10.1007/s001459900052](https://doi.org/10.1007/s001459900052) | b)2) |

---

## 六、与正篇的交叉连接

| 本节点 | 关联的正篇节点 | 关系 |
|:---|:---|---:|
| a) 哈希碰撞实验 | §2 c) Cryptanalysis 安全表 | 实验验证 MD5/SHA-1"已破"声明 |
| a) MD4 分析 | §1 c)3) Hash Functions | 展示哈希设计原理的实际后果 |
| b)1) 小素数 DLP | §1 a)1) DHP/DLP | 验证 DLP 参数依赖理论 |
| b)2) 异常曲线 | §1 c)2) ECC 理论 | 验证参数选择关键性 |
| a)+b) 全部实验 | Conclusion | 经典攻击实验 → 引向量子威胁 |
