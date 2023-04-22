/*
    USB Serial

    Wrapping usb/usb_uart_ice40.v to create a loopback.
*/

module usbserial_tbx (
        input  pin_clk,

        inout  pin_usb_p,
        inout  pin_usb_n,
        output pin_pu,

        output pin_led,

    );

    wire clk_48mhz = pin_clk;
    wire [3:0] debug;

    /* wire clk_locked; */
    
    // Use an icepll generated pll
    /* pll pll48( .clock_in(pin_clk), .clock_out(clk_48mhz), .locked( clk_locked ) ); */

    // LED
    reg [22:0] ledCounter;
    always @(posedge clk_48mhz) begin
        ledCounter <= ledCounter + 1;
    end
    assign pin_led = ledCounter[ 22 ];

    // Generate reset signal
    reg [5:0] reset_cnt = 0;
    wire reset = ~reset_cnt[5];
    always @(posedge clk_48mhz)
        /* if ( 1 ) */
            reset_cnt <= reset_cnt + reset;

    // uart pipeline in
    wire [7:0] uart_in_data;
    wire       uart_in_valid;
    wire       uart_in_ready;

    // assign debug = { uart_in_valid, uart_in_ready, reset, clk_48mhz };

    wire usb_p_tx;
    wire usb_n_tx;
    wire usb_p_rx;
    wire usb_n_rx;
    wire usb_tx_en;
    reg		[31 : 0]		reset_tick;
	reg					host_rst;

    // wire [11:0] debug_dum;
	localparam ticK_over = (48000000 / 300) - 1;


    // usb uart - this instanciates the entire USB device.
    usb_uart uart (
        .clk_48mhz  (clk_48mhz),
        .reset      (reset | host_rst),

        // pins
        .pin_usb_p( pin_usb_p ),
        .pin_usb_n( pin_usb_n ),

        // uart pipeline in
        .uart_in_data( uart_in_data + 1 ),
        .uart_in_valid( uart_in_valid ),
        .uart_in_ready( uart_in_ready ),

        .uart_out_data( uart_in_data ),
        .uart_out_valid( uart_in_valid ),
        .uart_out_ready( uart_in_ready  )

        //.debug( debug )
    );

    always@(posedge clk_48mhz)begin
		
		if(reset)begin
			
			host_rst <= 1'b0;
			reset_tick <= 'd0;
			
		end else begin
			if(!(usb_p_in | usb_n_in))begin
				if(reset_tick >= ticK_over)
					reset_tick <= 'd0;
				else
					reset_tick <= reset_tick + 'd1;
			end else begin
				reset_tick <= 'd0;
			end
			
			if(reset_tick >= ticK_over)
				host_rst <= 1'b1;
			else
				host_rst <= 1'b0;
		end
	end



    // USB Host Detect Pull Up
    assign pin_pu = 1'b1;

endmodule
