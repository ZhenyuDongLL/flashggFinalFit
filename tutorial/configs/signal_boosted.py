# Template for boosted signal fit. Placeholders filled by run_boosted.sh.

signalScriptCfg = {
    "inputWSDir": "@SIG_WS_DST@",
    "procs": "nmssm",
    "cats": "boosted",
    "ext": "@SIG_EXT@",
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
