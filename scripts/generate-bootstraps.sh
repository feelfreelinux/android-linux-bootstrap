#!/bin/bash
echo "Creating bootstrap for all archs"
SCRIPTS_PATH=$PWD
echo "Building proot..."
cd ../external/proot/

./build.sh

echo "Building minitar..."
cd ../minitar
./build.sh

cd $SCRIPTS_PATH
mkdir -p build
cd build
rm -rf *
cp ../ioctlHook.c .
../build-ioctl-hook.sh

cp -r ../../external/proot/build/* .

build_bootstrap () {
	echo "Packing bootstrap for arch $1"
	
	case $1 in
	aarch64)
		PROOT_ARCH="aarch64"
		ANDROID_ARCH="arm64-v8a"
		MUSL_ARCH="aarch64-linux-musl"
		;;
	armhf)
		PROOT_ARCH="armv7a"
		ANDROID_ARCH="armeabi-v7a"
		MUSL_ARCH="arm-linux-musleabihf"
		;;
	x86_64)
		PROOT_ARCH="x86_64"
		ANDROID_ARCH="x86_64"
		MUSL_ARCH="x86_64-linux-musl"
		;;
	x86)
		PROOT_ARCH="i686"
		ANDROID_ARCH="x86"
		MUSL_ARCH="i686-linux-musl"
		;;
	*)
		echo "Invalid arch"
		;;
	esac
	cd root-$PROOT_ARCH
	cp ../../../external/minitar/build/libs/$ANDROID_ARCH/minitar root/bin/minitar

	# separate binaries for platforms < android 5 not supporting 64bit
	if [[ "$1" == "armhf" || "$1" == "i386" ]]; then
		cp -r ../root-${PROOT_ARCH}-pre5/root root-pre5
		cp root/bin/minitar root-pre5/bin/minitar
	fi


	curl -o rootfs.tar.xz -L "http://dl-cdn.alpinelinux.org/alpine/v3.14/releases/$1/alpine-minirootfs-3.14.0-$1.tar.gz  "
	cp ../../run-bootstrap.sh .
	cp ../../install-bootstrap.sh .
	cp ../../add-user.sh .
	cp ../build-ioctl/ioctlHook-${MUSL_ARCH}.so ioctlHook.so
	cp ../../fake_proc_stat .
	zip -r bootstrap-$PROOT_ARCH.zip root ioctlHook.so root-pre5 fake_proc_stat rootfs.tar.xz run-bootstrap.sh install-bootstrap.sh add-user.sh
	mv bootstrap-$PROOT_ARCH.zip ../
	echo "Packed bootstrap $1"
	cd ..
}

build_bootstrap aarch64
build_bootstrap armhf
build_bootstrap x86_64
build_bootstrap x86
