BUILDER := builder
SDK := sdk
X86_BUILDER_TGZ := OpenWrt-ImageBuilder-15.05.1-x86-generic.Linux-x86_64.tar.bz2
X86_SDK_TGZ := OpenWrt-SDK-15.05.1-x86-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
MT7620_BUILDER_TGZ := OpenWrt-ImageBuilder-ramips-mt7620.Linux-x86_64.tar.bz2
MT7620_SDK_TGZ := OpenWrt-SDK-ramips-mt7620_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
MT7688_BUILDER_TGZ := OpenWrt-ImageBuilder-15.05.1-ramips-mt7688.Linux-x86_64.tar.bz2
MT7688_SDK_TGZ := OpenWrt-SDK-15.05.1-ramips-mt7688_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
BRCM47XX_BUILDER_TGZ := OpenWrt-ImageBuilder-15.05.1-brcm47xx-legacy.Linux-x86_64.tar.bz2
BRCM47XX_SDK_TGZ := OpenWrt-SDK-15.05.1-brcm47xx-legacy_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
BRCM63XX_BUILDER_TGZ := OpenWrt-ImageBuilder-15.05.1-brcm63xx-generic.Linux-x86_64.tar.bz2
BRCM63XX_SDK_TGZ := OpenWrt-SDK-15.05.1-brcm63xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2
AR71XX_BUILDER_TGZ := OpenWrt-ImageBuilder-15.05.1-ar71xx-generic.Linux-x86_64.tar.bz2
AR71XX_SDK_TGZ := OpenWrt-SDK-15.05.1-ar71xx-generic_gcc-4.8-linaro_uClibc-0.9.33.2.Linux-x86_64.tar.bz2

# Base Packages
OPKG_PACKAGES := kmod-ledtrig-gpio kmod-lib-zlib \
	kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8 \
	librt libubus-lua libuci-lua lua \
	luci luci-base luci-app-firewall luci-i18n-base-en luci-i18n-base-zh-cn \
	luci-lib-nixio luci-mod-admin-full luci-proto-ipv6 luci-proto-ppp luci-theme-bootstrap \
	luci-app-commands luci-i18n-commands-zh-cn \
	rpcd uhttpd uhttpd-mod-ubus zlib openssl-util
OPKG_PACKAGES_EXTRA := kmod-lib-textsearch uclibcxx libpthread libstdcpp kmod-usb-serial
# for usb-serial packages
OPKG_PACKAGES_EXTRA += kmod-usb-serial-pl2303 kmod-usb-serial-cp210x kmod-usb-serial-ftdi kmod-usb-serial-ch341
OPKG_PACKAGES_EXTRA += screen terminfo
PREPARED_TARGETS = .check_ib .patched .check_sdk

APRS := 1
MMDVM := 1

# APRS packages
ifeq ($(APRS),1)
	OPKG_PACKAGES_EXTRA += tinyaprs aprx
	PREPARED_TARGETS += .aprs 
endif

# MMDVM packages
ifeq ($(MMDVM),1)
	OPKG_PACKAGES_EXTRA += mmdvm-host mmdvm-cal ysf-clients p25-clients kmod-usb-ohci kmod-usb-acm shadow-useradd
	PREPARED_TARGETS += .mmdvm
endif

# NETWORK packages
ifeq ($(NETWORK),1)
        OPKG_PACKAGES_EXTRA += ipset-lists minivtun \
			shadowsocks-libev shadowsocks-tools -dnsmasq dnsmasq-full \
			kmod-proto-bridge kmod-yavlan \
			net-tools-slattach kmod-slip \
			usbutils
        PREPARED_TARGETS += .network
endif

# IoT packages
ifeq ($(IOT),1)
        OPKG_PACKAGES_EXTRA += c-ares luci-app-mosquitto lua-mosquitto 
        PREPARED_TARGETS += .iot
endif

# NAS packages
ifeq ($(NAS),1)
        OPKG_PACKAGES_EXTRA += file-storage
        PREPARED_TARGETS += .nas
endif

define UpdatePackageIndex
	[ -d $(SDK)/bin/$1/packages ] && cd "$(SDK)/bin/$1/packages" && ../../../scripts/ipkg-make-index.sh . > Packages && gzip -9c Packages > Packages.gz
endef

# $(1): chip arch type
# $(2): board type
# $(3): image profile name
# $(4): special package names to include
define BuildImage
	$(call UpdatePackageIndex,$(1))
	mkdir -p $(BUILDER)/dl
	cp -f files/$(2)/repo-base.conf $(BUILDER)/repositories.conf
	@[ -n "$(SDK)" -a -f "$(SDK)"/bin/$(1)/packages/Packages ] && \
		echo "src aprs file:$(shell cd $(SDK)/bin/$(1)/packages; pwd)" >> $(BUILDER)/repositories.conf || :	
	mkdir -p $(BUILDER)/target/linux/$(1)/base-files/etc
	cp -f files/$(2)/opkg.conf $(BUILDER)/target/linux/$(1)/base-files/etc/opkg.conf
	[ -d files/common ] && cp -fr files/common/* $(BUILDER)/target/linux/$(1)/base-files
	[ -d files/$(2) ] && cp -fr files/$(2)/* $(BUILDER)/target/linux/$(1)/base-files
	@echo "----------------------------------------------------------------------------------"
	make -C $(BUILDER) image PROFILE=$(3) \
		FILES="$(shell cd $(BUILDER); pwd)/target/linux/$1/base-files" \
		PACKAGES="$(OPKG_PACKAGES) $(OPKG_PACKAGES_EXTRA) $(4)"
	@echo "----------------------------------------------------------------------------------"
endef

brcm63xx: $(PREPARED_TARGETS)
	$(call BuildImage,brcm63xx,brcm63xx,RG100A,kmod-b43)

brcm47xx: $(PREPARED_TARGETS)
	$(call BuildImage,brcm47xx,brcm47xx,Broadcom-b43,kmod-b43)

rt305x:$(PREPARED_TARGETS)
	$(call BuildImage,ramips,rt305x,Default,kmod-rt2800-soc)

mt7620: $(PREPARED_TARGETS)
	$(call BuildImage,ramips,mt7620,Default,kmod-mt7620 kmod-mt76x2e)

mt7688: $(PREPARED_TARGETS)
	$(call BuildImage,ramips,mt7688,Default,kmod-mt76)

ar71xx: $(PREPARED_TARGETS)
	$(call BuildImage,ar71xx,ar71xx,Default,)

x86: $(PREPARED_TARGETS)
	$(call BuildImage,x86,x86,Default,)


.patched:
	#@cd $(BUILDER); cat ../patches/*.patch | patch -p2
	touch .patched

.aprs:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d aprs-feeds ] && { cd aprs-feeds; git pull; } || git clone https://github.com/shawnchain/openwrt-feeds.git aprs-feeds
	make package/aprx/compile V=s -C "$(SDK)"
	make package/tinyaprs/compile V=s -C "$(SDK)"

.mmdvm:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d aprs-feeds ] && { cd aprs-feeds; git pull; } || git clone https://github.com/shawnchain/openwrt-feeds.git aprs-feeds
	make package/mmdvm-host/compile V=s -C "$(SDK)"
	make package/mmdvm-cal/compile V=s -C "$(SDK)"
	make package/ysf-clients/compile V=s -C "$(SDK)"
	make package/p25-clients/compile V=s -C "$(SDK)"

.iot:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d iot-feeds ] && { cd iot-feeds; git pull; } || git clone https://github.com/remakeelectric/owrt_pub_feeds iot-feeds
	make package/lua-mosquitto/compile V=s -C "$(SDK)"
	make package/luci-app-mosquitto/compile V=s -C "$(SDK)"

.network:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d network-feeds ] && { cd network-feeds; git pull; } || git clone https://github.com/rssnsj/network-feeds.git
	@cd $(SDK)/package; [ -d aprs-feeds ] && { cd aprs-feeds; git pull; } || git clone https://github.com/shawnchain/openwrt-feeds.git aprs-feeds
	# update the network feed list
	#make -C $(SDK)/package/network-feeds/ipset-lists/tools
	# compile packages
	make package/ipset-lists/compile V=s -C "$(SDK)"
	make package/shadowsocks-libev/compile V=s -C "$(SDK)"
	make package/shadowsocks-tools/compile V=s -C "$(SDK)"
	make package/minivtun-tools/compile V=s -C "$(SDK)"
	make package/file-storage/compile V=s -C "$(SDK)"
	make package/dnspod-utils/compile V=s -C "$(SDK)"
	make package/proto-bridge/compile V=s -C "$(SDK)"
	make package/net-tools/compile V=s -C "$(SDK)"

.nas:

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
define ExtractImageBuilder
	@[ -d "$(subst .tar.bz2,,$(1))" ] || echo extracting $(1) && tar jxf /opt/openwrt/dl/$(1)
	@[ -d "$(subst .tar.bz2,,$(2))" ] || echo extracting $(2) && tar jxf /opt/openwrt/dl/$(2)
	rm -f builder sdk
	ln -s $(subst .tar.bz2,,$(1)) builder
	ln -s $(subst .tar.bz2,,$(2)) sdk
endef

define ExtractCustomizedImageBuilder
	@[ -d "$(subst .tar.bz2,,$(1))" ] || echo extracting customize/$(1) && tar jxf /opt/openwrt/dl/customize/$(1)
	@[ -d "$(subst .tar.bz2,,$(2))" ] || echo extracting customize/$(2) && tar jxf /opt/openwrt/dl/customize/$(2)
	rm -f builder sdk
	ln -s $(subst .tar.bz2,,$(1)) builder
	ln -s $(subst .tar.bz2,,$(2)) sdk
endef

extract_ar71xx:
	$(call ExtractImageBuilder,$(AR71XX_BUILDER_TGZ),$(AR71XX_SDK_TGZ))

extract_x86:
	$(call ExtractImageBuilder,$(X86_BUILDER_TGZ),$(X86_SDK_TGZ))

extract_mt7620:
	$(call ExtractCustomizedImageBuilder,$(MT7620_BUILDER_TGZ),$(MT7620_SDK_TGZ))
#	$(call ExtractImageBuilder,$(MT7620_BUILDER_TGZ),$(MT7620_SDK_TGZ))

extract_mt7688:
	$(call ExtractImageBuilder,$(MT7688_BUILDER_TGZ),$(MT7688_SDK_TGZ))
	
extract_brcm63xx:
	$(call ExtractImageBuilder,$(BRCM63XX_BUILDER_TGZ),$(BRCM63XX_SDK_TGZ))

extract_brcm47xx:
	$(call ExtractImageBuilder,$(BRCM47XX_BUILDER_TGZ),$(BRCM47XX_SDK_TGZ))
	
help:
	@echo "Usage:"
	@echo "  make mt7620 		build OpenWrt firmware with APRS software installed for Lenovo Y1/Y1S (MT7620 board)"
	@echo "  make mt7688 		build OpenWrt firmware with APRS software installed for Widora (MT7688 board)"
	@echo "  make rt305x		build OpenWrt firmware with APRS software installed for Huawei RG255D(RT305x board)"
	@echo "  make brcm47xx		build OpenWrt firmware with APRS software installed for H618B(BRCM47XX board)"
	@echo "  make brcm63xx		build OpenWrt firmware with APRS software installed for H618C(BRCM63XX board)"
	@echo "  make ar71xx		build OpenWrt firmware with APRS software installed for AR71XX board"
	
	@echo "Options:"
	@echo "  NETWORK=1                    build and install Shadowsocks, minivtun, kmod-proto-bridge, kmod-yavlan"
	@echo "  NAS=1                 	      build and install Samba file share server"

clean: .check_ib
	make clean -C $(BUILDER)
	@if [ -e .patched ]; then \
		cd $(BUILDER); cat ../patches/*.patch | patch -R -p2; cd ..; \
		rm -vf .patched; \
	fi
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/ramips ] && rm -rf "$(SDK)"/bin/ramips/* || :
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/brcm47xx ] && rm -rf "$(SDK)"/bin/brcm47xx/* || :
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/brcm63xx ] && rm -rf "$(SDK)"/bin/brcm63xx/* || :
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/x86 ] && rm -rf "$(SDK)"/bin/x86/* || :

distclean:
	rm -fr OpenWrt-ImageBuilder-*
	rm -fr OpenWrt-SDK-*
	rm -f .patched
	rm -f sdk builder

DEPLOY_ROOT := hamclub:/opt/openwrt/build/customize/15.05.1
deploy_packages:
	@[ ! -d sdk/bin/ramips/packages ] || scp -r sdk/bin/ramips/packages/* $(DEPLOY_ROOT)/ramips/mt7620/packages/
	@[ ! -d sdk/bin/brcm63xx/packages ] || scp -r sdk/bin/brcm63xx/packages/* $(DEPLOY_ROOT)/brcm63xx/generic/packages/
	@[ ! -d sdk/bin/brcm47xx/packages ] || scp -r sdk/bin/brcm47xx/packages/* $(DEPLOY_ROOT)/brcm47xx/legacy/packages/
	@[ ! -d sdk/bin/x86/packages ] || scp -r sdk/bin/x86/packages/* $(DEPLOY_ROOT)/x86/generic/packages/

deploy:
ifeq ($(TYPE),)
	[ ! -f builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1-notty-squashfs-sysupgrade.bin ] || scp builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1-notty-squashfs-sysupgrade.bin $(DEPLOY_ROOT)/15.05.1-Lenovo-y1-aprs-squashfs.bin
	[ ! -f builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1s-squashfs-sysupgrade.bin ] || scp builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1s-squashfs-sysupgrade.bin $(DEPLOY_ROOT)/15.05.1-Lenovo-y1s-aprs-squashfs.bin
	[ ! -f builder/bin/brcm63xx/openwrt-15.05.1-brcm63xx-generic-RG100A-squashfs-cfe.bin ] || scp builder/bin/brcm63xx/openwrt-15.05.1-brcm63xx-generic-RG100A-squashfs-cfe.bin $(DEPLOY_ROOT)/15.05.1-h618c-aprs-squashfs-cfe.bin
	[ ! -f builder/bin/brcm47xx/openwrt-15.05.1-brcm47xx-legacy-squashfs.trx ] || scp builder/bin/brcm47xx/openwrt-15.05.1-brcm47xx-legacy-squashfs.trx $(DEPLOY_ROOT)/15.05.1-h618b-aprs-squashfs.trx
else
	[ ! -f builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1-notty-squashfs-sysupgrade.bin ] || scp builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1-notty-squashfs-sysupgrade.bin $(DEPLOY_ROOT)/15.05.1-Lenovo-y1-$(TYPE)-squashfs.bin
	[ ! -f builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1s-squashfs-sysupgrade.bin ] || scp builder/bin/ramips/openwrt-ramips-mt7620-Lenovo-y1s-squashfs-sysupgrade.bin $(DEPLOY_ROOT)/15.05.1-Lenovo-y1s-$(TYPE)-squashfs.bin
	[ ! -f builder/bin/brcm63xx/openwrt-15.05.1-brcm63xx-generic-RG100A-squashfs-cfe.bin ] || scp builder/bin/brcm63xx/openwrt-15.05.1-brcm63xx-generic-RG100A-squashfs-cfe.bin $(DEPLOY_ROOT)/15.05.1-h618c-$(TYPE)-squashfs-cfe.bin
	[ ! -f builder/bin/brcm47xx/openwrt-15.05.1-brcm47xx-legacy-squashfs.trx ] || scp builder/bin/brcm47xx/openwrt-15.05.1-brcm47xx-legacy-squashfs.trx $(DEPLOY_ROOT)/15.05.1-h618b-$(TYPE)-squashfs.trx
endif
