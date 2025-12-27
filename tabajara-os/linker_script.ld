OUTPUT_FORMAT(binary)
ENTRY(main)

SECTIONS {
    /* O setor de boot é carregado no endereço 0x7c00 pela BIOS */
    . = 0x7c00;

    /* Seção de código - main deve estar primeiro */
    .text : {
        *(.text.main)    /* Garante que main vem primeiro */
        *(.text .text.*)
    }
    
    .rodata : { *(.rodata .rodata.*) }
    .data : { *(.data .data.*) }
    .bss : { *(.bss .bss.*) }
    
    /DISCARD/ : {
        *(.eh_frame .eh_frame.*)
        *(.eh_frame_hdr .eh_frame_hdr.*)
        *(.comment)
        *(.note*)
    }

    /* Assinatura de boot nos bytes 510-511 (offset 0x1FE e 0x1FF do setor) */
    . = 0x7c00 + 510;
    .boot_signature : { SHORT(0xaa55) }

    /* Garante que o setor tem exatamente 512 bytes */
    . = 0x7c00 + 512;
}

