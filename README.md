# Dynamic PV Model Parameter Identification

**基于进化算法的光伏动态模型（整数阶/分数阶）参数辨识**

---

## 项目概述

本项目实现了 **光伏（PV）动态模型** 的 **参数辨识**，使用多种 **进化算法**（群智能优化算法）对光伏系统的阶跃响应电流数据进行拟合，识别出等效电路模型中的未知参数。

支持两种模型：

| 模型 | 参数数量 | 待辨识参数 |
|------|---------|-----------|
| **整数阶模型 (IO)** | 3 | R_c (接触电阻), C (电容), L (电感) |
| **分数阶模型 (FO)** | 5 | R_c, C_α (分数阶电容), L_β (分数阶电感), α, β (分数阶阶次) |

其中分数阶模型基于 **FOMCON 工具箱**（Fractional-Order Modeling and Control）进行分数阶传递函数的建模与仿真。

### 参考论文

- **Yousri, D., Allam, D., Eteiba, M.B. and Suganthan, P.N., 2019.** Static and dynamic photovoltaic models' parameters identification using Chaotic Heterogeneous Comprehensive Learning Particle Swarm Optimizer variants. *Energy Conversion and Management*, 182, pp.546-563.

- **AbdelAty, A.M., Radwan, A.G., Elwakil, A. and Psychalinos, C., 2016.** A fractional-order dynamic PV model. *39th International Conference on Telecommunications and Signal Processing (TSP)*, pp.607-610.

- **AbdelAty, A.M., Radwan, A.G., Elwakil, A.S. and Psychalinos, C., 2018.** Transient and steady-state response of a fractional-order dynamic PV model under different loads. *Journal of Circuits, Systems and Computers*, 27(02), p.1850023.

---

## 项目结构

```
Dynamic_model/
│
├── README.md                          # 本文件
│
├── main/                              # 入口脚本
│   ├── Main_SERLDE_I_F_O_dynamic.m    # SERLDE 算法（FO模型，含结果分析）
│   ├── Main_HCLPSO_I_F_O_dynamic.m    # HCLPSO 算法（含拟合图与误差图）
│   ├── Main_SEDE_I_F_O_dynamic.m      # SEDE 算法
│   ├── Main_PGJAYA_I_F_O_dynamic.m    # PGJAYA 算法
│   ├── Main_RLDE_I_F_O_dynamic.m      # RLDE 算法
│   ├── Main_RLSEDE_I_F_O_dynamic.m    # RLSEDE 算法
│   └── Main_RLPGJAYA_I_F_O_dynamic.m  # RLPGJAYA 算法
│
├── algorithms/                        # 优化算法实现
│   ├── HCLPSO.m       # Heterogeneous Comprehensive Learning PSO
│   ├── SEDE.m          # Self-adaptive DE with Ensemble of strategies
│   ├── PGJAYA.m        # Parameter-adaptive JAYA 算法
│   ├── PGJAYA1.m       # PGJAYA 变体（含混沌局部搜索）
│   ├── RLDE.m          # Reinforcement Learning DE
│   ├── RLSEDE.m        # Reinforcement Learning SEDE
│   ├── RLPGJAYA1.m     # Reinforcement Learning PGJAYA
│   └── SERLDE.m        # Self-adaptive Ensemble RL Differential Evolution
│
├── model/                             # PV 动态模型（目标函数）
│   ├── FO_Load_current_step.m         # 分数阶模型
│   └── IO_Load_current_step.m         # 整数阶模型
│
├── utils/                             # 工具函数
│   ├── group1.m        # DE 变异组1: rand/1/bin & current-to-rand/1
│   ├── group2.m        # DE 变异组2: current-to-best/1 & current-to-rand/1
│   ├── group3.m        # DE 变异组3: rand/1/bin & current-to-rand/1 (SERLDE)
│   ├── group4.m        # DE 变异组4: current-to-best 变体 (SERLDE, 含存档差分)
│   ├── boundConstraint1.m         # 边界约束处理（中点法）
│   ├── boundConstraint_absorb.m   # 边界约束处理（吸收法）
│   ├── data_process.m              # 统计结果处理（最小值/均值/标准差/最大值）
│   └── test.m                      # 简单测试脚本
│
├── data/                             # 实验数据与运行结果
│   ├── Load_current_2011_paper_big_time.csv   # 实测PV负载电流数据
│   ├── HCLPSO_FO_dynamic.mat         # HCLPSO 分数阶模型运行结果
│   ├── SEDE_FO_dynamic.mat           # SEDE 运行结果
│   ├── RLSEDE_FO_dynamic.mat         # RLSEDE 运行结果
│   └── Dynamic_HCLPSO.*              # HCLPSO 拟合图与误差图
│
├── docs/                             # 文档/笔记
│   └── HCLPSO.md                     # HCLPSO 算法代码笔记
│
└── fomcon-1.21b/                     # FOMCON 分数阶建模与控制工具箱 (v1.21b)
```

> **注意**：所有 `Main_*.m` 入口脚本已在文件头自动添加路径配置，运行前无需手动 addpath。
> 但首次使用时仍建议运行 `addpath(genpath('fomcon-1.21b/1.21b'))` 以确保 FOMCON 工具箱可用。

---

## 算法详解

| 算法 | 全称 | 核心机制 |
|------|------|---------|
| **HCLPSO** | Heterogeneous Comprehensive Learning PSO | 异构综合学习粒子群，两子群分别侧重探索与开发 |
| **SEDE** | Self-adaptive DE with Ensemble | 自适应差分进化，多变异策略组合（group1/group2），多组 F/CR 参数 |
| **PGJAYA** | Parameter-adaptive JAYA | 基于排名概率选择，向最优解靠近、远离最差解 |
| **RLDE** | Reinforcement Learning DE | Q-learning 自适应调整 F 参数（3动作：-0.1/0/+0.1） |
| **RLSEDE** | Reinforcement Learning SEDE | RL + SEDE 组合 |
| **RLPGJAYA** | Reinforcement Learning PGJAYA | RL + PGJAYA 组合（含混沌 logistic 映射局部搜索） |
| **SERLDE** | Self-adaptive Ensemble RLDE | 混合策略：存档差分向量 + Q-learning 自适应 F + 多变异组 |

### RL（强化学习）机制

所有 RL 变体使用 **Q-learning** 在线调整缩放因子 F：

- **状态（2个）**：上一代是否改进（成功=1，失败=2）
- **动作（3个）**：F 调整量（-0.1, 0, +0.1）
- **Q 表**：每个体独立维护 2×3 Q 表（2状态 × 3动作）
- **选择策略**：Softmax (Boltzmann) 探索
- **学习率 α** = 0.1，**折扣因子 γ** = 0.9
- **奖励**：若新个体适应度更优 → R=1，否则 R=0

### SERLDE 特色

- 使用 **存档（Archive）** 存储历史成功差分向量 (deta_k)
- 当 FES/NEF 超过阈值时，使用存档差分代替随机差分
- 存档大小限制为 N（种群大小），超限时随机剪枝

---

## 实验设置

| 参数 | 值 |
|------|-----|
| 独立运行次数 | 30 |
| 种群大小 (N) | 30 |
| 最大评估次数 (NEF) | 20,000 |
| 目标函数 | 均方根误差 (RMS) |
| 数据源 | 2011论文 Fig.5 实测数据（G=655 W/m²） |

### 分数阶模型参数边界

| 参数 | 下界 | 上界 |
|------|------|------|
| R_c | 1×10⁻⁵ | 20 |
| C_α | 20×10⁻⁹ | 600×10⁻⁷ |
| L_β | 5×10⁻⁶ | 100×10⁻⁶ |
| α, β | 0.8 | 1.1 |

### 固定参数

| 参数 | 值 | 含义 |
|------|-----|------|
| R_s | 3.245 Ω | 串联电阻 |
| R_L | 23.1 Ω | 负载电阻 |
| V_oc | 19.6 V | 开路电压 |
| i_inf | 0.712 A | 稳态电流 |
| G | 655 W/m² | 辐照度 |

---

## 使用方法

### 环境要求

- MATLAB R2016b 或更新版本
- 需将 `fomcon-1.21b/1.21b/` 及其子目录加入 MATLAB 路径
- Optimization Toolbox（用于 `rms` 等函数）

### 运行步骤

1. **添加 FOMCON 工具箱到路径**
   ```matlab
   addpath(genpath('fomcon-1.21b/1.21b/'));
   ```

2. **选择模型类型**（在主脚本中修改注释）
   ```matlab
   % 分数阶模型（默认）
   fobj = @(x)rms(FO_Load_current_step(x, R_s, R_L, V_oc, tim, I_Load_inter));
   lb = [0.00001, 20e-9, 5e-6, 0.8, 0.8];
   ub = [20, 600e-7, 100e-6, 1.1, 1.1];

   % 切换为整数阶模型（取消注释）
   % fobj = @(x)rms(IO_Load_current_step(x, R_s, R_L, V_oc, tim, I_Load_inter));
   % lb = [0.00001, 20e-9, 5e-6];
   % ub = [20, 600e-7, 100e-6];
   ```

3. **运行指定算法**
   ```matlab
   run('Main_SERLDE_I_F_O_dynamic.m')
   ```

4. **查看结果** — 各脚本末尾会自动加载 `.mat` 结果文件，计算最优参数并绘制拟合曲线（HCLPSO 脚本含绘图功能）

### 测试
```matlab
run('test.m')   % 简单测试 FO_Load_current_step
```

---

## 数据

`Load_current_2011_paper_big_time.csv` 包含从文献中提取的 PV 负载电流阶跃响应实测数据：

- **列1**：时间 (s)
- **列2**：负载电流 i_L(t) (A)

数据预处理：去重取均值后，用线性插值重采样到 1×10⁻⁸ s 步长。

---

## 结果

各算法结果保存在对应 `.mat` 文件中，包含：
- `Best_pos(30×dim)` — 30次运行的最优参数向量
- `Best_score(30×1)` — 30次运行的最小 RMS 误差
- `<算法名>_time(30×1)` — 每次运行耗时

使用 `data_process.m` 可统计各算法的性能指标（最小值、均值、标准差、最大值）。

---

## 许可证

项目代码基于参考论文的原始代码修改和扩展。
FOMCON 工具箱基于 BSD 许可证（见 `fomcon-1.21b/1.21b/license.txt`）。

---

## 引用

如使用本代码，请引用以下文献：

```bibtex
@article{yousri2019static,
  title={Static and dynamic photovoltaic models' parameters identification using Chaotic Heterogeneous Comprehensive Learning Particle Swarm Optimizer variants},
  author={Yousri, Dalia and Allam, Dhiah and Eteiba, MB and Suganthan, PN},
  journal={Energy Conversion and Management},
  volume={182},
  pages={546--563},
  year={2019},
  publisher={Elsevier}
}

@inproceedings{abdelaty2016fractional,
  title={A fractional-order dynamic PV model},
  author={AbdelAty, Amr M and Radwan, Ahmed G and Elwakil, Ahmed and Psychalinos, Costas},
  booktitle={2016 39th International Conference on Telecommunications and Signal Processing (TSP)},
  pages={607--610},
  year={2016},
  organization={IEEE}
}

@article{abdelaty2018transient,
  title={Transient and steady-state response of a fractional-order dynamic PV model under different loads},
  author={AbdelAty, Amr M and Radwan, Ahmed G and Elwakil, Ahmed S and Psychalinos, Costas},
  journal={Journal of Circuits, Systems and Computers},
  volume={27},
  number={02},
  pages={1850023},
  year={2018},
  publisher={World Scientific}
}
```
