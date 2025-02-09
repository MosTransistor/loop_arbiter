`timescale 1ns/1ps

module tb_arb();

    initial begin
        $dumpfile("arb.vcd");
        $dumpvars(0, tb_arb );
    end

    parameter RN = 11;
    
    integer fh, seed;
    
    logic              clk=0;
    logic              rst_n=0;
    logic              t_arb_en=0;
    logic   [RN-1:0]   t_req=0;
    logic   [RN-1:0]   t_grant;
    
    int shadow_priority[RN];

    loop_arb #(.REQ_NUM(RN)) i_dut(.clk(clk), .rst_n(rst_n), .arb_en(t_arb_en), .req(t_req), .grant(t_grant));

    always #5 clk = ~clk;

    initial begin
        // generate random seed
        fh = $fopen("random.txt", "r");
        $fscanf(fh, "%d", seed);
        $fclose(fh);
        void'($urandom(seed));      
        
        // release reset
        repeat (2) @(negedge clk);
        rst_n = 1;
    end
    
    initial begin
        wait(rst_n);
        init_shadow_pri();
        
        // random test
        repeat(200) begin
            apply_random_test();
        end
        
        $display("All random tests completed successfully");
        $finish;
    end
    
    // Initialize shadow priority to match DUT
    function void init_shadow_pri();
        foreach(shadow_priority[i])
            shadow_priority[i] = i;
    endfunction

    // Generate and apply random test
    task apply_random_test();
        bit [RN-1:0] req;
        bit [RN-1:0] ref_grant;
        
        // Randomize with at least one request (90% probability)
        //std::randomize(req) with {
        //    req dist {0 := 1, [1:255] := 9};
        //};
        if (($urandom(seed) % 10) == 0)
            req = 0;
        else
            req = $urandom(seed) % (2**RN) + 1;
        
        @(posedge clk);
        t_req = req;
        ref_grant = predict_grant(req);
        @(negedge clk);  // Wait for response
        
        // Verify results
        if (t_grant !== ref_grant) begin
            $error("Grant mismatch!\nRequest: %b\nExp: %b\nGot: %b",
                  req, ref_grant, t_grant);
            $finish;
        end
        
        if (t_grant != 0) begin
            update_shadow_priority(ref_grant);
        end
    endtask

    // Predict grant based on shadow priority
    function bit [RN-1:0] predict_grant(bit [RN-1:0] req);
        predict_grant = 0;
        foreach(shadow_priority[i]) begin
            if (req[shadow_priority[i]]) begin
                predict_grant = (1 << shadow_priority[i]);
                return predict_grant;
            end
        end
    endfunction
    
    
    // Update shadow priority after valid grant
    function void update_shadow_priority(bit [RN-1:0] grant);
        int idx;
        idx = $clog2(grant);
        foreach(shadow_priority[i]) begin: loop_label2
            if (shadow_priority[i] == idx) begin
                for (int j = i; j < RN-1; j++)
                    shadow_priority[j] = shadow_priority[j+1];
                shadow_priority[RN-1] = idx;
                //break;
                disable loop_label2;
            end
        end
    endfunction

endmodule