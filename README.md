# TabajaraOS 🖥️

A minimal "Hello World" operating system written in Rust that runs in 16-bit real mode. This project demonstrates bare-metal programming concepts, including direct BIOS interrupt calls and custom linker scripts for bootloader development.

![Rust](https://img.shields.io/badge/Rust-nightly-orange?logo=rust)
![Platform](https://img.shields.io/badge/Platform-x86--16bit-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎯 What Does It Do?

When booted, TabajaraOS prints **"Hello, World!"** to the screen using BIOS interrupt `0x10` (video services) and then halts the CPU.

## 📋 Prerequisites

Before building TabajaraOS, ensure you have the following installed:

### 1. Rust (Nightly)

Install Rust via [rustup](https://rustup.rs/):

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Install the nightly toolchain and required components:

```bash
rustup install nightly
rustup component add rust-src --toolchain nightly
rustup component add llvm-tools-preview --toolchain nightly
```

### 2. QEMU (for running the OS)

**Windows (via Chocolatey):**
```powershell
choco install qemu
```

**Windows (via Scoop):**
```powershell
scoop install qemu
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install qemu-system-x86
```

**macOS:**
```bash
brew install qemu
```

## 🔨 Building

Clone the repository and build the OS:

```bash
git clone https://github.com/ricardoborges/TabajaraOS.git
cd TabajaraOS/tabajara-os
```

Build the release binary:

```bash
cargo +nightly build --release -Z build-std=core
```

> **Note:** The project is configured to automatically use the custom `16bit_target.json` target specification via `.cargo/config.toml`.

The compiled binary will be located at:
```
target/16bit_target/release/tabajara-os
```

## 🚀 Running

### Using the PowerShell Script (Windows)

```powershell
.\qemu_run.ps1
```

### Manual QEMU Command

**Windows (PowerShell):**
```powershell
qemu-system-x86_64 -drive format=raw,file=.\target\16bit_target\release\tabajara-os
```

**Linux/macOS:**
```bash
qemu-system-x86_64 -drive format=raw,file=./target/16bit_target/release/tabajara-os
```

You should see **"Hello, World!"** printed on the QEMU window!

### Exiting QEMU

- Press `Ctrl+Alt+G` to release the mouse
- Close the QEMU window, or
- Press `Ctrl+C` in the terminal

## 📁 Project Structure

```
tabajara-os/
├── .cargo/
│   └── config.toml       # Cargo configuration (target, linker flags)
├── src/
│   └── main.rs           # Main OS code (prints "Hello, World!")
├── 16bit_target.json     # Custom Rust target specification for 16-bit x86
├── build.rs              # Build script
├── Cargo.toml            # Rust package manifest
├── linker_script.ld      # Linker script for boot sector layout
├── qemu_run.ps1          # PowerShell script to run in QEMU
└── rust-toolchain.toml   # Specifies nightly Rust toolchain
```

## 🧠 How It Works

### 1. No Standard Library (`#![no_std]`)

The OS runs without Rust's standard library since there's no underlying OS to provide system calls. We only use `core`, which provides basic Rust primitives.

### 2. Custom Entry Point (`#![no_main]`)

The normal `main` function depends on the standard library's runtime. We define our own entry point that the BIOS jumps to after loading the boot sector.

### 3. BIOS Interrupts

The code uses **BIOS interrupt `0x10`** (video services) to print characters:

```rust
asm!(
    "mov ah, 0x0E",   // Teletype output function
    "mov al, {0}",    // Character to print
    "int 0x10",       // Call BIOS
    in(reg_byte) ch,
    out("ax") _,
);
```

### 4. Boot Sector Layout

The `linker_script.ld` ensures:
- Code is loaded at address `0x7C00` (where BIOS loads the boot sector)
- The boot signature `0xAA55` is placed at bytes 510-511
- Total size is exactly 512 bytes (one sector)

### 5. Custom Target

The `16bit_target.json` configures Rust to:
- Generate 16-bit x86 code (`i386-unknown-none-code16`)
- Use `rust-lld` as the linker
- Disable features unavailable in bare-metal (red zone, etc.)
- Use `abort` on panic (no unwinding support)

## 🛠️ Troubleshooting

### Error: "can't find crate for `std`"

Make sure `#![no_std]` is at the top of `src/main.rs`.

### Error: "section .boot_signature overlaps"

Ensure the linker script is not being passed twice. Check that only `.cargo/config.toml` OR `build.rs` passes the linker script, not both.

### QEMU shows "No bootable device"

1. Verify the build succeeded and the binary exists
2. Check that the boot signature (`0xAA55`) is correctly placed
3. Ensure the binary is exactly 512 bytes (or a multiple thereof)

### Rust nightly features not available

Update your nightly toolchain:

```bash
rustup update nightly
```

## 📚 Learning Resources

- [Writing an OS in Rust](https://os.phil-opp.com/) - Comprehensive guide to OS development in Rust
- [OSDev Wiki](https://wiki.osdev.org/) - Essential resource for OS development
- [Intel x86 Manual](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html) - Official CPU documentation
- [BIOS Interrupt List](http://www.ctyme.com/intr/int.htm) - Reference for BIOS interrupts

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

---

**Happy bare-metal hacking! 🦀**
