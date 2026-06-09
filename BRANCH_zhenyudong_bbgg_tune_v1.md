# Branch `zhenyudong_bbgg_tune_v1`

Fork of `bbgg_for_run3` (@ `0bf684a`) with Zhenyu Dong's bbgg tune-pipeline finalfit changes.

## Summary of changes vs `bbgg_for_run3`

- **Run3 luminosity / eras**: updated `tools/commonObjects.py` (13p6TeV, 2022–2024 lumi, merged 22+23)
- **Python 3 / NMSSM**: `tools/commonTools.py` (`items()`, NMSSM signal naming)
- **Signal fTest**: wider MH scan range in `Signal/scripts/fTest.py`
- **Run3 background configs**: `Background/configs_run3/`
- **Plotting / datacard helpers**: CMS_lumi, RunYields, plottingTools updates
- **Docs**: `docs/clean_pipeline_map_run3.md` and related workflow notes

## Used by

- bbgg-pnn repo: `finalfit_tune/run_one_point.sh`
- Wrapper shims (not in this repo): `finalfit_tune/flashgg_shim/`

## Setup

```bash
git clone https://github.com/ZhenyuDongLL/flashggFinalFit.git
cd flashggFinalFit
git checkout zhenyudong_bbgg_tune_v1
# Install under CMSSW_14_1_0_pre4/src/ per flashggFinalFit/README.md
```

Base upstream: https://github.com/TyCaoihep/flashggFinalFit.git branch `bbgg_for_run3`.
