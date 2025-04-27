#!/bin/bash

# ==============================
# 老范AV小姐姐工具箱 v1.2
# 适配多系统：Ubuntu/Debian/CentOS/Alpine/Kali/Arch/RedHat/Fedora/Alma/Rocky
# ==============================
# ================== 自动下载依赖文件 ==================
REPO_URL="https://raw.githubusercontent.com/Fanxing-9049/AV-X/main"
DEPENDENCIES=("tq.py" "ed2k_generator.py")

check_dependencies() {
    for file in "${DEPENDENCIES[@]}"; do
        if [[ ! -f "$file" ]]; then
            echo -e "\033[33m正在下载依赖文件: $file...\033[0m"
            if ! curl -sSL "${REPO_URL}/${file}" -o "$file"; then
                echo -e "\033[31m❌ 下载 $file 失败，请检查网络连接！\033[0m"
                exit 1
            fi
            chmod +x "$file"
        fi
    done
}

# 执行依赖检查
check_dependencies


# 核心配置
SCRIPT_VERSION="1.2"
SCRIPT_NAME="xx4"
REPO_OWNER="Fanxing-9049"
REPO_NAME="AV-X"
BRANCH="main"
CONFIG_FILE="$HOME/.xx4_config"

# 路径安全验证
REAL_SCRIPT_PATH=$(readlink -f "$0")
if [[ "$0" != "$REAL_SCRIPT_PATH" ]]; then
    exec /bin/bash "$REAL_SCRIPT_PATH" "$@"
    exit $?
fi

# ================== 样式配置 ==================
COLOR_HEADER="\033[38;5;27m"       # 蓝色标题
COLOR_ASCII="\033[38;5;208;5m"     # 橙色带闪烁特效
COLOR_DIVIDER="\033[38;5;46m"      # 绿色分割线
COLOR_OPTION="\033[38;5;231m"      # 白色选项
COLOR_DESC="\033[38;5;247m"        # 灰色描述
COLOR_YELLOW="\033[38;5;226m"      # 黄色提示
COLOR_CYAN="\033[38;5;51m"         # 亮青色
COLOR_ORANGE="\033[38;5;214m"      # 橙色
COLOR_RESET="\033[0m"              # 重置颜色
RED="\033[31m"                     # 红色
GREEN="\033[32m"                   # 绿色

# ================== 脚本映射 ==================
declare -A PY_SCRIPTS=(
    ["1"]="tq.py:提取磁力:从txt文件内提取"
    ["2"]="ed2k_generator.py:提取ed2k:从zml文件内提取"
    ["3"]="setup_shortcut:设置快捷方式:当前名称：$( [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo 'avtools' )"
    ["00"]="update:脚本更新:当前版本v$SCRIPT_VERSION"
    ["0"]="exit:退出脚本:" 
)

# ================== 显示标题 ==================
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
    echo -e "${COLOR_CYAN}老范AV小姐姐工具箱 v${SCRIPT_VERSION} 安全稳定版${COLOR_RESET}"
    echo -e "${COLOR_CYAN}GitHub仓库: https://github.com/${REPO_OWNER}/${REPO_NAME}${COLOR_RESET}"
    echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
}

# ================== 更新逻辑 ==================
safe_update() {
    # 创建备份文件
    local backup_file="$0.bak"
    cp -f "$0" "$backup_file"

    # 获取远程版本
    echo -e "${GREEN}正在连接GitHub仓库检查更新...${COLOR_RESET}"
    VERSION_CHECK_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/version.txt"
    if ! remote_version=$(curl -sL "$VERSION_CHECK_URL"); then
        echo -e "${RED}❌ 无法获取版本信息，请检查："
        echo -e "1. 网络连接状态\n2. 仓库地址是否正确\n3. GitHub服务状态${COLOR_RESET}"
        return 1
    fi

    # 版本比对
    if [ "$(printf '%s\n' "$remote_version" "$SCRIPT_VERSION" | sort -V | head -n1)" = "$remote_version" ]; then
        echo -e "${COLOR_CYAN}当前已是最新版本 (v$SCRIPT_VERSION)${COLOR_RESET}"
        return 0
    fi

    # 下载新版本
    echo -e "${GREEN}发现新版本 v$remote_version，正在安全下载...${COLOR_RESET}"
    UPDATE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH/$SCRIPT_NAME"
    if ! curl -sL "$UPDATE_URL" -o "$0.tmp"; then
        echo -e "${RED}❌ 下载更新失败，错误代码：$?${COLOR_RESET}"
        return 1
    fi

    # 完整性校验
    if ! grep -q '老范AV小姐姐工具箱' "$0.tmp"; then
        echo -e "${RED}❌ 文件校验失败：缺少标识特征${COLOR_RESET}"
        rm -f "$0.tmp"
        return 1
    fi

    # 文件替换保护
    sync && sleep 0.5
    chmod +x "$0.tmp"
    if ! mv -f "$0.tmp" "$0"; then
        echo -e "${RED}❌ 文件替换失败，请尝试："
        echo -e "1. 手动运行: sudo $0 00\n2. 检查文件权限\n3. 确认磁盘空间充足${COLOR_RESET}"
        return 1
    fi

    # 安全重启
    echo -e "\n${GREEN}✅ 更新成功！新版本v$remote_version正在启动...${COLOR_RESET}"
    exec "/bin/bash" "$REAL_SCRIPT_PATH" "$@"
    exit 0
}

# ================== 核心逻辑 ==================
run_script() {
    local script_name="$1"
    [[ "$script_name" == "exit" ]] && exit 0

    case $script_name in
        "setup_shortcut")
            current_name=$( [ -f "$CONFIG_FILE" ] && cat "$CONFIG_FILE" || echo "avtools" )
            echo -e "${COLOR_YELLOW}当前快捷指令名称：${current_name}${COLOR_RESET}"
            echo -en "${COLOR_ORANGE}🌸 请输入新名称（默认avtools）：${COLOR_RESET}"
            read -r new_name
            new_name=${new_name:-avtools}

            if [[ ! "$new_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                echo -e "${RED}❌ 名称包含非法字符！只允许字母、数字、_和-${COLOR_RESET}"
                sleep 2
                return
            fi

            # 删除旧链接
            [ -L "$HOME/bin/$current_name" ] && rm -f "$HOME/bin/$current_name"
            
            # 创建新链接
            mkdir -p "$HOME/bin"
            ln -sf "$REAL_SCRIPT_PATH" "$HOME/bin/$new_name"
            echo "$new_name" > "$CONFIG_FILE"
            
            echo -e "${GREEN}✅ 快捷方式 '$new_name' 已生效！"
            echo -e "重启终端后可直接输入 ${COLOR_CYAN}$new_name${GREEN} 启动${COLOR_RESET}"
            sleep 2
            ;;
        "update")
            safe_update
            ;;
        *)
            local full_path="${REAL_SCRIPT_PATH%/*}/${script_name}"
            if [[ -f "$full_path" ]]; then
                echo -e "\n${COLOR_HEADER}🎯 正在执行：${script_name%%:*}${COLOR_RESET}"
                python3 "$full_path"
                echo -e "\n${COLOR_HEADER}✅ 操作完成，按回车返回菜单${COLOR_RESET}"
                read -r
            else
                echo -e "${RED}❌ 找不到工具文件：$script_name${COLOR_RESET}"
                sleep 2
            fi
            ;;
    esac
}

# ================== 主循环 ==================
while true; do
    show_header
    echo -e "${COLOR_OPTION}[1] 提取磁力       ${COLOR_DESC}从txt文件内提取"
    echo -e "${COLOR_OPTION}[2] 提取ed2k       ${COLOR_DESC}从zml文件内提取"
    echo -e "${COLOR_OPTION}[3] 设置快捷方式   ${COLOR_CYAN}$([ -f "$CONFIG_FILE" ] && echo "当前命令: $(cat "$CONFIG_FILE")" || echo "首次使用请设置")${COLOR_RESET}"
    echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"
    echo -e "${COLOR_OPTION}[00] ${COLOR_YELLOW}脚本更新       ${COLOR_DESC}当前版本v${SCRIPT_VERSION}${COLOR_RESET}"
    echo -e "${COLOR_OPTION}[0] ${RED}退出脚本${COLOR_RESET}"
    echo -e "${COLOR_DIVIDER}---------------------------${COLOR_RESET}"

    echo -en "${COLOR_ORANGE}🛠️ 请输入选项编号：${COLOR_RESET}"
    read -r choice

    case $choice in
        "00"|"0"|"1"|"2"|"3")
            IFS=':' read -r filename _ <<< "${PY_SCRIPTS[$choice]}"
            run_script "$filename"
            ;;
        *)
            echo -e "${RED}输入无效，请选择正确的选项编号！${COLOR_RESET}"
            sleep 1
            ;;
    esac
done
