; This file must stay UTF-8 *with BOM*: makensis falls back to the system codepage without
; one, which turns the Russian strings below into mojibake.
!include x64.nsh
!include LogicLib.nsh
!include StrFunc.nsh
${StrRep}
${StrLoc}

; The ESP32 toolchain ships a Rust helper that panics with "Failed to get path name" when its
; own path holds anything outside this set, so ESP32 cannot compile from e.g. E:\уавцуа\.
; AVR/Uno is unaffected. Only the toolchain path matters — the build path and the Windows
; account name do not, so a user named C:\Users\Пользователь is fine on an ASCII install dir.
!define ASCII_PATH_CHARS "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\:/._- ()"
!define SAFE_INSTALL_DIR "C:\OpenBlockDesktop"

Var NonAsciiFlag

; Sets $NonAsciiFlag to "1" when $INSTDIR holds a character the ESP32 toolchain cannot handle.
Function CheckInstDirAscii
    Push $0
    Push $1
    Push $2
    Push $3
    StrCpy $NonAsciiFlag "0"
    StrLen $2 $INSTDIR
    StrCpy $3 0
    checkLoop:
        ${If} $3 >= $2
            Goto checkDone
        ${EndIf}
        StrCpy $1 $INSTDIR 1 $3
        ${StrLoc} $0 "${ASCII_PATH_CHARS}" $1 ">"
        ${If} $0 == ""
            StrCpy $NonAsciiFlag "1"
            Goto checkDone
        ${EndIf}
        IntOp $3 $3 + 1
        Goto checkLoop
    checkDone:
    Pop $3
    Pop $2
    Pop $1
    Pop $0
FunctionEnd

; Runs after the directory page, before install. Warns and offers to fix a non-ASCII path.
; Aborts unconditionally so no page is ever drawn — this is a guard, not a real page.
Function AsciiPathGuard
    Call CheckInstDirAscii
    ${If} $NonAsciiFlag == "1"
        MessageBox MB_YESNO|MB_ICONEXCLAMATION \
"The installation path contains non-Latin characters:$\r$\n$\r$\n\
$INSTDIR$\r$\n$\r$\n\
ESP32 boards will FAIL to compile from this path. Arduino Uno is not affected.$\r$\n\
Install into ${SAFE_INSTALL_DIR} instead? (recommended)$\r$\n$\r$\n\
--------$\r$\n$\r$\n\
Путь установки содержит не-латинские символы:$\r$\n$\r$\n\
$INSTDIR$\r$\n$\r$\n\
Платы ESP32 НЕ БУДУТ компилироваться из этой папки. На Arduino Uno это не влияет.$\r$\n\
Установить в ${SAFE_INSTALL_DIR}? (рекомендуется)" \
            IDNO keepUserChoice
        StrCpy $INSTDIR "${SAFE_INSTALL_DIR}"
    keepUserChoice:
    ${EndIf}
    Abort
FunctionEnd

!macro customPageAfterChangeDir
    Page custom AsciiPathGuard
!macroend

!macro preInit

    ${If} ${RunningX64}
        SetRegView 64
    ${EndIf}

    ${StrRep} $0 "${UNINSTALL_REGISTRY_KEY}" "Software" "SOFTWARE"
    ${StrRep} $1 "${INSTALL_REGISTRY_KEY}" "Software" "SOFTWARE"

    ReadRegStr $R0 HKCU "$0" "UninstallString"
    ReadRegStr $R1 HKCU "$1" "InstallLocation"

    StrCmp $R0 "" 0 +4

    ReadRegStr $R0 HKLM "$0" "UninstallString"
    ReadRegStr $R1 HKLM "$1" "InstallLocation"

    StrCmp $R0 "" 0 done
    StrCmp $R1 "" 0 done

    WriteRegExpandStr HKLM "${INSTALL_REGISTRY_KEY}" InstallLocation "C:\OpenBlockDesktop"
    WriteRegExpandStr HKCU "${INSTALL_REGISTRY_KEY}" InstallLocation "C:\OpenBlockDesktop"

done:
    ${If} ${RunningX64}
        SetRegView LastUsed
    ${EndIf}

!macroend

!macro customUnInstall

    ${If} ${RunningX64}
        SetRegView 64
    ${EndIf}

    DeleteRegKey HKLM "${INSTALL_REGISTRY_KEY}"
    DeleteRegKey HKCU "${INSTALL_REGISTRY_KEY}"

    ${If} ${RunningX64}
        SetRegView LastUsed
    ${EndIf}

 !macroend
