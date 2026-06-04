#!/bin/bash

set -e

create_folder(){
	mkdir demo
}

#if ! create_folder; then
#	echo "code is exited as directory is already exist"
#	exit 1
#fi

create_folder

echo "this code should not work because code is interrupted"
