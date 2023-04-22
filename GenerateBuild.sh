#!/bin/bash
USBCORE=/home/bthom/git/core_usb_bridge/
mkdir -p build

cp $USBCORE/usb_bridge_top.v build/.
cp $USBCORE/usb_bridge/src_v/*.v build/.
cp $USBCORE/usb_cdc/src_v/*.v build/.
cp $USBCORE/usb_fs_phy/src_v/*.v build/.
cp Makefile build/.
cp orangecrab_r0.2.pcf build/.


BLUEAXI=/home/bthom/git/BlueAXI/src
BLUELIB=/home/bthom/git/BlueLib/src

bsc --aggressive-conditions -bdir build -vdir build -p $BLUEAXI:$BLUELIB:+ -verilog -u OrangeCrabTop.bsv
sed -i 's/\.usb_d_p(usb_core$usb_dp_io)/usb_core$usb_dp_io/g' build/top.v
sed -i 's/\.usb_d_n(usb_core$usb_dn_io)/usb_core$usb_dn_io/g' build/top.v
