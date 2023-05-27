ENTRY(Reset_Handler)

/* end of stack, 128K RAM */
_estack = 0x20020000 ;

MEMORY
{
   FLASH ( rx )      : ORIGIN = 0x08000000, LENGTH = 512K
   RAM ( rxw )       : ORIGIN = 0x20000000, LENGTH = 128K
}

SECTIONS
{
   /* The vector tables goes at the start of flash */
   .vector_table :
   {
      . = ALIGN(4) ;
      KEEP (*(.isr_vector))
      . = ALIGN(4) ;
   } >FLASH

   /* The 'text' section contains the main program code */
   .text :
   {
      . = ALIGN(4) ;
      *(.text)
      *(.text*)
      . = ALIGN(4) ;
   } >FLASH

   /* The 'rodata' section contains read-only data,
   constants, strings, information that won't change. */
   .rodata :
   {
      . = ALIGN(4);
      *(.rodata)
      *(.rodata*)
      . = ALIGN(4);
   } >FLASH

   /* The 'data' section is space set aside in RAM for
    * things like variables, which can change. */
   _sidata = .;
   .data :
   {
      . = ALIGN(4);
      /* Mark start/end locations for the 'data' section. */
      _sdata = .;
      *(.data)
      *(.data*)
      _edata = .;
      . = ALIGN(4);
   } >RAM AT >FLASH
   _data_addr = LOADADDR(.data);

   .preinit :
   {
      . = ALIGN(4);
      PROVIDE_HIDDEN(__preinit_array_start = .);
      KEEP (*(.preinit_array))
      KEEP (*(.preinit_array*))
      PROVIDE_HIDDEN(__preinit_array_end = .);
      . = ALIGN(4);
   } >FLASH

   .init :
   {
      . = ALIGN(4);
      PROVIDE_HIDDEN(__init_array_start = .);
      KEEP (*(.init_array))
      KEEP (*(.init_array*))
      PROVIDE_HIDDEN(__init_array_end = .);
      . = ALIGN(4);
   } >FLASH

   .fini :
   {
      . = ALIGN(4);
      PROVIDE_HIDDEN(__fini_array_start = .);
      KEEP (*(.fini_array))
      KEEP (*(.fini_array*))
      PROVIDE_HIDDEN(__fini_array_end = .);
      . = ALIGN(4);
   } >FLASH

   /* The 'bss' section is similar to the 'data' section,
    * but its space is initialized to all 0s at the
    * start of the program. */
   .bss :
   {
      . = ALIGN(4);
      /* Also mark the start/end of the BSS section. */
      _sbss = .;
      __bss_start__ = .;
      *(.bss)
      *(.bss*)
      *(COMMON)
      . = ALIGN(4);
      _ebss = .;
      __bss_end__ = .;
   } >RAM
   end = .;
   _end = end;
   __end = end;
  
   /* Space set aside for the application's heap/stack. */

   .dynamic_allocations :
   {
      . = ALIGN(4);
      _ssystem_ram = .;
      . = ALIGN(4);
      _esystem_ram = .;
   } >RAM
}