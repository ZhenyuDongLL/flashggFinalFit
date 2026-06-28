#!/usr/bin/env bash
source /cvmfs/cms.cern.ch/cmsset_default.sh
cmsenv
source "${CMSSW_BASE}/src/flashggFinalFit/setup.sh"
unset PYTHONHOME
