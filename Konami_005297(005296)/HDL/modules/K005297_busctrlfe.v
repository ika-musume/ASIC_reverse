module K005297_busctrlfe
(
    //master clock
    input   wire            i_MCLK,

    //clock enables
    input   wire            i_CLK4M_PCEN_n,
    input   wire            i_CLK2M_PCEN_n,

    //timing
    input   wire    [7:0]   i_ROT8,

    //control
    input   wire            i_DMA_ACT,
    input   wire            i_DMA_WR_ACT_n,
    output  wire            o_DMA_R_nW,

    //bus control
    output  wire            o_UDS_n,
    output  wire            o_LDS_n,
    output  wire            o_AS_n,
    output  wire            o_R_nW
);

//DMA RW mode indicator
assign          o_DMA_R_nW = (i_DMA_WR_ACT_n == 1'b0) ? 1'b0 : 1'b1; //write : read


//DATA STROBE(UDS+LDS)
wire            data_strobe_set_n = (i_DMA_WR_ACT_n == 1'b0) ? ~i_ROT8[4] : ~i_ROT8[2]; //write : read
wire            data_strobe_reset_n = (i_DMA_WR_ACT_n == 1'b0) ? (~i_ROT8[6] & i_DMA_ACT) : (~i_ROT8[7] & i_DMA_ACT); //write : read
wire            data_strobe_n;
assign          o_UDS_n = data_strobe_n;
assign          o_LDS_n = data_strobe_n;

SRNAND C43 (.i_CLK(i_MCLK), .i_CEN_n(i_CLK4M_PCEN_n), .i_S_n(data_strobe_set_n), .i_R_n(data_strobe_reset_n), .o_Q(), .o_Q_n(data_strobe_n));


//ADDRESS STROBE
wire            addr_strobe_set_n = ~i_ROT8[2];
wire            addr_strobe_reset_n = ~i_ROT8[7] & i_DMA_ACT;

SRNAND C68 (.i_CLK(i_MCLK), .i_CEN_n(i_CLK4M_PCEN_n), .i_S_n(addr_strobe_set_n), .i_R_n(addr_strobe_reset_n), .o_Q(), .o_Q_n(o_AS_n));


//R/W
wire            bus_read_n = (~i_ROT8[7] & i_DMA_ACT) & ~(i_ROT8[2] & o_DMA_R_nW);
wire            bus_write_n = ~i_ROT8[2] | ~(~o_DMA_R_nW & i_DMA_ACT);

SRNAND C53 (.i_CLK(i_MCLK), .i_CEN_n(i_CLK4M_PCEN_n), .i_S_n(bus_write_n), .i_R_n(bus_read_n), .o_Q(), .o_Q_n(o_R_nW));


endmodule