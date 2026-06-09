# flashggFinalFit 现状全览（2026-03-23）

## 1. 目标

你当前的目标是搭建可稳定复现的全流程框架，覆盖 4 种分析组合并扫描全部 Xmass, Ymass:

- era 22/23 + boosted
- era 22/23 + resolved
- era 2024 + boosted
- era 2024 + resolved

完整流程为: Trees2WS -> Signal -> Background -> Datacard -> Combine。

## 2. 当前状态结论

### 2.1 你本地目录（开发与重构态）

- 顶层模块齐全: Background, Signal, Datacard, Combine, Trees2WS, Plots, run_scripts, scripts。
- 规模统计:
  - flashggFinalFit 两层目录数: 283
  - run_scripts 两层文件数: 263
  - Signal 两层目录数: 748
- 脚本生态表现为多版本并存:
  - 存在多代生成脚本: generate_runs_boosted_2022_v2_fullscan.py, generate_runs_boosted_2022_v3.py, generate_runs_boosted_2024_v2_fullscan.py 等
  - 存在大量逐质量点脚本: run_boosted_MX*_MY*_2024.sh

### 2.2 同事目录（生产与批量产出态，只读观察）

- 两层目录数: 6780，明显高于本地，说明已经形成大规模产物矩阵。
- 顶层存在清晰的总控入口脚本:
  - run_signal_model_2022.sh, run_signal_model_2023.sh, run_signal_model_2024.sh
  - run_background_datacard.sh, run_tth_datacard.sh
  - step1.sh, step2.sh, step3.sh
- Signal 产物命名体现了批量化与多分类扫描能力，包含大量 mergeyears 与多 cat 组合目录。

## 3. 四组合覆盖度判断（基于目录与命名证据）

### 3.1 已见覆盖

- Signal 配置目录存在:
  - configs_run3/boosted_22_23
  - configs_run3_2024/boosted
  - std_v1（resolved 旧链路痕迹）
- Background 配置目录存在:
  - configs_run3/boosted_22_23
  - configs_run3_2024/boosted
  - std_v1（resolved 旧链路痕迹）
- Datacard 中已见:
  - output_run3_22_23_MX1000_boosted
  - output_run3_MX1000_2024_boosted
  - yields_run3_22_23_MX1000_MY**resolved_cat0**

### 3.2 关键差距

- 你的本地链路尚未形成统一单入口，当前仍主要依赖大量点对点脚本。
- 四组合中的 resolved（尤其 2024 resolved）未看到与 boosted 同等成熟的统一批量入口。
- 路径与命名规范尚未收敛为单一配置源，跨阶段衔接风险较高。

## 4. 风险清单

- 版本漂移风险: 同一阶段存在多套脚本版本，后续修订容易不同步。
- 命名漂移风险: ext/output 规则不一致会导致 Datacard 与 Combine 找不到模型。
- 批量失败追踪风险: 当前日志与重试机制分散，Condor 失败后恢复成本高。
- 协同风险: 你与同事独立推进，若缺乏输入输出契约，后期合并代价会增大。

## 5. 结论

你当前最优策略不是继续堆新脚本，而是先建立“主流程框架 + 单一配置源 + 四组合回归测试”的工程底座。先跑通最小闭环，再扩展到全 mass 扫描与 Condor 并行。