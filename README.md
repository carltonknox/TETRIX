# TETRIX (Tetris x RGB MATRIX)
A FPGA Tetris game implementation that outputs to a 32x64 RGB Matrix

Presentation: [Here!](https://docs.google.com/presentation/d/1lpAguwqQLs3ycHhpyAirgHyVBe7RRwruO7fxQZyo7Tg/edit?usp=sharing)

Tetrix (a combination of the words Tetris and RGB Matrix) is a FPGA implementation of the classic Tetris real time strategy puzzle arcade game, designed to support up to 4 players, and output to both vga and an 32x64 RGB matrix. Our project runs on the Xilinx NEXYS A7 FPGA, and our Adafruit RGB Matrix is driven by an Arduino Uno. The communication between the FPGA and Arduino is performed via serial UART port.

Currently, the project has varying functionality

Functionality:
1. UART RGB Matrix output to Arduino (previous version) (git checkout 2661397146d5749b115ddc16e6ca0ba44ab72df3)
2. VGA graphics output to screen (current version and "wokring" branch)
3. Tetris game logic (Game board and falling block)
4. Keyboard input module, 4 players with 1 keyboard using ps/2 protocol

Issues:
1. RGB matrix output has artifacting/trailing issue
2. PS2 clock much slower than fpga clock, leading to repeated inputs
3. In some versions, tetris game does not advance beyond 'S_FALL' state.

Several bitstreams are included in the root folder, for different states of the project.
