/usr/bin/openqa-cli api --o3 -X post isos?async=1 \
 ARCH=x86_64 \
 ASSET_256=openSUSE-Staging:E-MicroOS-DVD-x86_64-Build1230.2-Media.iso.sha256 \
 BUILD=20260723-my-build \
 CHECKSUM_ISO=$(cut -b-64 /var/lib/openqa/factory/other/openSUSE-Staging:E-MicroOS-DVD-x86_64-Build1230.2-Media.iso.sha256 | grep -E '[0-9a-f]{5,40}' | head -n1) \
 DISTRI=microos \
 FLAVOR=DVD \
 FULLURL=1 \
 INST_INSTALL_URL=https://openqa.opensuse.org/assets/repo/openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 ISO=openSUSE-Staging:E-MicroOS-DVD-x86_64-Build1230.2-Media.iso \
 MIRROR_HTTP=http://openqa.opensuse.org/assets/repo/openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 MIRROR_HTTPS=https://openqa.opensuse.org/assets/repo/openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 MIRROR_PREFIX=http://openqa.opensuse.org/assets/repo \
 REPO_0=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 REPO_1=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723-Debug \
 REPO_2=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723-Source \
 REPO_3=openSUSE-Tumbleweed-non-oss-x86_64-Snapshot20260723 \
 REPO_NON_OSS=openSUSE-Tumbleweed-non-oss-x86_64-Snapshot20260723 \
 REPO_OSS=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 REPO_OSS_DEBUG=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723-Debug \
 REPO_OSS_DEBUG_PACKAGES='java*,kernel-default-debug*,kernel-default-base-debug*,mraa-debug*,wicked-debug*' \
 REPO_OSS_SOURCE=openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723-Source \
 REPO_OSS_SOURCE_PACKAGES='coreutils*,yast2-network*,yast2-http-server*' \
 SUSEMIRROR=http://openqa.opensuse.org/assets/repo/openSUSE-Tumbleweed-oss-x86_64-Snapshot20260723 \
 VERSION=Tumbleweed


