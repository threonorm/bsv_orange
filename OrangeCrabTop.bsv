import UsbByte::*;
import GetPut::*;
import Orange::*;


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
    UsbCore usb_core <- mkUsbCore();
    GsdOrange system <- mkGsdOrange();
    AXI4_Lite_Master_Wr#(32,32,1) wServer <- mkAXI4_Lite_Master_Wr;
    AXI4_Lite_Master_Rd#(32,32) rServer <- mkAXI4_Lite_Master_Rd;
    mkConnection(wServer.fab, system.write);
    mkConnection(rServer.fab, system.read);

    Inout#(Bit#(1)) usbp = usb_core.usb_d_p; 
    Inout#(Bit#(1)) usbn = usb_core.usb_d_n; 

    Reg#(Bit#(8)) r <- mkReg(0);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(Bit#(8)) req <- mkReg(0);
    Reg#(State) s <- mkReg(Addr);

    rule reset_setup;
        cnt <= cnt + 1;
        if (rcnt < 10) rcnt <= rcnt + 1;
        usb_core.reset(pack(rcnt<10));
    endrule

    rule pull_respW;
        let x <- wServer.response.get();
    endrule

    rule get_w if (s == Addr);
        let addr <- usb_core.uart_out();
        req <= addr;
        s <= Data;

        if (addr[7] == 0) begin 
            rServer.request.put(AXI4_Lite_Read_Rq_Pkg{addr: zeroExtend(addr[6:0]), prot: 0});
    endrule

    rule get_d if (s == Data);
        let datauart <- usb_core.uart_out();
        if (req[7] == 1) begin 
            wServer.request.put(AXI4_Lite_Write_Rq_Pkg{addr: zeroExtend(req[6:0]), data: zeroExtend(datauart), strb: -1, prot: 0});
        end else 
         begin
            let datamem_aux <- rServer.response.get()
            Bit#(32) datamem = datamem_aux.data;
            case (datauart)
            /* pack('r'): begin  */
            8'd114: begin 
                r <= truncate(datamem);
                end
            /* pack('g'): begin  */
            8'd103: begin 
                g <= truncate(datamem);
                end
            /* pack('b'): begin  */
            8'd98: begin 
                b <= truncate(datamem);
                end
       endcase

       end
       s <= Data;
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
    endinterface;

    /* method Action      ddram_dqs_n(Bit#(2) ddram_dqs_n); */
    /* method Action            ddram_clk_n; */
endmodule
