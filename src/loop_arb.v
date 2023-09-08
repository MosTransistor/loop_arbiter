`define RD 1ns

module loop_arb #(
    parameter  REQ_NUM = 7
) (
    input   logic                   clk     ,
    input   logic                   rst_n   ,
    input   logic                   arb_en  ,
    input   logic  [REQ_NUM-1:0]    req     ,
    output  logic  [REQ_NUM-1:0]    grant
);

localparam N = REQ_NUM;
localparam W = $clog2(REQ_NUM);

logic [W-1:0] mst_pri_c[N];
logic [W-1:0] mst_pri[N];
logic [W-1:0] hit_pri;
logic [N-1:0] req_sft;
logic [N-1:0] grant_raw;

generate
    genvar i;
    for(i=0;i<N;i=i+1) begin: MASTER_PRIORITY
        // last grant bit become lowest priority, other keep priority
        // 3210 -> (2 grant) -> 2310 -> (0 grant) -> 0231
        always @(*) begin
            if (|req) begin
                if (i == N-1) begin
                    mst_pri_c[i] = mst_pri[hit_pri];
                end
                else if (i >= hit_pri) begin
                    mst_pri_c[i] = mst_pri[i+1];
                end
                else begin
                    mst_pri_c[i] = mst_pri[i];
                end
            end
            else begin
                mst_pri_c[i] = mst_pri[i];
            end
        end

        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                mst_pri[i] <= #`RD i;
            end
            else begin
                mst_pri[i] <= #`RD mst_pri_c[i];
            end
        end
        assign req_sft[i] = req[mst_pri[i]];
    end
endgenerate

assign grant_raw = req_sft & (~(req_sft-1));

assign hit_pri = onehot2bin(grant_raw);

assign grant = (|req) ? 1'b1 << mst_pri[hit_pri] : {N{1'b0}};

function integer onehot2bin(input integer onehot);
    integer i;
    onehot2bin = 0;
    for (i=0; i<N; i=i+1) begin
        if (onehot[i]) onehot2bin = i;
    end
endfunction

endmodule