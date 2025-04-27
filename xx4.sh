#!/bin/bash

# ==============================
# 老范AV小姐姐工具箱 v1.1
# 适配多系统：Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky
# ==============================


SCRIPT_DIR="$HOME/my_tools"
CONFIG_FILE="$HOME/.avtools_config"


# ================== 样式配置 ==================
COLOR_HEADER="\033[38;5;27m"       # 蓝色标题
COLOR_ASCII="\033[38;5;208;5m"     # 橙色带闪烁特效（用于ASCII艺术字）
COLOR_DIVIDER="\033[38;5;46m"      # 绿色分割线
COLOR_OPTION="\033[38;5;231m"      # 白色选项编号
COLOR_DESC="\033[38;5;247m"        # 灰色描述文字
COLOR_YELLOW="\033[38;5;226m"      # 黄色提示
COLOR_CYAN="\033[38;5;51m"         # 亮青色标题内容
COLOR_ORANGE="\033[38;5;214m"      # 橙色普通提示
COLOR_RESET="\033[0m"              # 重置颜色
RED="\033[31m"                     # 红色
GREEN="\033[32m"                   # 绿色

# ================== 脚本映射 ==================
declare -A PY_SCRIPTS=(
    ["1"]="tq.py:提取磁力:从txt文件内提取"
    ["2"]="ed2k_generator.py:提取ed2k:从zml文件内提取"
    ["3"]="setup_shortcut:设置快捷方式:当前名称：$( [ -f "$CONFIG_FILE" ] && echo $(cat "$CONFIG_FILE") || echo 'avtools' )"
    ["00"]="update.sh:脚本更新:从仓库获取最新版本"
    ["0"]="exit:退出脚本:" 
)

# ================== 显示顶部标题 ==================
show_header() {
    clear
    echo -e "${COLOR_ASCII}"
    echo '   █████╗ ██╗   ██╗     ██████╗ ██╗██████╗ ██╗     '
    echo '  ██╔══██╗██║   ██║    ██╔════╝ ██║██╔══██╗██║     '
    echo '  ███████║██║   ██║    ██║  ███╗██║██████╔╝██║     '
    echo '  ██╔══██║╚██╗ ██╔╝    ██║   ██║██║██╔══██╗██║     '
    echo '  ██║  ██║ ╚████╔╝     ╚██████╔╝██║██║  ██║███████╗'
    echo '  ╚═╝  ╚═╝  ╚═══╝       ╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝'
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_CYAN}老范AV小姐姐工具箱 v1.1 支持自定义快捷指令名称！${COLOR_RESET}"
    echo -e "${COLOR_CYAN}适配Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky系统${COLOR_RESET}"
    echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
}

# ================== 菜单生成 ==================
generate_menu() {
    local order=("1" "2" "3" "00" "0")
    for key in "${order[@]}"; do
        IFS=':' read -r _ display_name description <<< "${PY_SCRIPTS[$key]}"
        case $key in
            "00")  # 更新脚本特别显示黄色
                echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
                printf "${COLOR_OPTION}[${COLOR_YELLOW}%s${COLOR_OPTION}] ${COLOR_YELLOW}%-15s${COLOR_RESET} ${COLOR_DESC}%s${COLOR_RESET}\n" \
                    "$key" "$display_name" "$description"
                ;;
            "0")  # 退出脚本特别显示红色
                echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
                printf "${COLOR_OPTION}[${RED}%s${COLOR_OPTION}] ${RED}%-15s${COLOR_RESET}\n" \
                    "$key" "$display_name"
                ;;
            "3")  # 快捷方式设置显示青色
                echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
                printf "${COLOR_OPTION}[${COLOR_CYAN}%s${COLOR_OPTION}] ${COLOR_CYAN}%-15s${COLOR_RESET} ${COLOR_DESC}%s${COLOR_RESET}\n" \
                    "$key" "$display_name" "$description"
                ;;
            *)  # 正常工具选项
                printf "${COLOR_OPTION}[%s] %-15s ${COLOR_DESC}%s${COLOR_RESET}\n" \
                    "$key" "$display_name" "$description"
                ;;
        esac
    done
}

# ================== 核心逻辑 ==================
run_script() {
    local script_name="$1"
    [[ "$script_name" == "exit" ]] && exit 0

    # 处理设置快捷方式
    if [[ "$script_name" == "setup_shortcut" ]]; then
        current_name=$( [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "avtools" )
        echo -e "${COLOR_YELLOW}当前快捷指令名称：${current_name}${COLOR_RESET}"
        echo -en "${COLOR_ORANGE}🌸 请输入新快捷指令名称（留空使用默认值）：${COLOR_RESET}"
        read -r new_name
        new_name=${new_name:-avtools}  # 空值则使用默认
        
        # 验证名称合法性
        if [[ ! "$new_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            echo -e "${RED}❌ 名称包含非法字符，仅允许字母、数字、下划线和减号！${COLOR_RESET}"
            sleep 2
            return
        fi
        
        # 保存配置
        echo "$new_name" > "$CONFIG_FILE"
        echo -e "${GREEN}✅ 名称已保存为：$new_name${COLOR_RESET}"
        
        # 创建快捷方式
        mkdir -p "$HOME/bin"
        ln -sf "$(realpath "$0")" "$HOME/bin/$new_name" 2>/dev/null
        chmod +x "$HOME/bin/$new_name"
        
        # 检查PATH
        if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
            echo -e "${COLOR_YELLOW}提示：请将以下行添加到shell配置文件中：${COLOR_RESET}"
            echo 'export PATH="$HOME/bin:$PATH"'
            echo -e "${COLOR_YELLOW}然后运行命令：source ~/.bashrc 或重新打开终端。${COLOR_RESET}"
        fi
        
        echo -e "${GREEN}✅ 快捷方式 '$new_name' 已创建！现在可直接输入 '$new_name' 启动工具。${COLOR_RESET}"
        sleep 2
        return
    fi


    # 如果选择更新脚本
    if [[ "$script_name" == "update.sh" ]]; then
        echo -e "${GREEN}正在从仓库获取最新版本...${COLOR_RESET}"
        wget -q https://github.com/Fanxing-9049/AV-X/blob/main/xx4.sh -O $0
        chmod +x $0
        echo -e "${GREEN}更新完成，正在重新启动脚本！${COLOR_RESET}"
        exec $0
        exit
    fi

    local full_path="${SCRIPT_DIR}/${script_name}"
    if [[ -f "$full_path" ]]; then
        echo -e "\n${COLOR_HEADER}🎀 正在运行：${display_name}${COLOR_RESET}"
        "$full_path"
        echo -e "\n${COLOR_HEADER}✅ 操作完成，按回车返回菜单~${COLOR_RESET}"
        read -r
    else
        echo -e "${RED}❌ 错误：找不到工具文件 $script_name${COLOR_RESET}"
        sleep 2
    fi
}

# ================== 快速启动模式 ==================
[[ "$1" == "F" ]] && {
    echo -e "${GREEN}🚀 快速启动菜单系统...${COLOR_RESET}"
    sleep 1
    exec $0
}

# ================== 主循环 ==================
while true; do
    show_header
    generate_menu
    echo -en "${COLOR_ORANGE}🌸 请输入选项编号：${COLOR_RESET}"
    read -r choice

    case $choice in
        "F") exec $0 ;;
        "00"|"0"|"1"|"2"|"3")
            IFS=':' read -r filename display_name _ <<< "${PY_SCRIPTS[$choice]}"
            run_script "$filename"
            ;;
        *)
            echo -e "${RED}输入有误，请选择有效选项哦~ (´･ω･\`)っ${COLOR_RESET}"
            sleep 1
            ;;
    esac
done
