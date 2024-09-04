TangNano9K


1. Install Dependencies:
```
sudo apt-get update
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev git cmake libboost-all-dev libeigen3-dev \
libftdi1-2 libftdi1-dev libhidapi-hidraw0 libhidapi-dev \
libudev-dev zlib1g-dev pkg-config g++ clang bison flex \
gawk tcl-dev graphviz xdot pkg-config zlib1g-dev
```

2. Install pyenv and Python:
```
curl https://pyenv.run | bash
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n eval "$(pyenv init -)"\nfi' >> ~/.bashrc
source ~/.bashrc
pyenv install 3.9.13
pyenv global 3.9.13
```

3. Install Apicula:
```
pip install apycula
```

4. Install Yosys:
```
git clone https://github.com/YosysHQ/yosys.git
cd yosys
make
sudo make install
```

5. Install nextpnr:
```
cd ~
git clone https://github.com/YosysHQ/nextpnr.git
cd nextpnr
cmake . -DARCH=gowin -DGOWIN_BBA_EXECUTABLE=`which gowin_bba`
make
sudo make install
```

6. Install openFPGALoader:
```
cd ~
git clone https://github.com/trabucayre/openFPGALoader.git
cd openFPGALoader
mkdir build
cd build
cmake ../
cmake --build .
sudo make install
```

Using the Toolchain:

1. Synthesis (using Yosys):
```
yosys -p "read_verilog counter.v; synth_gowin -top counter -json counter.json"
```

2. Place and Route (using nextpnr):
```
nextpnr-gowin --json counter.json --freq 27 --write counter_pnr.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst tangnano9k.cst
```

3. Generate Bitstream (using gowin_pack):
```
gowin_pack -d GW1N-9C -o counter.fs counter_pnr.json
```

4. Program FPGA (using openFPGALoader):
```
openFPGALoader -b tangnano9k -f counter.fs
```

Each step in this process serves a specific purpose:

1. Synthesis: Converts high-level HDL to a gate-level netlist.
2. Place and Route: Maps the logical design to the physical FPGA layout.
3. Bitstream Generation: Creates a binary file that configures the FPGA.
4. Programming: Loads the bitstream onto the physical FPGA device.

This workflow allows for the transformation of a high-level hardware description into a working implementation on an FPGA, with each step reducing the level of abstraction until the design is realized in hardware.
