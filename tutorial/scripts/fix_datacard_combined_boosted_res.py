#!/usr/bin/env python3
"""Patch combined boosted+resolved datacards after combineCards.

1. Restore v3 merged lumi param (dropped by combineCards).
2. Propagate boosted lnN nuisances onto resolved signal columns so both
   channels carry comparable rate systematics in the combined fit.
"""

from __future__ import annotations

import argparse
import glob
import re
import shutil
from pathlib import Path

SCALE_LINE = (
    "CMS_hgg_nuisance_scale_13p6TeVscale_"
    "                                    param    0.0    1.0\n"
)

# parts layout: name, lnN, boosted(6), resolved(10)
RESOLVED_SLICE_SIG_IDX = [0, 2, 4, 6, 8]


def _parse_lnN_val(raw: str) -> tuple[float, float]:
    raw = raw.strip()
    if raw in ("-", ""):
        return 1.0, 1.0
    if "/" in raw:
        up_s, down_s = raw.split("/", 1)
        return float(up_s), float(down_s)
    v = float(raw)
    return v, 1.0 / v


def _format_lnN_val(up: float, down: float) -> str:
    if abs(up - down) < 1e-6 and abs(up - 1.0 / down) < 1e-6:
        return f"{up:.6g}".rstrip("0").rstrip(".") if "." in f"{up:.6g}" else f"{up:.6g}"
    return f"{up:.6g}/{down:.6g}"


def _merged_boosted_uncertainty(values: list[str]) -> str | None:
    ups: list[float] = []
    downs: list[float] = []
    for val in values:
        if val.strip() in ("-", ""):
            continue
        up, down = _parse_lnN_val(val)
        ups.append(up)
        downs.append(down)
    if not ups:
        return None
    return _format_lnN_val(max(ups), min(downs))


def _insert_scale_param(lines: list[str]) -> bool:
    if any("CMS_hgg_nuisance_scale_13p6TeVscale_" in ln for ln in lines):
        return False
    for i, line in enumerate(lines):
        if line.startswith("bin ") and i > 0:
            lines.insert(i, SCALE_LINE)
            return True
    return False


def _extend_lnN_to_resolved(lines: list[str]) -> bool:
    modified = False
    for i, line in enumerate(lines):
        if " lnN " not in line:
            continue
        parts = line.split()
        if len(parts) < 2 + 6 + 10:
            continue
        name_type = parts[0]
        boosted_sig = parts[2 : 2 + 5]
        merged = _merged_boosted_uncertainty(boosted_sig)
        if merged is None:
            continue
        resolved = parts[8:18]
        changed = False
        for idx in RESOLVED_SLICE_SIG_IDX:
            if resolved[idx].strip() in ("-", ""):
                resolved[idx] = merged
                changed = True
        if not changed:
            continue
        prefix = line[: line.index(name_type)] if name_type in line else ""
        new_line = f"{prefix}{name_type}   lnN                     "
        new_line += "".join(f"{col:24}" for col in parts[2:8])
        new_line += "".join(f"{col:24}" for col in resolved)
        if not new_line.endswith("\n"):
            new_line += "\n"
        lines[i] = new_line
        modified = True
    return modified


def fix_file(path: Path, dry_run: bool = False) -> bool:
    lines = path.read_text().splitlines(keepends=True)
    modified = _insert_scale_param(lines) | _extend_lnN_to_resolved(lines)
    if not modified:
        return False
    if dry_run:
        print(f"[dry-run] would patch {path}")
        return True
    bak = path.with_suffix(path.suffix + ".bak")
    if not bak.exists():
        shutil.copy(path, bak)
    path.write_text("".join(lines))
    print(f"Patched {path}")
    return True


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("inputs", nargs="+", help="Combined datacard path(s) or globs")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()
    paths = [Path(p) for raw in args.inputs for p in glob.glob(raw)]
    if not paths:
        ap.error("No datacard files matched")
    n = sum(fix_file(p, dry_run=args.dry_run) for p in paths)
    print(f"Done. Patched {n}/{len(paths)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
