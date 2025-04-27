#!/usr/bin/env python3
import os
import xml.etree.ElementTree as ET

def extract_ed2k_info(folder_path, output_file):
    with open(output_file, 'w', encoding='utf-8') as f:  # 自动覆盖旧文件
        for filename in os.listdir(folder_path):
            if not filename.endswith('.xml'):
                continue
            
            file_path = os.path.join(folder_path, filename)
            
            try:
                tree = ET.parse(file_path)
                root = tree.getroot()
                
                # 查找所有FileEntry元素
                file_entries = root.findall('.//FileEntry')
                if not file_entries:
                    print(f"警告：{filename} 中未找到FileEntry节点")
                    continue
                
                for idx, file_entry in enumerate(file_entries, 1):
                    # 提取并处理路径
                    rel_path = file_entry.get('RelativePathName')
                    if not rel_path:
                        print(f"警告：{filename} 第{idx}个FileEntry缺少路径")
                        continue
                    
                    # 替换路径分隔符为点号
                    rel_path = rel_path.replace("/", ".").replace("\\", ".")
                    
                    size = file_entry.get('Size')
                    emule_hash = file_entry.get('eMuleHash')
                    
                    if not all([size, emule_hash]):
                        print(f"警告：{filename} 第{idx}个FileEntry属性不全")
                        continue
                    
                    # 生成并输出ed2k链接
                    ed2k_link = f"ed2k://|file|{rel_path}|{size}|{emule_hash}|/\n"
                    f.write(ed2k_link)
                    print(ed2k_link.strip())  # 控制台同时显示
                
            except ET.ParseError:
                print(f"错误：{filename} 不是有效的XML文件")
            except Exception as e:
                print(f"处理 {filename} 时发生错误：{str(e)}")

if __name__ == "__main__":
    # 内置配置（直接修改下方变量值）
    target_folder = "/vol1/1000/脚本项目/xml文件提取"         # 要处理的XML文件夹路径
    output_file = "/vol1/1000/脚本项目/ed2k_links.txt"        # 输出文件路径
    
    if not os.path.exists(target_folder):
        print(f"错误：目录 {target_folder} 不存在")
        exit(1)
        
    extract_ed2k_info(target_folder, output_file)
    print(f"\nED2K链接已导出到：{os.path.abspath(output_file)}")