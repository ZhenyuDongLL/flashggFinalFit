# Template for resolved signal fit (one category per generated file).
# Placeholders SIG_WS_DST / SIG_EXT / category are filled by run_resolved.sh.

signalScriptCfg = {
    "inputWSDir": "@SIG_WS_DST@",
    "procs": "nmssm",
    "cats": "resolved_cat0",
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
