cargo build

ls assembly_routines | xargs -I {} basename {} .asm | xargs -I {} ./target/debug/assembler assembly_routines/{}.asm output/{}.mif

./target/debug/emulator output/main.mif
