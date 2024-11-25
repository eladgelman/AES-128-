# AES-128 ECB/CBC Encryption/Decryption FPGA Implementation

This project implements AES-128 encryption and decryption in ECB (Electronic Codebook) and CBC (Cipher Block Chaining) modes using an FPGA. The implementation is designed for the PYNQ-Z2 FPGA board by TUL and integrates with PYNQ Overlay for Python-based interaction.  
There are two block designs for each mode of operation, with each block design based on a custom IP Core for the specific mode: ECB or CBC. 


## Prerequisites

### Software Requirements
- **Vivado 2020.1** (ensure it is installed and configured)
- **PYNQ Image** (for using the PYNQ Overlay)
- **Git** (for cloning the repository)

### Hardware Requirements
- **FPGA Board**: PYNQ-Z2 by TUL

### Vivado Board Files
Download the PYNQ-Z2 board files and unzip them into the Vivado installation directory:

**For Windows**:  
C:\Xilinx\Vivado\2020.1\data\boards\board_files

**For Linux**:  
/opt/Xilinx/Vivado/2020.1/data/boards/board_files


## Build the Block Design

### Clone the Repository
```bash
git clone https://github.com/eladgelman/AES-128-EBC-CBC.git
```
### Open Vivado 2020.1. In the Tcl Console (bottom left corner), navigate to the repository directory:
```bash
cd <your_path_to_the_repo>/AES-128-EBC-CBC
```
### Run the appropriate TCL script for the desired block design:
```bash
# For AES-128 ECB mode:
source AES_EBC_128_ip_check.tcl

# For AES-128 CBC mode:
source AES_CBC_128_ip_check.tcl
```
### Run the appropriate TCL script for the desired block design:
If there are no errors, Vivado will generate a complete project for each mode.

### Open the Project
After generation, you can access the projects in the repository:

- AES-128 ECB: AES-128-EBC/AES_EBC_128.xpr
- AES-128 CBC: AES-128-CBC/AES_CBC_128.xpr
Open the respective .xpr file in Vivado to continue.

Generate the Bitstream
In each project: 
- Generate the bitstream.
- Export the hardware.


## Build the Software

The software integrates with the PYNQ Overlay to allow Python-based configuration and interaction with the FPGA.

### Option 1: Use PYNQ Image (Recommended)
1. Set up the PYNQ Image on the PYNQ-Z2 board.
2. Copy the directory:
```
Software/AES-128 PYNQ/AES-128
```
to the PYNQ board.
3. Replace the existing .bit and .hwh files in the Software/AES-128 PYNQ/AES-128/overlays with the files generated from the Vivado block designs.
4. Open the provided Jupyter Notebooks in the PYNQ environment and follow the guidance for testing.

### Option 2: Use Vitis
If you do not plan to use PYNQ:
1. Create a new project in Vitis. (use .xsa file, Export the hardware in vivado).
2. Use the files in:
```
Software/AES-128 PYNQ/Vitis_files
```
as the base for your project.
3. Build and deploy the software for basic functionality testing.

## Notes
* Ensure that Vivado 2020.1 and the PYNQ board files are correctly installed.
* For any issues with Jupyter Notebooks or Python integration, refer to the PYNQ documentation.

