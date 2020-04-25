start_vi_normal_mode(){
  global vi_normal_mode
  vi_normal_mode["repeat_count"] := 0
  vi_normal_mode["mode"] := ""
  vi_normal_mode["last_chars"] := ""
}

end_vi_normal_mode(){

}


KMD_ViperDoRepeat(tosend)
{

  global vi_normal_mode
    c := vi_normal_mode["repeat_count"]
    if (c == 0)
      c := 1

    ;; guard:
    ;; should use confirmation instead
    if (c > 2000)
      c := 2000
    
    Loop %c%
    {
        S := S . tosend
    }
    KMD_Send(S)
    vi_normal_mode["repeat_count"] := 0
}

vi_slow_goto_line(nr)
{
  ; goto line
    ; this implementation of G can be optimized. Most editiors support "goto line"
    vi_normal_mode["repeat_count"] := vi_normal_mode["repeat_count"] -1
    KMD_Send("^{Home}")
    KMD_ViperDoRepeat("{Down}")
}


vi_normal_mode_handle_keys(key)
{
  ; MsgBox, %key%
  global

  WinGet, win_id, ID, A

  if (key == "/" || key == "?")
  {
    KMD_Send("^f")
    return
  }


  if (vi_normal_mode["last_chars"] == "g")
  {
    ;; gg gT gt
    if (key == "g")
    {
      KMD_ViperDoRepeat("^{Home}")
    } else if (key == "t")
    {
      KMD_ViperDoRepeat("^{Tab}")
    } else if (key == "+t")
    {
      KMD_ViperDoRepeat("^+{Tab}")
    }
    vi_normal_mode["last_chars"] :=  ""
    return
  }

  if (key == "+g")
  {
    if (vi_normal_mode["repeat_count"] == 0){
       KMD_Send("^{End}")
    } else 
    {
      api["goto_line"](vi_normal_mode["repeat_count"])
      vi_normal_mode["repeat_count"] := 0
    }
    return
  }

  if (key == "g")
  {
      vi_normal_mode["last_chars"] := vi_normal_mode["last_chars"] . key
    return
  }
  if (key == "^d") {
      KMD_Send("{PgDn}")
      return
  }
  if (key="^u")
  {
      KMD_Send("{PgUp}")
      return
  }
  
  if (key == "z")
  {
    c := vi_normal_mode["repeat_count"] ** 2
    if c > 100
      c := 100
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Up}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Down}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Down}")
    vi_normal_mode["repeat_count"] := c
    KMD_ViperDoRepeat("{Up}")
    return
  }

  if (key == "0" && vi_normal_mode["repeat_count"] == 0)
  {
    KMD_Send("{Home}")
    return
  }
  if (key == 0 || key == 1 || key == 2 || key == 3 || key == 4 || key == 5 || key == 6 || key == 7 || key == 8 || key == 9)
  {
    vi_normal_mode["repeat_count"] := vi_normal_mode["repeat_count"] * 10 + key
    return
  }

  if (vi_normal_mode["last_chars"] == "d"){
    if (key == "d"){
      KMD_Send("{Home}+{Down}")
    }
    else if (key == "j"){
      KMD_Send("{Home}+{Down}")
      KMD_ViperDoRepeat("+{Down}")
    }
    else if (key == "k"){
      KMD_Send("{Home}{Down}+{Up}")
      KMD_ViperDoRepeat("+{Up}")
    }
    KMD_Send("{Del}")
    vi_normal_mode["last_chars"] := ""
    return
  }
  if (key == "d"){
    vi_normal_mode["last_chars"] := "d"
    return
  }

  if (key == "v"){
    KMD_Send("{Shift Down}")
    return
  }


  if (vi_normal_mode["simple_commands"].HasKey(key)) 
  {
    KMD_ViperDoRepeat(vi_normal_mode["simple_commands"][key])
    return
  }
  if (vi_normal_mode["goto_insert_mode"].HasKey(key))
  {
    KMD_ViperDoRepeat(vi_normal_mode["goto_insert_mode"][key])
    KMD_SetMode("vi_insert_mode")
    return
  }

  ; drop repeat count
  vi_normal_mode["repeat_count"] := 0
  vi_normal_mode["last_chars"] := ""
  KMD_Send(key)
}


vi_normal_mode := {}
vi_normal_mode["start"] := "start_vi_normal_mode"
vi_normal_mode["end"] := "end_vi_normal_mode"
vi_normal_mode["shortcut"] := "v"
vi_normal_mode["repeat_count"] := 0
vi_normal_mode["handle_keys"] := "vi_normal_mode_handle_keys"

vi_normal_mode["simple_commands"] := {}
vi_normal_mode["simple_commands"]["h"] := "{Left}"
vi_normal_mode["simple_commands"]["j"] := "{Down}"
vi_normal_mode["simple_commands"]["k"] := "{Up}"
vi_normal_mode["simple_commands"]["l"] := "{Right}"

vi_normal_mode["simple_commands"]["w"] := "^{Right}"
vi_normal_mode["simple_commands"]["e"] := "^{Right}{Left}"
vi_normal_mode["simple_commands"]["b"] := "^{Left}"

vi_normal_mode["simple_commands"]["x"] := "{Del}"
vi_normal_mode["simple_commands"]["+x"] := "{BS}"
vi_normal_mode["simple_commands"]["+d"] := "+{END}{Del}"

vi_normal_mode["simple_commands"]["$"]  := "{END}"
; vi_normal_mode["simple_commands"]["^u"] := "{PgUp}"
; vi_normal_mode["simple_commands"]["^d"] := "{PgDn}"
vi_normal_mode["simple_commands"]["u"]  := "^z"
vi_normal_mode["simple_commands"]["{Enter}"]  := "{Home}{Down}"
vi_normal_mode["simple_commands"]["-"]  := "{Home}{Up}"

vi_normal_mode["goto_insert_mode"] := {}
vi_normal_mode["goto_insert_mode"]["o"] := "{End}{Enter}"
vi_normal_mode["goto_insert_mode"]["+o"] := "{Up}{End}{Enter}"
vi_normal_mode["goto_insert_mode"]["i"] := ""
vi_normal_mode["goto_insert_mode"]["+i"] := "{Home}"
vi_normal_mode["goto_insert_mode"]["a"] := "{Right}"
vi_normal_mode["goto_insert_mode"]["+a"] := "{End}"
vi_normal_mode["goto_insert_mode"]["+c"] := "+{End}{Del}"

; vi_normal_mode["app_depending_commands"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"]["/"] := {}
; vi_normal_mode["app_depending_commands"]["CodeGear"]["?"] := {}

KMD_ViperRepeatCount := 0
