# ticao 工作复现总工作流（从后往前）

更新时间: 2026-03-24
适用范围: flashggFinalFit run3 X->YH->bbgg 复现与重构

## 1. 文档目标

本文件作为当前主工作流档案，记录:

- 我们正在执行的复现策略（从最终产物向上游回溯）
- 当前已完成阶段与证据
- 统一检查口径（最终输出 QA）
- 待完善事项（后续持续更新）

## 2. 当前策略: 从后往前复现

执行顺序不是传统正向流水，而是反向拆解:

1. 先复现最终 plot（确认画图输入和可视化链路）
2. 再复现 combine 输出（确认 root 产物与 mass coverage）
3. 再回溯 Datacard 生成链路
4. 再回溯 Signal/Background/Trees2WS 上游阶段

目标是先让末端可验证，再逐层补齐来源，降低整体返工风险。

## 3. 全流程阶段图（维护版）

- Stage 5: Plot
- Stage 4: Combine (AsymptoticLimits)
- Stage 3: Datacard
- Stage 2: Signal / Background
- Stage 1: Trees2WS / 输入样本准备

当前完成到 Stage 5 + Stage 4，后续向 Stage 3/2/1推进。

## 4. 当前完成状态（截至 2026-03-24）

### 4.1 Stage 5 Plot（已完成）

核心脚本:

- Plots/from_ticao/plot_yh_limit_run3_channel.py

当前能力:

- 支持 `--prefix all|boosted|res`
- 绘图时区分并统计:
  - loaded
  - missing_root
  - bad_root（存在 root 但无 `limit` tree）
  - filtered_by_boosted_threshold
- 输出 point-level QA 报告 CSV（最终检查输入）

默认产物:

- Plots/from_ticao/yh_limit_run3_all.pdf
- Plots/from_ticao/yh_limit_run3_boosted.pdf
- Plots/from_ticao/yh_limit_run3_res.pdf
- Plots/from_ticao/yh_limit_run3__points_check.csv

### 4.2 Stage 4 Combine（已完成，可增量重跑）

已具备:

- all_* 批量 combine 产物组织方式
- AFS 提交点与 condor 脚本
- 局部点位定点重跑流程（用于修复 bad_root/missing_root）

本轮关键结论:

- `all_1600` 的 boosted card/root 文件名覆盖到 MY=400
- 之前未画到 300/400 的原因是 root 内容问题（bad_root）而非文件不存在
- 已对 `1600_300`、`1600_400` 做定点重跑，并重生图和 QA 报告

## 5. 统一 QA 口径（最终输出检查）

### 5.1 必查文件

- Plot PDF: `Plots/from_ticao/yh_limit_run3_<prefix>.pdf`
- Point QA: `Plots/from_ticao/yh_limit_run3_<prefix>_points_check.csv`

### 5.2 CSV 状态定义

- `loaded`: 进入绘图曲线的有效点
- `missing_root`: 预期 root 不存在
- `bad_root`: root 存在但格式/内容不满足（如仅 `toys` 无 `limit`）
- `filtered_by_boosted_threshold`: boosted 物理阈值过滤点

### 5.3 通过标准（当前版本）

- `missing_root = 0`
- `bad_root = 0`（若不为 0，必须有重跑记录）
- `filtered_by_boosted_threshold` 仅出现在 boosted 且符合阈值表

## 6. 关键配置与约束

### 6.1 boosted 阈值（画图过滤）

在 `plot_yh_limit_run3_channel.py` 中维护 `BOOSTED_MAX_MY`。

当前特别确认:

- MX=1600 的阈值为 400（不是 300）

### 6.2 环境加载顺序

涉及 `setup.sh` 时，建议统一:

1. `source /cvmfs/cms.cern.ch/cmsset_default.sh`
2. `export PYTHONPATH="${PYTHONPATH:-}"`
3. `source ./setup.sh`

## 7. 标准操作（当前稳定版）

### 7.1 重画某个通道并输出 QA

```bash
cd /afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit
source /cvmfs/cms.cern.ch/cmsset_default.sh
export PYTHONPATH="${PYTHONPATH:-}"
source ./setup.sh
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py --flashgg-dir . --prefix boosted
```

### 7.2 定点重跑 combine（示例: boosted 1600_300/400）

```bash
cd /afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit
source /cvmfs/cms.cern.ch/cmsset_default.sh
export PYTHONPATH="${PYTHONPATH:-}"
source ./setup.sh
cd Datacard/all_1600
for my in 300 400; do
  combine -M AsymptoticLimits -m 125 -n "boosted_1600_${my}" \
    "Datacard_boosted_1600_combine_${my}.txt" --run expected \
    > "limit_boosted_1600_${my}.log" 2>&1
done
```

## 8. 下一阶段任务（从后往前继续）

1. Stage 3 Datacard: 建立缺失/异常卡片的自动检查表，并与 combine 缺失点双向映射。
2. Stage 2 Signal/Background: 梳理 run3 22/23 与 2024 在 boosted/resolved 的入口脚本映射表。
3. Stage 1 Trees2WS: 明确输入样本路径、命名规则、版本标签，沉淀为配置字典。
4. 建立统一 changelog: 每次修复 bad_root/missing_root 均登记（点位、原因、处理人、时间）。

## 9. 维护规则

- 本文档作为主档案，按日期滚动更新。
- 发生以下任一变化必须更新本文档:
  - 阈值规则变更
  - combine 提交/重跑方式变更
  - QA 字段定义变更
  - 新增或替换关键脚本
- 变更后应至少重跑一次对应 prefix 的 plot + QA CSV，作为回归证据。

## 10. 里程碑记录

- 2026-03-24:
  - 已完成复现链路中的 Stage 5（plot）与 Stage 4（combine）。
  - 已形成最终输出检查口径（point-level QA CSV）。
  - 已支持针对异常点（bad_root/missing_root）的定点重跑与回填。
  - 下阶段进入 Stage 3（Datacard）整理与缺失映射自动化。

