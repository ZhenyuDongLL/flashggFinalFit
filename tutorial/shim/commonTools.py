"""Py3 shim: load Trees2WS commonTools with iteritems -> items."""
from __future__ import annotations

import importlib.util
import os
import sys

_CMSSW = os.environ.get(
    "CMSSW_BASE", "/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4"
)
_REAL = os.path.join(_CMSSW, "src/flashggFinalFit/Trees2WS/tools/commonTools.py")


def _load_real():
    code = open(_REAL, encoding="utf-8").read().replace(".iteritems()", ".items()")
    spec = importlib.util.spec_from_loader("_ff_real_commonTools", loader=None)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["_ff_real_commonTools"] = mod
    exec(compile(code, _REAL, "exec"), mod.__dict__)
    return mod


_mod = _load_real()
for _name in dir(_mod):
    if not _name.startswith("_"):
        globals()[_name] = getattr(_mod, _name)


def iteritems(d):
    return d.items()
