cc1:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for BRCM47XX devices ="
	@echo "============================================================"
	make -C aprs-box extract_brcm47xx
	make -C aprs-box brcm47xx NETWORK=1 NAS=1
	make -C aprs-box deploy_packages
	make -C aprs-box deploy TYPE=full
	make -C aprs-box brcm47xx NETWORK=1
	make -C aprs-box deploy TYPE=net
	make -C aprs-box brcm47xx 
	make -C aprs-box deploy TYPE=aprs
#	make -C aprs-box distclean

cc2:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for BRCM63XX devices ="
	@echo "============================================================"
	make -C aprs-box extract_brcm63xx
	make -C aprs-box brcm63xx NETWORK=1 NAS=1
	make -C aprs-box deploy_packages
	make -C aprs-box deploy TYPE=full
	make -C aprs-box brcm63xx NETWORK=1
	make -C aprs-box deploy TYPE=net
	make -C aprs-box brcm63xx
	make -C aprs-box deploy
#	make -C aprs-box distclean	

bb1:
	@echo "==========================================================="
	@echo "= Building OpenWrt-14.07 APRS image for BRCM47XX devices ="
	@echo "=========================================================="
	make -C aprs-box-14.07 extract_brcm47xx
	make -C aprs-box-14.07 brcm47xx NETWORK=1 NAS=1
	make -C aprs-box-14.07 deploy_packages
	make -C aprs-box-14.07 deploy TYPE=full
	make -C aprs-box-14.07 brcm47xx NETWORK=1
	make -C aprs-box-14.07 deploy TYPE=net
	make -C aprs-box-14.07 brcm47xx 
	make -C aprs-box-14.07 deploy TYPE=aprs
#	make -C aprs-box distclean
bb2:
	@echo "=========================================================="
	@echo "= Building OpenWrt-14.07 APRS image for BRCM63XX devices ="
	@echo "=========================================================="
	make -C aprs-box-14.07 extract_brcm63xx
	make -C aprs-box-14.07 brcm63xx NETWORK=1 NAS=1
	make -C aprs-box-14.07 deploy_packages
	make -C aprs-box-14.07 deploy TYPE=full
	make -C aprs-box-14.07 brcm63xx NETWORK=1
	make -C aprs-box-14.07 deploy TYPE=net
	make -C aprs-box-14.07 brcm63xx
	make -C aprs-box-14.07 deploy
#	make -C aprs-box-14.07 distclean

cc: cc1 cc2
bb: bb1 bb2

all: bb cc
