#!/bin/bash

INST_DIR="\$HOME/px4/toolchain"
INST_FILE="px4_toolchain_mac_os_v0.3.tar.gz"
URL="http://cloud.github.com/downloads/px4/px4_toolchain/$INST_FILE"
CURR_DIR=`pwd`

# Install the PX4 toolchain on the current system
echo
echo "This script downloads and installs the PX4 toolchain"

if [ -f /usr/bin/gcc ]; then
	echo "Found GCC"
else
	echo "FATAL ERROR: XCode not installed. Please follow the instructions on this wiki page:"
	echo "https://pixhawk.ethz.ch/px4/dev/minimal_build_env"
	exit 1
fi

echo "Enter the installation location (Type [RETURN] to accept default or CTRL-C to abort):"
echo "Default: $INST_DIR"
read ANSWER

if [ -n "$ANSWER" ]; then
	INST_DIR=$ANSWER
else
	echo "Kept default directory"
fi

INST_DIR_EXPANDED=`eval echo $INST_DIR`

# Create directory
mkdir -p $INST_DIR_EXPANDED
RETVAL=$?
if [ $RETVAL -ne 0 ]; then
	echo "Could not create directory $INST_DIR_EXPANDED"
else
	echo "Created directory: $INST_DIR_EXPANDED"
fi

if [ -w $INST_DIR_EXPANDED ]; then
	echo "Installing to: $INST_DIR_EXPANDED"
	cd $INST_DIR_EXPANDED
	curl -O $URL
	RETVAL=$?
	if [ $RETVAL -ne 0 ]; then
		echo "Failed downloading file: $URL"
		exit 2
	else
		echo "Downloaded $URL"
	fi
	tar xvzf $INST_FILE
	cd $CURR_DIR

	echo "Installed toolchain to $INST_DIR"
	echo
	echo "Should the toolchain be added to the path? (RECOMMENDED) (answer y or n, default is y)"
	read ANSWER
	BIN_DIR=$INST_DIR/bin
	LIB_DIR=$INST_DIR/lib
	BIN_LINE="export PATH=$BIN_DIR:\$PATH"
	LIB_LINE="export DYLD_FALLBACK_LIBRARY_PATH=$LIB_DIR:\$DYLD_FALLBACK_LIBRARY_PATH"
	if [ "$ANSWER" != "n" ]; then
		echo "Adding bin and lib dirs to $HOME/.bash_profile"
		echo $BIN_LINE >> $HOME/.bash_profile
		echo $LIB_LINE >> $HOME/.bash_profile
		source $HOME/.bash_profile
		echo "Successfully installed arm-none-eabi-gcc:"
		arm-none-eabi-gcc --version
	else
		echo "Make sure to add these two lines to your environment before using the toolchain:"
		echo ""
		echo $BIN_LINE
		echo $LIB_LINE
	fi
else
	echo "FATAL ERROR: The directory $INST_DIR is not writable.\nPlease choose a different directory or re-run the script using sudo"
	exit 1
fi
