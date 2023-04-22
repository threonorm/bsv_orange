#!/bin/bash
BLUEAXI=/home/bthom/git/BlueAXI/src
BLUELIB=/home/bthom/git/BlueLib/src

bsc --aggressive-conditions -bdir build -vdir build -p $BLUEAXI:$BLUELIB:+ -verilog -u UsbCoreWrapper.bsv
