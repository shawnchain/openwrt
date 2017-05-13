cc0:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for X86 devices      ="
	@echo "============================================================"
	make -C 15.05.1 extract_x86
	make -C 15.05.1 x86 NETWORK=1 NAS=1 IOT=1
	make -C 15.05.1 deploy_packages
#	make -C 15.05.1 deploy TYPE=full
#	make -C 15.05.1 x86 NETWORK=1
#	make -C 15.05.1 deploy TYPE=net
#	make -C 15.05.1 x86 IOT=1
#	make -C 15.05.1 deploy TYPE=iot
#       make -C 15.05.1 distclean
cc1:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for BRCM47XX devices ="
	@echo "============================================================"
	make -C 15.05.1 extract_brcm47xx
	make -C 15.05.1 brcm47xx NETWORK=1 NAS=1
	make -C 15.05.1 deploy_packages
	make -C 15.05.1 deploy TYPE=full
	make -C 15.05.1 brcm47xx NETWORK=1
	make -C 15.05.1 deploy TYPE=net
	make -C 15.05.1 brcm47xx 
	make -C 15.05.1 deploy TYPE=aprs
#	make -C 15.05.1 distclean

cc2:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for BRCM63XX devices ="
	@echo "============================================================"
	make -C 15.05.1 extract_brcm63xx
	make -C 15.05.1 brcm63xx NETWORK=1 NAS=1
	make -C 15.05.1 deploy_packages
	make -C 15.05.1 deploy TYPE=full
	make -C 15.05.1 brcm63xx NETWORK=1
	make -C 15.05.1 deploy TYPE=net
	make -C 15.05.1 brcm63xx
	make -C 15.05.1 deploy
#	make -C 15.05.1 distclean	

cc3:
	@echo "============================================================"
	@echo "= Building OpenWrt-15.05.1 APRS image for MT7620 devices   ="
	@echo "============================================================"
	make -C 15.05.1 extract_mt7620
	make -C 15.05.1 mt7620 NETWORK=1 NAS=1
	make -C 15.05.1 deploy_packages
	make -C 15.05.1 deploy TYPE=full
	make -C 15.05.1 mt7620 NETWORK=1
	make -C 15.05.1 deploy TYPE=net
	make -C 15.05.1 mt7620
	make -C 15.05.1 deploy
#	make -C 15.05.1 distclean	

bb1:
	@echo "==========================================================="
	@echo "= Building OpenWrt-14.07 APRS image for BRCM47XX devices ="
	@echo "=========================================================="
	make -C 14.07 extract_brcm47xx
	#make -C 14.07 brcm47xx NETWORK=1 NAS=1
	make -C 14.07 .aprs .network NAS=1
	make -C 14.07 deploy_packages
	#make -C 14.07 deploy TYPE=full
	make -C 14.07 brcm47xx NETWORK=1
	make -C 14.07 deploy TYPE=net
	make -C 14.07 brcm47xx 
	make -C 14.07 deploy TYPE=aprs
#	make -C 14.07 distclean
bb2:
	@echo "=========================================================="
	@echo "= Building OpenWrt-14.07 APRS image for BRCM63XX devices ="
	@echo "=========================================================="
	make -C 14.07 extract_brcm63xx
	make -C 14.07 brcm63xx NETWORK=1 NAS=1
	make -C 14.07 deploy_packages
	make -C 14.07 deploy TYPE=full
	make -C 14.07 brcm63xx NETWORK=1
	make -C 14.07 deploy TYPE=net
	make -C 14.07 brcm63xx
	make -C 14.07 deploy
#	make -C 14.07 distclean

cc: cc1 cc2 cc3
bb: bb1 bb2

all: bb cc

distclean:
	make -C 14.07 distclean
	make -C 15.05.1 distclean
