"""Load flashgg replacementMap and add bbgg resolved_cat* entries."""
from __future__ import annotations

import importlib.util
import os
import sys
from collections import OrderedDict as od

_CMSSW = os.environ.get(
    "CMSSW_BASE", "/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4"
)
_REAL = os.path.join(_CMSSW, "src/flashggFinalFit/Signal/tools/replacementMap.py")

spec = importlib.util.spec_from_file_location("_ff_replacementMap", _REAL)
_mod = importlib.util.module_from_spec(spec)
sys.modules["_ff_replacementMap"] = _mod
spec.loader.exec_module(_mod)

globalReplacementMap = _mod.globalReplacementMap

_MAX_CATS = 128


def _add_resolved_cats(analysis: str) -> None:
    if analysis not in globalReplacementMap:
        globalReplacementMap[analysis] = od()
    for key in ("procRVMap", "catRVMap"):
        globalReplacementMap[analysis].setdefault(key, od())
    for i in range(_MAX_CATS):
        cat = f"resolved_cat{i}"
        globalReplacementMap[analysis]["procRVMap"][cat] = "nmssm"
        globalReplacementMap[analysis]["catRVMap"][cat] = cat


_add_resolved_cats("STXS")
_add_resolved_cats("BBGG")
