#!/usr/bin/env python3
from __future__ import annotations

import argparse
import glob
import re
import shutil
from pathlib import Path

INSERT_LINE = (
    "CMS_hgg_nuisance_scale_13p6TeVscale_"
    "                                    param    0.0    1.0\n"
)


def replacements_for_text(text: str) -> dict[str, str]:
    reps: dict[str, str] = {}
    for cat in sorted(set(re.findall(r"resolved_cat(\d+)", text))):
        reps[f"pdfindex_resolved_cat{cat}_13TeV"] = f"pdfindex_resolved_cat{cat}_13p6TeV"
        reps[f"CMS_hgg_resolved_cat{cat}_13TeV_bkgshape"] = (
            f"CMS_hgg_resolved_cat{cat}_13p6TeV_bkgshape"
        )
    return reps


def fix_file(path: Path, dry_run: bool = False) -> bool:
    text = path.read_text()
    lines = text.splitlines(keepends=True)
    modified = False
    for wrong, correct in replacements_for_text(text).items():
        for i, line in enumerate(lines):
            if wrong in line and correct not in line:
                lines[i] = line.replace(wrong, correct)
                modified = True
    for i in range(len(lines) - 1, -1, -1):
        if "13TeV" in lines[i] and "13p6TeV" not in lines[i]:
            lines[i] = lines[i].replace("13TeV", "13p6TeV")
            modified = True
            break
    if not any("CMS_hgg_nuisance_scale_13p6TeVscale_" in ln for ln in lines):
        while len(lines) < 26:
            lines.append("\n")
        lines.insert(26, INSERT_LINE)
        modified = True
    if not modified:
        return False
    if dry_run:
        return True
    shutil.copy(path, path.with_suffix(path.suffix + ".bak"))
    path.write_text("".join(lines))
    print(f"Patched {path}")
    return True


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("inputs", nargs="*")
    args = ap.parse_args()
    paths = [Path(p) for raw in args.inputs for p in glob.glob(raw)]
    if not paths:
        ap.error("No datacard files")
    n = sum(fix_file(p) for p in paths)
    print(f"Done. Patched {n}/{len(paths)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
