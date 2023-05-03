import BlueAXI::*;

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
    (* always_ready, always_enabled,  prefix = "" *)
    method Action           ddram_cke(Bit#(1) ddram_cke);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_odt(Bit#(1) ddram_odt);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_reset_n(Bit#(1) ddram_reset_n);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_vccio(Bit#(6) ddram_vccio);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_gnd(Bit#(2) ddram_gnd);
endinterface

interface GsdOrange;
    interface DramPins dram;


    interface AXI4_Lite_Slave_Rd_Fab#(32,32) read;
    interface AXI4_Lite_Slave_Wr_Fab#(32,32) write;
endinterface

import "BVI" gsd_orangecrab =
module mkGsdOrange(GsdOrange);
    default_clock clk(clk48);
    default_reset rst(rst_n);
    interface DramPins dram;
        method ddram_a ddram_a;
        method ddram_ba  ddram_ba;
        method ddram_ras_n  ddram_ras_n;
        method ddram_cas_n  ddram_cas_n;
        method ddram_we_n  ddram_we_n;
        method ddram_cs_n  ddram_cs_n;
        method ddram_dm  ddram_dm;
        method ddram_dq(ddram_dq) enable ((* inhigh *)  EN_ddram_dq);
        method ddram_dqs_p(ddram_dqs_p) enable ((* inhigh *)  EN_ddram_dqs_p);
        method ddram_clk_p ddram_clk_p;
        method ddram_cke(ddram_cke) enable ((* inhigh *)  EN_ddram_cke);
        method ddram_odt(ddram_odt) enable ((* inhigh *)  EN_ddram_odt);
        method ddram_reset_n(ddram_reset_n) enable ((* inhigh *)  EN_ddram_reset_n);
        method ddram_vccio(ddram_vccio) enable ((* inhigh *) EN_ddram_vccio);
        method ddram_gnd(ddram_gnd) enable ((* inhigh *) EN_gnd);
    endinterface
     
    interface AXI4_Lite_Slave_Rd_Fab read;
        method axi_arready arready;
        method parvalid(axi_arvalid) enable ((*inhigh*) EN_arvalid);
        method paraddr(axi_araddr) enable ((*inhigh *) EN_araddr);
        method parprot(axi_arprot) enable ((*inhigh*) EN_arprot);

        method axi_rvalid rvalid;
        method prready(axi_rready) enable ((*inhigh*) EN_rready);
        method axi_rdata rdata();
        method axi_rresp rresp();
////////
        /* method axi_arvalid arvalid; */
        /* method parready(arready) enable ((* inhigh *) EN_arready); */
        /* method axi_araddr araddr; */
        /* method axi_arprot arprot; */
        /*  */
        /* method axi_rready rready; */
        /* method prvalid(axi_rvalid) enable ((*inhigh*) EN_rvalid); */
        /* method prdata(axi_rdata) enable ((*inhigh*) EN_rdata); */
        /* method prresp(axi_rresp) enable ((*inhigh*) EN_rresp); */
    endinterface

    interface AXI4_Lite_Slave_Wr_Fab write;
        method axi_awready awready;
        method pawvalid(axi_awvalid) enable ((* inhigh *) EN_awvalid);
        method pawaddr(axi_awaddr) enable ((* inhigh *) EN_awaddr);
        method pawprot(axi_awprot) enable ((* inhigh *) EN_awprot);

        method axi_wready wready;
        method pwvalid(axi_wvalid) enable((*inhigh*) EN_wvalid);
        method pwdata(axi_wdata) enable ((*inhigh*) EN_wdata);
        method pwstrb(axi_wstrb) enable ((*inhigh*) EN_wstrb);

        method axi_bvalid bvalid;
        method pbready(bready) enable ((*inhigh*) EN_bready);
        method axi_bresp bresp();
	    /*  */
	    /* method pawready(axi_awready) enable (* inhigh *) EN_awready); */
	    /* method axi_awvalid awvalid; */
	    /* method axi_awaddr awaddr; */
	    /* method axi_awprot awprot; */
	    /*  */
	    /* method pwready(axi_wready) enable ((*inhigh*) EN_wready); */
	    /* method axi_wvalid wvalid; */
	    /* method axi_wdata wdata; */
	    /* method axi_wstrb wstrb; */
	    /*  */
	    /* method pbvalid(axi_bvalid) enable ((* inhigh*) EN_bvalid ); */
	    /* method axi_bready bready; */
	    /* method pbresp(axi_bresp) enable ((*inhigh *) EN_bresp); */
    endinterface
endmodule
