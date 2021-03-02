#! /bin/bash -x


my_check_error='[[ $? != 0 ]] && return -1'

mypwd=/root/

function install_depends(){
	echo -e "+ $FUNCNAME"

	dpkg -l | grep gcc-8
	if [[ $? != 0 ]] ; then
		add-apt-repository ppa:ubuntu-toolchain-r/test				;eval $my_check_error
		apt update								;eval $my_check_error
		apt -y upgrade								;eval $my_check_error
		apt -y install build-essential gcc-8 g++-8 pkg-config			;eval $my_check_error
		apt -y install wget git protobuf-compiler libprotobuf-dev libssl-dev	;eval $my_check_error

		update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100	;eval $my_check_error
		update-alternatives --config gcc					;eval $my_check_error
		update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100	;eval $my_check_error
		update-alternatives --config g++					;eval $my_check_error		
	fi
}

function install_cmake() {
	echo -e "+ $FUNCNAME"

	cmake --version | grep 3.13.3
	if [ $? != 0 ]; then
		if [ ! -e cmake-3.13.3-Linux-x86_64.sh ] ; then
			wget https://github.com/Kitware/CMake/releases/download/v3.13.3/cmake-3.13.3-Linux-x86_64.sh    ;eval $my_check_error
		fi
	fi

	sh cmake-3.13.3-Linux-x86_64.sh --prefix=/usr/local --exclude-subdir                			;eval $my_check_error
}

function install_boost() {
	echo -e "+ $FUNCNAME"

	cd $mypwd

	if [ ! -d "boost_1_71_0" ]; then
		if [ ! -e boost_1_71_0.tar.gz ] ; then
			wget https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz  ;eval $my_check_error
		fi
	fi

	tar xvzf boost_1_71_0.tar.gz                                                    ;eval $my_check_error
	cd boost_1_71_0
	./bootstrap.sh                                                                  ;eval $my_check_error
	./b2 headers                                                                  	;eval $my_check_error
	./b2 -j 12                                                                      ;eval $my_check_error
}

function build_rippled() {
	echo -e "+ $FUNCNAME"

	cd $mypwd

	if [ ! -d "rippled" ]; then
		git clone https://github.com/ripple/rippled     ;eval $my_check_error
	fi

	cd rippled
	mkdir -p build      ;eval $my_check_error
	cd build
	export BOOST_ROOT=$mypwd/boost_1_71_0
	cmake ..            ;eval $my_check_error
	cmake --build .     ;eval $my_check_error
	cd ../..
}


function build_vkey() {
	echo -e "+ $FUNCNAME"

	cd $mypwd

	if [ ! -d "validator-keys-tool" ]; then
		git clone https://github.com/ripple/validator-keys-tool.git     ;eval $my_check_error
	fi

	cd validator-keys-tool
	git checkout master
	mkdir -p build      ;eval $my_check_error
	cd build
	export BOOST_ROOT=$mypwd/boost_1_71_0
	cmake ..            ;eval $my_check_error
	cmake --build .     ;eval $my_check_error	
}


#install_depends ;eval $my_check_error
#install_cmake   ;eval $my_check_error
#install_boost   ;eval $my_check_error

#build_rippled   ;eval $my_check_error

#build_vkey      ;eval $my_check_error






