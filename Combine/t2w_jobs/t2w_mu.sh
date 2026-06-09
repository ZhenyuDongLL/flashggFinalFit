#!/bin/bash

cd /afs/cern.ch/user/z/zhdong/work/Xbbgg/CMSSW_14_1_0_pre4/src/flashggFinalFit/Combine

eval `scramv1 runtime -sh`

text2workspace.py Datacard.txt -o Datacard_mu.root -m 125 higgsMassRange=122,128 -P HiggsAnalysis.CombinedLimit.PhysicsModel:multiSignalModel --PO "map=.*/ggH.*:r_ggH[1,0,2]" --PO "map=.*/bbH.*:r_ggH[1,0,2]" --PO "map=.*/qqH.*:r_VBF[1,0,3]" --PO "map=.*/WH_had.*:r_VH[1,0,3]" --PO "map=.*/ZH_had.*:r_VH[1,0,3]" --PO "map=.*/ggZH_had.*:r_VH[1,0,3]" --PO "map=.*/WH_lep.*:r_VH[1,0,3]" --PO "map=.*/ZH_lep.*:r_VH[1,0,3]" --PO "map=.*/ggZH_ll.*:r_VH[1,0,3]" --PO "map=.*/ggZH_nunu.*:r_VH[1,0,3]" --PO "map=.*/ttH.*:r_top[1,0,3]" --PO "map=.*/tHq.*:r_top[1,0,3]" --PO "map=.*/tHW.*:r_top[1,0,3]"