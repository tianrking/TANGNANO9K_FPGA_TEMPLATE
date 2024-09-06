Lushay code   change top module name to top


1. 进入工程目录:
```
cd uart_loopback
```

2. 综合(Synthesis):
```
yosys -p "read_verilog src/uart_loop_back.v src/uart_rx.v src/uart_tx.v; synth_gowin -top uart_loop_back -json impl/uart_loopback.json"
```

3. 布局布线(Place and Route):
```  
nextpnr-gowin --json impl/uart_loopback.json --freq 27 --write impl/uart_loopback_pnr.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst src/uart_loopback.cst
```

4. 生成比特流(Generate Bitstream):
```
gowin_pack -d GW1N-9C -o impl/uart_loopback.fs impl/uart_loopback_pnr.json  
```

5. 烧录FPGA(Program FPGA):
```
openFPGALoader -b tangnano9k -f impl/uart_loopback.fs
```

