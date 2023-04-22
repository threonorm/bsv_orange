import BlueAXI::*;

interface Usb;
    interface Inout#(Bit#(1)) usb_d_p;
    interface Inout#(Bit#(1)) usb_d_n;
    /* interface Inout#(Bit#(1)) usb_pullup; */
endinterface

(* always_ready, always_enabled *)
interface UsbCore;
    interface Inout#(Bit#(1)) usb_d_p;
    interface Inout#(Bit#(1)) usb_d_n;
    method Action reset(Bit#(1) rst_i);
    /* interface Inout#(Bit#(1)) usb_pullup; */

    interface AXI4_Lite_Master_Rd_Fab#(32, 32) axird;
    interface AXI4_Lite_Master_Wr_Fab#(32, 32) axiwr;
endinterface


// Import BVI for the usb_bridge_top
import "BVI" usb_bridge_top =
module mkUsbCore(UsbCore ifc);
    Bit#(3) defaultproto = 0;
    default_clock clk (clk_i);
    default_reset no_reset;
    /* default_reset rst (rst_i); */

    ifc_inout usb_d_p(usb_dp_io);// = usb_d_p;
    ifc_inout usb_d_n(usb_dn_io);// = usb_d_n;
    /* ifc_inout usb_pullup(usb_pullup); */

    method reset(rst_i) enable((*inhigh*) EN_rst_i);
    interface  AXI4_Lite_Master_Rd_Fab axird;
        method axi_arvalid_o arvalid;
        method parready(axi_arready_i) enable ((*inhigh*) EN_axi_arready_i);
        method axi_araddr_o araddr;
        // Hardcode prot to 0
        method axi_arprot_o arprot;

        method axi_rready_o rready;
        method prvalid(axi_rvalid_i)  enable ((*inhigh*) EN_axi_rvalid_i);
        method prdata(axi_rdata_i) enable ((*inhigh*) EN_axi_rdata_i);
        method prresp(axi_rresp_i) enable ((*inhigh*) EN_axi_rresp_i);
    endinterface

    interface  AXI4_Lite_Master_Wr_Fab axiwr;
        method pawready(axi_awready_i) enable ((*inhigh*) EN_axi_awready_i);
    	method axi_awvalid_o awvalid;
    	method axi_awaddr_o awaddr;
        // Hardcode prot to 0
    	method axi_awprot_o awprot;
    
    	method pwready(axi_wready_i) enable ((*inhigh*) EN_axi_wready_i);
    	method axi_wvalid_o wvalid;
    	method axi_wdata_o wdata;
    	method axi_wstrb_o wstrb;
    
    	method pbvalid(axi_bvalid_i) enable ((*inhigh*) EN_axi_bvalid_i);
    	method axi_bready_o bready;
    	method pbresp(axi_bresp_i) enable ((*inhigh*) EN_axi_bresp_i);
    endinterface
    schedule (reset,
                axird_arvalid, axird_parready, axird_araddr,
            axird_arprot,
            axird_rready, axird_prvalid, axird_prdata, axird_prresp,
              axiwr_pawready, axiwr_awvalid, axiwr_awaddr, 
          axiwr_awprot,
            axiwr_pwready, axiwr_wvalid, axiwr_wdata, axiwr_wstrb, axiwr_pbvalid, axiwr_bready, axiwr_pbresp)
              CF
            (reset,
                    axird_arvalid, axird_parready, axird_araddr, 
                axird_arprot,
                axird_rready, axird_prvalid, axird_prdata, axird_prresp,
              axiwr_pawready, axiwr_awvalid, axiwr_awaddr, 
            axiwr_awprot,
        axiwr_pwready, axiwr_wvalid, axiwr_wdata, axiwr_wstrb, axiwr_pbvalid, axiwr_bready, axiwr_pbresp);


endmodule


