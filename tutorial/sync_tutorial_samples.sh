#!/usr/bin/env bash
# Publish or fetch pinned tutorial ROOT inputs.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

DEFAULT_SOURCE_ROOT="/afs/cern.ch/user/z/zhdong/hgg/bbgg_sample/optimization_outputs_fullbkg_v3"
DEFAULT_PUBLIC_ROOT="/eos/user/z/zhdong/public/flashgg-finalfit-tutorial"
DEFAULT_FETCH_DEST="${SCRIPT_DIR}/samples"
TUTORIAL_VARIANT="${TUTORIAL_VARIANT:-run3_1d_legacy12_nonadv_full150_fullbkg_v3}"
MX="${MX:-1000}"
MY="${MY:-125}"

BOOSTED_SIGNAL_SRC="/eos/cms/store/group/phys_higgs/cmshgg/zhenyudong/v4/processed_slimmed/Run3_2024/signalMC/root/NMSSM_XtoYHto2B2G_MX-1000_MY-125/output_NMSSM_XtoYHto2B2G_M125_13p6TeV_amcatnloFXFX_pythia8.root"
BOOSTED_DATA_SRC="${SCRIPT_DIR}/../myRun3/Boosted/data_EGamma/merged_22_23/allData.root"

RESOLVED_REL_PATHS=(
  "resolved/MX${MX}/MY${MY}/signal/signal_${MX}_${MY}_analysis_pnn_cat0.root"
  "resolved/MX${MX}/MY${MY}/signal/signal_${MX}_${MY}_analysis_pnn_cat1.root"
  "resolved/MX${MX}/MY${MY}/data/data_resolved_${MX}_${MY}_pnn_cat0.root"
  "resolved/MX${MX}/MY${MY}/data/data_resolved_${MX}_${MY}_pnn_cat1.root"
)

RESOLVED_SOURCE_NAMES=(
  "signal/signal_${MX}_${MY}_analysis_pnn_cat0.root"
  "signal/signal_${MX}_${MY}_analysis_pnn_cat1.root"
  "data/data_resolved_${MX}_${MY}_pnn_cat0.root"
  "data/data_resolved_${MX}_${MY}_pnn_cat1.root"
)

BOOSTED_REL_PATHS=(
  "boosted/MX${MX}/MY${MY}/signal/output_NMSSM_signal.root"
  "boosted/MX${MX}/MY${MY}/data/allData.root"
)

usage() {
  cat <<EOF
Usage: $0 publish
       $0 fetch [DEST]
       $0 verify [ROOT]

Environment:
  TUTORIAL_VARIANT   Resolved optimization variant (default: ${TUTORIAL_VARIANT})
  BBGG_OPT_SOURCE    Resolved source root (default: group optimization_outputs_fullbkg_v3)
  TUTORIAL_PUBLIC_ROOT
EOF
}

copy_pair() {
  local src="$1"
  local dst="$2"
  if [[ ! -f "${src}" ]]; then
    echo "ERROR: missing ${src}" >&2
    exit 1
  fi
  mkdir -p "$(dirname "${dst}")"
  echo "  -> ${dst}"
  cp -a "${src}" "${dst}"
}

publish_all() {
  local src_root="${BBGG_OPT_SOURCE:-${DEFAULT_SOURCE_ROOT}}"
  local pub_root="${TUTORIAL_PUBLIC_ROOT:-${DEFAULT_PUBLIC_ROOT}}"
  local opt_point="${src_root}/${TUTORIAL_VARIANT}/MX${MX}/MY${MY}"
  local i rel src

  echo "Publishing resolved from ${opt_point}"
  for i in "${!RESOLVED_REL_PATHS[@]}"; do
    rel="${RESOLVED_REL_PATHS[$i]}"
    src="${opt_point}/${RESOLVED_SOURCE_NAMES[$i]}"
    copy_pair "${src}" "${pub_root}/${rel}"
  done

  echo "Publishing boosted"
  copy_pair "${BOOSTED_SIGNAL_SRC}" "${pub_root}/${BOOSTED_REL_PATHS[0]}"
  if [[ -f "${BOOSTED_DATA_SRC}" ]]; then
    copy_pair "${BOOSTED_DATA_SRC}" "${pub_root}/${BOOSTED_REL_PATHS[1]}"
  else
    echo "WARN: local boosted data missing at ${BOOSTED_DATA_SRC}; skip data publish" >&2
  fi
  echo "Done. Public root: ${pub_root}"
}

fetch_all() {
  local pub_root="${TUTORIAL_PUBLIC_ROOT:-${DEFAULT_PUBLIC_ROOT}}"
  local dest="${1:-${DEFAULT_FETCH_DEST}}"
  local rel

  mkdir -p "${dest}"
  for rel in "${RESOLVED_REL_PATHS[@]}" "${BOOSTED_REL_PATHS[@]}"; do
    copy_pair "${pub_root}/${rel}" "${dest}/${rel}"
  done
  echo "Fetched to ${dest}"
}

verify_all() {
  local root="${1:-${TUTORIAL_SAMPLES_ROOT:-${DEFAULT_FETCH_DEST}}}"
  local rel missing=0
  for rel in "${RESOLVED_REL_PATHS[@]}" "${BOOSTED_REL_PATHS[@]}"; do
    if [[ ! -f "${root}/${rel}" ]]; then
      echo "MISSING ${root}/${rel}" >&2
      missing=1
    fi
  done
  if [[ "${missing}" -eq 1 ]]; then
    exit 1
  fi
  echo "OK: all tutorial ROOT files present under ${root}"
}

case "${1:-}" in
  publish) publish_all ;;
  fetch) fetch_all "${2:-}" ;;
  verify) verify_all "${2:-}" ;;
  *) usage; exit 1 ;;
esac
