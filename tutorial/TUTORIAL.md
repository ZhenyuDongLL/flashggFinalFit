# flashggFinalFit hands-on tutorial (bbgg Run 3)

End-to-end mini final fit for **MX=1000, MY=125**: ROOT → Trees2WS → signal/background modelling → datacard → `combine`, for three limits:

1. **Resolved** — `resolved_cat0` + `resolved_cat1`
2. **Boosted** — single `boosted` channel
3. **All** — `combineCards` boosted + resolved

---

## 1. Environment

```bash
export CMSSW_BASE=/path/to/CMSSW_14_1_0_pre4   # must contain flashggFinalFit + HiggsAnalysis/CombinedLimit
cd $CMSSW_BASE/src/flashggFinalFit/tutorial
```

Build background fTest once if needed:

```bash
make -C $CMSSW_BASE/src/flashggFinalFit/Background
```

---

## 2. Input samples

Six ROOT files (see `sync_tutorial_samples.sh`):

| Channel | Files |
|---------|-------|
| Resolved | `signal/signal_1000_125_analysis_pnn_cat{0,1}.root`, `data/data_resolved_1000_125_pnn_cat{0,1}.root` |
| Boosted | `signal/output_NMSSM_signal.root`, `data/allData.root` |

Fetch pinned copies from public EOS:

```bash
./sync_tutorial_samples.sh fetch          # -> samples/
./sync_tutorial_samples.sh verify         # check all six files
```

Override sample location: `export TUTORIAL_SAMPLES_ROOT=/your/path`.

---

## 3. One-command run

```bash
./run_tutorial.sh all          # resolved → boosted → combine-all
./run_tutorial.sh resolved     # resolved only
./run_tutorial.sh boosted      # boosted only
./run_tutorial.sh combine-all  # needs existing resolved + boosted datacards
```

Logs:

- `outputs/resolved/MX1000/MY125/combine/combine_resolved.log`
- `outputs/boosted/MX1000/MY125/combine/combine_boosted.log`
- `outputs/all/MX1000/MY125/combine/combine_all.log`

Reference limits: `outputs/GOLDEN.md`.

---

## 4. Pipeline steps (per channel)

Each `scripts/run_*.sh` runs:

1. **Trees2WS** — `trees2ws_new.py` + `trees2ws_data_new.py`
2. **Signal** — `fTest.py` → `signalFit.py` → `packageSignal.py`
3. **Background** — `Background/bin/fTest` (multipdf)
4. **Datacard** — `makeYields.py` → `makeDatacard.py` → channel-specific fix script
5. **Limit** — `combine -M AsymptoticLimits`

Combined limit: `scripts/run_all.sh` uses `combineCards.py` + `fix_datacard_combined_boosted_res.py`.

---

## 5. Reading the limit

In each `combine_*.log`:

```text
Expected 50.0%: r < X.XXXX
```

`r` is the expected asymptotic upper limit on the signal strength modifier at mH=125 GeV.

---

## 6. FAQ

**`Background/bin/fTest` missing** — run `make -C $CMSSW_BASE/src/flashggFinalFit/Background`.

**`PYTHONPATH` / import errors** — run via `run_*.sh` (sources `env_cmssw.sh` + shim).

**`13TeV` in datacard** — `scripts/fix_datacard_resolved.py` patches resolved cards; `scripts/fix_datacard_boosted.py` patches boosted; combined card uses `fix_datacard_combined_boosted_res.py`.

**Boosted data tree name** — `allData.root` uses `Data_13p6TeV_Boosted` (capital B); flashgg expects lowercase. `run_boosted.sh` calls `scripts/prepare_boosted_data.py` automatically.

**Sample path** — set `export TUTORIAL_SAMPLES_ROOT=/path/to/samples`.
