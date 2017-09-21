BUILDER := builder
SDK := sdk
BRCM47XX_BUILDER_TGZ := OpenWrt-ImageBuilder-brcm47xx_legacy-for-linux-x86_64.tar.bz2
BRCM47XX_SDK_TGZ := OpenWrt-SDK-brcm47xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
BRCM63XX_BUILDER_TGZ := OpenWrt-ImageBuilder-brcm63xx_generic-for-linux-x86_64.tar.bz2
BRCM63XX_SDK_TGZ := OpenWrt-SDK-brcm63xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
AR71XX_BUILDER_TGZ := OpenWrt-ImageBuilder-ar71xx_generic-for-linux-x86_64.tar.bz2
AR71XX_SDK_TGZ := OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2

# Base Packages
OPKG_PACKAGES := kmod-ledtrig-gpio kmod-lib-zlib \
	kmod-nls-cp437 kmod-nls-iso8859-1 kmod-nls-utf8 \
	librt libubus-lua libuci-lua lua \
	luci luci-base luci-app-firewall luci-i18n-english luci-i18n-chinese \
	luci-lib-nixio luci-mod-admin-full luci-proto-ipv6 luci-proto-ppp luci-theme-bootstrap \
	rpcd uhttpd uhttpd-mod-ubus zlib luci-app-commands 
OPKG_PACKAGES_EXTRA := kmod-lib-textsearch uclibcxx libpthread libstdcpp kmod-usb-serial
# for usb-serial packages
OPKG_PACKAGES_EXTRA += kmod-usb-serial-pl2303 kmod-usb-serial-cp210x kmod-usb-serial-ftdi kmod-usb-serial-ch341
OPKG_PACKAGES_EXTRA += screen terminfo
# wget for https:// under 14.07
OPKG_PACKAGES_EXTRA += wget ca-certificates

PREPARED_TARGETS = .check_ib .patched .check_sdk

APRS := 1
MMDVM := 1

ifeq ($(APRS),1)
	OPKG_PACKAGES_EXTRA += tinyaprs aprx
	PREPARED_TARGETS += .aprs
endif

ifeq ($(MMDVM),1)
	OPKG_PACKAGES_EXTRA += mmdvm-host ysf-clients p25-clients kmod-usb-acm shadow-useradd
	PREPARED_TARGETS += .mmdvm
endif

# for network packages as NAS or GW
ifeq ($(NETWORK),1)
	OPKG_PACKAGES_EXTRA += ipset-lists minivtun shadowsocks-libev shadowsocks-tools -dnsmasq dnsmasq-full \
		kmod-proto-bridge kmod-yavlan \
		net-tools-slattach kmod-slip \
		usbutils
	PREPARED_TARGETS += .network
endif

ifeq ($(NAS),1)
	OPKG_PACKAGES_EXTRA += file-storage
	PREPARED_TARGETS += .nas
endif

define UpdatePackageIndex
	[ -d $(SDK)/bin/$1/packages ] && cd "$(SDK)/bin/$1/packages" && ../../../scripts/ipkg-make-index.sh . > Packages && gzip -9c Packages > Packages.gz
endef

# $(1): chip arch type
# $(2): image profile name
# $(3): special package names to include
define BuildImage
	$(call UpdatePackageIndex,$(1))
	mkdir -p $(BUILDER)/dl
	cp -f files/$(1)/repo-base.conf $(BUILDER)/repositories.conf
	@[ -n "$(SDK)" -a -f "$(SDK)"/bin/$(1)/packages/Packages ] && \
		echo "src aprs file:$(shell cd $(SDK)/bin/$(1)/packages; pwd)" >> $(BUILDER)/repositories.conf || :	
	mkdir -p $(BUILDER)/target/linux/$(1)/base-files/etc
	cp -f files/$(1)/opkg.conf $(BUILDER)/target/linux/$(1)/base-files/etc/opkg.conf
	[ -d files/common ] && cp -fr files/common/* $(BUILDER)/target/linux/$(1)/base-files
	[ -d files/$(1) ] && cp -fr files/$(1)/* $(BUILDER)/target/linux/$(1)/base-files
	@echo "----------------------------------------------------------------------------------"
	make -C $(BUILDER) image PROFILE=$(2) \
		FILES="$(shell cd $(BUILDER); pwd)/target/linux/$1/base-files" \
		PACKAGES="$(OPKG_PACKAGES) $(OPKG_PACKAGES_EXTRA) $(3)"
	@echo "----------------------------------------------------------------------------------"
endef

brcm63xx: $(PREPARED_TARGETS)
	$(call BuildImage,brcm63xx,RG100A,kmod-b43)

brcm47xx: $(PREPARED_TARGETS)
	$(call BuildImage,brcm47xx,Broadcom-b43,kmod-b43)

rt305x:$(PREPARED_TARGETS)
	$(call BuildImage,rt305x,Default,kmod-rt2800-soc)

mt7620: $(PREPARED_TARGETS)
	$(call BuildImage,mt7620,Default,kmod-mt7620 kmod-mt76x2e)

ar71xx: $(PREPARED_TARGETS)
	$(call BuildImage,ar71xx,Default,)

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
	make package/ysf-clients/compile V=s -C "$(SDK)"
	make package/p25-clients/compile V=s -C "$(SDK)"

.network:
	@cd $(SDK); [ ! -L dl -a -d /opt/openwrt/dl ] && { rmdir dl && ln -s /opt/openwrt/dl; } || :
	@cd $(SDK)/package; [ -d network-feeds ] && { cd network-feeds; git pull; } || git clone https://github.com/rssnsj/network-feeds.git
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

extract_ar71xx:
	$(call ExtractImageBuilder,$(AR71XX_BUILDER_TGZ),$(AR71XX_SDK_TGZ))

extract_brcm63xx:
	$(call ExtractImageBuilder,$(BRCM63XX_BUILDER_TGZ),$(BRCM63XX_SDK_TGZ))

extract_brcm47xx:
	$(call ExtractImageBuilder,$(BRCM47XX_BUILDER_TGZ),$(BRCM47XX_SDK_TGZ))
	
help:
	@echo "APRS Image Build Script for 14.07"
	@echo "---------------------------------"
	@echo "Usage:"
	@echo "  make mt7620 		build OpenWrt firmware with APRS software installed for Lenovo Y1/Y1S (MT7620 board)"
	@echo "  make rt305x		build OpenWrt firmware with APRS software installed for Huawei RG255D(RT305x board)"
	@echo "  make brcm47xx		build OpenWrt firmware with APRS software installed for H618B(BRCM47XX board)"
	@echo "  make brcm63xx		build OpenWrt firmware with APRS software installed for H618C(BRCM63XX board)"
	
	@echo "Options:"
	@echo "  NETWORK=1                    build and install Shadowsocks, minivtun, kmod-proto-bridge, kmod-yavlan"

clean: .check_ib
	make clean -C $(BUILDER)
	@if [ -e .patched ]; then \
		cd $(BUILDER); cat ../patches/*.patch | patch -R -p2; cd ..; \
		rm -vf .patched; \
	fi
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/ramips ] && rm -rf "$(SDK)"/bin/ramips/* || :
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/brcm47xx ] && rm -rf "$(SDK)"/bin/brcm47xx/* || :
	@[ -n "$(SDK)" -a -d "$(SDK)"/bin/brcm63xx ] && rm -rf "$(SDK)"/bin/brcm63xx/* || :

distclean:
	rm -fr OpenWrt-ImageBuilder-*
	rm -fr OpenWrt-SDK-*
	rm -f .patched
	rm -f sdk builder

DEPLOY_ROOT := hamclub:/opt/openwrt/build/customize/14.07
deploy_packages:
	@[ ! -d sdk/bin/brcm63xx/packages ] || scp -r sdk/bin/brcm63xx/packages/* $(DEPLOY_ROOT)/brcm63xx/generic/packages/
	@[ ! -d sdk/bin/brcm47xx/packages ] || scp -r sdk/bin/brcm47xx/packages/* $(DEPLOY_ROOT)/brcm47xx/legacy/packages/

deploy:
ifeq ($(TYPE),)
	[ ! -f builder/bin/brcm63xx/openwrt-RG100A_DB120-squashfs-cfe.bin ] || scp builder/bin/brcm63xx/openwrt-RG100A_DB120-squashfs-cfe.bin $(DEPLOY_ROOT)/14.07-h618c-aprs-squashfs-cfe.bin
	[ ! -f builder/bin/brcm47xx/openwrt-brcm47xx-legacy-squashfs.trx ] || scp builder/bin/brcm47xx/openwrt-brcm47xx-legacy-squashfs.trx $(DEPLOY_ROOT)/14.07-h618b-aprs-squashfs-cfe.bin
else
	[ ! -f builder/bin/brcm63xx/openwrt-RG100A_DB120-squashfs-cfe.bin ] || scp builder/bin/brcm63xx/openwrt-RG100A_DB120-squashfs-cfe.bin $(DEPLOY_ROOT)/14.07-h618c-$(TYPE)-squashfs-cfe.bin
	[ ! -f builder/bin/brcm47xx/openwrt-brcm47xx-legacy-squashfs.trx ] || scp builder/bin/brcm47xx/openwrt-brcm47xx-legacy-squashfs.trx $(DEPLOY_ROOT)/14.07-h618b-$(TYPE)-squashfs-cfe.bin
endif
