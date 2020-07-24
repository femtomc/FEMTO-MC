This directory should contain all of the code for your assembler.

---

See below to compile and test this code using Docker.

Using Docker:

1. Pull the latest Rust docker image.

```
docker pull rust
```
This has been tested with the latest image from https://hub.docker.com/_/rust/.

2. Deploy container.

```
docker run -i -t rust
```

In the `/emu` directory, running `cargo build` or `compile.sh` will (respectively) compile and run the project with the .mif code to multiply two signed integers.

To understand how to use the binary to run other .mif files, look inside `compile.sh`.

---

Currently, I am missing two assembly routines:

1. `main.asm` is not working correctly yet, because I'm working on bugs related to organizing memory (the assembler automatically resolves references, but this is sometimes useless if the reference has a memory address > 2^8 because my `addi` instruction only supports immediate addition up to 2^8. Thus, as the program gets longer, you have to manually manage addresses in use.

2. My output signed integer subroutine is not complete yet. Input is working correctly but I need to mirror this on the output side.
