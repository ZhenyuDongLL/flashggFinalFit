# trees2wsCfg template: resolved_cat0 is replaced per category (see run_resolved.sh).
trees2wsCfg = {
    "inputTreeDir": "DiphotonTree",
    "mainVars": ["CMS_hgg_mass", "Res_dijet_mass", "weight", "dZ", "weight_*", "*sigma"],
    "dataVars": ["CMS_hgg_mass", "Res_dijet_mass", "weight"],
    "stxsVar": "",
    "notagVars": ["weight", "*sigma"],
    "systematicsVars": ["CMS_hgg_mass", "Res_dijet_mass", "weight"],
    "theoryWeightContainers": {},
    "systematics": [],
    "cats": ["resolved_cat1"],
}
