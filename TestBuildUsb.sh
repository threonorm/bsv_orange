#!/bin/bash
USBCORE=/home/bthom/git/orangecrab-template/tinyfpga_bx_usbserial/
rm -rf build/
mkdir -p build

cp $USBCORE/usb/*.v build/.
cp $USBCORE/*.v build/.
cp Makefile build/.
cp usborange.pcf build/.

bsc --aggressive-conditions -bdir build -vdir build -verilog -u OrangeCrabTop.bsv
sed -i '0,/\.pin_usb_p/{s/\.pin_usb_p(usb_core$pin_usb_p)/usb_core$pin_usb_p/}' build/top.v
sed -i '0,/\.pin_usb_n/{s/\.pin_usb_n(usb_core$pin_usb_n)/usb_core$pin_usb_n/}' build/top.v
