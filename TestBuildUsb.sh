#!/bin/bash
USBCORE=/home/bthom/git/bsv_orange/tinyfpga_bx_usbserial/
# WISHBONE=/home/bthom/git/Wishbone_BSV/src
BLUEAXI=/home/bthom/git/BlueAXI/src
BLUELIB=/home/bthom/git/BlueLib/src
rm -rf build/
mkdir -p build
# $WISHBONE:
cp $USBCORE/usb/*.v build/.
cp $USBCORE/*.v build/.
cp Makefile build/.
cp usborange.pcf build/.
cp gsd_orange.v build/.
cp gsd_orangecrab_sram.init build/.
cp FIFO2.v build/.
cp SizedFIFO.v build/.
cp BRAM2BE.v build/.
cp SyncReset0.v build/.
cp ResetEither.v build/.

bsc -p $BLUEAXI:$BLUELIB:+ --show-schedule -opt-AndOr -opt-bool -opt-ATS  --aggressive-conditions -bdir build -vdir build -verilog -u OrangeCrabTop.bsv
sed -i '0,/\.pin_usb_p/{s/\.pin_usb_p(usb_core$pin_usb_p)/usb_core$pin_usb_p/}' build/top.v
sed -i '0,/\.pin_usb_n/{s/\.pin_usb_n(usb_core$pin_usb_n)/usb_core$pin_usb_n/}' build/top.v
