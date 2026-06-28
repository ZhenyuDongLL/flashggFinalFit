#!/usr/bin/env bash
# Resolved tutorial: cat0+cat1 ROOT -> combined datacard -> limit.
set -eo pipefail

TUTORIAL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CMSSW_BASE="${CMSSW_BASE:-/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4}"
FLASHGG="${CMSSW_BASE}/src/flashggFinalFit"
MX="${MX:-1000}"
MY="${MY:-125}"
YEAR="${YEAR:-222324}"
TUTORIAL_TAG="${TUTORIAL_TAG:-tutorial}"
NCATS="${NCATS:-2}"
MJET="${MY}"
MJET_LOW=0
MJET_HIGH=400
SKIP_SIGNAL_SYST="${SKIP_SIGNAL_SYST:-1}"
SAMPLES_ROOT="${TUTORIAL_SAMPLES_ROOT:-${TUTORIAL_ROOT}/samples}"
SAMPLE_POINT="${SAMPLES_ROOT}/resolved/MX${MX}/MY${MY}"
OUT_POINT="${TUTORIAL_ROOT}/outputs/resolved/MX${MX}/MY${MY}"

export CMSSW_BASE
unset PYTHONHOME PYTHONPATH
cd "${CMSSW_BASE}/src"
source "${TUTORIAL_ROOT}/env_cmssw.sh"

export PYTHONPATH_TREES2WS="${TUTORIAL_ROOT}/shim:${FLASHGG}/Trees2WS/tools:${FLASHGG}/tools:${FLASHGG}/Signal/tools:${PYTHONPATH}"
export PYTHONPATH_DATACARD="${TUTORIAL_ROOT}/shim:${FLASHGG}/Datacard/tools:${FLASHGG}/tools:${PYTHONPATH}"

mkdir -p "${OUT_POINT}/signal" "${OUT_POINT}/background" "${OUT_POINT}/datacards" "${OUT_POINT}/combine"
T2W_TEMPLATE="${TUTORIAL_ROOT}/configs/trees2ws_resolved.py"
CFG_DIR="${OUT_POINT}/configs"
mkdir -p "${CFG_DIR}"
YIELD_EXT="run3_${YEAR}_${TUTORIAL_TAG}_MX${MX}_MY${MY}_resolved"
DC_BASE="Datacard_${YIELD_EXT}"
DC_FILE="${FLASHGG}/Datacard/${DC_BASE}.txt"
DC_OUT="${TUTORIAL_ROOT}/outputs/resolved/datacards/Datacard_resolved.txt"

write_trees2ws_cfg() {
  local CAT="$1"
  local CFG="${CFG_DIR}/trees2ws_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}.py"
  sed "s/\"resolved_cat0\"/\"resolved_cat${CAT}\"/" "${T2W_TEMPLATE}" > "${CFG}"
  echo "${CFG}"
}

run_cat_pipeline() {
  local CAT="$1"
  local WS_BASE="${OUT_POINT}/workspaces/cat${CAT}"
  mkdir -p "${WS_BASE}/signal/${YEAR}" "${WS_BASE}/data/${YEAR}"
  local T2W_CFG T2W_CFG_BASE T2W_LINK
  T2W_CFG="$(write_trees2ws_cfg "${CAT}")"
  T2W_CFG_BASE="$(basename "${T2W_CFG}")"
  export PYTHONPATH="${PYTHONPATH_TREES2WS}"
  T2W_LINK="${FLASHGG}/Trees2WS/${T2W_CFG_BASE}"
  ln -sf "${T2W_CFG}" "${T2W_LINK}"

  local SIG_IN DATA_IN
  SIG_IN="$(ls "${SAMPLE_POINT}/signal/"*_cat${CAT}.root | head -1)"
  DATA_IN="$(ls "${SAMPLE_POINT}/data/"*_cat${CAT}.root | head -1)"

  cd "${FLASHGG}/Trees2WS"
  python3 trees2ws_new.py --inputConfig "${T2W_CFG_BASE}" --inputTreeFile "${SIG_IN}" \
    --productionMode nmssm --inputMass 125 --year "${YEAR}" \
    --jetmass "${MJET}" --low "${MJET_LOW}" --high "${MJET_HIGH}"
  python3 trees2ws_data_new.py --inputConfig "${T2W_CFG_BASE}" --inputTreeFile "${DATA_IN}" \
    --jetmass "${MJET}" --low "${MJET_LOW}" --high "${MJET_HIGH}"
  rm -f "${T2W_LINK}"

  local SIG_WS_SRC SIG_WS_DST SIG_WS_FILE
  SIG_WS_SRC="$(dirname "${SIG_IN}")/ws_nmssm"
  SIG_WS_DST="${WS_BASE}/signal/${YEAR}/ws_nmssm"
  mkdir -p "${SIG_WS_DST}"
  rm -f "${SIG_WS_DST}"/*.root
  SIG_WS_FILE="$(ls "${SIG_WS_SRC}"/*cat${CAT}*.root | head -1)"
  cp -f "${SIG_WS_FILE}" "${SIG_WS_DST}/$(basename "${SIG_WS_FILE}")"
  local SIG_WS_FLASHGG="output_signal_${MX}_${MY}_analysis_pnn_cat${CAT}_M125_pythia8_nmssm.root"
  [[ "$(basename "${SIG_WS_FILE}")" != "${SIG_WS_FLASHGG}" ]] && \
    ln -sf "$(basename "${SIG_WS_FILE}")" "${SIG_WS_DST}/${SIG_WS_FLASHGG}"

  local DATA_WS_SRC DATA_WS_DST DATA_WS_FILE
  DATA_WS_SRC="$(dirname "${DATA_IN}")/ws"
  DATA_WS_DST="${WS_BASE}/data/${YEAR}/ws"
  mkdir -p "${DATA_WS_DST}"
  rm -f "${DATA_WS_DST}"/*.root
  DATA_WS_FILE="$(ls "${DATA_WS_SRC}"/*cat${CAT}*.root 2>/dev/null | head -1)"
  [[ -z "${DATA_WS_FILE}" ]] && DATA_WS_FILE="$(ls "${DATA_WS_SRC}"/data_*.root | head -1)"
  cp -f "${DATA_WS_FILE}" "${DATA_WS_DST}/$(basename "${DATA_WS_FILE}")"
  cp -f "${DATA_WS_FILE}" "${DATA_WS_DST}/allData.root"

  local SIG_EXT PACK_EXT SIG_MODEL_DIR PACK_FILE BKG_EXT BKG_OUTDIR
  SIG_EXT="signal_${YEAR}_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}_13p6TeV"
  PACK_EXT="packaged_${YEAR}_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}"

  cd "${FLASHGG}/Signal"
  mkdir -p "${FLASHGG}/Signal/outdir_${SIG_EXT}/fTest/json" \
    "${FLASHGG}/Signal/outdir_${SIG_EXT}/signalFit/output"
  python3 scripts/fTest.py --cat "resolved_cat${CAT}" --procs nmssm --ext "${SIG_EXT}" --inputWSDir "${SIG_WS_DST}"
  local SIGFIT_EXTRA=()
  [[ "${SKIP_SIGNAL_SYST}" == "1" ]] && SIGFIT_EXTRA+=(--skipSystematics)
  python3 scripts/signalFit.py --inputWSDir "${SIG_WS_DST}" --ext "${SIG_EXT}" --proc nmssm \
    --cat "resolved_cat${CAT}" --year merged --analysis STXS --massPoints 125 \
    --scales '' --scalesCorr '' --scalesGlobal '' --smears '' \
    --replacementThreshold 50 --skipVertexScenarioSplit "${SIGFIT_EXTRA[@]}"
  python3 scripts/packageSignal.py --cat "resolved_cat${CAT}" --exts "${SIG_EXT}" \
    --massPoints 125 --mergeYears --outputExt "${PACK_EXT}"
  SIG_MODEL_DIR="${FLASHGG}/Signal/outdir_${PACK_EXT}"
  PACK_FILE="$(ls "${SIG_MODEL_DIR}"/*.root 2>/dev/null | head -1)"
  [[ -n "${PACK_FILE}" ]] && cp -f "${PACK_FILE}" "${SIG_MODEL_DIR}/CMS-HGG_sigfit_packaged_resolved_cat${CAT}.root"
  mkdir -p "${OUT_POINT}/signal/packaged_cat${CAT}"
  cp -a "${SIG_MODEL_DIR}/"* "${OUT_POINT}/signal/packaged_cat${CAT}/"

  BKG_EXT="allData_${YEAR}_${TUTORIAL_TAG}_MX${MX}_MY${MY}_cat${CAT}"
  BKG_OUTDIR="${FLASHGG}/Background/outdir_${BKG_EXT}"
  cd "${FLASHGG}/Background"
  mkdir -p "${BKG_OUTDIR}"
  ./bin/fTest -i "${DATA_WS_DST}/allData.root" \
    --saveMultiPdf "${BKG_OUTDIR}/CMS-HGG_multipdf_resolved_cat${CAT}.root" \
    -D "${BKG_OUTDIR}/bkgfTest-Data" -f "resolved_cat${CAT}" --isData 1 --year all --catOffset 0
  mkdir -p "${OUT_POINT}/background/multipdf_cat${CAT}"
  cp -a "${BKG_OUTDIR}/"* "${OUT_POINT}/background/multipdf_cat${CAT}/"

  export PYTHONPATH="${PYTHONPATH_DATACARD}"
  cd "${FLASHGG}/Datacard"
  python3 makeYields.py --cat "resolved_cat${CAT}" --procs nmssm --ext "${YIELD_EXT}" --mass 125 \
    --inputWSDirMap "merged=${SIG_WS_DST}/" --sigModelWSDir "${SIG_MODEL_DIR}/" --sigModelExt packaged \
    --bkgModelWSDir "${BKG_OUTDIR}/" --bkgModelExt multipdf --mergeYears
}

for ((CAT = 0; CAT < NCATS; CAT++)); do
  echo "=== resolved cat${CAT} ==="
  run_cat_pipeline "${CAT}"
done

export PYTHONPATH="${PYTHONPATH_DATACARD}"
cd "${FLASHGG}/Datacard"
python3 makeDatacard.py --ext "${YIELD_EXT}" --mass 125 --years merged --output "${DC_BASE}" || true
test -s "${DC_FILE}" || { echo "ERROR: missing ${DC_FILE}"; exit 1; }
python3 "${TUTORIAL_ROOT}/scripts/fix_datacard_resolved.py" "${DC_FILE}"
mkdir -p "$(dirname "${DC_OUT}")"
cp -f "${DC_FILE}" "${OUT_POINT}/datacards/${DC_BASE}.txt"
cp -f "${DC_FILE}" "${DC_OUT}"

cd "${OUT_POINT}/combine"
combine -M AsymptoticLimits -m 125 -n "res_${TUTORIAL_TAG}_MX${MX}_MY${MY}" \
  "${DC_OUT}" --run expected -v 2 | tee combine_resolved.log
echo "=== resolved limit done MX${MX} MY${MY} ==="
