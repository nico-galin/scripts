#SingleInstance Force ; Only 1 instance of the script can run
#Warn

!Z::toggle("CDViewer.exe", "C:\Program Files (x86)\Citrix\ICA Client\SelfServicePlugin\SelfService.exe")

toggle(process_name, default_executable := "") {      ; Open/Restore/Minimize
    if (SubStr(process_name, -3) != ".exe") {
        throw Exception("Not an app")
    }

    if (default_executable = "") {
        default_executable := process_name
    }

    if WinExist(handle := "ahk_exe" process_name) {   ; If the process is running
        WinGet state, MinMax, % handle                  ; Get the state of the window
        if (state = -1) {                                 ; If Minimized
            WinRestore, % handle                           ; Restore
        } else if (state = 0){                           ; If not Minimized
            WinMinimize, A                               ; Minimize 
        }       
    } else {                                            ; If the process is not running
        run % default_executable                          ; Run the default process
    }
}