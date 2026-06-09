
backgroundScriptCfg = {
  
  'inputWSDir':'/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit/myRun3/Resolved/cat0/output_X1000_root4fit_resolved_v1/data_X1000_resolved_cat0/data_X1000_Y200/ws', # location of 'allData.root' file
  'cats':'resolved_cat0', # auto: automatically inferred from input ws
  'catOffset':0, # add offset to category numbers (useful for categories from different allData.root files)  
  'ext':'allData_EGamma_22_23_X1000_Y200_resolved_cat0', # extension to add to output directory
  'year':'combined', # Use combined when merging all years in category (for plots)

  # Job submission options
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury
}

