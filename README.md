# Design-of-Floating-Point-Fused-Multiply-Add
Authors: Marco Salvatori, Simone Catenacci

Final Project for "Architetture e Sistemi VLSI per il DSP" (Università di Roma "Tor Vergata")

This repository contains the design and implementation of a **Floating-Point Fused Multiply-Add** (FMA) unit and it adheres to the IEEE 754 standard for floating-point arithmetic. The FMA unit is a critical component in modern processors, frequently used in scientific computations, machine learning, graphics rendering, and other applications requiring high-performance arithmetic operations.
In this project, the unit has been created based on different sources (which can be found in the bibliography section inside the report) using different design principles and ideas (All codes are written in VHDL-2008, so set as File Type: VHDL 2008, on all VHDL codes). After the implementation of the design (using the Zynq Ultrascale+ MPSoCs FPGA as a target), several simulations were performed to visualize the error probability density function under different rounding modes.

Furthermore, a thorough study of the paper "Enhanced Floating-Point Multiply-Add with Full Denormal Support" has been done, but no implementation of the project shown inside it has been done.

For more info look into the project presentation and the project report!

WARNING:
The synthesis and implementation of the FMA without pipelining works perfectly including
the post synthesis and post implementation simulations.
While for the FMA with pipelining the behavioral simulation is perfectly correct,
the code is synthesizable and implementable, but the post synthesis simulation
generates outputs that do not match the behavioral simulation.
So probably there is a bug in the management of Vivado synthesis for pipelining,
so to solve it you need to see if there is a different method of pipelining that does not lead to this
problem or change the synthesis configuration.


