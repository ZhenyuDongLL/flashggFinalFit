"""Py3 shim: load Trees2WS commonObjects and patch Run3 sqrts / lumi / workspace name."""
from __future__ import annotations

import importlib.util
import os
import sys

_CMSSW = os.environ.get(
    "CMSSW_BASE", "/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4"
)
_REAL = os.path.join(_CMSSW, "src/flashggFinalFit/Trees2WS/tools/commonObjects.py")


def _load_real():
    spec = importlib.util.spec_from_file_location("_ff_real_commonObjects", _REAL)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["_ff_real_commonObjects"] = mod
    spec.loader.exec_module(mod)
    return mod


_mod = _load_real()
for _name in dir(_mod):
    if not _name.startswith("_"):
        globals()[_name] = getattr(_mod, _name)

sqrts__ = "13p6TeV"
inputWSName__ = "tagsDumper/cms_hgg_13p6TeV"

# Run 3 golden JSON total (2022–2024), AN-26-035 Samples.tex tab:Data_samples
RUN3_LUMI_FB = 170.537
lumiMap = dict(lumiMap)
lumiMap.update(
    {
        "222324": RUN3_LUMI_FB,
        "merged": RUN3_LUMI_FB,
        "combined": RUN3_LUMI_FB,
    }
)

outputNuisanceExtMap = {
    "scales": "%sscale" % sqrts__,
    "scalesCorr": "%sscaleCorr" % sqrts__,
    "smears": "%ssmear" % sqrts__,
    "scalesGlobal": "%sscale" % sqrts__,
}
