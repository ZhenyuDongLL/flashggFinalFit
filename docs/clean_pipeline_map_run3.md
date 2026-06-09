# flashggFinalFit Clean Pipeline Map (Run3 X->HY->bbgg)

This note gives one clean path through this repository, from categorized ROOT inputs to limits and plots.

For the **current analysis production**, the stable path is:
- **existing cards from colleague Tianyu** under `Datacard/all_*`
- then run `combine` and plotting only

The full trees2ws->signal->background->datacard chain is kept as a secondary/rebuild path.

## 0) Inputs expected by this framework

- **Resolved channel input**: ROOT trees already processed with PNN and category assignment.
- **Boosted channel input**: ROOT trees already processed with ParticleNet-based selection/cuts.
- Inputs are consumed by `Trees2WS` and converted to RooWorkspaces used by later stages.

## 1) Directory roles (high-level)

- `Trees2WS/`: ROOT trees -> `ws_*.root` workspaces.
- `Signal/`: signal model chain (`fTest`, photon systematics, signal fit, packager).
- `Background/`: data background model and multipdf (`fTestParallel`).
- `Datacard/`: yields extraction + datacard production + nuisance lines.
- `Combine/`: `text2workspace.py` and combine orchestration.
- `Plots/`: limit plotting scripts (in practice, `Plots/from_ticao/` is actively used).
- `scripts/`: unified stage runner (`master_run.py`) for trees2ws->combine.

## 2) Production path used now (stable)

This is the path used for final/stable outputs in this repo right now.

1. Start from trusted cards in `Datacard/all_*` (copied from Tianyu).
2. Run `combine -M AsymptoticLimits` on `all/boosted/res` card variants.
3. Produce limit plots from combine outputs.

Single-point check:

```bash
cd Datacard/all_1000
combine -M AsymptoticLimits -m 125 -n all_1000_100 Datacard_all_1000_combined_100.txt --run expected
combine -M AsymptoticLimits -m 125 -n boosted_1000_100 Datacard_boosted_1000_combine_100.txt --run expected
combine -M AsymptoticLimits -m 125 -n res_1000_100 Datacard_res_1000_combined_100.txt --run expected
```

Batch from all cards:

```bash
python3 Datacard/tools/generate_limit_condor_jobs.py \
  --flashgg-dir "$PWD" \
  --channels all,boosted,res \
  --skip-existing
```

Plot:

```bash
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py --flashgg-dir "$PWD" --prefix all
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py --flashgg-dir "$PWD" --prefix boosted
python3 Plots/from_ticao/plot_yh_limit_run3_channel.py --flashgg-dir "$PWD" --prefix res
```

## 3) Full rebuild path (secondary, not current production)

1. `trees2ws`: build per-era workspaces from input trees.
2. `signal`: run signal modeling and package outputs.
3. `background`: run background fTest/multipdf.
4. `datacard`: compute yields and write datacards.
5. `combine`: run statistical inference (limits/fits).

Entry point:

```bash
python3 scripts/master_run.py \
  --mass-point MX1000_MY100 \
  --year 2024 \
  --category boosted \
  --stages all
```

The stage code is under `scripts/stage_*.py`.

## 4) Year/era and category handling

Global config:
- `config/global_config.yaml`
- `config/mass_points.yaml`

Important conventions in this repo:
- years/eras include `2022preEE`, `2022postEE`, `2023preBPix`, `2023postBPix`, `2024`
- merge group `"22_23"` combines 2022+2023 eras
- categories are `boosted` and `resolved` (currently `resolved.enabled: false` in mass config example)

In stage scripts, year/category are passed explicitly and used in output naming, for example:
- ext: `<year>_<category>_MX<mX>_MY<mY>`

## 5) Systematics flow (where they enter)

Primary nuisance definitions:
- `Datacard/systematics.py`
  - `theory_systematics`
  - `experimental_systematics`
  - `signal_shape_systematics`

Propagation:
- `Datacard/RunYields.py` collects nominal/systematic yields from model workspaces.
- `Datacard/makeDatacard.py` writes nuisance lines to final text datacards.

Notes:
- `correlateAcrossYears` controls correlation behavior.
- This file still includes legacy lumi key naming (2016/2017/2018 style), so Run3 workflows may require adaptation/patch scripts.

## 6) Known friction points

- Docs are split between `docs/`, `scripts/README.md`, and old `run_scripts/`.
- `PYTHONPATH` may be undefined before `setup.sh`; robust pattern:
  - `export PYTHONPATH="${PYTHONPATH:-}"`
- Naming mismatch (`ext`, channel labels, 13TeV vs 13p6TeV) can break downstream scripts.
- Datacard/systematics for Run3 may need cleanup to match era naming and approved nuisances.
- Some helper scripts are channel/year-specific and should not be treated as universal.

## 7) Minimal reproducible command template (current production path)

```bash
cd /afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit
source /cvmfs/cms.cern.ch/cmsset_default.sh
cmsenv
export PYTHONPATH="${PYTHONPATH:-}"
source ./setup.sh

# Generate and submit combine jobs from all cards
python3 Datacard/tools/generate_limit_condor_jobs.py --flashgg-dir "$PWD" --channels all,boosted,res --skip-existing
cd Datacard/condor_from_all_cards
condor_submit submit.sub
```

Then inspect combine outputs under each `Datacard/all_*` folder (`higgsCombine*.root`), then run plotting scripts in `Plots/from_ticao/`.

## 8) Recommended next cleanup tasks

1. Freeze one canonical runbook per channel (`boosted`, `resolved`) and per year grouping (`22_23`, `2024`).
2. Harmonize systematics naming/correlation policy in one Run3 file.
3. Keep one naming scheme for datacards and outputs to avoid fragile regex matching.
4. Keep direct-card path (`Datacard/all_*`) and full-stage path documented separately to avoid mixing steps.
