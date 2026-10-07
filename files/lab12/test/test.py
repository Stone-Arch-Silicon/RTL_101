# Lesson 12: cocotb tests for the PWM project (cocotb 2.x).
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


async def reset(dut):
    """Start the clock, hold reset for 5 cycles, then release it."""
    Clock(dut.clk, 100, unit="ns").start()   # 10 MHz
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1


@cocotb.test()
async def duty_cycle(dut):
    """For several duty values, count high cycles in one full 256-cycle period."""
    await reset(dut)
    for duty in (0, 1, 64, 128, 200, 255):
        dut.ui_in.value = duty
        await ClockCycles(dut.clk, 300)          # let a new period pick up the value
        high = 0
        for _ in range(256):
            await RisingEdge(dut.clk)
            high += int(dut.uo_out.value) & 1
        dut._log.info(f"duty {duty:3d}: {high:3d} high cycles out of 256")
        assert high == duty, f"duty {duty}: counted {high} high cycles"


@cocotb.test()
async def outputs_are_complementary(dut):
    """uo_out[1] must always be the opposite of uo_out[0]."""
    await reset(dut)
    dut.ui_in.value = 77
    for _ in range(600):
        await RisingEdge(dut.clk)
        v = int(dut.uo_out.value)
        assert (v & 1) != ((v >> 1) & 1), "uo_out[1] is not the inverse of uo_out[0]"
    assert int(dut.uio_oe.value) == 0, "uio pins should all be inputs"
