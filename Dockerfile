FROM centos

MAINTAINER Haifeng Zhang "zhanghf@zailingtech.com"

# 设置go相关环境变量
ENV GOLANG_VERSION 1.8.3
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
# 设置locale，进入终端可以输入中文
ENV LANG en_US.utf8
# 设置容器时区
ENV TZ "Asia/Shanghai"

RUN yum update -y \
# 安装开发工具包和man
    && yum install -y epel-release.noarch \
    && yum -y groupinstall "Development Tools" \
    && yum -y install gitflow \
    && yum -y install git-svn \
    && yum -y install man \
# 安装zsh和oh-my-zsh
    && yum install -y zsh \
    && yum install -y which \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && chsh -s /bin/zsh \
# 安装vim需要的工具包
    && yum install -y cscope \
    && yum install -y python \
    && yum install -y python-devel \
    && yum install -y ruby \
    && yum install -y ruby-devel \
    && yum install -y lua \
    && yum install -y lua-devel \
    && yum install -y perl \
    && yum install -y tcl \
    && yum install -y tcl-devel \
    && yum install -y ncurses \
    && yum install -y ncurses-devel \
    && yum install -y the_silver_searcher \
    && yum install -y tmux \
    && yum install -y python34 \
    && yum install -y python34-devel \
# 安装Cmake
    && yum install -y wget \
    && cd /usr/local/src \
    && wget -O cmake.tgz https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz \
    && tar -C /usr/local/src -xzf cmake.tgz \
    && cd cmake-3.9.0 \
    && ./bootstrap \
    && gmake -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf cmake* \
# 安装Clang
    && wget http://releases.llvm.org/4.0.1/llvm-4.0.1.src.tar.xz \
    && wget http://releases.llvm.org/4.0.1/cfe-4.0.1.src.tar.xz \
    && wget http://releases.llvm.org/4.0.1/compiler-rt-4.0.1.src.tar.xz \
    && wget http://releases.llvm.org/4.0.1/clang-tools-extra-4.0.1.src.tar.xz \
    && tar xf llvm-4.0.1.src.tar.xz \
    && mv llvm-4.0.1.src llvm \
    && cd llvm/tools \
    && tar xf ../../cfe-4.0.1.src.tar.xz \
    && mv cfe-4.0.1.src clang \
    && cd clang/tools \
    && tar xf ../../../../clang-tools-extra-4.0.1.src.tar.xz \
    && mv clang-tools-extra-4.0.1.src extra \
    && cd ../../../projects \
    && tar xf ../../compiler-rt-4.0.1.src.tar.xz \
    && mv compiler-rt-4.0.1.src compiler-rt \
    && cd ../.. \
    && mkdir llvm-build \
    && cd llvm-build \
    && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DLLVM_OPTIMIZED_TABLEGEN=1 ../llvm \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && rm -rf *
# 安装go
    && goRelArch='linux-amd64' \
    && url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz" \
    && wget -O go.tgz "$url" \
    && tar -C /usr/local -xzf go.tgz \
    && rm go.tgz \
    && go version \
# 安装vim
    && cd /usr/local/src \
    && git clone https://github.com/vim/vim.git \
    && cd vim \
    && ./configure --prefix=/usr \
        --with-features=huge \
        --enable-multibyte \
        --enable-cscope=yes \
        --enable-luainterp=yes \
        --enable-rubyinterp=yes \
        --enable-pythoninterp=yes \
        --with-python-config-dir=/usr/lib64/python2.7/config/ \
        --with-python3-config-dir=/usr/lib64/python3.4/config-3.4m \
        --enable-python3interp=yes \
        --enable-tclinterp=yes \
        --enable-gui=auto \
    && make \
    && make install \
    && cd .. \
    && rm -rf vim/ \
# 安装powerline字体
    && git clone https://github.com/powerline/fonts.git \
    && cd fonts \
    && ./install.sh \
    && cd .. \
    && rm -rf fonts/ \
# 安装vim初次启动需要的插件
    && curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
    && git clone https://github.com/morhetz/gruvbox.git ~/.vim/bundle/gruvbox \
    && git clone https://github.com/Shougo/unite.vim.git ~/.vim/bundle/unite.vim \
    && git clone https://github.com/shougo/vimfiler.vim.git ~/.vim/bundle/vimfiler.vim \
# 下载安装我自己的工作环境配置
    && git clone https://github.com/wuzangsama/vim_ide.git \
    && cd ./vim_ide \
    && cp -f .vimrc ~/ \
    && cp -f .zshrc ~/ \
    && cp -f .tmux.conf ~/ \
# vim其他插件安装
    && export CC=/usr/local/bin/clang \
    && export CXX=/usr/local/bin/clang++ \
    && vim -c "PlugInstall" -c "q" -c "q" \
    && cd ~/.vim/bundle/ultisnips/ \
    && mkdir mysnippets \
    && cp -rf /usr/local/src/vim_ide/mysnippets/* ~/.vim/bundle/ultisnips/mysnippets \
    && rm -rf /usr/local/src/vim_ide/ \
# 清理
    && yum clean all

#work dir
WORKDIR /work

