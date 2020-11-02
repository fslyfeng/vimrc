#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 获取平台类型，mac还是linux平台
function get_platform_type() {
    echo $(uname)
}
# 获取linux发行版名称
function get_linux_distro() {
    if grep -Eq "Debian" /etc/*-release; then
        echo "Debian"
    else
        echo "Unknow"
    fi
}
# 获取日期
function get_datetime() {
    time=$(date "+%Y%m%d%H%M%S")
    echo $time
}
# 判断文件是否存在
function is_exist_file() {
    filename=$1
    if [ -f $filename ]; then
        echo 1
    else
        echo 0
    fi
}

# 判断目录是否存在
function is_exist_dir() {
    dir=$1
    if [ -d $dir ]; then
        echo 1
    else
        echo 0
    fi
}

# 备份原有的.vim目录
function backup_vim_dir() {
    old_vim=$HOME"/.vim"
    is_exist=$(is_exist_dir $old_vim)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_vim=$old_vim"_bak_"$time
        read -p "Find "$old_vim" already exists,backup "$old_vim" to "$backup_vim"? [Y/n] " ch
        if [[ $ch == "N" ]] || [[ $ch == "n" ]]; then
            echo "No backup file, continue installation."
        else
            cp -R $old_vim $backup_vim
        fi
    fi
    rm -rf old_vim
}

# 判断是否是macos10.15版本
function is_macos1015() {
    product_version=$(sw_vers | grep ProductVersion)
    if [[ $product_version =~ "10.15" ]]; then
        echo 1
    else
        echo 0
    fi
}

# 安装mac平台必备软件
function install_prepare_software_on_mac() {
    xcode-select --install
    brew install vim
    macos1015=$(is_macos1015)
    if [ $macos1015 == 1 ]; then
        open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.15.pkg
    fi
}

# 安装debian必备软件
function install_prepare_software_on_debian() {
    sudo apt-get update
    sudo apt-get install -y git curl vim python
}

# 下载文件
function linux_download_file() {
    git clone https://github.com/fslyfeng/vimrc.git \
        ~/.vim
    cp ~/.vim/.vimrc ~/.vim/vimrc
}
# 安装vim插件
function install_vim_plugin() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    vim -c "PlugInstall" -c "q" -c "q"
}

# 在mac平台安装vim
function install_vim_on_mac() {
    backup_vim_dir
    install_prepare_software_on_mac
    install_vim_plugin
}

# 在debian上安装vim
function install_vim_on_debian() {
    backup_vim_dir
    install_prepare_software_on_debian
    linux_download_file
    install_vim_plugin
}

# 在linux平上台安装vim
function install_vim_on_linux() {
    distro=$(get_linux_distro)
    echo "Linux distro: "${distro}

    if [ ${distro} == "Debian" ]; then
        install_vim_on_debian
    else
        echo "Not support linux distro: "${distro}
    fi
}

# 获取当前时间戳
function get_now_timestamp() {
    cur_sec_and_ns=$(date '+%s-%N')
    echo ${cur_sec_and_ns%-*}
}

# main函数
function main() {
    begin=$(get_now_timestamp)
    type=$(get_platform_type)
    echo "Platform type: "${type}

    if [ ${type} == "Darwin" ]; then
        install_vim_on_mac
    elif [ ${type} == "Linux" ]; then
        install_vim_on_linux
    else
        echo "Not support platform type: "${type}
    fi

    end=$(get_now_timestamp)
    second=$(expr ${end} - ${begin})
    echo "It takes "${second}" second."
    echo "Done!"
}

# 调用main函数
main
