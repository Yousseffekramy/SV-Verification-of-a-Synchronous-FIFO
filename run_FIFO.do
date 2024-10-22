vlib work

vlog -f src_files.list +cover -covercells +define+SIM

vsim -voptargs=+acc work.FIFO_top -cover

add wave /FIFO_top/FIFO_if/*  

add wave -position insertpoint  \
sim:/FIFO_top/MONITOR/FIFO_sb

coverage save FIFO.ucdb -onexit

run -all

# vcover report FIFO.ucdb -details -annotate -all -output FIFO.txt