import BlueAXI::*;
import UsbCoreWrapper::*;
import Connectable::*;
import GetPut::*;


interface OrangeCrab;
    (* prefix = "" *)
    interface Usb usb;

    (* always_ready, prefix = "" *)
    interface Bit#(1) usb_pullup;
    
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_r();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_g();
    (* always_ready, prefix = "" *)
    method Bit#(1) rgb_led0_b();

endinterface


// Import BVI for the usb_bridge_top
(* synthesize, default_clock_osc = "clk48", default_reset = "rst_n" *)
module top(OrangeCrab ifc);
    Reg#(Bit#(16)) cnt <- mkReg(0);
    UsbCore usb_core <- mkUsbCore();
    AXI4_Lite_Slave_Rd#(32,32) rd <- mkAXI4_Lite_Slave_Rd(0);
    AXI4_Lite_Slave_Wr#(32,32) wr <- mkAXI4_Lite_Slave_Wr(0);

    mkConnection(usb_core.axird,rd.fab);
    mkConnection(usb_core.axiwr,wr.fab);

    Reg#(Bit#(16)) r <- mkReg(0);
    Reg#(Bit#(16)) g <- mkReg(0);
    Reg#(Bit#(16)) b <- mkReg(0);


    Inout#(Bit#(1)) usbp = usb_core.usb_d_p; 
    Inout#(Bit#(1)) usbn = usb_core.usb_d_n; 


    rule tic;
        cnt <= cnt + 1;
        usb_core.reset(pack(cnt>3));
    endrule

    rule get_rd if (cnt > 5);
        let req <- rd.request.get();
        //If the read request is 0
        case (req.addr)
            0:   rd.response.put(AXI4_Lite_Read_Rs_Pkg {data: zeroExtend(r), resp: tagged OKAY});
            1:   rd.response.put(AXI4_Lite_Read_Rs_Pkg {data: zeroExtend(g), resp: tagged OKAY});
            2:   rd.response.put(AXI4_Lite_Read_Rs_Pkg {data: zeroExtend(b), resp: tagged OKAY});
        endcase
    endrule

    rule get_wr  if (cnt > 5);
        let req <- wr.request.get();
        //If the read request is 0
        case (req.addr)
        0:  begin 
                r <= truncate(req.data);
                wr.response.put(AXI4_Lite_Write_Rs_Pkg{ resp:tagged OKAY});
            end 
        1:  begin 
                g <= truncate(req.data);
                wr.response.put(AXI4_Lite_Write_Rs_Pkg{ resp:tagged OKAY});
            end
        2:  begin 
                b <= truncate(req.data);
                wr.response.put(AXI4_Lite_Write_Rs_Pkg{ resp:tagged OKAY});
            end
        endcase
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
