# Verilog-Lab-5
1 Introduction
In this lab, you will continue to develop assembly programs to configure and control
General Purpose Input/Output (GPIO) port pins and execute them with the LPC2148 Education
board. You will continue to practice the ARM7TDMI loading and storing instructions. The
objectives are:
 to understand how 32‐bit constants are loaded to 32‐bit registers
 to practice using different addressing modes
 to learn more on how to output signals to control LEDs
 to get familiar with the Keil µVision IDE simulator
2 Pre‐lab Preparation
Please prepare the lab (e.g., read this entire section, write the needed code, and assemble
them to eliminate any syntax error), before you come to the laboratory. This will help you to
complete the required tasks on time.  
2.1 FLASHING LEDS  
As we already know, eight red LEDs are connected to pin P0.8 – P0.15 of the
microcontroller chip on the education board. Figure 1 below illustrates the 8 LEDs in the design.
Each LED can be individually enabled or disable via jumpers: J8, J10, …, J21. These jumpers are
inserted presently.
To control the LEDs, we need to configure the port pins which are connected to one end of
each of the LEDs. From the last lab experiment, we know that the configuration includes three
steps and three control registers are involved. Each control register is 32‐bit long and assigned
with a memory address so that we can modify the bits as if they are memory contents. The
following are the steps:
(1) Select the function of these pins P0.8 – P0.15 to be general purpose input/output (GPIO) by
writing all zeros to the following address defined as
PINSEL0    EQU 0xE002C000   ;pin function selection for port 0
(2) Set the direction of the pins by writing a “1” or “0” to the corresponding bits of
IO0DIR    EQU 0xE0028008
For example, a “1” on bit 8 of the register IO0DIR sets pin P0.8 as an output pin, and a “0” sets
the pin as an input pin. The register is 32‐bit long so that it can be used to set the signal
directions of pins P0.0 – P0.31.  
(3) Output a signal level to the pins by writing to the corresponding bits of IO0PIN register.
California State University, Northridge ECE425L
ECE Department By Xiaojun Geng
2 
IO0PIN    EQU 0xE0028000
Again, this register is 32‐bit long so that it can be used to control the signal level of all the
output pins in P0.0 – P0.31, correspondingly.
In this lab, we are going to learn a new way to output values to port pins. In the step (3), by
writing a 32‐bit number to the IO0PIN register, we modify all the output pins from P0.0 to
P0.31; However, in order to control the eight LEDs, only pins P0.8, P0.9, …, P0.15 need to be
configured. Instead of directly writing to the value register IO0PIN, we can set or clear selected
bit of IO0PIN. The following two 32‐bit registers are involved:
IO0SET    EQU 0xE0028004
IO0CLR    EQU 0xE002800C
Figure 1. LPC2148 Education Board Schematic: LEDs 
To set a certain bit in IO0PIN, we can select the corresponding bit positions in IO0SET with
“1”s. For example, the following code sets bit 0 and bit 1 in IO0PIN:
MOV   r0, #0x00000003
LDR   r1, =IO0SET
STR   r0, [r1]
California State University, Northridge ECE425L
ECE Department By Xiaojun Geng
3 
To clear a certain bit in the value register IO0PIN, we can select the corresponding bit
positions in IO0CLR with “1”s. For example, the following code clears bits [31:28] in IO0PIN:
LDR   r0, =0xF0000000
LDR   r1, =IO0CLR
STR   r0, [r1]
Question 1: Is it OK to replace LDR by MOV in the first line of the above code segment? Is it OK
to replace instruction LDR by MOV in the second line?
2.2 LOADING CONSTANTS OR ADDRESSES INTO REGISTERS  
Since the machine code of each ARM instruction is 32‐bit long, we cannot load an arbitrary
32‐bit immediate constant into a register in a single instruction without performing a data load
from memory. The following describes how a 32‐bit can be loaded into a 32‐bit register with a
32‐bit instruction LDR.  
We often use a pseudo‐instruction to load constants into registers, with syntax:
LDR   rd,  =constant
where rd is the destination register, and constant is the numeric constant. The assembler
understands this pseudo‐instruction and converts it to a proper ARM instruction. The two
following cases may occur:
Case 1: The constant can be represented with an 8‐bit number or its rotation.  
Example:    LDR r0,=0x5F000000; 0x5F000000 can be obtained by rotating 0x0000005F.
Solution: The actual execution of this pseudo instruction is
MOV   r0, #0x5F000000
Case 2: The constant cannot be obtained by rotating an 8‐bit value
Example:    LDR r0,=0x11223344; 0x11223344 cannot be constructed by rotating 8‐bits.  
Solution: The Assembler places the constant 0x11223344 in the memory near the machine
code. Such a memory block which holds constants is called a literal pool.    For short
programs, the literal pool is placed at the end of the program code in the memory by
default. Then, the actual execution of the above loading instruction is
LDR    r0, [PC, #offset to the constant in literal pool]
where the #offset is a numeric value which indicates how far away the constant
0x11223344 is placed from the current PC value. The distance of the constant in the
memory from the current PC value needs to be in range ±4K. The addressing mode used in
this load instruction will be explained below.   
In this lab experiment, you need to find out how the pseudo‐instructions in your program
are executed.  
California State University, Northridge ECE425L
ECE Department By Xiaojun Geng
4 
2.3 ADDRESSING MODES  
Loading instructions can transfer a single value from memory into a CPU register; and
storing instructions can read a value from a CPU register and store it to a memory location. The
actual memory address for the loading and storing operations to operate with are called
effective address. Different addressing modes are allowed to produce such effective address,
which are detailed out on page 69 – 72 in the textbook.  
In this lab experiment, you will practice using pre‐indexed addressing modes to construct
the effective address. Examples of the normal single‐operand loads and stores are:
LDR   r0, [r3]
STR   r9, [r7]
where the first line loads a 32‐bit value from memory to register r0, and the second line stores
the 32‐bit value in register r9 to memory. The memory addresses are provided by registers r3
and r7, respectively. Below are examples of using pre‐indexed addressing mode:
LDR   r0, [r3, #4]
STR   r9, [r7, #0x1F]
The first instruction load the 32‐bit memory contents at address r3+4 to CPU register r0, and
the second instruction store the 32‐bit value in register r9 to memory address r7+0x1F. After
the above operations, the register values of r3 and r7 keep unchanged. In the above examples,
r3 and r7 are referred to as base registers, and the immediate numbers 4 and 0x1F are offsets
of the actual address from the base register. The offset can be a 12‐bit constant.  
The following shows how to use the address modes in this lab. To configure GPIO pins, a
few control registers are involved; the addresses allocated to all these registers are very close in
memory except the register PINSEL0. In order to use the meaning names of these registers
instead of their address, we can define the base address as
IO0_BASE EQU 0xE0028000   
followed with the offsets
IO0PIN    EQU 0
IO0DIR    EQU 0x8
IO0SET    EQU 0x4
IO0CLR    EQU 0xC
With these definitions, the pre‐indexing addressing mode can be conveniently used.  
Question 2: Any advantage could be gained with the above definitions of control registers along
with using pre‐indexing address mode?  
2.4 USING LOGIC ANALYZER IN THE µVISION IDE
The Logic Analyzer can graphically display signals and program variables as they change
over time. Follow the steps below to observe the pin value variation with the Simulator in the
µVision IDE.  
1. Select “Start/Stop Debugger Session” in Debug menu to enter the debugging mode.
California State University, Northridge ECE425L
ECE Department By Xiaojun Geng
5 
2. Click the Logic Analyzer button   on the toolbar to open the Logic Analyzer Dialog.  
3. A window pops up by clicking the Setup button on the upper left corner of the Logic
Analyzer window, as illustrated in Figure 2.
4. Pressing New(Insert) button allows you to enter variable or signal names. Enter PORT0
and select to show a certain port pin with AND MASK. Then, click Close.
5. Select Run button , Single‐Step button , or Run‐to‐Cursor button    to start
execute your program. You may click on Zoom In/Out in the logic analyze window to adjust
the time resolution.
Figure 2. Setup Logic Analyzer Window. 
2.5 EXPANSION CONNECTOR ON BOARD
The expansion connector on the education board helps users have easy access to various
microcontroller pins. Fifty pins are available, as listed in Table 1.  
3 Procedures
For each of the following tasks, you need to  
 Create and assemble your code to implement the task BEFORE coming to the lab. Note:
pre‐indexed addressing mode must be used.
 Simulate your code and verify the result with the simulator.
 Download the machine code in HEX file to the LPC2148 microcontroller, and verity the
result after execution.
 Demonstrate the results to the lab instructor before you leave the lab.
California State University, Northridge ECE425L
ECE Department By Xiaojun Geng
6 
Task 1: Write a complete program to flash all of the 8 LEDs, i.e., all LEDs on, then all off, and
repeat. Note that you must output signals by writing to IO0SET and IO0CLR, and you must
practice the pre‐indexing address mode in your code. Once the program is running, connect the
oscilloscope probe to test any port pin of P0.8‐P0.15. Adjust the oscilloscope so that you can
see the square wave pattern produced on the test pin.  
Task 2: With the simulator in the Keil µVision IDE, examine how all the pseudo‐instructions LDR
are implemented in your program for Task 1. You need to explain how the PC offset value is
obtained if applicable. Also find where the literal pool is placed and what data are stored in
there.   
Task 3: Using the Logic Analyzer function in the Keil µVision IDE, display the signal changes on
any port pin of P0.8‐P0.15. Describe your observation in detail.
Table 1. Connector Pins 1-50. 
Connector
Pin #
LPC2148 Pin Connector
Pin #
LPC2148 Pin Connector
Pin #
LPC2148 Pin
1 P1.25 18 GND 35 P0.9
2 P1.24 19 P0.25 36 P0.8
3 P1.23 20 XRST_OUT 37 P0.7
4 P1.22 21 P0.23 38 P0.6
5 P1.21 22 P0.22 39 P0.5
6 P1.20 23 P0.21 40 P0.4
7 P1.19 24 P0.20 41 P0.3
8 P1.18 25 P0.19 42 P0.2
9 P1.17 26 P0.18 43 P0.1
10 P1.16 27 P0.17 44 P0.0
11 XVBAT_IN 28 P0.16 45 GND
12 XVREF_IN 29 P0.15 46 GND
13 P0.31 30 P0.14 47 +3V3
14 P0.30 31 P0.13 48 +3V3
15 P0.29 32 P0.12 49 VIN
16 P0.28 33 P0.11 50 VIN
17 GND 34 P0.10
4 Requirements
1. Pre‐lab is required.  You need to show your assembly code on paper for all the tasks.
2. Lab report is DUE right before the next lab time. The report should include your names,
experiment objectives, experiment problems, the print‐out of your work, and
explanation and discussion.
3. Demonstrate your results to the instructor before you leave. Failure to do so will result
in zero point for performance.
