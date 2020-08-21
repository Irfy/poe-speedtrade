; poe-speedtrate.ahk, MIT license, original author: Irfy [https://github.com/Irfy/poe-speedtrade]

#SingleInstance Force

SendMode, Input
SetKeyDelay 150,100
;SetDefaultMouseSpeed 5
SetDefaultMouseSpeed, 0
SetMouseDelay, -1

; These change every league!
global primary  := "IrfyHA"  ; character name on primary account
global secondary := "IrfyTwoHA" ; character name on secondary account, if any

#UseHook On

global conditional_hotkeys_enabled := 0
;Insert::conditional_hotkeys_toggle()	; global, not limited to PoE window being active -- enable to conditionally enable/disable another hotkey.

#if conditional_hotkeys_enabled
	Esc::teleport_to_party_member()
#if

#IfWinActive ahk_class POEWindowClass

;;;;;;;;;;;;;;;
;;; HOTKEYS ;;;
;;;;;;;;;;;;;;;

^F1::ChatCmd("test")
F2::oos() remaining() hideout(primary)
^F2::kick(primary)		; used to leave party as this char or kick this char (see also F5 and ^F5)
;F3::hideout(secondary) ; enable if using two accounts
F3::ChatCmd("/harvest") ; otherwise used for arbitrary things
^F3::kick(secondary)	; used to leave party as this char or kick this char (see also F5 and ^F5)
F4::wait_invite()		; inform the last person that you need a minute and then invite them
^F4::invite_last()		; invite the last person
+F4::trade_last()		; trade the last person
F5::kick(fast:=true, secondary, primary) hideout(fast:=true) invite(primary, secondary)
	; leave/break-up party, start personal hideout transfer, re-create private party -- this is my typical use-case after trade
	; "fast:=true" here means to skip the default ChatCmdDelay for the initial/intermediate actions -- last action should still have the delay to prevent accidental spam
^F5::kick(secondary, primary)	; leave/break-up party
+F5::invite(primary, secondary)	; re-create private party

F6::repeater("F6", "{Ctrl Down}", "{Click}", "{Ctrl Up}")	; repeated ctrl-click to move inventory items to stash, or from stash stacks to inventory
+F6::repeater("F6", "", "^+{Click}", "", 150)				; *BUGGY* repeated shift-ctrl-click to buy portal scrolls in chunks of 40, instead of individually with ctrl-click
F7::repeater("F7", "{Shift Down}", "{Click}", "{Shift Up}")	; repeated shift-click after manually right-clicking on a quality orb to repeatedly quality an item/gem
F9::trade_inventory("F9")			; move "up to" the whole inventory to trade-window (as long as key pressed)
F10::confirm_inventory("F10")		; confirm other player's trade window by moving mouse over each slot (as long as key pressed)
F11::trade_inventory_funny("F11")	; like F9 but funny, try it out with a lot of items (e.g. wisdom scrolls) in your inventory when trading someone

#MaxThreadsPerHotkey 2	; affect only following hotkeys (enables the experimental toggle feature) -- move up when/if F6-F11 are switched to toggle mode
;F12::test_toggle_approach("F12")
F12::ChatLast("Thank you. Thank you soooooooo much. Thank you so sooo sooooooooooooooooooooo much. May you have many children, and may RNG always be on your side. Like always. And like really many. Like 40. May your offspring and your RNG both make you happy. Like amazingly happy for the rest of your life. I wish you soooooo much luck and best of stuff, like you wouldn't be able to imagine. Seriously.{Enter}{Enter}Did I tell you how grateful I am to you right now? Give me a second to elaborate in detail:")		; this is just for messing with people by sending them ridiculously long thank-you messages

global fkey_pressed := {}

test_toggle_approach(fkey) { ; unfinished!
	global fkey_pressed
	debug("fkey_pressed[F12]: " . fkey_pressed["F12"])
	if (fkey_pressed[fkey]) {
		debug(fkey . " deactivated, old value: " . fkey_pressed[fkey])
		fkey_pressed[fkey] := false
		return
	} else {
		debug(fkey . " activated, old value: " . fkey_pressed[fkey])
		fkey_pressed[fkey] := true
	}
	debug(fkey . " handler starting, fkey value: " . fkey_pressed[fkey])
    While (fkey_pressed[fkey]) {
        SendInput x
        Sleep 2000 ;  milliseconds
    }
	debug(fkey . " original handler exiting, fkey value: " . fkey_pressed[fkey])
}

;;;;;;;;;;;;;;;;
;;; HANDLERS ;;;
;;;;;;;;;;;;;;;;

teleport_to_party_member() {
	MouseGetPos oldx, oldy
	MouseMove, 17, 255
	Sleep, 30
	Click, 17, 255
	Sleep, 100
	ForegroundSend("{Enter}")
	Sleep, 30
	ForegroundSend("{Esc}{Esc}")
	MouseMove %oldx%, %oldy%
}

oos() {
	ChatCmd("/oos", fast:=true)
}

remaining() {
	ChatCmd("/remaining", fast:=true)
}

hideout(fast:=false, char_name:="") {	; allow both parms to be optional, and figure out if char_name was passed as first arg manually
	if fast is not digit				; This is AHK. If you put the opening brace here, it won't compile. If you put the expression in parentheses, it compiles, but doesn't work.
	{									; anyway, this is the most reasonable check to see if fast is actually a boolean...
		char_name := fast
		fast := false
	}
	ChatCmdEach("/hideout", fast, char_name)
}

kick(char_names*) {
	ChatCmdEach("/kick", char_names*)
}

invite(char_names*) {
	ChatCmdEach("/invite", char_names*)
}

invite_last() {
	ChatCmdLast("/invite")
}

trade_last() {
	ChatCmdLast("/tradewith")
}

wait_invite(msg := "Can you give me a minute?") {
	ChatLast(msg)
	Sleep, 100
	ChatCmdLast("/invite")
}

pause_toggle() {
	if %A_IsPaused% {
		SoundPlay C:\Windows\Media\Windows Hardware Remove.wav
	} else {
		SoundPlay C:\Windows\Media\Windows Hardware Insert.wav
	}
	Pause Toggle, 1
}

conditional_hotkeys_toggle() {
	if (conditional_hotkeys_enabled) {
		SoundPlay C:\Windows\Media\Windows Hardware Remove.wav
		conditional_hotkeys_enabled := False
	} else {
		SoundPlay C:\Windows\Media\Windows Hardware Insert.wav
		conditional_hotkeys_enabled := True
	}
}

global MB_OK				:= 0x00000000 ;The sound specified as the Windows Default Beep sound.
global MB_ICONERROR			:= 0x00000010 ;The sound specified as the Windows Critical Stop sound.
global MB_ICONQUESTION		:= 0x00000020 ;The sound specified as the Windows Question sound.
global MB_ICONWARNING		:= 0x00000030 ;The sound specified as the Windows Exclamation sound.
global MB_ICONINFORMATION	:= 0x00000040 ;The sound specified as the Windows Asterisk sound.

exit() {
	debug("ctrl_break")
	SoundPlay *%MB_ICONERROR%
	ExitApp 1
}

trade_inventory(fkey) {
	complex_mouse_op(fkey, 1297, 615, 53, 5, 12, true, "Ctrl")
	goto_trade()
}

confirm_inventory(fkey) {
	complex_mouse_op(fkey, 335, 231, 53, 5, 12)
	goto_accept()
}

trade_inventory_funny(fkey) {
	slot_dim := 53
	sx_base := 1297 ; source-x coordinate 0
	sy_base := 615  ; source-y coordinate 0
	tx_base := 337  ; target-x coordinate 0
	ty_base := 562  ; target-y coordinate 0
	t_seq :=[[5,2],[6,2],[6,3],[5,3],[4,3]
			,[4,2],[4,1],[5,1],[6,1],[7,1]
			,[7,2],[7,3],[7,4],[6,4],[5,4]
			,[4,4],[3,4],[3,3],[3,2],[3,1]
			,[3,0],[4,0],[5,0],[6,0],[7,0]
			,[8,0],[8,1],[8,2],[8,3],[8,4]
			,[2,4],[2,3],[2,2],[2,1],[2,0]
			,[9,0],[9,1],[9,2],[9,3],[9,4]
			,[1,4],[1,3],[1,2],[1,1],[1,0]
			,[10,0],[10,1],[10,2],[10,3],[10,4]
			,[0,4],[0,3],[0,2],[0,1],[0,0]
		,	[11,0],[11,1],[11,2],[11,3],[11,4]]
	debug(t_seq[1][1] . t_seq[1][2])
	debug(t_seq[2][1] . t_seq[2][2])
	sx := sx_base
	sy := sy_base
	MouseGetPos, x_old, y_old
	Sleep, 10
	i := 1
	while (GetKeyState(fkey, "P")) {
		tx := tx_base + slot_dim * t_seq[i][1]
		ty := ty_base + slot_dim * t_seq[i][2]
		if (sy >= sy_base + 5 * slot_dim) { ;have we been over all 5 rows?
			sx += slot_dim  ;next column
			if (sx >= sx_base + 12 * slot_dim)
				break
			sy := sy_base    ;reset to top row
		}
		MouseMove, %sx%, %sy%
		Sleep, 40
		Click, Down
		Sleep, 20
		Click, Up
		Sleep, 20
		MouseMove, %tx%, %ty%
		Sleep, 40
		Click, Down
		Sleep, 20
		Click, Up
		Sleep, 20
		sy += slot_dim
		i++
	}
	Sleep, 100
	;MouseMove, x_old, y_old
	goto_trade()
	Sleep, 1000
	Return
}

;;;;;;;;;;;;;;;
;;; HELPERS ;;;
;;;;;;;;;;;;;;;

goto_trade() {
	MouseMove, 337, 240
}

goto_accept() {
	MouseMove, 380, 835
}

debug(string:="", eol:="`n") {
	FileAppend % string eol, *
}

repeater(fkey, keys_down, cmd, keys_up, delay:=30) {
	SendInput %keys_down%
	Sleep 100 ; key down takes some time
	debug("While " . fkey . " pressed:")
    While GetKeyState(fkey, "P") {
        SendInput %cmd%
        Sleep %delay% ;  milliseconds
    }
	SendInput %keys_up%
}

complex_mouse_op(fkey, x_base, y_base, slot_dim, rows, cols, click := false, mouse_modifier := "") {
	local x := x_base
	local y := y_base
	local did_anything := false
	;SendInput, {Ctrl down}
	if (mouse_modifier != "") {
		SendInput, {%mouse_modifier% down}
	}
	MouseGetPos, x_old, y_old
	Sleep, 10
	while (GetKeyState(fkey, "P")) {
		did_anything := true
		if (y >= y_base + rows * slot_dim) { ;have we been over all `rows` rows?
			x += slot_dim  ;next column
			if (x >= x_base + cols * slot_dim)
				break
			y := y_base    ;reset to top row
			MouseMove, %x%, %y%
			Sleep, 50
		}
		MouseMove, %x%, %y%
		Sleep, 30
		if (click) {
			Click, %x%, %y%
		}
		Sleep, 10
		if (click) {
			Click, %x%, %y%
		}
		Sleep, 10
		;Click, %x%, %y%
		;Sleep, 10
		y += slot_dim
	}
	Sleep, 100
	if (mouse_modifier != "") {
		SendInput, {%mouse_modifier% up}
	}
	Sleep, 10
	Return did_anything
}

ChatCmdEach(cmd, args*) {
	local fast := false
	if (args[1] = true) {			; emulate optional "fast true/false" argument in face of variadic args* -- can't be done otherwise
		fast := args.RemoveAt(1)	; remember the "fast:=true" case
;		debug("ChatCmdEach: fast = true")
	} else if (args[1] = false) {
		args.RemoveAt(1)            ; just discard if "fast:=false" was explicitly passed
;		debug("ChatCmdEach: fast = false")
;	} else {
;		debug("ChatCmdEach: fast unset")
	}
	local string = ""
	for i, arg in args {
		debug("ChatCmdEach[" . (fast ? "fast" : "slow") . "][" . cmd . "][" . i . "]: " . arg)
		string .= cmd
		string .= " "
		string .= arg
		if (i < args.MaxIndex()) {
			string .= "{Enter}{Enter}"
		}
	}
	ChatCmd(string, fast)
}

ExploreObj(Obj, NewRow="`n", Equal="  =  ", Indent="`t", Depth=12, CurIndent="") { 

    for k,v in Obj 

        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow 

    return RTrim(ToReturn, NewRow) 

}

ChatCmd(cmd, fast:=false) {
	ForegroundSend("{Enter}^a^x" . cmd . "{Enter}{Enter}^v{Esc}", fast)
}

ChatCmdLast(cmd, fast:=false) {
	ForegroundSend("^{Enter}^a^c{Home}{Del}" . cmd . " {Enter}{Enter}^v{Esc}", fast)
}

ChatLast(msg, fast:=false) {
	ForegroundSend("^{Enter}" . msg . "{Enter}", fast)
}

; Except the "trivial" commands `oos` and `remaining`, all commands by default sleep for this many
; milliseconds after sending the chat command in order to prevent accidental spam when holding the key.
global ChatCmdDelay := 1000

ForegroundSend(string, fast:=false) {
	debug("SendInput[" . (fast ? "fast" : "slow") . "]: " . string)
	SendInput %string%
	if (!fast) {
		Sleep %ChatCmdDelay% ; prevent accidental spam
	}
}

;;;;;;;;;;;;;;
;;; UNUSED ;;;
;;;;;;;;;;;;;;

BackgroundSend(string, force:=false) {
	If force or !stop_requested {
		ControlSend ,, %string%, ahk_id %handle%
	}
}

ClearUI() {
	SendInput "{Esc}"
	Sleep 10
	SendInput "{Space}"
}

PixelWaitColor(x, y, exp_color, max_wait) {
	return PixelWaitColor2(x, y, exp_color, exp_color, max_wait)
}

PixelWaitColor2(x, y, exp_color1, exp_color2, max_wait) {
	Loop % max_wait/10 {
		PixelGetColor color, %x%, %y%
		if (color = exp_color1)
			return true
		if (color = exp_color2)
			return true
		Sleep 10
	}
	if (exp_color1 == exp_color2)
		MsgBox, , Pixel color error, Couldn't find color %exp_color1% at (%x%, %y%) after %max_wait% ms,, found color %color%
	else
		MsgBox, , Pixel color error, Couldn't find color %exp_color1% or %exp_color2% at (%x%, %y%) after %max_wait% ms,, found color %color%
	return false
}

;;;;;;;;;;;;;;;;;;;;;;;
;;; Private Scripts ;;;
;;;;;;;;;;;;;;;;;;;;;;;

;If you have any ad-hoc scripts you'd like to include, add them to the below file with an `#Include include/<filename>` statement

#Include *i include/_includes.ahk
