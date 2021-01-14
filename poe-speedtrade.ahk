; poe-speedtrate.ahk, MIT license, original author: Irfy [https://github.com/Irfy/poe-speedtrade]

#SingleInstance Force

SendMode, Input
SetKeyDelay 150,100
;SetDefaultMouseSpeed 5
SetDefaultMouseSpeed, 0
SetMouseDelay, -1

; These change every league!
global primary  := "YourIGNHere"  ; character name on primary account
global secondary := "" ; character name on secondary account, if any

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

^!Enter::ChatCmdLast("/whois")	; Alt-Shift-Enter to show info on the last whispered person (like the original PoE-TradeMacro)
^F1::ChatCmd("/destroy")		; Destroy the item picked up by the cursor, useful when cleaning up an area to prevent crashes.

;F2::ChatCmd("/oos", "/remaining", hideout_cmd(primary)) ; original hybrid hotkey: while mapping, re-sync and show remaining monsters, otherwise back to primary's hideout
F2::hideout(primary)			; Since most people play in Lockstep networking mode and maps show remaining monsters in the upper right corner, just go to primary's hideout
;^F2::kick(primary)				; used to leave party as this char or kick this char (but recommend using F5 and ^F5)

;F3::hideout(secondary)			; enable if using two accounts
;F3::ChatCmd("/destroy")		; otherwise used for arbitrary things
;^F3::kick(secondary)			; used to leave party as this char or kick this char (see also F5 and ^F5)

F4::wait_invite()				; inform the last person that you need a minute and then invite them
^F4::ChatCmdLast("/kick", "{Sleep 200}", "/invite") ; invite the last person that whispered us, or kick-invite last invited-person to fix transient party bug
+F4::ChatCmdLast("/tradewith")	; trade the last person that whispered us

F5::ChatRaw(ChatLast_str("t4t"), ChatCmd_str(kick_self_cmd(), hideout_cmd(), invite_self_cmd()))
	; thank last person, leave/break-up party, start personal hideout transfer, re-create private party -- this is the typical use-case after trade
^F5::kick(secondary, primary)	; leave/break-up party
;+F5::invite(primary, secondary)	; re-create private party, meaningful only when actively playing with a secondary account too
+F5::ChatCmd(kick_self_cmd(), hideout_cmd(), invite_self_cmd())	; like F5, but without the t4t

F6::repeater("{Ctrl Down}", "{Click}", "{Ctrl Up}")		; repeated ctrl-click to move inventory items to stash, or from stash stacks to inventory
+F6::repeater("", "^+{Click}", "", 150)					; *BUGGY* repeated shift-ctrl-click to buy portal scrolls in chunks of 40, instead of individually with ctrl-click
F7::repeater("{Shift Down}", "{Click}", "{Shift Up}")	; repeated shift-click after manually right-clicking on a quality orb to repeatedly quality an item/gem

F9::trade_inventory()			; while key pressed, ctrl-click slots in inventory in the natural order (column-by-column, downwards), finally, move mouse to first item in trade window
;F9::trade_inventory_funny()	; like F9 but funny, try it out with a lot of items (e.g. wisdom scrolls) in your inventory when trading someone WARNING: cannot have F9 with ^F9 or +F9 unfortunately, has to be a separate key
F10::confirm_trade()			; while key pressed, confirm other player's trade window by moving mouse over each slot, finally, move mouse to Accept button (but don't click)

F11::click_stash_quad("Shift")	; quad and normal stash tab item rolling: while pressed, shift-right-click each item in the stash tab in natural order.
F12::click_stash("Shift")		; use by right-clicking e.g. on a chaos orb and then hold F11/F12 to apply it to each item in the tab, exactly once, while pressed.
								; well-suited for rolling maps and horizoning maps to a desired natural map like Burial Chambers.

^F11::click_stash_quad("Ctrl")	; quad and...
^F12::click_stash("Ctrl")		; normal stash tab item ctrl-clicking (moving to inventory), while pressed, in natural order

;F12::ChatLast("Thank you. Thank you soooooooo much. Thank you so sooo sooooooooooooooooooooo much. May you have many children, and may RNG always be on your side. Like always. And like really many. Like 40. May your offspring and your RNG both make you happy. Like amazingly happy for the rest of your life. I wish you soooooo much luck and best of stuff, like you wouldn't be able to imagine. Seriously.{Enter}{Enter}Did I tell you how grateful I am to you right now? Give me a second to elaborate in detail:")		; this is just for messing with people by sending them ridiculously long thank-you messages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Some experimental/disabled stuff here ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#MaxThreadsPerHotkey 2	; affect only following hotkeys (enables the experimental toggle feature) -- move up when/if F6-F11 are switched to toggle mode
;F12::test_toggle_approach("F12")

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

hideout_cmd(char_name:="") {
	return "/hideout " . char_name ; empty char_name is okay
}
hideout(char_name:="") {
	ChatCmd(hideout_cmd(char_name))
}

kick_cmd(char_names*) {
	return ChatCmdEach_str("/kick", char_names*)
}

kick(char_names*) {
	ChatCmd(kick_cmd(char_names*))
}

kick_self_cmd() {
	if (secondary == "") {
		return kick_cmd(primary)
	}
	return kick_cmd(primary, secondary)
}

invite_cmd(char_names*) {
	return ChatCmdEach_str("/invite", char_names*)
}

invite(char_names*) {
	ChatCmd(invite_cmd(char_names*))
}

invite_self_cmd() {
	if (secondary == "") {
		return null
	}
	return invite_cmd(primary, secondary)
}

wait_invite(msg := "Can you give me a minute?") {
	ChatLast(msg)
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

click_stash_quad(modifier:="") {
	click_stash(modifier, 2)
}

click_stash(modifier:="", scale:=1) {
	complex_mouse_op(30, 140, 53/scale, 12*scale, 12*scale, true, modifier, true)
}

trade_inventory() {
	complex_mouse_op(1297, 615, 53, 5, 12, true, "Ctrl")
	goto_trade()
}

confirm_trade() {
	complex_mouse_op(335, 231, 53, 5, 12)
	goto_accept()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CHAT & COMMAND HELPERS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

debug(string:="", eol:="`n") {
	FileAppend % string eol, *
}

ChatCmdEach_str(cmd, args*) {
	local multi_cmd = ""
	local skip_separator = false
	for i, arg in args {
		if (InStr(arg, "{") == 1) {
			if (i == 1 or i == args.MaxIndex()) {
				MsgBox, , ChatCmdEach error, Can't pass a command as first or last argument, has to be in-between other commands/texts
				return
			}
			multi_cmd .= "{Enter}" . arg . "{Enter}"
			skip_separator := true
		} else {
			if (i > 1 and not skip_separator) {
				multi_cmd .= "{Enter}{Enter}"
			}
			skip_separator := false
			multi_cmd .= cmd . " " . arg
		}
		;debug("ChatCmdEach[" . cmd . "][" . i . "][" . arg . "]: " . multi_cmd)
	}
	return multi_cmd
}

ChatCmdEach(cmd, args*) {
	ChatCmd(ChatCmdEach_str(cmd, args*))
}

ChatCmd_str_custom(separator_end, separator_start, cmds*) {
	local multi_cmd = ""
	local skip_separator = false
	for i, cmd in cmds {
		if (cmd == "") {
			; debug("ChatCmd[" . concat(cmds*) . "] got empty cmd at index " . i)
			; MsgBox, , ChatCmd error, ChatCmd got empty cmd at index %i%
			; return
			continue
		}
		if (InStr(cmd, "{") == 1) {
			if (i == 1 or i == cmds.MaxIndex()) {
				MsgBox, , ChatCmd error, Can't pass a command as first or last argument, has to be in-between other commands/texts
				return
			}
			multi_cmd .= separator_end . cmd . separator_start
			skip_separator := true
		} else {
			if (i > 1 and not skip_separator) {
				multi_cmd .= separator_end . separator_start
			}
			skip_separator := false
			multi_cmd .= cmd
		}
		;debug("ChatCmd[" . i . "][" . cmd . "]: " . multi_cmd)
	}
	return multi_cmd
}

ChatCmd_str(cmds*) {
	return "{Enter}^a^x" . ChatCmd_str_custom("{Enter}", "{Enter}", cmds*) . "{Enter}{Enter}^v{Esc}"
}

ChatCmd(cmds*) {
	ForegroundSend(ChatCmd_str(cmds*))
}

ChatCmdLast_str(cmds*) {
	return "^{Enter}^a^c{Home}{Right}{Backspace}" . ChatCmd_str_custom(" {Enter}", "^{Enter}{Home}{Right}{Backspace}", cmds*) . " {Enter}{Enter}^v{Esc}"
}

ChatCmdLast(cmds*) {
	ForegroundSend(ChatCmdLast_str(cmds*))
}

ChatLast_str(msgs*) {
	return "^{Enter}" . ChatCmd_str_custom("{Enter}", "{Enter}", msgs*) . "{Enter}"
}

ChatLast(msgs*) {
	ForegroundSend(ChatLast_str(msgs*))
}

ChatRaw(strings*) {
	ForegroundSend(concat(strings*))
}

ForegroundSend(string) {
	debug("SendInput: " . string)
	SendInput %string%
	Sleep, 2000 ; prevent accidental spam
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TRADE & MOUSE HELPERS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

concat(strs*) {
	local multi_str = ""
	for i, str in strs {
		multi_str .= str
	}
	return multi_str
}

goto_trade() {
	MouseMove, 337, 240
}

goto_accept() {
	MouseMove, 380, 835
}

this_hotkey_stripped() {
	return RegExReplace(A_ThisHotkey, "[#!^+&<>*~$]")
}

repeater(keys_down, cmd, keys_up, delay:=30) {
	SendInput %keys_down%
	Sleep 100 ; key down takes some time
	debug("While " . A_ThisHotkey . " pressed:")
    While GetKeyState(this_hotkey_stripped(), "P") {
        SendInput %cmd%
        Sleep %delay% ;  milliseconds
    }
	SendInput %keys_up%
}

complex_mouse_op(x_base, y_base, slot_dim, rows, cols, click := false, mouse_modifier := "", return_mouse := false) {
	local x := x_base
	local y := y_base
	local did_anything := false
	;SendInput, {Ctrl down}
	if (mouse_modifier != "") {
		SendInput, {%mouse_modifier% down}
	}
	MouseGetPos, x_old, y_old
	Sleep, 10
	while (GetKeyState(this_hotkey_stripped(), "P")) {
		did_anything := true
		if (y >= y_base + rows * slot_dim) { ;have we been over all `rows` rows?
			x += slot_dim  ;next column
			if (x >= x_base + cols * slot_dim) {
				;debug("Finished last column, break out of loop")
				;break
			}
			;debug("Finished last row, next column")
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
	;if (GetKeyState(this_hotkey_stripped(), "P")) {
	;	debug(A_ThisHotkey . " is still pressed after loop finished")
	;} else {
	;	debug(A_ThisHotkey . " is not pressed after loop finished")
	;}
	Sleep, 100
	if (mouse_modifier != "") {
		SendInput, {%mouse_modifier% up}
	}
	Sleep, 10
	if (return_mouse) {
		MouseMove, x_old, y_old
	}
	Return did_anything
}

trade_inventory_funny() {
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
	while (GetKeyState(this_hotkey_stripped(), "P")) {
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

ExploreObj(Obj, NewRow="`n", Equal="  =  ", Indent="`t", Depth=12, CurIndent="") {
    for k,v in Obj
        ToReturn .= CurIndent . k . (IsObject(v) && depth>1 ? NewRow . ExploreObj(v, NewRow, Equal, Indent, Depth-1, CurIndent . Indent) : Equal . v) . NewRow
    return RTrim(ToReturn, NewRow)
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
