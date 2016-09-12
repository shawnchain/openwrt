#
#
openwrt_dir = openwrt-src
host_packages = build-essential git flex gettext libncurses5-dev unzip gawk liblzma-dev u-boot-tools
openwrt_feeds = luci luci-app-ddns
config_file = hg255d-mywrt-full.config

mtk: .prepare_config
	@make -C $(openwrt_dir)

.prepare_config: .install_feeds
	@cd $(openwrt_dir); [ -f .config ] && mv -vf .config .config.bak || :
	@cp -vf config/$(config_file) $(openwrt_dir)/.config
	[ -f config/config.extra ] && config/config.extra >> $(openwrt_dir)/.config || :

.install_feeds: .update_feeds
	@cd $(openwrt_dir); ./scripts/feeds install $(openwrt_feeds);
	# the network feeds	
	@cd $(openwrt_dir)/package; \
	 [ -e rssnsj-feeds ] || git clone https://github.com/rssnsj/network-feeds.git rssnsj-feeds; \
		make -C rssnsj-feeds/ipset-lists/tools
	@touch .install_feeds

.update_feeds: .patched
	@cd $(openwrt_dir); ./scripts/feeds update;
	@touch .update_feeds

.patched: .checkout_src
	@cd $(openwrt_dir); cat ../patches/*.patch | patch -p1
	@touch .patched

# 2. Checkout source code:
.checkout_src: .check_hostdeps
	[ -d $(openwrt_dir) ] ||  git clone git://git.openwrt.org/15.05/openwrt.git $(openwrt_dir);
	@cd $(openwrt_dir); git pull; 
	@[ ! -L $(openwrt_dir)/dl -a -d /opt/openwrt/dl ] && ln -sf /opt/openwrt/dl $(openwrt_dir)/dl || :
	@touch .checkout_src

.check_hostdeps:
# 1. Install required host components:
	@which dpkg >/dev/null 2>&1 || exit 0; \
	for p in $(host_packages); do \
		dpkg -s $$p >/dev/null 2>&1 || to_install="$$to_install$$p "; \
	done; \
	if [ -n "$$to_install" ]; then \
		echo "Please install missing packages by running the following commands:"; \
		echo "  sudo apt-get update"; \
		echo "  sudo apt-get install -y $$to_install"; \
		exit 1; \
	fi;
	@touch .check_hostdeps

menuconfig: .prepare_config
	@touch config/$(config_file) # change modification time
	@make -C $(openwrt_dir) menuconfig
	@[ $(openwrt_dir)/.config -nt config/$(config_file) ] && cp -vf $(openwrt_dir)/.config config/$(config_file) || :

clean:
	make clean -C $(openwrt_dir) V=s

distclean: clean
	rm .check_hostdeps .checkout_src .patched .update_feeds .install_feeds
	rm -fr $(openwrt_dir)
