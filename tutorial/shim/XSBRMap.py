"""Load flashgg XSBRMap and add BBGG analysis for nmssm signal fits."""
from __future__ import annotations

import importlib.util
import os
import sys
from collections import OrderedDict as od

_CMSSW = os.environ.get(
    "CMSSW_BASE", "/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4"
)
_REAL = os.path.join(_CMSSW, "src/flashggFinalFit/Signal/tools/XSBRMap.py")

spec = importlib.util.spec_from_file_location("_ff_XSBRMap", _REAL)
_mod = importlib.util.module_from_spec(spec)
sys.modules["_ff_XSBRMap"] = _mod
spec.loader.exec_module(_mod)

globalXSBRMap = _mod.globalXSBRMap

if "BBGG" not in globalXSBRMap:
    globalXSBRMap["BBGG"] = od()
    globalXSBRMap["BBGG"]["decay"] = {"mode": "hgg"}
    globalXSBRMap["BBGG"]["nmssm"] = {"mode": "ggH"}
