# Tutorial reference outputs (MX1000 MY125)

Pinned **text** results from `./run_tutorial.sh all`. Regenerate plots, ROOT workspaces, and packaged models locally.

## Tracked in git (lightweight)

| Type | Paths |
|------|--------|
| Limits summary | [`GOLDEN.md`](GOLDEN.md) |
| Combine logs | `*/combine/combine_{resolved,boosted,all}.log` |
| Datacards | `*/datacards/Datacard_*.txt` |
| Filled configs | `*/configs/config_*.py`, `trees2ws_*.py` |

## Local only (not in git)

- `**/workspaces/` — Trees2WS intermediates
- `**/signal/plots*`, `**/background/multipdf*/` — PDF/PNG diagnostic plots
- `**/*.root` — packaged signal, multipdf, combine ROOT, prepared data
- `*_run.log`, `combine_logger.out`, `**/fTestParallel/`

After `./run_tutorial.sh all`, see [TUTORIAL.md §3.1](../TUTORIAL.md) for on-disk paths under `outputs/` and `flashggFinalFit/Signal|Background/outdir_*`.

## Limits (MX1000 MY125)

| Channel | Log | Expected 50% |
|---------|-----|----------------|
| Resolved | [`resolved/.../combine_resolved.log`](resolved/MX1000/MY125/combine/combine_resolved.log) | r < 0.2148 |
| Boosted | [`boosted/.../combine_boosted.log`](boosted/MX1000/MY125/combine/combine_boosted.log) | r < 0.0806 |
| All | [`all/.../combine_all.log`](all/MX1000/MY125/combine/combine_all.log) | r < 0.0698 |

## Filled configs

| Channel | Signal | Background | Trees2WS |
|---------|--------|------------|----------|
| Resolved cat0 | [`config_signal_..._cat0.py`](resolved/MX1000/MY125/configs/config_signal_tutorial_MX1000_MY125_cat0.py) | [`config_background_..._cat0.py`](resolved/MX1000/MY125/configs/config_background_tutorial_MX1000_MY125_cat0.py) | [`trees2ws_..._cat0.py`](resolved/MX1000/MY125/configs/trees2ws_tutorial_MX1000_MY125_cat0.py) |
| Resolved cat1 | [`config_signal_..._cat1.py`](resolved/MX1000/MY125/configs/config_signal_tutorial_MX1000_MY125_cat1.py) | [`config_background_..._cat1.py`](resolved/MX1000/MY125/configs/config_background_tutorial_MX1000_MY125_cat1.py) | [`trees2ws_..._cat1.py`](resolved/MX1000/MY125/configs/trees2ws_tutorial_MX1000_MY125_cat1.py) |
| Boosted | [`config_signal_..._boosted.py`](boosted/MX1000/MY125/configs/config_signal_tutorial_MX1000_MY125_boosted.py) | [`config_background_..._boosted.py`](boosted/MX1000/MY125/configs/config_background_tutorial_MX1000_MY125_boosted.py) | [`trees2ws_boosted.py`](boosted/MX1000/MY125/configs/trees2ws_boosted.py) |

## Datacards

- [`resolved/datacards/Datacard_resolved.txt`](resolved/datacards/Datacard_resolved.txt)
- [`boosted/datacards/Datacard_boosted.txt`](boosted/datacards/Datacard_boosted.txt)
- [`all/datacards/Datacard_all.txt`](all/datacards/Datacard_all.txt)
