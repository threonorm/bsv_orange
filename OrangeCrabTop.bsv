import UsbByte::*;
import GetPut::*;
import Orange::*;
import AXI4_Lite_Master::*;
import AXI4_Lite_Slave::*;
import AXI4_Lite_Types::*;
import Connectable::*;
import DefaultValue::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import BRAM::*;


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

typedef enum {Kind, AddrRead, AddrWrite, Data} State deriving (Eq,Bits);

// Import BVI for the usb_bridge_top
(* synthesize, default_clock_osc = "pin_clk", default_reset = "usr_btn" *)
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

    /* BRAM_Configure cfg = defaultValue(); */
    /* BRAM2PortBE#(Bit#(8), Bit#(32), 4) bram <- mkBRAM2ServerBE(cfg); */

    Reg#(Bit#(8)) r <- mkReg(255);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(Bit#(8)) req <- mkReg(0);
    Reg#(State) s <- mkReg(Kind);
    FIFO#(Bit#(8)) to_host <- mkFIFO;
    FIFOF#(Bit#(8)) from_host <- mkSizedFIFOF(8);

    rule reset_setup;
        cnt <= cnt + 1;
        let reset = ~rcnt[5];
        rcnt <= rcnt + zeroExtend(reset);
        usb_core.reset(reset);
    endrule

    rule pull_respW;
        let x <- wServer.response.get();
    endrule

    rule get_k ;
        Bit#(8) addr = 0;
        if (from_host.notFull) begin
            addr <- usb_core.uart_out();
            if (usb_core.uart_out_ready() == 1) begin 
                from_host.enq(addr);
                r <= ~r;
            end
        end
    endrule

    rule color;
        case (s)
            Kind:  b <= 255;
            AddrRead: b <= 128;
            AddrWrite: b <= 64;
            Data: b <= 0;
        endcase
    endrule

    rule start if (s == Kind);
        let addr = from_host.first();
        from_host.deq();
        if (addr == 0) s <= AddrRead;
        else s <= AddrWrite;
    endrule

    rule get_r if (s==AddrRead);
        Bit#(8) addr = 0;
        addr = from_host.first();
        from_host.deq();
        rServer.request.put(AXI4_Lite_Read_Rq_Pkg{addr: zeroExtend(addr[7:0]), prot: unpack(0)});
        /* bram.portA.request.put(BRAMRequestBE{ */
        /*         writeen: 0, */
        /*         responseOnWrite: False, */
        /*         address:addr, */
        /*         datain: ?}); */
        s <= Kind;
    endrule
    
    rule yo; 
        let datamem_aux <- rServer.response.get();
        /* let datamem_aux <- bram.portA.response.get(); */
        Bit#(32) datamem = datamem_aux.data;
        to_host.enq(truncate(datamem));
    endrule
    
    
    rule get_wa if (s==AddrWrite);
        Bit#(8) addr = 0;
        addr = from_host.first();
        from_host.deq();
        req <= addr;
        s <= Data;
    endrule
    
    rule get_wd if (s==Data);
        Bit#(8) addr = 0;
        addr = from_host.first();
        from_host.deq();
        /* bram.portA.request.put(BRAMRequestBE{ */
        /*         writeen: -1, */
        /*         responseOnWrite: False, */
        /*         address:req, */
        /* datain: zeroExtend(addr)}); */
        wServer.request.put(AXI4_Lite_Write_Rq_Pkg{addr: zeroExtend(req[6:0]), data: zeroExtend(addr), strb: -1, prot: unpack(0)});
        s <= Kind;
    endrule
    
    
    rule output_uart;
        usb_core.uart_in(to_host.first());
        if (usb_core.uart_in_ready() == 1) 
            to_host.deq();
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
