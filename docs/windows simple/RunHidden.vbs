If WScript.Arguments.Count > 0 Then
    Set objShell = CreateObject("WScript.Shell")
    scriptPath = Replace(WScript.ScriptFullName, WScript.ScriptName, "") & "CopyWithRAW.ps1"
    
    ' Build the command to run PowerShell completely hidden
    command = "powershell.exe -STA -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & scriptPath & """ -FilePath """ & WScript.Arguments(0) & """"
    
    For i = 1 To WScript.Arguments.Count - 1
        arg = WScript.Arguments(i)
        If Left(arg, 8) = "DEFAULT:" Then
            command = command & " -DefaultPickerFolder """ & Mid(arg, 9) & """"
        ElseIf arg = "AutoSubfolder" Then
            command = command & " -AutoSubfolder"
        ElseIf arg = "SkipSubfolderPrompt" Then
            command = command & " -SkipSubfolderPrompt"
        ElseIf arg = "OpenDestination" Then
            command = command & " -OpenDestination"
        Else
            command = command & " -FixedDestination """ & arg & """"
        End If
    Next
    
    objShell.Run command, 0, False
End If
