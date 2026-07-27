---
tags: [infrastructure, gpu, aws, guide]
status: running
phase: 3
date: 2026-07-27
---
# AWS GPU 使用指南

> **Phase 3 实验专用 GPU 实例操作手册。** 所有实验均在 AWS g4dn.xlarge (T4 15GB) 上运行，通过 tmux + SSH 管理。

## Instance Specification

| 参数 | 值 |
|------|-----|
| 实例类型 | g4dn.xlarge |
| GPU | NVIDIA T4 (15GB VRAM) |
| vCPU | 4 (Intel Cascade Lake) |
| RAM | 16 GB |
| 实例 ID | `i-0cbdb085a1e726bef` |
| 公网 IP | `44.211.123.115` |
| 区域 | us-east-1 |
| AMI | Deep Learning AMI (Ubuntu 22.04) |
| 存储 | 64GB gp3 (EBS) |

**为什么选 g4dn.xlarge？** Qwen2.5-0.5B-Instruct + LoRA 推理约需 2-3GB VRAM，T4 15GB 完全够用且成本可控（$0.526/hr）。更大实例（g5.xlarge ~$0.82/hr）对 0.5B 模型无意义。

## Launch Process

### 通过 AWS Console
1. EC2 Dashboard → Launch Instance
2. AMI: 搜索 "Deep Learning AMI (Ubuntu 22.04)"
3. Instance type: g4dn.xlarge
4. Key pair: 已有或创建新 key pair
5. Network: 默认 VPC
6. Security group: 只开放 SSH (22)，Source = 你的 IP
7. Storage: 64GB gp3
8. 启动

### 通过 aws-cli
```bash
aws ec2 run-instances \
  --image-id <DL-AMI-ID> \
  --instance-type g4dn.xlarge \
  --key-name <your-key> \
  --security-group-ids <sg-id> \
  --block-device-mappings 'DeviceName=/dev/xvda,Ebs={VolumeSize=64,VolumeType=gp3}'
```

### 成本
| 项目 | 费用 |
|------|------|
| g4dn.xarge on-demand (Linux, us-east-1) | ~$0.526/hr |
| EBS 64GB gp3 | ~$0.01/hr |
| N=5 实验 (20 episodes, ~1.5h) | ~$0.79 |
| N=20 实验 (80 episodes, ~4h) | ~$2.10 |
| Phase 3 总预估 | **$5-10** |
| 数据传输 | 可忽略（JSONL 文件仅 KB 级） |
> [!tip] 成本优化
> Phase 3 总预估仅 **$5-10**（on-demand）。SPOT 实例价格更低（~$0.26/hr），但长实验建议用 on-demand 避免中断。
>
> **实验后立即关机**：`aws ec2 stop-instances --instance-ids i-0cbdb085a1e726bef`
>

> SPOT 实例价格更低（~$0.26/hr），但可能被中断。长实验（N=20, ~4h）建议用 on-demand。

## SSH Quirks

### EC2 Instance Connect (推荐)
EC2 Instance Connect 生成的 SSH key 只有 **60 秒有效期**：

```bash
# Step 1: Push public key (在本地执行)
aws ec2-instance-connect send-ssh-public-key \
  --region us-east-1 \
  --instance-id i-0cbdb085a1e726bef \
  --instance-os-user ubuntu \
  --ssh-public-key file://~/.ssh/id_rsa.pub

# Step 2: SSH (在 key 过期前执行)
ssh ubuntu@44.211.123.115
```

> [!warning] SSH Key 有效期 60 秒
> EC2 Instance Connect 生成的 SSH key 只有 **60 秒有效期**。必须在 push key 后立即 SSH，否则 key 过期需要重新 push。
>
> 推荐使用 SSM Session Manager（不需要 IP）：`aws ssm start-session --target i-0cbdb085a1e726bef --region us-east-1`
>

### SSM Session Manager (不需要 IP)
```bash
aws ssm start-session --target i-0cbdb085a1e726bef --region us-east-1
```
### 默认用户
- **用户名**: `ubuntu`
- DL AMI 自带 `ec2-user` 和 `ubuntu`，但 `ubuntu` 是最稳定的

## Python Environment

**不要使用系统 Python。** DL AMI 自带一个预配置的 PyTorch + CUDA 环境：

```bash
# ✅ 正确的 Python
/opt/pytorch/bin/python --version
# 输出: Python 3.11.x, CUDA 13.2, PyTorch 2.11+

# ❌ 不要使用
/usr/bin/python3
python3
```

### 检查 GPU
```bash
/opt/pytorch/bin/python -c "import torch; print(torch.cuda.is_available(), torch.cuda.get_device_name())"
# 输出: True NVIDIA T4
```

### 为什么不直接用 system python？
DL AMI 的 `/opt/pytorch/` 环境包含：
- CUDA 13.2 + cuDNN 预装
- PyTorch 2.11 预编译，与 CUDA 版本匹配
- 常用 ML 库（transformers, accelerate, peft）预装

用 system python 跑 PyTorch 会 fallback 到 CPU（慢 100×+）。

## tmux — 实验工作流（ESSENTIAL）

**规则：每次启动实验必须用 tmux。** SSH 断开连接会 kill 所有子进程，没有 tmux 的 4 小时实验会白跑。

```bash
# 创建新 session（实验开始）
tmux new -s peda

# 在 tmux 内运行实验
cd ~/Folunar_
/opt/pytorch/bin/python scripts/phase3_sandbox_experiment.py \
  --baseline peda --condition known --num-episodes 5

# Detach（Ctrl+B 然后 D）
# 实验在后台继续运行

# 重新 attach（稍后检查进度）
tmux attach -t peda

# 列出所有 session
tmux ls

# Kill session（实验完成后清理）
tmux kill-session -t peda
```

### 常用 tmux 快捷键
| 快捷键 | 功能 |
|--------|------|
| Ctrl+B → D | Detach（保持后台运行） |
| Ctrl+B → % | 垂直分屏 |
| Ctrl+B → " | 水平分屏 |
| Ctrl+B → 方向键 | 切换 pane |
| Ctrl+B → [ | 滚动查看历史输出 |
| Ctrl+B → c | 新建窗口 |
| Ctrl+B → n/p | 下一个/上一个窗口 |

## Docker Setup

沙箱实验依赖 Docker 容器模拟 Linux 环境：

```bash
# 构建镜像（第一次或更新 Dockerfile 后）
cd ~/Folunar_
docker build -t peda-sandbox:v2 -f Dockerfile.sandbox .

# 实验脚本自动创建容器，不需要手动 docker run
# 每个实验创建新容器（用完即弃）
```

**注意**: Docker socket 不挂载到容器内。`peda-sandbox:v2` 是基于 busybox 的只读容器，用于安全执行 shell 命令。

## 完整工作流示例

以下是 Phase 3 N=5 pilot 的完整流程（来自 `PEDA_WORKING_LOG.md`）：

```
1. AWS Console → Launch g4dn.xarge (DL AMI)
2. aws ec2-instance-connect send-ssh-public-key ...
3. ssh ubuntu@44.211.123.115
4. tmux new -s peda
5. cd ~/Folunar_
6. /opt/pytorch/bin/python scripts/phase3_sandbox_experiment.py \
     --baseline peda --condition known --num-episodes 5
7. Ctrl+B D  → detach（实验继续）
8. 等 ~1 小时后 tmux attach -t peda → 检查结果
9. 重复步骤 6-8 更换 --baseline/--condition 参数
```

### N=20 批量运行
```bash
# 使用批处理脚本（自动跑所有 4 个条件 × 20 episodes）
/opt/pytorch/bin/python scripts/phase3_n20.py
```

## Cost Tracking 最佳实践

1. **实验前**：检查实例是否在运行
   ```bash
   aws ec2 describe-instances --instance-ids i-0cbdb085a1e726bef --query 'Reservations[0].Instances[0].State.Name'
   ```

2. **实验后**：立即关机
   ```bash
   aws ec2 stop-instances --instance-ids i-0cbdb085a1e726bef
   ```

3. **彻底释放**：terminate（EBS 费用仍会产生直到 terminate）
   ```bash
   aws ec2 terminate-instances --instance-ids i-0cbdb085a1e726bef
   ```

4. **Cost Explorer**：us-east-1 → EC2-Other → g4dn.xarge 筛选

5. **预算**：建议设置 $10/month 的 AWS Budget 告警

## Related
- [[Phase 3 Sandbox N=5]]
- [[Phase 3 Sandbox N=20]]
- [[Phase 2 详细报告]]
- [[Phase Restructure v2.0]]

## Reference
- `PEDA_WORKING_LOG.md` — Phase 2 GPU 训练与 Phase 3 GPU 实验日志
- `scripts/phase3_sandbox_experiment.py` — 实验入口脚本
- `scripts/phase3_n20.py` — N=20 批处理
- `results/phase3_gpu/report.json` — Grid World 天花板效应数据
