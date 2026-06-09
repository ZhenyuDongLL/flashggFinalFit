
backgroundScriptCfg = {
  
  # Input Workspace Directory
  # 指向 EOS 上对应 Mass 点的 Data workspace
  'inputWSDir':'/eos/cms/store/group/phys_higgs/cmshgg/zhenyudong/v3/processed_slimmed/merged_22_23//ws', 
  
  'cats':'auto', # auto: automatically inferred from input ws (usually 'boosted')
  'catOffset':0, # add offset to category numbers
  
  # Extension name for output directory
  # 格式: allData_2024_X1000_Y100_boosted
  'ext':'allData_22_23_MX_1000_MY_80_boosted', 
  
  'year':'merged', # Use 2024 for this specific run

  # Job submission options
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury
}
