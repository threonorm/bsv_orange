import 
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
endinterface

interface GsdOrange;
    (* prefix = "" *)
    interface DramPins dram;
   
    (* prefix = "axi" *)
    interface AXI4_Lite_Master_Rd_Fab read;
    (* prefix = "axi" *)
    interface AXI4_Lite_Master_Wr_Fab write;
endinterface

import "BVI" gsd_orangecrab =
module mkLitedram(Clock clk, Reset rst, Litedram ifc);
    default_clock clk(clk48);
    default_reset rst(rst_n);
  
endmodule
