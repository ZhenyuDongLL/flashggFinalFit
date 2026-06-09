# all_* 卡片到 limit plot 的流程

## 1. 输入与目标

输入目录:

- Datacard/all_1000 ... Datacard/all_4000

每个 all_MX 目录里有:

- Datacard_all_MX_combined_MY.txt
- Datacard_boosted_MX_combine_MY.txt
- Datacard_res_MX_combined_MY.txt

目标输出:

- higgsCombineall_MX_MY.AsymptoticLimits.mH125.root
- higgsCombineboosted_MX_MY.AsymptoticLimits.mH125.root
- higgsCombineres_MX_MY.AsymptoticLimits.mH125.root

然后交给 plotting 脚本出图。

## 2. 单点验证（推荐先做）

在 flashggFinalFit 根目录执行:

```bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
export PYTHONPATH="${PYTHONPATH:-}"
source ./setup.sh

cd Datacard/all_1000
combine -M AsymptoticLimits -m 125 -n all_1000_100 Datacard_all_1000_combined_100.txt --run expected
combine -M AsymptoticLimits -m 125 -n boosted_1000_100 Datacard_boosted_1000_combine_100.txt --run expected
combine -M AsymptoticLimits -m 125 -n res_1000_100 Datacard_res_1000_combined_100.txt --run expected
```

## 3. 批量生成 Condor 作业

脚本:

- Datacard/tools/generate_limit_condor_jobs.py

示例（全通道、跳过已存在输出）:

```bash
cd /afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit
python3 Datacard/tools/generate_limit_condor_jobs.py \
  --flashgg-dir "$PWD" \
  --channels all,boosted,res \
  --skip-existing
```

生成文件:

- Datacard/condor_from_all_cards/run_limit_job.sh
- Datacard/condor_from_all_cards/jobs.tsv
- Datacard/condor_from_all_cards/submit.sub
- Datacard/condor_from_all_cards/run_local.sh

你可直接提交:

```bash
cd Datacard/condor_from_all_cards
condor_submit submit.sub
```

如果只想先跑某几个 MX:

```bash
python3 Datacard/tools/generate_limit_condor_jobs.py \
  --flashgg-dir "$PWD" \
  --channels boosted,res \
  --only-mx 1000,1200 \
  --skip-existing
```

## 4. 画图

通用画图脚本:

- Plots/from_ticao/plot_yh_limit_run3_channel.py

画 all:

```bash
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py \
  --flashgg-dir "$PWD" \
  --prefix all
```

画 boosted:

```bash
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py \
  --flashgg-dir "$PWD" \
  --prefix boosted
```

画 resolved:

```bash
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py \
  --flashgg-dir "$PWD" \
  --prefix res
```

默认输出:

- Plots/from_ticao/yh_limit_run3_all.pdf
- Plots/from_ticao/yh_limit_run3_boosted.pdf
- Plots/from_ticao/yh_limit_run3_res.pdf

## 5. 常见问题

- 如果报 PYTHONPATH unbound variable:
  - 先执行 `export PYTHONPATH="${PYTHONPATH:-}"` 再 source setup.sh。
- 如果部分质量点缺失:
  - 画图脚本会跳过缺失点并统计 missing 数量；优先检查对应 all_MX 下是否存在 higgsCombine 前缀 root 文件。

