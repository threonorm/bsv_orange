interface Dram;
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
    method Action      ddram_dq(Bit#(16) i);
    (* always_ready, always_enabled, prefix = "" *)
    method Action       ddram_dqs_p(Bit#(2) i);
    (* always_ready, always_enabled, prefix = "" *)
    method Action      ddram_dqs_n(Bit#(2) i);
    (* always_ready, prefix = "" *)
    method Bit#(1)           ddram_clk_p;
    (* always_ready, always_enabled, prefix = "" *)
    method Action            ddram_clk_n(Bit#(1) i);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_cke(Bit#(1) i);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_odt(Bit#(1) i);
    (* always_ready, always_enabled, prefix = "" *)
    method Action           ddram_reset_n(Bit#(1) i);
endinterface

interface Literam;
    (* always_ready, prefix = "" *)
    method Bit#(1) pll_locked();
    (* prefix = "" *)
    interface Dram ddr_pins;

    method Action user_command(Bit#(23) addr, Bit#(1) we);
    method Action write(Bit#(128) data, Bit#(16) we);
    method ActionValue#(Bit#(128)) read();

    interface Clock user_clk;
    interface Reset user_rst; 
endinterface

import "BVI" litedram =
module mkLitedram(Litedram);
endmodule
