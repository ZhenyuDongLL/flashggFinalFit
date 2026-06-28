#!/usr/bin/env bash
# Combine boosted + resolved datacards -> all-channel limit.
set -eo pipefail

TUTORIAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMSSW_BASE="${CMSSW_BASE:-/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4}"
MX="${MX:-1000}"
MY="${MY:-125}"
TUTORIAL_TAG="${TUTORIAL_TAG:-tutorial}"

RESOLVED_DC="${TUTORIAL_ROOT}/outputs/resolved/datacards/Datacard_resolved.txt"
BOOSTED_DC="${TUTORIAL_ROOT}/outputs/boosted/datacards/Datacard_boosted.txt"
ALL_DIR="${TUTORIAL_ROOT}/outputs/all/MX${MX}/MY${MY}"
ALL_DC="${TUTORIAL_ROOT}/outputs/all/datacards/Datacard_all.txt"
COMBINE_CARDS="${CMSSW_BASE}/src/HiggsAnalysis/CombinedLimit/scripts/combineCards.py"

export CMSSW_BASE
unset PYTHONHOME PYTHONPATH
cd "${CMSSW_BASE}/src"
source "${TUTORIAL_ROOT}/env_cmssw.sh"

test -s "${RESOLVED_DC}" || { echo "ERROR: run resolved first: ${RESOLVED_DC}"; exit 1; }
test -s "${BOOSTED_DC}" || { echo "ERROR: run boosted first: ${BOOSTED_DC}"; exit 1; }

mkdir -p "${ALL_DIR}/combine" "$(dirname "${ALL_DC}")"
python3 "${COMBINE_CARDS}" boosted="${BOOSTED_DC}" resolved="${RESOLVED_DC}" > "${ALL_DC}"
python3 "${TUTORIAL_ROOT}/scripts/fix_datacard_combined_boosted_res.py" "${ALL_DC}"

cd "${ALL_DIR}/combine"
combine -M AsymptoticLimits -m 125 -n "all_${TUTORIAL_TAG}_MX${MX}_MY${MY}" \
  "${ALL_DC}" --run expected -v 2 | tee combine_all.log
echo "=== all (boosted+resolved) limit done MX${MX} MY${MY} ==="
