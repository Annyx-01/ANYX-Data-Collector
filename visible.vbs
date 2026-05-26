' USB Data Collector - Hidden Launcher
Set shell = CreateObject("WScript.Shell")

If WScript.Arguments.Count > 0 Then
    cmd = Chr(34) & WScript.Arguments(0) & Chr(34)
    shell.Run cmd, 0, False
End If