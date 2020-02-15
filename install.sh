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
# 下载文件
function linux_download_file() {
    git clone https://github.com/fslyfeng/vimrc.git \
        ~/vimrc
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

#备份原有的.vimrc文件
function backup_vimrc_file() {
    old_vimrc=$HOME"/.vimrc"
    is_exist=$(is_exist_file $old_vimrc)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_vimrc=$old_vimrc"_bak_"$time
        read -p "Find "$old_vimrc" already exists,backup "$old_vimrc" to "$backup_vimrc"? [Y/N] " ch
        if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
            cp $old_vimrc $backup_vimrc
        fi
    fi
}

#备份原有的.vimrc.custom.plugins文件
function backup_vimrc_custom_plugins_file() {
    old_vimrc_plugins=$HOME"/.vimrc.custom.plugins"
    is_exist=$(is_exist_file $old_vimrc_plugins)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_vimrc_plugins=$old_vimrc_plugins"_bak_"$time
        read -p "Find "$old_vimrc_plugins" already exists,backup "$old_vimrc_plugins" to "$backup_vimrc_plugins"? [Y/N] " ch
        if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
            cp $old_vimrc_plugins $backup_vimrc_plugins
        fi
    fi
}

#备份原有的.vimrc.custom.config文件
function backup_vimrc_custom_config_file() {
    old_vimrc_config=$HOME"/.vimrc.custom.config"
    is_exist=$(is_exist_file $old_vimrc_config)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_vimrc_config=$old_vimrc_config"_bak_"$time
        read -p "Find "$old_vimrc_config" already exists,backup "$old_vimrc_config" to "$backup_vimrc_config"? [Y/N] " ch
        if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
            cp $old_vimrc_config $backup_vimrc_config
        fi
    fi
}

#备份原有的.vim目录
function backup_vim_dir() {
    old_vim=$HOME"/.vim"
    is_exist=$(is_exist_dir $old_vim)
    if [ $is_exist == 1 ]; then
        time=$(get_datetime)
        backup_vim=$old_vim"_bak_"$time
        read -p "Find "$old_vim" already exists,backup "$old_vim" to "$backup_vim"? [Y/N] " ch
        if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
            cp -R $old_vim $backup_vim
        fi
    fi
}

# 备份原有的.vimrc和.vim
function backup_vimrc_and_vim() {
    backup_vimrc_file
    backup_vimrc_custom_plugins_file
    backup_vimrc_custom_config_file
    backup_vim_dir
}

# 判断是否是macos10.14版本
function is_macos1014() {
    product_version=$(sw_vers | grep ProductVersion)
    if [[ $product_version =~ "10.14" ]]; then
        echo 1
    else
        echo 0
    fi
}

# 在debian上源代码安装vim
function compile_vim_on_debian() {
    sudo apt-get remove -y vim vim-runtime gvim
    sudo apt-get remove -y vim-tiny vim-common vim-gui-common vim-nox
    sudo rm -rf /usr/bin/vim*
    sudo rm -rf /usr/local/bin/vim*
    sudo rm -rf /usr/share/vim/vim*
    sudo rm -rf /usr/local/share/vim/vim*

    sudo apt-get install -y libncurses5-dev libncurses5 libgtk2.0-dev libatk1.0-dev libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev python3-dev ruby-dev lua5.1 lua5.1-dev

    git clone https://gitee.com/chxuan/vim81.git ~/vim81
    cd ~/vim81
    ./configure --with-features=huge \
        --enable-multibyte \
        --enable-rubyinterp \
        --enable-pythoninterp \
        --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
        --enable-perlinterp \
        --enable-luainterp \
        --enable-gui=gtk2 \
        --enable-cscope \
        --prefix=/usr
    make
    sudo make install
    cd -
}

# 安装mac平台必备软件
function install_prepare_software_on_mac() {
    xcode-select --install

    brew install vim

    macos1015=$(is_macos1014)
    if [ $macos1014 == 1 ]; then
        open /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.15.pkg
    fi
}

# 安装debian必备软件
function install_prepare_software_on_debian() {
    sudo apt-get update
    sudo apt-get install -y cmake exuberant-ctags build-essential python python-dev python3-dev libfile-next-perl ack git curl
    compile_vim_on_debian
}

# 拷贝文件
function copy_files() {
    cd ~/vimrc
    mkdir ~/.vim
    cp -R ${PWD}/colors ~/.vim

    rm -rf ~/.vim/.vimrc
    cp ${PWD}/.vimrc ~/.vim/vimrc

    rm -rf ~/.vimrc.custom.plugins
    cp ${PWD}/.vimrc.custom.plugins ~/.vim

    rm -rf ~/.vimrc.custom.config
    cp ${PWD}/.vimrc.custom.config ~/.vim

    cp ${PWD}/help.md ~/.vim

    rm -rf ~/.vim/autoload
    cp ${PWD}/autoload ~/.vim
}

# 安装vim插件
function install_vim_plugin() {
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    git clone https://github.com/lifepillar/vim-solarized8.git \
        ~/.vim/pack/themes/opt/solarized8

    vim -c "PlugInstall" -c "q" -c "q"
}

# 在mac平台安装vimplus
function install_vimplus_on_mac() {
    backup_vimrc_and_vim
    install_prepare_software_on_mac
    copy_files
    install_vim_plugin
}

# 开始安装vimplus
function begin_install_vimplus() {
    copy_files
    install_vim_plugin
    rm_file
}

# 在debian上安装vimplus
function install_vimplus_on_debian() {
    backup_vimrc_and_vim
    install_prepare_software_on_debian
    linux_download_file
    begin_install_vimplus
}

# 在linux平上台安装vimplus
function install_vimplus_on_linux() {
    distro=$(get_linux_distro)
    echo "Linux distro: "${distro}

    if [ ${distro} == "Debian" ]; then
        install_vimplus_on_debian
    else
        echo "Not support linux distro: "${distro}
    fi
}
# 删除文件
function rm_file() {
    cd ~
    rm -rf ~/vim81
    rm -rf ~/vimrc
}
# 获取当前时间戳
function get_now_timestamp() {
    cur_sec_and_ns=$(date '+%s-%N')
    echo ${cur_sec_and_ns%-*}
}

# main函数
function main() {
    begin=$(get_now_timestamp)
    :
    type=$(get_platform_type)
    echo "Platform type: "${type}

    if [ ${type} == "Darwin" ]; then
        install_vimplus_on_mac
    elif [ ${type} == "Linux" ]; then
        install_vimplus_on_linux
    else
        echo "Not support platform type: "${type}
    fi

    clear
    end=$(get_now_timestamp)
    second=$(expr ${end} - ${begin})
    min=$(expr ${second} / 60)
    echo "It takes "${min}" minutes."
    echo "Done!"
}

# 调用main函数
main
