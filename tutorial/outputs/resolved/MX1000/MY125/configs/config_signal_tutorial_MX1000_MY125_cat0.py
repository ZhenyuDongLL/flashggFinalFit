# Template for resolved signal fit (one category per generated file).
# Placeholders SIG_WS_DST / SIG_EXT / category are filled by run_resolved.sh.

signalScriptCfg = {
    "inputWSDir": "/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit/tutorial/outputs/resolved/MX1000/MY125/workspaces/cat0/signal/222324/ws_nmssm",
    "procs": "nmssm",
    "cats": "resolved_cat0",
    "ext": "signal_222324_tutorial_MX1000_MY125_cat0_13p6TeV",
    "analysis": "STXS",
    "year": "merged",
    "massPoints": "125",
    "scales": "",
    "scalesCorr": "",
    "scalesGlobal": "",
    "smears": "",
    "batch": "local",
    "queue": "hep.q",
}
