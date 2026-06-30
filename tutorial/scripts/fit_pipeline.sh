#!/usr/bin/env bash
# Shared signal / background fit helpers for tutorial drivers.
# Default: config + RunSignalScripts / RunBackgroundScripts.
# Set TUTORIAL_USE_CLI=1 to call fTest.py / signalFit.py / bin/fTest directly.

write_signal_cfg_resolved() {
  local CAT="$1" SIG_WS_DST="$2" SIG_EXT="$3" CFG_DIR="$4"
  local OUT="${CFG_DIR}/config_signal_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}.py"
  local REL="configs_tutorial/config_signal_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}.py"
  sed -e "s|@SIG_WS_DST@|${SIG_WS_DST}|g" \
      -e "s|@SIG_EXT@|${SIG_EXT}|g" \
      -e "s/\"resolved_cat0\"/\"resolved_cat${CAT}\"/" \
      "${TUTORIAL_ROOT}/configs/signal_resolved.py" > "${OUT}"
  mkdir -p "${FLASHGG}/Signal/configs_tutorial"
  cp -f "${OUT}" "${FLASHGG}/Signal/${REL}"
  echo "${REL}"
}

write_signal_cfg_boosted() {
  local SIG_WS_DST="$1" SIG_EXT="$2" CFG_DIR="$3"
  local OUT="${CFG_DIR}/config_signal_${TUTORIAL_TAG}_MX${MX}_MY${MY}_boosted.py"
  local REL="configs_tutorial/config_signal_${TUTORIAL_TAG}_MX${MX}_MY${MY}_boosted.py"
  sed -e "s|@SIG_WS_DST@|${SIG_WS_DST}|g" \
      -e "s|@SIG_EXT@|${SIG_EXT}|g" \
      "${TUTORIAL_ROOT}/configs/signal_boosted.py" > "${OUT}"
  mkdir -p "${FLASHGG}/Signal/configs_tutorial"
  cp -f "${OUT}" "${FLASHGG}/Signal/${REL}"
  echo "${REL}"
}

write_background_cfg_resolved() {
  local CAT="$1" DATA_WS_DST="$2" BKG_EXT="$3" CFG_DIR="$4"
  local OUT="${CFG_DIR}/config_background_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}.py"
  sed -e "s|@DATA_WS_DST@|${DATA_WS_DST}|g" \
      -e "s|@BKG_EXT@|${BKG_EXT}|g" \
      -e "s/\"resolved_cat0\"/\"resolved_cat${CAT}\"/" \
      "${TUTORIAL_ROOT}/configs/background_resolved.py" > "${OUT}"
  echo "${OUT}"
}

write_background_cfg_boosted() {
  local DATA_WS_DST="$1" BKG_EXT="$2" CFG_DIR="$3"
  local OUT="${CFG_DIR}/config_background_${TUTORIAL_TAG}_MX${MX}_MY${MY}_boosted.py"
  sed -e "s|@DATA_WS_DST@|${DATA_WS_DST}|g" \
      -e "s|@BKG_EXT@|${BKG_EXT}|g" \
      "${TUTORIAL_ROOT}/configs/background_boosted.py" > "${OUT}"
  echo "${OUT}"
}

signal_fit_mode_opts() {
  local EXTRA=("--doPlots" "--replacementThreshold" "50" "--skipVertexScenarioSplit")
  [[ "${SKIP_SIGNAL_SYST}" == "1" ]] && EXTRA+=(--skipSystematics)
  printf '%s' "${EXTRA[*]}"
}

run_signal_fit_config() {
  local SIG_CFG_REL="$1" SIG_EXT="$2"
  local MODE_OPTS RUN_SIG="${FLASHGG}/Signal/RunSignalScripts.py"
  MODE_OPTS="$(signal_fit_mode_opts)"
  [[ -f "${RUN_SIG}" ]] || {
    echo "ERROR: missing ${RUN_SIG} (flashggFinalFit Signal/RunSignalScripts.py)" >&2
    exit 1
  }
  export PYTHONPATH="${PYTHONPATH_SIGNAL}"
  cd "${FLASHGG}/Signal"
  mkdir -p "${FLASHGG}/Signal/outdir_${SIG_EXT}/fTest/json" \
    "${FLASHGG}/Signal/outdir_${SIG_EXT}/signalFit/output"
  python3 "${RUN_SIG}" --inputConfig "${SIG_CFG_REL}" --mode fTest \
    --modeOpts "--doPlots"
  python3 "${RUN_SIG}" --inputConfig "${SIG_CFG_REL}" --mode signalFit \
    --modeOpts "${MODE_OPTS}"
}

run_signal_fit_cli() {
  local SIG_WS_DST="$1" SIG_EXT="$2" CAT_LABEL="$3"
  export PYTHONPATH="${PYTHONPATH_SIGNAL}"
  cd "${FLASHGG}/Signal"
  mkdir -p "${FLASHGG}/Signal/outdir_${SIG_EXT}/fTest/json" \
    "${FLASHGG}/Signal/outdir_${SIG_EXT}/signalFit/output"
  python3 scripts/fTest.py --cat "${CAT_LABEL}" --procs nmssm --ext "${SIG_EXT}" \
    --inputWSDir "${SIG_WS_DST}" --doPlots
  local SIGFIT_EXTRA=()
  [[ "${SKIP_SIGNAL_SYST}" == "1" ]] && SIGFIT_EXTRA+=(--skipSystematics)
  python3 scripts/signalFit.py --inputWSDir "${SIG_WS_DST}" --ext "${SIG_EXT}" --proc nmssm \
    --cat "${CAT_LABEL}" --year merged --analysis STXS --massPoints 125 \
    --scales '' --scalesCorr '' --scalesGlobal '' --smears '' \
    --replacementThreshold 50 --skipVertexScenarioSplit --doPlots "${SIGFIT_EXTRA[@]}"
}

run_background_fit_config() {
  local BKG_CFG="$1" BKG_EXT="$2"
  local RUN_BKG="${FLASHGG}/Background/RunBackgroundScripts.py"
  local BKG_OUTDIR="${FLASHGG}/Background/outdir_${BKG_EXT}"
  [[ -f "${RUN_BKG}" ]] || {
    echo "ERROR: missing ${RUN_BKG} (flashggFinalFit Background/RunBackgroundScripts.py)" >&2
    exit 1
  }
  export PYTHONPATH="${PYTHONPATH_BACKGROUND}"
  cd "${FLASHGG}/Background"
  rm -rf "${BKG_OUTDIR}"
  # Upstream RunBackgroundScripts.py calls sys.exit(1) even on success.
  python3 "${RUN_BKG}" --inputConfig "${BKG_CFG}" --mode fTestParallel || true
  compgen -G "${BKG_OUTDIR}/CMS-HGG_multipdf_*.root" >/dev/null || {
    echo "ERROR: background multipdf missing under ${BKG_OUTDIR}" >&2
    exit 1
  }
}

run_background_fit_cli() {
  local DATA_WS_DST="$1" BKG_EXT="$2" BKG_OUTDIR="$3" CAT_LABEL="$4"
  local MULTIPDF_NAME="$5"
  cd "${FLASHGG}/Background"
  rm -rf "${BKG_OUTDIR}"
  mkdir -p "${BKG_OUTDIR}"
  ./bin/fTest -i "${DATA_WS_DST}/allData.root" \
    --saveMultiPdf "${BKG_OUTDIR}/${MULTIPDF_NAME}" \
    -D "${BKG_OUTDIR}/bkgfTest-Data" -f "${CAT_LABEL}" --isData 1 --year all --catOffset 0
}

run_signal_fit() {
  local MODE="${1:-config}"
  shift
  if [[ "${MODE}" == "cli" ]]; then
    run_signal_fit_cli "$@"
  else
    run_signal_fit_config "$@"
  fi
}

run_background_fit() {
  local MODE="${1:-config}"
  shift
  if [[ "${MODE}" == "cli" ]]; then
    run_background_fit_cli "$@"
  else
    run_background_fit_config "$@"
  fi
}
