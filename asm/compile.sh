ls assembly_routines | xargs -I {} basename {} .asm | xargs -I {} cargo run assembly_routines/{}.asm output/{}.mif
