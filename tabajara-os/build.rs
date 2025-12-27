fn main() {
    // Linker script is already configured in .cargo/config.toml
    // via rustflags = ["-C", "link-arg=-Tlinker_script.ld", ...]
    // 
    // This build.rs is kept for potential future build-time logic.
    
    // Rerun if the linker script changes
    println!("cargo:rerun-if-changed=linker_script.ld");
}