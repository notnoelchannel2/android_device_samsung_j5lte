# From twrp/build/make/core/Makefile

LOCAL_PATH := $(call my-dir)

KERNEL_OUT_TARGET := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbToolLineage
DTS_OUT_TARGET := $(KERNEL_OUT_TARGET)/arch/$(TARGET_ARCH)/boot/dts/
DTC_OUT_TARGET := $(KERNEL_OUT_TARGET)/scripts/dtc/
INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

$(INSTALLED_DTIMAGE_TARGET): $(DTBTOOL) $(INSTALLED_KERNEL_TARGET)
	$(call pretty,"Target dt image: $@")
	$(hide) $(DTBTOOL) -o $@ -s $(BOARD_KERNEL_PAGESIZE) -p $(DTC_OUT_TARGET) $(DTS_OUT_TARGET)

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS) \
		$(INSTALLED_DTIMAGE_TARGET)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) \
		$(INTERNAL_BOOTIMAGE_ARGS) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--dt $(INSTALLED_DTIMAGE_TARGET) \
		--output $@
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_ramdisk) $(recovery_kernel) \
		$(RECOVERYIMAGE_EXTRA_DEPS)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) \
		$(INTERNAL_RECOVERYIMAGE_ARGS) \
		$(INTERNAL_MKBOOTIMG_VERSION_ARGS) \
		$(BOARD_MKBOOTIMG_ARGS) \
		--dt $(INSTALLED_DTIMAGE_TARGET) \
		--output $@ --id > $(RECOVERYIMAGE_ID_FILE)
	$(hide) echo -n "SEANDROIDENFORCE" >> $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
