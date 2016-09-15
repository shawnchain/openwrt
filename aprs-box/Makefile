BUILDER ?= OpenWrt-ImageBuilder-ramips-mt7620.Linux-x86_64
SDK ?= OpenWrt-SDK-ramips-mt7620_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64
BUILDER_TGZ ?= mywrt-imagebuilder-15.05.1-mt7620.tar.bz2
SDK_TGZ ?= mywrt-sdk-15.05.1-mt7620.tar.bz2

OPKG_PACKAGES := kmod-ledtrig-gpio kmod-lib-zlib \
	kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8 \
	kmod-usb-serial \
	librt libubus-lua libuci-lua lua \
	luci luci-base luci-app-firewall luci-base luci-i18n-base-en luci-i18n-base-zh-cn \
	luci-lib-nixio luci-mod-admin-full luci-proto-ipv6 luci-proto-ppp luci-theme-bootstrap \
	uclibcxx rpcd uhttpd uhttpd-mod-ubus zlib openssl-util
OPKG_PACKAGES_EXTRA := kmod-lib-textsearch
PREPARED_TARGETS = .check_ib .patched

# for aprs/aprx
OPKG_APRS_PACKAGES := kmod-usb-serial-ch341 kmod-usb-serial-cp210x kmod-usb-serial-ftdi kmod-usb-serial-pl2303 \
	screen terminfo
OPKG_APRS_PACKAGES += libpthread aprx 
PREPARED_TARGETS += .check_sdk .aprx 

define BeforeBuildImage_mt7620
	mkdir -p $(BUILDER)/dl
	cp -f files/mt7620/repo-base.conf $(BUILDER)/repositories.conf
	@[ -n "$(SDK)" -a -f "$(SDK)"/bin/ramips/packages/Packages ] && \
		echo "src aprs file:$(shell cd $(SDK)/bin/ramips/packages; pwd)" >> $(BUILDER)/repositories.conf || :	
	mkdir -p $(BUILDER)/target/linux/ramips/base-files/etc
	cp -f files/mt7620/opkg.conf $(BUILDER)/target/linux/ramips/base-files/etc/opkg.conf
	[ -d files ] && cp -fr files/common/* $(BUILDER)/target/linux/ramips/base-files
endef

define CopyFiles_brcm47xx
	mkdir -p $(BUILDER)/dl
	cp -f files/brcm47xx/repo-base.conf $(BUILDER)/repositories.conf
	@[ -n "$(SDK)" -a -f "$(SDK)"/bin/brcm47xx/packages/Packages ] && \
		echo "src aprs file:$(shell cd $(SDK)/bin/brcm47xx/packages; pwd)" >> $(BUILDER)/repositories.conf || :	
	mkdir -p $(BUILDER)/target/linux/brcm47xx/base-files/etc
	cp -f files/brcm47xx/opkg.conf $(BUILDER)/target/linux/brcm47xx/base-files/etc/opkg.conf
	[ -d files ] && cp -fr files/common/* $(BUILDER)/target/linux/brcm47xx/base-files
endef

define CopyFiles_rt305x
	mkdir -p $(BUILDER)/dl
	cp -f files/rt305x/repo-base.conf $(BUILDER)/repositories.conf
	@[ -n "$(SDK)" -a -f "$(SDK)"/bin/ramips/packages/Packages ] && \
		echo "src aprs file:$(shell cd $(SDK)/bin/ramips/packages; pwd)" >> $(BUILDER)/repositories.conf || :	
	mkdir -p $(BUILDER)/target/linux/ramips/base-files/etc
	cp -f files/rt305x/opkg.conf $(BUILDER)/target/linux/ramips/base-files/etc/opkg.conf
	[ -d files ] && cp -fr files/common/* $(BUILDER)/target/linux/ramips/base-files
endef

brcm47xx: $(PREPARED_TARGETS)
	$(call CopyFiles_brcm47xx)
	make -C $(BUILDER) image PROFILE=Default \
		FILES="$(shell cd $(BUILDER); pwd)/target/linux/brcm47xx/base-files" \
		PACKAGES="$(OPKG_PACKAGES) $(OPKG_APRS_PACKAGES) $(OPKG_PACKAGES_EXTRA) kmod-b43legacy"

rt305x:$(PREPARED_TARGETS)
	$(call CopyFiles_rt305x)
	make -C $(BUILDER) image PROFILE=Default \
		FILES="$(shell cd $(BUILDER); pwd)/target/linux/ramips/base-files" \
		PACKAGES="$(OPKG_PACKAGES) $(OPKG_APRS_PACKAGES) $(OPKG_PACKAGES_EXTRA) kmod-rt2800-soc"

mt7620: $(PREPARED_TARGETS)
	$(call BeforeBuildImage_mt7620)
	make -C $(BUILDER) image PROFILE=Default \
		FILES="$(shell cd $(BUILDER); pwd)/target/linux/ramips/base-files" \
		PACKAGES="$(OPKG_PACKAGES) $(OPKG_APRS_PACKAGES) $(OPKG_PACKAGES_EXTRA) kmod-mt7620 kmod-mt76x2e"

.patched:
	@cd $(BUILDER); cat ../patches/*.patch | patch -p2
	touch .patched

.aprx:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d aprs-feeds ] && { cd aprs-feeds; git pull; } || git clone https://github.com/shawnchain/openwrt-feeds.git aprs-feeds
	make package/aprx/compile V=s -C "$(SDK)"
	cd "$(SDK)/bin/ramips/packages" && ../../../scripts/ipkg-make-index.sh . > Packages && gzip -9c Packages > Packages.gz

.gfw:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d network-feeds ] && { cd network-feeds; git pull; } || git clone https://github.com/rssnsj/network-feeds.git
	make package/ipset-lists/compile V=s -C "$(SDK)"
	make package/shadowsocks-libev/compile V=s -C "$(SDK)"
	make package/shadowsocks-tools/compile V=s -C "$(SDK)"
	make package/minivtun-tools/compile V=s -C "$(SDK)"
	make package/file-storage/compile V=s -C "$(SDK)"
	make package/dnspod-utils/compile V=s -C "$(SDK)"
	make package/proto-bridge/compile V=s -C "$(SDK)"
	cd "$(SDK)/bin/ramips/packages" && ../../../scripts/ipkg-make-index.sh . > Packages && gzip -9c Packages > Packages.gz

.check_ib:
	@if ! [ -n "$(BUILDER)" -a -d "$(BUILDER)" ]; then \
		echo "Please specify a valid ImageBuilder directory by adding \"BUILDER=...\"."; \
		echo "Type \"make help\" for more details."; \
		exit 1; \
	fi
.check_sdk:
	@if ! [ -n "$(SDK)" -a -d "$(SDK)/package" ]; then \
		echo "Please specify a valid OpenWrt SDK directory by adding \"SDK=...\"."; \
		echo "Type \"make help\" for more details."; \
		exit 1; \
	fi

# Try extracting ImageBuilder & SDK to current directory
extract:
	@[ -d "$(BUILDER)" ] || tar jxvf /opt/openwrt/dl/$(BUILDER_TGZ)
	@[ -d "$(SDK)" ] || tar jxvf /opt/openwrt/dl/$(SDK_TGZ)

help:
	@echo "Usage:"
	@echo "  make mt7620		build OpenWrt firmware with APRS software installed for Lenovo Y1/Y1S (MT7620 board)"
	@echo "  make rt305x		build OpenWrt firmware with APRS software installed for Huawei RG255D(RT305x board)"
	@echo "  make brcm47xx		build OpenWrt firmware with APRS software installed for H618B(BRCM47XX board)"
	
	@echo "Options:"
	@echo "  none"

clean: .check_ib
	make clean -C $(BUILDER)
	@if [ -e .patched ]; then \
		cd $(BUILDER); cat ../patches/*.patch | patch -R -p2; cd ..; \
		rm -vf .patched; \
	fi
	[ -n "$(SDK)" -a -d "$(SDK)"/bin/ramips ] && rm -rf "$(SDK)"/bin/ramips/* || :
	[ -n "$(SDK)" -a -d "$(SDK)"/bin/brcm47xx ] && rm -rf "$(SDK)"/bin/brcm47xx/* || :
