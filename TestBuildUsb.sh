#!/bin/bash
USBCORE=/home/bthom/git/orangecrab-template/tinyfpga_bx_usbserial/
mkdir -p build

cp $USBCORE/usb/*.v build/.
cp $USBCORE/*.v build/.
cp Makefile build/.
cp usborange.pcf build/.


