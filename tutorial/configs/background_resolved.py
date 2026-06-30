# Template for resolved background multipdf (one category per generated file).
# Placeholders DATA_WS_DST / BKG_EXT / category are filled by run_resolved.sh.

backgroundScriptCfg = {
    "inputWSDir": "@DATA_WS_DST@",
    "cats": "resolved_cat0",
    "catOffset": 0,
    "ext": "@BKG_EXT@",
    "year": "combined",
    "batch": "local",
    "queue": "hep.q",
}
