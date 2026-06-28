#!/usr/bin/env python3
"""Rename boosted data tree to flashggFinalFit convention (lowercase boosted)."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

import uproot


SRC_TREE = "DiphotonTree/Data_13p6TeV_Boosted"
DST_TREE = "DiphotonTree/Data_13p6TeV_boosted"


def prepare(src: Path, dst: Path) -> None:
    with uproot.open(src) as handle:
        if DST_TREE in handle:
            print(f"OK: {dst} already has {DST_TREE}")
            return
        if SRC_TREE not in handle:
            raise SystemExit(f"Missing {SRC_TREE} in {src}")
        data = handle[SRC_TREE].arrays(library="np")
    dst.parent.mkdir(parents=True, exist_ok=True)
    with uproot.recreate(dst) as out:
        out[DST_TREE] = data
    print(f"Wrote {dst} with {DST_TREE}")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("src")
    ap.add_argument("dst", nargs="?", default="")
    args = ap.parse_args()
    src = Path(args.src)
    dst = Path(args.dst) if args.dst else src
    prepare(src, dst)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
