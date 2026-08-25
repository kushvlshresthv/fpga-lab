#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$project_dir"

iverilog -g2012 -s rv32i_tb -o riscv_sim \
    alu.v \
    immediate_generator.v \
    register_file.v \
    instruction_memory.v \
    data_memory.v \
    rv32i_cpu.v \
    rv32i_tb.v

vvp ./riscv_sim
echo "Waveform generated: $project_dir/wave.vcd"
echo "Open it with: gtkwave wave.vcd wave.gtkw"

if [[ "${1:-}" == "--gtk" ]]; then
    gtkwave wave.vcd wave.gtkw
fi
