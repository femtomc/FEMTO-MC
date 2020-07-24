`/src` contains all the VHDL code for the FEMTO-MC system, including the memory subsystem (which can be gotten at [the course website](https://cscie93.dce.harvard.edu/spring2020/index.html).

`/emu` contains the emulator and assembler for FEMTO-MC architecture in a pipeline. You can assemble and run `*.asm` files on the emulator using the build script there.

`/asm` is a separate directory containing just the assembler.

Both of the above directories contain a set of `*.asm` files designed to implement a calculator program which prompts the user for integer inputs, multiplies them, and returns. By the end of this class, I did not get the `main` program working to do everything correctly in order - but parts of this pipeline work (i.e. multiplication works if done separately from IO).

The slides and operations manual also provide reference material on the architecture and usage.
