## How it works

An 8-bit counter runs continuously. The output `uo[0]` is high while the
counter is below the duty value, so out of every 256 clock cycles the output
is high for `duty` cycles. The duty value is read from `ui[7:0]` once per
period, which keeps the output glitch free when the switches change.

## How to test

Set `ui[7:0]` to a value between 0 and 255 and watch `uo[0]` on an oscilloscope
or through an LED. At 10 MHz one period lasts 25.6 microseconds, so an LED
looks dimmer or brighter as the duty value changes.

## External hardware

An LED with a series resistor on `uo[0]`, or an oscilloscope probe.
