#NoEnv
#SingleInstance Force

; Store the original key state of Caps Lock
originalCapsLockState := GetKeyState("CapsLock", "T")

!CapsLock::
  ; Temporarily remap Caps Lock to do nothing
  SetCapsLockState, AlwaysOff

  WinGetClass, OldClass, A
  WinGet, ActiveProcessName, ProcessName, A
  WinGet, WinClassCount, Count, ahk_exe %ActiveProcessName%
  If WinClassCount = 1
    Return
  loop, 2 {
    WinSet, Bottom,, A
    WinActivate, ahk_exe %ActiveProcessName%
    WinGetClass, NewClass, A
    if (OldClass <> "CabinetWClass" or NewClass = "CabinetWClass")
      break
  }

  ; Restore the original state of Caps Lock
  if (originalCapsLockState)
    SetCapsLockState, On
  else
    SetCapsLockState, Off
  return

^F1::
  WinMinimize, A
  return

