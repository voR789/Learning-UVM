module apb_math_peripheral (
    input  logic        pclk,
    input  logic        presetn,
    input  logic        psel,
    input  logic        penable,
    input  logic        pwrite,
    input  logic [7:0]  paddr,
    input  logic [31:0] pwdata,
    output logic [31:0] prdata,
    output logic        pready,
    output logic        pslverr
);
    logic       enable;
    logic [7:0] gain;
    logic [7:0] result;
    logic       done;
    logic       overflow;
    logic [1:0] busy_count;
    logic [7:0] pending_data;
    logic [7:0] pending_gain;
    logic [15:0] product;

    always_comb begin
        pready = 1'b1;
        prdata = '0;
        pslverr = 1'b0;
        if (psel && penable) begin
            case (paddr)
                8'h00: prdata = {31'b0, enable};
                8'h04: prdata = {24'b0, gain};
                8'h08: begin
                    if (!pwrite)
                        pslverr = 1'b1;
                end
                8'h0C: begin
                    prdata = {29'b0, overflow, done, (busy_count != 0)};
                    if (pwrite)
                        pslverr = 1'b1;
                end
                8'h10: begin
                    prdata = {24'b0, result};
                    if (pwrite)
                        pslverr = 1'b1;
                end
                default: pslverr = 1'b1;
            endcase
            if (pwrite && (paddr == 8'h08) &&
                (!enable || (busy_count != 0)))
                pslverr = 1'b1;
        end
    end

    always_ff @(posedge pclk) begin
        if (!presetn) begin
            enable <= 1'b0;
            gain <= 8'h01;
            result <= '0;
            done <= 1'b0;
            overflow <= 1'b0;
            busy_count <= '0;
            pending_data <= '0;
            pending_gain <= '0;
        end else begin
            if (busy_count != 0) begin
                busy_count <= busy_count - 1'b1;
                if (busy_count == 1) begin
                    product = pending_data * pending_gain;
                    if (product > 16'h00FF) begin
                        result <= 8'hFF;
                        overflow <= 1'b1;
                    end else begin
                        result <= product[7:0] + 1'b1;
                        overflow <= 1'b0;
                    end
                    done <= 1'b1;
                end
            end
            if (psel && penable && pready && !pslverr && pwrite) begin
                case (paddr)
                    8'h00: enable <= pwdata[0];
                    8'h04: gain <= pwdata[7:0];
                    8'h08: begin
                        pending_data <= pwdata[7:0];
                        pending_gain <= gain;
                        busy_count <= 2;
                        done <= 1'b0;
                        overflow <= 1'b0;
                    end
                    default: begin
                    end
                endcase
            end
        end
    end
endmodule
