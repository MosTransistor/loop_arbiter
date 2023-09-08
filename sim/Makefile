sim:
	iverilog -g2012 -o sim.o  ./tb_arb.sv ../src/loop_arb.v
	vvp sim.o

wave:
	gtkwave *.vcd

clean:
	rm -rf *.o *.vcd