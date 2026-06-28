#!/usr/bin/env bash
# Top-level driver: resolved, boosted, or combined limits.
set -eo pipefail

TUTORIAL_ROOT="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-all}"

ensure_background() {
  local BKG_BIN="${CMSSW_BASE:-/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4}/src/flashggFinalFit/Background/bin/fTest"
  if [[ ! -x "${BKG_BIN}" ]]; then
    echo "Building Background/fTest..."
    make -C "${CMSSW_BASE}/src/flashggFinalFit/Background"
  fi
}

case "${MODE}" in
  resolved)
    ensure_background
    "${TUTORIAL_ROOT}/scripts/run_resolved.sh"
    ;;
  boosted)
    ensure_background
    "${TUTORIAL_ROOT}/scripts/run_boosted.sh"
    ;;
  combine-all|all)
    if [[ "${MODE}" == "all" ]]; then
      ensure_background
      "${TUTORIAL_ROOT}/scripts/run_resolved.sh"
      "${TUTORIAL_ROOT}/scripts/run_boosted.sh"
    fi
    "${TUTORIAL_ROOT}/scripts/run_all.sh"
    ;;
  *)
    echo "Usage: $0 {all|resolved|boosted|combine-all}" >&2
    exit 1
    ;;
esac
