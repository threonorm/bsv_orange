import UsbByte::*;
import GetPut::*;


interface OrangeCrab;
    (* prefix = "" *)
    interface Usb usb;

    (* always_ready, prefix = "" *)
    interface Bit#(1) pin_pu;
    
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_r();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_g();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_b();

endinterface
typedef enum {Addr, Data} State deriving (Eq,Bits);

// Import BVI for the usb_bridge_top
(* synthesize, default_clock_osc = "clk48", default_reset = "rst_n" *)
module top(OrangeCrab ifc);
    Reg#(Bit#(8)) cnt <- mkReg(0);
    Reg#(Bit#(16)) rcnt <- mkReg(0);
    UsbCore usb_core <- mkUsbCore();
    Inout#(Bit#(1)) usbp = usb_core.usb_d_p; 
    Inout#(Bit#(1)) usbn = usb_core.usb_d_n; 

    Reg#(Bit#(8)) r <- mkReg(0);
    Reg#(Bit#(8)) g <- mkReg(0);
    Reg#(Bit#(8)) b <- mkReg(0);
    Reg#(Bit#(2)) req <- mkReg(0);
    Reg#(State) s <- mkReg(Addr);

    rule reset_setup;
        cnt <= cnt + 1;
        if (rcnt < 10) rcnt <= rcnt + 1;
        usb_core.reset(pack(rcnt<10));
    endrule

    rule get_w if (s == Addr);
        let addr <- usb_core.uart_out();
        case (addr)
        pack('r'): begin 
            req <= 0;
            end
        pack('g'): begin 
            req <= 1;
            end
        pack('b'): begin 
            req <= 2;
            end
       endcase
       s <= Data;
    endrule

    rule get_w if (s == Data);
        let data <- usb_core.uart_out();
        case (req)
        pack('r'): begin 
            r <= data;
            end
        pack('g'): begin 
            g <= data;
            end
        pack('b'): begin 
            b <= data;
            end
       endcase
       s <= Addr;
    endrule


    method Bit#(1) rgb_led0_r();
        return pack(cnt < r);
    endmethod

    method Bit#(1) rgb_led0_g();
        return pack(cnt < g);
    endmethod

    method Bit#(1) rgb_led0_b();
        return pack(cnt < b);
    endmethod

    method Bit#(1) usb_pullup;
        return 1;
    endmethod
    
    interface usb = interface Usb;
        interface usb_d_p = usbp;
        interface usb_d_n = usbn;
        /* interface usb_pullup = ;  */
    endinterface;
endmodule
