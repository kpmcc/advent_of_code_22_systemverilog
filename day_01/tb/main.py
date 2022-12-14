#!/usr/bin/env python3

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge
from cocotb.result import TestSuccess, TestFailure

@cocotb.test()
async def part_one(dut):


    #input_file = "example_input.txt"
    input_file = "actual_input.txt"
    with open(input_file, "r") as f:
        t = f.read()

    # zero out inputs
    dut.clk.value = 0
    dut.rst.value = 0
    dut.food_calories.value = 0
    dut.food_vld.value = 0
    dut.store_sum.value = 0
    dut.read_max.value = 0

    # start clock running
    cocotb.start_soon(Clock(dut.clk, 4, units="ns").start())
    for i in range(5):
        await RisingEdge(dut.clk)

    # reset
    dut.rst.value = 1
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    # for checking output
    expected_max_calories = 0

    # process inputs
    elf_foods = t.split('\n\n')
    top_3 = [0, 0, 0]
    #print(elf_foods)
    for e in elf_foods:
        items = e.strip()
        items = items.split('\n')
        #print(items)
        items = [int(i) for i in items]

        current_sum = 0
        for i in items:
            await RisingEdge(dut.clk)
            dut.food_calories.value = i
            dut.food_vld.value = 1
            current_sum += i

        await RisingEdge(dut.clk)
        dut.food_vld.value = 0
        dut.store_sum.value = 1

        await RisingEdge(dut.clk)
        dut.store_sum.value = 0

        top_3.append(current_sum)
        top_3.sort()
        top_3 = top_3[1:]
        expected_max_calories = max(expected_max_calories, current_sum)

    await RisingEdge(dut.clk)
    dut.read_max.value = 1

    await RisingEdge(dut.max_vld)
    await RisingEdge(dut.clk)
    max_calories = int(dut.max_calories_sum.value)
    max_calories_top_three_sum = int(dut.max_calories_top_three_sum.value)
    expected_sum = sum(top_3)

    if max_calories == expected_max_calories and max_calories_top_three_sum == expected_sum:
        print("Max calories: %d" % max_calories)
        print("Sum of top 3: %d" % max_calories_top_three_sum)
        raise TestSuccess()
    else:
        print("expected max: %d - actual: %d" % (expected_max_calories, max_calories))
        print("expected sum: %d - actual: %d" % (expected_sum, max_calories_top_three_sum))
        raise TestFailure()
