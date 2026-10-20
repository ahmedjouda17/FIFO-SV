quit -sim
vdel -all -lib work
vlib work
vlog -sv shared_pkg.sv
vlog -sv FIFO_transaction.sv
vlog -sv FIFO_coverage.sv
vlog -sv FIFO_scoreboard.sv
vlog -sv FIFO_interface.sv
vlog -sv +define+SIM FIFO.sv
vlog -sv FIFO_monitor.sv
vlog -sv FIFO_tb.sv
vlog -sv FIFO_top.sv
vsim -voptargs=+acc FIFO_top
run -all