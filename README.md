# Flipper Zero External CC1101 PCB

A PCB that plugs onto the Flipper Zero GPIO header and carries an external
CC1101 sub-GHz module, so you can use a better antenna than the built-in radio.
It also brings out the Flipper signals the radio does not use, and has a
prototyping area for further development.

## V2 — current design

**[CC1101ExtBoardV2/](CC1101ExtBoardV2/)** — KiCad 10, 61.34 × 32.84 mm, two
layers, hand-solderable. ERC and DRC clean, schematic and board in parity, with
gerbers, drill, BOM, position file and reports committed.

![V2 board](CC1101ExtBoardV2/doc/render-top.png)

The radio now runs from Flipper pin 9 (+3V3) through a series Schottky and a
ferrite bead — no regulator and no zener. Every one of the eighteen connector
pads carries a real net, GDO2 is broken out to pin 7, ESD arrays sit at the
connector, ground is poured on both layers, and the prototyping grid is a true
2.54 mm array with rails on real nets.

See [CC1101ExtBoardV2/README.md](CC1101ExtBoardV2/README.md) for the pin map,
the bill of materials, the setup step you need on the Flipper, and a full
account of what changed and why.

One correction worth flagging: the V1 review claimed the connector could not
mate with a Flipper Zero because the GPIO header is "two rows of nine". It is
not. The Flipper Zero GPIO is a single row of 18 pins, split 8 + 10 with a
17.78 mm gap, 58.42 mm from pad 1 to pad 18 — exactly what V1 had. That
geometry was right and V2 keeps it. Everything else in the review was real and
is fixed.

## V1 — original design

**[CC1101ExtBoard/](CC1101ExtBoard/)** — kept for reference. Do not build it:
its 3.6 V zener is fitted backwards across the supply, its regulator has input
and output on the same net, and the radio is fed from the Flipper's +5V pin.

![V1 protoboard design](PCB.png)

![V1 schematic](Schematic.png)
