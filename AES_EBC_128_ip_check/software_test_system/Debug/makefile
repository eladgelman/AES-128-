#
# This file was created by Xilinx Vitis tool.
#


#
# tools
#

RM = rm -f
RMDIR = rm -rf



#
# variables
#

SDCARD_GEN = sdcard_gen
GENERATE_BIF = ::scw::generate_bif

XPFM_PATH = C:/Users/User/AES_EBC_128_ip_check/myplatfrom/export/myplatfrom/myplatfrom.xpfm
SYS_CONFIG = myplatfrom
DOMAINS = standalone_domain
BIF_PATH = C:/Users/User/AES_EBC_128_ip_check/software_test_system/Debug/system.bif

BITSTREAM_PATH = C:/Users/User/AES_EBC_128_ip_check/software_test/_ide/bitstream/AES_EBC_128_design_wrapper.bit
SD_FILES = --elf C:/Users/User/AES_EBC_128_ip_check/software_test/Debug/software_test.elf,ps7_cortexa9_0

#
# primary build targets
#

all: package

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 54738 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean


