; AutoHotkey v2 configuration

; Ctrl+Space -> Alt+` (window switcher / IME toggle)
^Space::!`

; CapsLock -> Escape (tap) / Ctrl (hold)
; Same as xremap (Linux) and Karabiner (macOS)
*CapsLock:: {
    KeyWait "CapsLock", "T0.2"
    if (ErrorLevel) {
        Send "{Blind}{Ctrl down}"
        KeyWait "CapsLock"
        Send "{Blind}{Ctrl up}"
    } else {
        Send "{Escape}"
    }
}
