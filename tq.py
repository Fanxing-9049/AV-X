#!/usr/bin/env python3
import re

def extract_magnets(input_file):
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # 匹配标准磁力链接格式（同时支持十六进制和Base32哈希）
    pattern = r'magnet:\?xt=urn:btih:[\da-zA-Z]{32,40}(?:&[^\s&]*)*'
    magnets = re.findall(pattern, content)
    
    return magnets

if __name__ == '__main__':
    # 内置文件名配置
    input_file = '/vol1/1000/脚本项目/input.txt'    # 输入文件名（直接修改此处）
    output_file = '/vol1/1000/脚本项目/output.txt'  # 输出文件名（设为None则直接打印结果）
    
    magnets = extract_magnets(input_file)
    
    if output_file:
        with open(output_file, 'w') as f:
            for link in magnets:
                f.write(link + '\n')
        print(f"已提取 {len(magnets)} 个磁力链接到 {output_file}")
    else:
        for link in magnets:
            print(link)