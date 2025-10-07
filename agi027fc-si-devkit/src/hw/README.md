# Agilex&trade; 7 Multi-Channel 25GbE Precision Time Protocol System Example Design - Hardware


## Dependency

- Quartus Prime (See Release Notes for the supported version)

## Build Steps

1. Compile design and generate configuration (sof) file:
   
The synth folder contains a Makefile and the Quartus Project.The Makefile support various compile options such as:

- `make compile` - runs the compile stage of Quartus
- `make synth`   - runs synthesis stage of Quartus
- `make all`     - runs a full Quartus compile including the Assembler

Running `make` will print out all the options supported

Alternatively, if using the GUI is preferred, the qpf file can be opened in Quartus and compile options selected there.

``` bash
cd synth/
make all
```

## Programming Files Generation Steps

1. Download `u-boot-spl-dtb.hex` from 
2. Generate `ghrd_agmf039r47a1e2vr0.{core,hps}.rbf` including U-Boot SPL: agi027fc-si-devkit/src/sw/artifacts

``` bash
cd synth/
quartus_pfg -c -o hps=on -o hps_path=u-boot-spl-dtb.hex output_files/top.sof output_files/top.rbf
```
