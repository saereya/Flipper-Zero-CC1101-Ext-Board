#!/usr/bin/env bash
# Regenerate every reviewable and fabricable output for CC1101 Ext Board V2.
# Needs kicad-cli 10.x; set KICAD_CLI if it is not on PATH.
set -euo pipefail
cd "$(dirname "$0")"
KICAD_CLI="${KICAD_CLI:-}"
if [ -z $KICAD_CLI ]; then
    if command -v kicad-cli >/dev/null; then
        KICAD_CLI=kicad-cli
    else
        # AppImage installs put kicad-cli inside the image rather than on PATH
        APPIMAGE=$(ls -1 "$HOME"/.local/bin/kicad-*.AppImage 2>/dev/null | tail -1 || true)
        [ -n "$APPIMAGE" ] || { echo "kicad-cli not found; set KICAD_CLI" >&2; exit 1; }
        KICAD_CLI="$APPIMAGE kicad-cli"
    fi
fi
SCH=CC1101ExtBoardV2.kicad_sch
PCB=CC1101ExtBoardV2.kicad_pcb

rm -rf fab doc
mkdir -p fab/gerbers doc

# --- checks ---------------------------------------------------------------
$KICAD_CLI sch erc --severity-all --units mm -o doc/erc.rpt "$SCH"
$KICAD_CLI pcb drc --refill-zones --schematic-parity --severity-all --units mm \
    -o doc/drc.rpt "$PCB"

# --- documentation --------------------------------------------------------
$KICAD_CLI sch export pdf -o doc/schematic.pdf "$SCH"
$KICAD_CLI sch export netlist --format kicadsexpr -o doc/netlist.net "$SCH"
$KICAD_CLI sch export bom --fields 'Reference,Value,Footprint,${QUANTITY},Datasheet' \
    --group-by Value --labels 'Refs,Value,Footprint,Qty,Datasheet' -o doc/bom.csv "$SCH"
$KICAD_CLI pcb render --side top    --quality high --width 2200 --height 1250 \
    --zoom 0.95 -o doc/render-top.png "$PCB"
$KICAD_CLI pcb render --side bottom --quality high --width 2200 --height 1250 \
    --zoom 0.95 -o doc/render-bottom.png "$PCB"
$KICAD_CLI pcb export pdf --layers F.Cu,F.SilkS,Edge.Cuts -o doc/pcb-front.pdf "$PCB"
$KICAD_CLI pcb export pdf --layers B.Cu,B.SilkS,Edge.Cuts --mirror \
    -o doc/pcb-back.pdf "$PCB"

# --- fabrication ----------------------------------------------------------
$KICAD_CLI pcb export gerbers --no-protel-ext -o fab/gerbers/ "$PCB"
$KICAD_CLI pcb export drill --format excellon --drill-origin absolute \
    --excellon-units mm --generate-map --map-format gerberx2 -o fab/gerbers/ "$PCB"
$KICAD_CLI pcb export pos --format csv --units mm --side both \
    -o fab/positions.csv "$PCB"
$KICAD_CLI pcb export step --subst-models --no-dnp -o fab/CC1101ExtBoardV2.step "$PCB"
( cd fab/gerbers && zip -q -r ../CC1101ExtBoardV2-gerbers.zip . )
echo "outputs written to fab/ and doc/"
