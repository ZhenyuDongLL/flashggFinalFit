import os

# Paths and directory
cmsswbase__ = os.environ['CMSSW_BASE']
cwd__ = os.environ['CMSSW_BASE']+"/src/flashggFinalFit"
swd__ = "%s/Signal"%cwd__
bwd__ = "%s/Background"%cwd__
dwd__ = "%s/Datacard"%cwd__
fwd__ = "%s/Combine"%cwd__
pwd__ = "%s/Plots"%cwd__
twd__ = "%s/Trees2WS"%cwd__

# Centre of mass energy string
#sqrts__ = "13TeV"
sqrts__ = "13p6TeV"

# Luminosity map in fb^-1: for using UL 2018w
lumiMap = {
    '2016':36.33, 
    '2016pre':19.48, 
    '2016post': 16.76, 
    '2017':41.48, 
    '2018':59.83, 
    'combined':61.8971,
    '2022preEE':7.98,
    '2022postEE':26.67,
    '2023preBPix':17.794,
    '2023postBPix':9.451,
    'merged':61.8971,
    '2024':109.08,

    }
# If using ReReco samples then switch to lumiMap below (missing data in 2018 EGamma data set)
#lumiMap = {'2016':36.33, '2017':41.48, '2018':59.35, 'combined':137.17, 'merged':137.17}
lumiScaleFactor = 1000. # Converting from pb to fb

# Constants
BR_W_lnu = 3.*10.86*0.01
BR_Z_ll = 3*3.3658*0.01
BR_Z_nunu = 20.00*0.01
BR_Z_qq = 69.91*0.01
BR_W_qq = 67.41*0.01

# Production modes and decay channel: for extract XS from combine
productionModes = ['ggH','qqH','ttH','tHq','tHW','WH','ZH','bbH']
decayMode = 'hgg'

years_to_process = ['2016','2017','2018','2022preEE','2022postEE','2023preEE','2023postEE', 'merged', '2024']

# flashgg input WS objects
#inputWSName__ = "tagsDumper/cms_hgg_13TeV"
inputWSName__ = "tagsDumper/cms_hgg_13p6TeV"
inputNuisanceExtMap = {'scales':'','scalesCorr':'','smears':''}
# Signal output WS objects
outputWSName__ = "wsig"
outputWSObjectTitle__ = "hggpdfsmrel"
# outputWSObjectTitle__ = "hjjpdfsmrel"
outputWSNuisanceTitle__ = "CMS_hgg_nuisance"
# outputWSNuisanceTitle__ = "CMS_hjj_nuisance"
outputNuisanceExtMap = {'scales':'%sscale'%sqrts__,'scalesCorr':'%sscaleCorr'%sqrts__,'smears':'%ssmear'%sqrts__,'scalesGlobal':'%sscale'%sqrts__}
# Bkg output WS objects
bkgWSName__ = "multipdf"
