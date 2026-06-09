mass_list = ['100', '60', '150', '125', '90', '400', '95', '500', '200', '600', '70', '80', '800', '300']
inputdir='/afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit/myRun3/Resolved/cat0/output_X1000_root4fit_resolved_std_tianyuinput_v4_n10/data_X1000_resolved_cat0/'

template = """
backgroundScriptCfg = {{
  
  'inputWSDir':'{inputdir}data_X1000_Y{Ymass}/ws', # location of 'allData.root' file
  'cats':'resolved_cat0', # auto: automatically inferred from input ws
  'catOffset':0, # add offset to category numbers (useful for categories from different allData.root files)  
  'ext':'allData_EGamma_22_23_X1000_Y{Ymass}_resolved_cat0', # extension to add to output directory
  'year':'combined', # Use combined when merging all years in category (for plots)

  # Job submission options
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury
}}

"""

for Ymass in mass_list:
    cfg = template.format(Ymass=Ymass, inputdir=inputdir)
    with open(f"config_run3_EGamma_22_23_X1000_Y{Ymass}_resolved_cat0.py", "w") as f:
        f.write(cfg)
