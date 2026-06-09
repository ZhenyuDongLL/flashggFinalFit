WhichSamples=${1}
if [ ${WhichSamples} -eq 0 ]
  then
    # echo 'run plot_limits'
    python3 plot_limits_run3_dzy.py  --resultType 'bbgg' --unit 'fb' --ymin 0.01 --ymax 10 --year 2022 --yboost 0
    
    
    python plot_limit_2.py --resultType 'bbgg' --unit 'fb' --ymin 0.01 --ymax 10000000000 --year 2017 --yboost 0 
    # python plot_limit_all.py --resultType 'bbgg' --unit 'fb' --ymin 0.01 --ymax 10000000000 --year 2017 --yboost 0
    # python plot_limit_cp.py --resultType 'HY' --unit 'fb' --ymin 0.01 --ymax 10 --year 2017 --yboost 0
    # for i in {1000,1200,1400,1600,1800,2000,2200,2400,2500,2600,2800,3000,3500,4000}
    # do
    #   python plot_limit_$i.py --resultType 'bbgg' --unit 'fb' --ymin 0.01 --ymax 100 --year 2017 --yboost 0 
    #   python plot_limit_$i.py --resultType 'HY' --unit 'fb' --ymin 10 --ymax 10000 --year 2017 --yboost 0
    # done

    python3 plot_limits_run3_dzy_v2.py --resultType 'bbgg' --unit fb --ymin 0.1 --ymax 10 --yboost 0 --year 2024 --MX 1000 --maxMY 250
fi
