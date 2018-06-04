CONFIG_RTL8821C = y
CONFIG_PLATFORM_ARM_RPI = y

FW_INSTALL_DIR	:= /lib/firmware
obj-m := rtk_btusb.o
rtk_btusb-y = rtk_coex.o rtk_bt.o
	
ifeq ($(CONFIG_RTL8821C), y)
MODULE_NAME := rtk_btusb
FW_DIR := 8821CU
FW_NAME := rtl8821cu_fw
FW_CONF := rtl8821cu_config
endif

MDL_DIR	:= /lib/modules/$(shell uname -r)
DRV_DIR	:= $(MDL_DIR)/kernel/drivers/bluetooth

ifeq ($(CONFIG_PLATFORM_ARM_RPI), y)
ARCH := arm
CROSS_COMPILE ?=
KVER  := $(shell uname -r)
KSRC := /lib/modules/$(KVER)/build
MODDESTDIR := /lib/modules/$(KVER)/kernel/drivers/net/wireless/
INSTALL_PREFIX :=
STAGINGMODDIR := /lib/modules/$(KVER)/kernel/drivers/staging
endif

all: modules

modules:
	$(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) -C $(KSRC) M=$(shell pwd) modules

strip:
	$(CROSS_COMPILE)strip $(MODULE_NAME).ko

clean:
	rm -fr Module.symvers ; rm -fr Module.markers ; rm -fr modules.order
	rm -fr *.mod.c *.mod *.o .*.cmd *.ko *~ *.symvers *.order *.a
	rm -fr .tmp_versions

.PHONY: modules clean

install:
	mkdir -p $(FW_DIR)
	cp -f $(FW_DIR)/$(FW_NAME) $(FW_INSTALL_DIR)/$(FW_NAME)
	cp -f $(FW_DIR)/$(FW_CONF) $(FW_INSTALL_DIR)/$(FW_CONF)
	cp -f $(MODULE_NAME).ko $(DRV_DIR)/$(MODULE_NAME).ko
	depmod -a $(MDL_DIR)

uninstall:
	rm -f $(DRV_DIR)/$(MODULE_NAME).ko
	depmod -a $(MDL_DIR)
	rm -f $(FW_DIR)/${FW_NAME}
	rm -f $(FW_DIR)/${FW_CONF}
