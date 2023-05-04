import UsbByte::*;
import GetPut::*;
import Orange::*;
import AXI4_Lite_Master::*;
import AXI4_Lite_Slave::*;
import AXI4_Lite_Types::*;
import Connectable::*;
import DefaultValue::*;
import FIFO::*;


interface OrangeCrab;
    (* prefix = "" *)
    interface Usb usb;

    (* always_ready, prefix = "" *)
    method Bit#(1) pin_pu;
    
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_r();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_g();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_b();

    (* prefix = "" *)
    interface DramPins dram;
endinterface

typedef enum {Addr, Data} State deriving (Eq,Bits);

// Import BVI for the usb_bridge_top
(* synthesize, default_clock_osc = "pin_clk", default_reset = "rst_n" *)
module top(OrangeCrab ifc);
    Reg#(Bit#(8)) cnt <- mkReg(0);
    Reg#(Bit#(16)) rcnt <- mkReg(0);
    // USB Core
    UsbCore usb_core <- mkUsbCore();
    // DRAM Core
    GsdOrange system <- mkGsdOrange();

    AXI4_Lite_Master_Wr#(32,32) wServer <- mkAXI4_Lite_Master_Wr(1);
    AXI4_Lite_Master_Rd#(32,32) rServer <- mkAXI4_Lite_Master_Rd(1);
    mkConnection(wServer.fab, system.write);
    mkConnection(rServer.fab, system.read);

    Inout#(Bit#(1)) usbp = usb_core.usb_d_p; 
    Inout#(Bit#(1)) usbn = usb_core.usb_d_n; 

    // 
    Reg#(Bit#(8)) r <- mkReg(0);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(Bit#(8)) req <- mkReg(0);
    Reg#(State) s <- mkReg(Addr);
    FIFO#(Bit#(8)) to_host <- mkFIFO;

    rule reset_setup;
        cnt <= cnt + 1;
        let reset = ~rcnt[5];
        rcnt <= rcnt + zeroExtend(reset);
        usb_core.reset(reset);
    endrule
    /*  */
    rule pull_respW;
        let x <- wServer.response.get();
    endrule

    rule get_w if (s == Addr);
        Bit#(8) addr = 0;
        if (usb_core.uart_out_ready() == 1) begin
            addr <- usb_core.uart_out();

            r <= addr;
            let newaddr = 0;
            /* to_host.enq(addr); */
            if (addr[7] == 1) begin 
                newaddr = addr;
            end else begin 
                if (req[7] != 1)
                rServer.request.put(AXI4_Lite_Read_Rq_Pkg{addr: zeroExtend(addr[6:0]), prot: unpack(0)});
            end
            if (req[7] == 1)  begin 
                wServer.request.put(AXI4_Lite_Write_Rq_Pkg{addr: zeroExtend(req[6:0]), data: zeroExtend(addr), strb: -1, prot: unpack(0)});
                newaddr = 0;
            end 
            req <= newaddr;
        end
    endrule


    rule output_uart;
        usb_core.uart_in(to_host.first());
            if (usb_core.uart_in_ready() == 1) 
                to_host.deq();
    endrule


    rule yo; 
        let datamem_aux <- rServer.response.get();
        Bit#(32) datamem = datamem_aux.data;
        to_host.enq(truncate(datamem));
    endrule



    method Bit#(1) rgb_led0_r();
        return ~pack(cnt < r);
    endmethod

    method Bit#(1) rgb_led0_g();
        return ~pack(cnt < g);
    endmethod

    method Bit#(1) rgb_led0_b();
        return ~pack(cnt < b);
    endmethod

    method Bit#(1) pin_pu;
        return 1;
    endmethod
    
    interface usb = interface Usb;
        interface pin_usb_p = usbp;
        interface pin_usb_n = usbn;
    endinterface;

    interface dram = system.dram;        

endmodule
