#!/bin/bash

# Copy sensor PQ parameters and return any validation or copy failure.
function copyBinToOutFolder()
{
	local tuning_arch=${CHIP_ARCH,,}
	local out_path=$1
	local sensor_name=$2
	local param_path sdr_bin wdr_bin

	if [ "$#" -ne 2 ] || [ -z "$out_path" ] || [ -z "$sensor_name" ] || [ -z "$tuning_arch" ]; then
		printf 'Error: CHIP_ARCH, output directory and sensor name are required.\n' >&2
		return 1
	fi

	# 88a2 uses the existing sophon tuning directory.
	if [ "$tuning_arch" = "88a2" ]; then
		tuning_arch=sophon
	fi
	param_path=$tuning_arch/src/$sensor_name
	sdr_bin=$param_path/${sensor_name}_sdr.bin
	wdr_bin=$param_path/${sensor_name}_wdr.bin

	if [ ! -f "$sdr_bin" ] || [ ! -s "$sdr_bin" ]; then
		printf 'Error: SDR parameter file is missing or empty: %s\n' "$sdr_bin" >&2
		return 1
	fi
	if [ -e "$wdr_bin" ] || [ -L "$wdr_bin" ]; then
		if [ ! -f "$wdr_bin" ] || [ ! -s "$wdr_bin" ]; then
			printf 'Error: WDR parameter path must be a non-empty regular file: %s\n' "$wdr_bin" >&2
			return 1
		fi
	fi

	mkdir -p -- "$out_path" || return
	cp -- "$sdr_bin" "$out_path/cvi_sdr_bin" || return
	if [ -f "$wdr_bin" ]; then
		cp -- "$wdr_bin" "$out_path/cvi_wdr_bin" || return
	else
		# Remove stale WDR parameters when switching to an SDR-only sensor.
		rm -f -- "$out_path/cvi_wdr_bin" || return
	fi
}

copyBinToOutFolder "$@"
