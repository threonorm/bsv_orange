import UsbByte::*;
import GetPut::*;
import Litedram::*;

interface DramPins;
    // We removed ddram_dqs_n and  ddram_clk_n
    (* always_ready, prefix = "" *)
    method Bit#(13) ddram_a;
    (* always_ready, prefix = "" *)
    method Bit#(3) ddram_ba;
    (* always_ready, prefix = "" *)
    method Bit#(1)          ddram_ras_n;
    (* always_ready, prefix = "" *)
    method Bit#(1)          ddram_cas_n;
    (* always_ready, prefix = "" *)
    method Bit#(1)          ddram_we_n;
    (* always_ready, prefix = "" *)
    method Bit#(1)          ddram_cs_n;
    (* always_ready, prefix = "" *)
    method Bit#(2) ddram_dm;
    (* always_ready, always_enabled, prefix = "" *)
    method Action      ddram_dq(Bit#(16) ddram_dq);
    (* always_ready, always_enabled, prefix = "" *)
    method Action       ddram_dqs_p(Bit#(2) ddram_dqs_p);
    (* always_ready, prefix = "" *)
    method Bit#(1)           ddram_clk_p;
    (* always_ready,  prefix = "" *)
    method Action           ddram_cke;
    (* always_ready,  prefix = "" *)
    method Action           ddram_odt;
    (* always_ready,  prefix = "" *)
    method Action           ddram_reset_n;
endinterface


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
    Clock clk <- exposeCurrentClock;
    Reset rst <- exposeCurrentReset;
    Litedram litedram <- mkLitedram(clk,rst);
    Inout#(Bit#(1)) usbp = usb_core.usb_d_p; 
    Inout#(Bit#(1)) usbn = usb_core.usb_d_n; 

    Reg#(Bit#(8)) r <- mkReg(0);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(Bit#(8)) req <- mkReg(0);
    Reg#(State) s <- mkReg(Addr);

    rule placeholder;
        litedram.wb_ctrl_adr(?);
        litedram.wb_ctrl_dat_w(?);
        litedram.wb_ctrl_sel(?);
        litedram.wb_ctrl_cti(?);
        litedram.wb_ctrl_bte(?);
    endrule
    rule reset_setup;
        cnt <= cnt + 1;
        if (rcnt < 10) rcnt <= rcnt + 1;
        usb_core.reset(pack(rcnt<10));
    endrule

    rule get_w if (s == Addr);
        let addr <- usb_core.uart_out();
        req <= addr;
        s <= Data;
    endrule

    rule get_d if (s == Data);
        let data <- usb_core.uart_out();
        case (req)
        /* pack('r'): begin  */
        8'd114: begin 
            r <= data;
            end
        /* pack('g'): begin  */
        8'd103: begin 
            g <= data;
            end
        /* pack('b'): begin  */
        8'd98: begin 
            b <= data;
            end
       endcase
       s <= Addr;
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
        /* interface usb_pullup = ;  */
    endinterface;
    interface dram = litedram.ddr_pins;
endmodule
