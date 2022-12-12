module polynom_solver_top
(
	input clk,
	input reset_n,
	input start,
	input [1:0] sw,
	output [3:0] sel,
	output [7:0] sseg
);

wire start_db;
wire [3:0] bcd0,bcd1,bcd2,bcd3;
reg calc_start; wire calc_done; reg bcd_start; wire bcd_done;
wire [19:0] calc_out;
// component instantiation
db_fsm db_fsm_inst
(.clk(clk), .reset_n(reset_n), .sw(!start), 
	 .db(start_db));

polynom_solver polynom_solver_inst
(.clk(clk), .reset_n(reset_n), .start(calc_start),
     .done_tick(calc_done), .in(~sw), .out(calc_out));

bin2bcd bin2bcd_unit
 (.clk(clk), .reset_n(reset_n), .start(bcd_start),
     .bin(calc_out[13:0]), .ready(), .done_tick(bcd_done),
     .bcd3(bcd3), .bcd2(bcd2), .bcd1(bcd1), .bcd0(bcd0));

disp_hex_mux disp_unit
(.clk(clk), .reset_n(reset_n), .active(1), .mesg(0), .dp_in(4'b1111),
     .hex3(bcd3), .hex2(bcd2), .hex1(bcd1), .hex0(bcd0),
     .an(sel), .sseg(sseg));


localparam [1:0] idle=2'b00,
calc=2'b01,
bin2bcd=2'b10;

reg [1:0] current_state,next_state;

always @(posedge clk or negedge reset_n)
begin
	if(!reset_n)
		current_state <= idle;
	else
		current_state <= next_state;
end

always @(*)
begin
	next_state = current_state;
	calc_start = 0;
	bcd_start = 0;
	case(current_state)
		idle:
			if(start_db)
			begin
				calc_start = 1;
				next_state = calc;
			end
		calc:
		begin
			if(calc_done)
			begin
				next_state = bin2bcd;
				bcd_start = 1;
			end
		end
		bin2bcd:
			if(bcd_done)
				next_state=idle;
	endcase
end
endmodule