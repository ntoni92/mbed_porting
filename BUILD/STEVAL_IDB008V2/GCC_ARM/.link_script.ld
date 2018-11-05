_MEMORY_RAM_BEGIN_ = 0x20000000;
_MEMORY_RAM_SIZE_ = 0x6000;
_MEMORY_RAM_END_ = 0x20005FFF;
_MEMORY_FLASH_BEGIN_ = 0x10040000;
_MEMORY_FLASH_SIZE_ = 0x40000;
_MEMORY_FLASH_END_ = 0x1007FFFF;
_MEMORY_ROM_BEGIN_ = 0x10000000;
_MEMORY_ROM_SIZE_ = 0x800;
_MEMORY_ROM_END_ = 0x100007FF;
FLASH_NVM_DATASIZE = (4*1024);
MEMORY_FLASH_APP_OFFSET = DEFINED(MEMORY_FLASH_APP_OFFSET) ? (MEMORY_FLASH_APP_OFFSET) : (0) ;
MEMORY_FLASH_APP_SIZE = DEFINED(MEMORY_FLASH_APP_SIZE) ? (MEMORY_FLASH_APP_SIZE) : ( _MEMORY_FLASH_SIZE_ - FLASH_NVM_DATASIZE - MEMORY_FLASH_APP_OFFSET);
MEMORY_RAM_APP_OFFSET = DEFINED(MEMORY_RAM_APP_OFFSET) ? (MEMORY_RAM_APP_OFFSET) : (0x2CC) ;
RESET_SM_MANAGER_SIZE = 0;
RESET_MANAGER_SIZE = 0;
RESET_MANAGER_SIZE = DEFINED(ST_OTA_HIGHER_APPLICATION) ? 0x800 : RESET_MANAGER_SIZE ;
MEMORY_FLASH_APP_SIZE = DEFINED(ST_OTA_HIGHER_APPLICATION) ? ((_MEMORY_FLASH_SIZE_ - RESET_MANAGER_SIZE - FLASH_NVM_DATASIZE - 2048) / 2) : MEMORY_FLASH_APP_SIZE ;
MEMORY_FLASH_APP_OFFSET = DEFINED(ST_OTA_HIGHER_APPLICATION) ? (RESET_MANAGER_SIZE + MEMORY_FLASH_APP_SIZE) : MEMORY_FLASH_APP_OFFSET ;
RESET_MANAGER_SIZE = DEFINED(ST_OTA_LOWER_APPLICATION) ? 0x800 : RESET_MANAGER_SIZE ;
MEMORY_FLASH_APP_SIZE = DEFINED(ST_OTA_LOWER_APPLICATION) ? ((_MEMORY_FLASH_SIZE_ - RESET_MANAGER_SIZE - FLASH_NVM_DATASIZE - 2048) / 2) : MEMORY_FLASH_APP_SIZE ;
MEMORY_FLASH_APP_OFFSET = DEFINED(ST_OTA_LOWER_APPLICATION) ? (RESET_MANAGER_SIZE) : MEMORY_FLASH_APP_OFFSET ;
RESET_SM_MANAGER_SIZE = DEFINED(ST_USE_OTA_SERVICE_MANAGER_APPLICATION) ? 0xF000 : RESET_SM_MANAGER_SIZE ;
MEMORY_FLASH_APP_SIZE = DEFINED(ST_USE_OTA_SERVICE_MANAGER_APPLICATION) ? (_MEMORY_FLASH_SIZE_ - RESET_SM_MANAGER_SIZE - FLASH_NVM_DATASIZE) : MEMORY_FLASH_APP_SIZE ;
MEMORY_FLASH_APP_OFFSET = DEFINED(ST_USE_OTA_SERVICE_MANAGER_APPLICATION) ? (RESET_SM_MANAGER_SIZE) : MEMORY_FLASH_APP_OFFSET ;
EXTERNAL_BLE_STACK_FLASH_OFFSET = DEFINED(EXTERNAL_BLE_STACK_FLASH_OFFSET) ? EXTERNAL_BLE_STACK_FLASH_OFFSET : 0;
cmd_call_table = _MEMORY_FLASH_BEGIN_ + 0xC0 + EXTERNAL_BLE_STACK_FLASH_OFFSET;
ev_call_table = 0x200002cc;
ENTRY(RESET_HANDLER2)
_Min_Heap_Size = 0x0;
_Min_Stack_Size = 0xC00;
MEMORY
{
  REGION_RAM (xrw) : ORIGIN = _MEMORY_RAM_BEGIN_, LENGTH = _MEMORY_RAM_SIZE_
  REGION_FLASH_BOOTLOADER (rx) : ORIGIN = _MEMORY_FLASH_BEGIN_, LENGTH = MEMORY_FLASH_APP_OFFSET
  REGION_FLASH (rx) : ORIGIN = _MEMORY_FLASH_BEGIN_ + MEMORY_FLASH_APP_OFFSET, LENGTH = MEMORY_FLASH_APP_SIZE
  REGION_NVM (rx) : ORIGIN = _MEMORY_FLASH_END_ + 1 - FLASH_NVM_DATASIZE, LENGTH = FLASH_NVM_DATASIZE
  REGION_ROM (rx) : ORIGIN = _MEMORY_ROM_BEGIN_, LENGTH = _MEMORY_ROM_SIZE_
}
SECTIONS
{
  .bootloader (ORIGIN(REGION_FLASH_BOOTLOADER)) :
  {
    . = ALIGN(4);
    KEEP(*(.bootloader))
    . = ALIGN(4);
  } >REGION_FLASH_BOOTLOADER
  .intvec (ORIGIN(REGION_FLASH)) :
  {
    . = ALIGN(4);
    KEEP(*(.intvec))
    . = ALIGN(4);
  } >REGION_FLASH
  .text :
  {
    . = ALIGN(4);
    KEEP(*(.cmd_call_table))
    *(.text)
    *(.text*)
    *crtbegin.o(.ctors)
    *crtbegin?.o(.ctors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
    *(SORT(.ctors.*))
    *(.ctors)
    *crtbegin.o(.dtors)
    *crtbegin?.o(.dtors)
    *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
    *(SORT(.dtors.*))
    *(.dtors)
    *(i.*)
    KEEP(*(.init))
    KEEP(*(.fini))
    *(.rodata)
    *(.rodata*)
    *(.constdata)
    *(.glue_7)
    *(.glue_7t)
 KEEP(*(.eh_frame*))
    . = ALIGN(4);
     _etext = .;
  } >REGION_FLASH
  _sidata = LOADADDR(.data);
  _sidata2 = LOADADDR(.ram_preamble);
  .ram_preamble_noinit 0x20000000 (NOLOAD) :
  {
    . = ALIGN(4);
    . = 0x04 ;
    KEEP(*(.ota_sw_activation))
  } >REGION_RAM
  .ram_preamble 0x20000008 :
  {
    _sdata2 = .;
    KEEP(*(.savedMSP))
    . = 0x04 ;
    KEEP(*(.wakeupFromSleepFlag))
    . = 0x08 ;
    KEEP(*(.app_base))
    . = 0x28 ;
    KEEP(*(.__blueflag_RAM))
      _edata2 = .;
  } >REGION_RAM AT> REGION_FLASH
  .ram_preamble_noinit2 0x20000034 (NOLOAD) :
  {
    KEEP(*(.__crash_RAM))
  } >REGION_RAM
  .bss.blueRAM 0x200000C0 :
  {
    . = ALIGN(4);
    _sbssblue = .;
    KEEP(*(.bss.__blue_RAM))
    . = ALIGN(4);
    _ebssblue = .;
    . = 0x20c + MEMORY_RAM_APP_OFFSET - 0x2cc;
  } >REGION_RAM
  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = .;
    *(.bss.ev_call_table)
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
    _ebss = .;
  } >REGION_RAM
  .data :
  {
    __data_start__ = .;
    _sdata = .;
    *(vtable)
    *(.data*)
    . = ALIGN(4);
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP(*(.preinit_array))
    PROVIDE_HIDDEN (__preinit_array_end = .);
    . = ALIGN(4);
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP(*(SORT(.init_array.*)))
    KEEP(*(.init_array))
    PROVIDE_HIDDEN (__init_array_end = .);
    . = ALIGN(4);
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP(*(SORT(.fini_array.*)))
    KEEP(*(.fini_array))
    PROVIDE_HIDDEN (__fini_array_end = .);
    KEEP(*(.jcr*))
    . = ALIGN(4);
    __data_end__ = .;
    _edata = .;
  } >REGION_RAM AT> REGION_FLASH
  .noinit (NOLOAD):
  {
    . = ALIGN(4);
    *(.noinit)
    . = ALIGN(4);
  } >REGION_RAM
  BLOCK_STACKLIB_FLASH_DATA (_MEMORY_FLASH_END_ - FLASH_NVM_DATASIZE + 1) (NOLOAD) :
  {
    . = ALIGN(2048);
    KEEP(*(.noinit.stacklib_flash_data))
    KEEP(*(.noinit.stacklib_stored_device_id_data))
  } >REGION_NVM
  CSTACK (ORIGIN(REGION_RAM) + LENGTH(REGION_RAM) - _Min_Stack_Size) (NOLOAD) :
  {
    . = ALIGN(4);
    _estack = . + _Min_Stack_Size;
    . = ALIGN(4);
  } > REGION_RAM
  .rom_info (NOLOAD) :
  {
    . = ALIGN(4);
    KEEP(*(.rom_info))
    . = ALIGN(4);
  } >REGION_ROM
  .heap (COPY):
    {
        __end__ = .;
        end = __end__;
        *(.heap*)
        __HeapLimit = .;
    } > REGION_RAM
    .stack_dummy (COPY):
    {
        *(.stack*)
    } > REGION_RAM
    __StackTop = ORIGIN(REGION_RAM) + LENGTH(REGION_RAM);
    _estack = __StackTop;
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(__stack = __StackTop);
    ASSERT(__StackLimit >= __HeapLimit, "region RAM overflowed with stack")
   .ARM.attributes 0 : { *(.ARM.attributes) }
}
