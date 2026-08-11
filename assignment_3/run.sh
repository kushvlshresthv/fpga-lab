#!/usr/bin/env bash
set -e

SIM="fft_sim"
VCD="fft.vcd"

command -v iverilog >/dev/null 2>&1 || {
    echo "Error: iverilog is not installed."
    echo "Ubuntu/Debian: sudo apt install iverilog"
    exit 1
}

command -v vvp >/dev/null 2>&1 || {
    echo "Error: vvp is not installed. Install Icarus Verilog."
    exit 1
}

rm -f "$SIM" "$VCD"

echo "Compiling..."
iverilog -g2012 -Wall -o "$SIM" fft.v tb_fft.v

echo "Running simulation..."
vvp "$SIM"

echo
if [ -f "$VCD" ]; then
    echo "Generated waveform: $VCD"
    echo "Open it with: gtkwave $VCD"
else
    echo "Error: $VCD was not generated."
    exit 1
fi
