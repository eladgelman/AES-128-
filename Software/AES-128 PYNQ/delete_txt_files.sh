#!/bin/bash

TARGET_DIR="/home/xilinx/jupyter_notebooks/AES-128"

if [ -d "$TARGET_DIR" ]; then
	rm "$TARGET_DIR"/*.txt
	echo "All .txt file in $TARGET_DIR have been deleted."
else
	echo "Directory $TARGET_DIR does not exist."
fi
