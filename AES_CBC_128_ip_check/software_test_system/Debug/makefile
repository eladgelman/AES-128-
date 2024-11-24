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

XPFM_PATH = C:/Users/User/AES_CBC_128_ip_check/my_platfrom/export/my_platfrom/my_platfrom.xpfm
SYS_CONFIG = my_platfrom
DOMAINS = standalone_domain
BIF_PATH = C:/Users/User/AES_CBC_128_ip_check/software_test_system/Debug/system.bif

BITSTREAM_PATH = C:/Users/User/AES_CBC_128_ip_check/software_test/_ide/bitstream/AES_CBC_128_design_wrapper.bit
SD_FILES = --elf C:/Users/User/AES_CBC_128_ip_check/software_test/Debug/software_test.elf,ps7_cortexa9_0

#
# primary build targets
#

all: package

package:
	-@echo Generating bif file for the system project
	generate_system_bif.bat 53325 ${XPFM_PATH} ${DOMAINS} ${BIF_PATH}
	${SDCARD_GEN} --xpfm ${XPFM_PATH} --sys_config ${SYS_CONFIG} --bif ${BIF_PATH} --bitstream ${BITSTREAM_PATH} ${SD_FILES}

clean:
	$(RMDIR) ./_sds
	${RMDIR} package
	${RM} system.bif

.PHONY: all package clean


