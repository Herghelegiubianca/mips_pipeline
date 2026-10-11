MIPS 32-bit Pipelined Processor

A VHDL implementation of a 32-bit MIPS processor, structured on a 5-stage pipeline architecture
(Instruction Fetch, Instruction Decode, Execute, Memory, Write Back). The project includes hazard
resolution and extends the standard instruction set with bitwise logical operations and custom 
conditional branching.

(For complete technical details, RTL schematics, machine code formats, and pipeline design, please
refer to the documentatie.docx file and the sketches included in the repository).

Features:
Full Pipeline Architecture: The processor executes overlapping instructions using intermediate
                             pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) to maximize efficiency.   
Extended Instruction Set (Custom Instructions)
Hazard Resolution: Integration of forwarding/stalling mechanisms to ensure correct code execution,
                   resolving bottlenecks identified during simulation.  
Rigorous Testing: The project was fully tested and functionally validated in the Vivado simulator.
