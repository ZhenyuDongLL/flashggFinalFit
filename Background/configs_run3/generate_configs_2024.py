import os

# ================= 配置区域 =================
mass_list = ['100', '60', '150', '125', '90', '400', '95', '500', '200', '600', '70', '80', '800', '300']

# [修改点 1] Data 在 EOS 上的基础路径
# 请务必确认这个路径！通常 Signal 在 .../signalMC，Data 可能在 .../Data 或者 .../data
# 假设路径如下 (如果不同请修改):
eos_base_path = "/eos/cms/store/group/phys_higgs/cmshgg/zhenyudong/v4/processed_root/data"

# 输出 Config 的文件夹 (保持与 Signal 脚本一致)
output_config_dir = "../configs_run3_2024/boosted"

# 确保输出目录存在
if not os.path.exists(output_config_dir):
    os.makedirs(output_config_dir)

# ================= 模板 =================
template = """
backgroundScriptCfg = {{
  
  # Input Workspace Directory
  # 指向 EOS 上对应 Mass 点的 Data workspace
  'inputWSDir':'{inputdir}', 
  
  'cats':'auto', # auto: automatically inferred from input ws (usually 'boosted')
  'catOffset':0, # add offset to category numbers
  
  # Extension name for output directory
  # 格式: allData_2024_X1000_Y{Ymass}_boosted
  'ext':'allData_2024_X1000_Y{Ymass}_boosted', 
  
  'year':'2024', # Use 2024 for this specific run

  # Job submission options
  'batch':'local', # [condor,SGE,IC,local]
  'queue':'hep.q' # for condor e.g. microcentury
}}
"""

# ================= 生成逻辑 =================
print(f"Generating Background configs in directory: {output_config_dir}")

for Ymass in mass_list:
    
    # [修改点 2] 动态构建 Data 的 EOS 路径
    # 假设文件夹命名格式为: data_X1000_Y100
    # 假设子文件夹为: ws (或者是 ws_data，请检查你的 EOS 目录结构)
    # folder_name = f"data_X1000_Y{Ymass}"
    
    # 拼接完整路径: /eos/.../Data/data_X1000_Y100/ws
    # input_ws_dir = os.path.join(eos_base_path, folder_name, "ws")
    input_ws_dir = os.path.join(eos_base_path, "ws")

    # 填充模板
    cfg = template.format(
        Ymass=Ymass, 
        inputdir=input_ws_dir
    )
    
    # 文件名: config_background_data_2024_X1000_Y..._boosted.py
    filename = f"config_background_data_2024_X1000_Y{Ymass}_boosted.py"
    full_path = os.path.join(output_config_dir, filename)
    
    with open(full_path, "w") as f:
        f.write(cfg)
        
    print(f"  -> Generated: {filename}")
    # print(f"     Pointing to: {input_ws_dir}") # 调试用

print("Done.")