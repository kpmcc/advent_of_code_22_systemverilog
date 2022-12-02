#!/usr/bin/env python3

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.result import TestSuccess, TestFailure

@cocotb.test()
async def part_one(dut):


    input_file = "example_input.txt"
    #input_file = "actual_input.txt"
    with open(input_file, "r") as f:
        t = f.read()

    cocotb.start_soon(Clock(dut.clk, 4, units="ns").start())
    for i in range(5):
        await RisingEdge(dut.clk)

    # reset
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    entry_lines = t.strip().split('\n')

    for l in entry_lines:
        opponent_play, player_action = l.split(' ')
        await RisingEdge(dut.clk)
        dut.entry_vld.value = 1
        dut.opponent_item_char.value = ord(opponent_play)
        dut.player_action_char.value = ord(player_action)

    await RisingEdge(dut.clk)
    dut.entry_vld.value = 0
    dut.opponent_item_char.value = 0
    dut.player_action_char.value = 0

    await RisingEdge(dut.eg_score_vld)
    await RisingEdge(dut.clk)

    score_sum = int(dut.eg_score.value)

    print(score_sum)

    raise TestSuccess
